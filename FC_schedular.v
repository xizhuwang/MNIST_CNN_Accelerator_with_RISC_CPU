module FC_scheduler #(
    parameter   ADDR_BIT = 10
) (
    input                       clk,
    input                       rst_n,
    input                       start,
    output  [           1 : 0]  MAC_norm_mode,
    output                      MAC_rst_n,
    output                      MAC_en,
    output  [ADDR_BIT - 1 : 0]  picture_mem_addr,
    output                      picture_mem_we,
    output  [ADDR_BIT - 1 : 0]  weight_mem_addr,
    output                      done
);

        // state
    localparam  [3 - 1 : 0] IDLE        = 0;
    localparam  [3 - 1 : 0] LOAD        = 1;
    localparam  [3 - 1 : 0] COMPUTE     = 2;
    localparam  [3 - 1 : 0] WAIT        = 3;
    localparam  [3 - 1 : 0] WRITE_BACK  = 4;
    localparam  [3 - 1 : 0] WRITE_BACK_WAIT  = 5;

    reg         [3 - 1 : 0] cur_state;
    reg         [3 - 1 : 0] next_state;

    wire        [ADDR_BIT - 1 : 0]  weight_base_addr;
    parameter   [ADDR_BIT - 1 : 0]  weight_base_addr_l2   = 50;

    assign weight_base_addr = weight_base_addr_l2;

    //----------------------------------------------------------------
    //-----------------------WEIGHT POINTER---------------------------
    //----------------------------------------------------------------
    // weight base address
    reg         [ADDR_BIT - 1 : 0]  weight_base_addr_r;
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            weight_base_addr_r <= 0;
        end else if ((cur_state == IDLE)) begin
            weight_base_addr_r <= weight_base_addr;
        end else if ((cur_state == WRITE_BACK_WAIT)) begin
            weight_base_addr_r <= weight_base_addr_r + 16;
        end else begin
            weight_base_addr_r <= weight_base_addr_r;
        end
    end
    // weight relative address
    reg         [ADDR_BIT - 1 : 0]  weight_mem_rela_addr_r;
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            weight_mem_rela_addr_r <= 0;
        end else if ((cur_state == COMPUTE) && (weight_mem_rela_addr_r != 15)) begin
            weight_mem_rela_addr_r <= weight_mem_rela_addr_r + 1;
        end else if ((cur_state == COMPUTE) && (weight_mem_rela_addr_r == 15)) begin
            weight_mem_rela_addr_r <= 0;
        end
    end
    // weight address
    assign weight_mem_addr = weight_base_addr_r + weight_mem_rela_addr_r;

    //----------------------------------------------------------------
    //-----------------------PICTURE POINTER--------------------------
    //----------------------------------------------------------------
    // picture address counter
    // x base address
    reg         [ADDR_BIT - 1 : 0]  picture_mem_base_addr_r;
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            picture_mem_base_addr_r <= 0;
        end else if ((cur_state == COMPUTE) && (picture_mem_base_addr_r != 15)) begin
            picture_mem_base_addr_r <= picture_mem_base_addr_r + 1;
        end else if ((cur_state == COMPUTE) && picture_mem_base_addr_r == 15) begin
            picture_mem_base_addr_r <= 0;
        end else begin
            picture_mem_base_addr_r <= picture_mem_base_addr_r;
        end
    end
    //----------------------------------------------------------------
    //-----------------------PICTURE POINTER--------------------------
    //--------------------------FOR WRITE-----------------------------
    //----------------------------------------------------------------
    parameter   [ADDR_BIT - 1 : 0]  picture_mem_wr_base_addr = 16;

    reg         [ADDR_BIT - 1 : 0]  picture_mem_wr_addr_r;
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            picture_mem_wr_addr_r <= 0;
        end else if ((cur_state == IDLE)) begin
            picture_mem_wr_addr_r <= picture_mem_wr_base_addr;
        end else if ((cur_state == WRITE_BACK_WAIT)) begin
            picture_mem_wr_addr_r <= picture_mem_wr_addr_r + 1;
        end else begin
            picture_mem_wr_addr_r <= picture_mem_wr_addr_r;
        end
    end

    //----------------------------------------------------------------
    //------------------------CONTROLLER------------------------------
    //----------------------------------------------------------------

    // address
    reg  [ADDR_BIT - 1 : 0]  picture_mem_addr_w;
    assign picture_mem_addr = picture_mem_addr_w;

    // control logic
    reg         [    1 : 0] MAC_norm_mode_w;
    reg                     MAC_rst_n_w;
    reg                     MAC_en_w;
    reg                     picture_mem_we_w;
    reg                     done_w;

    // connect output wire
    assign MAC_norm_mode        = MAC_norm_mode_w;
    assign MAC_rst_n            = MAC_rst_n_w;
    assign MAC_en               = MAC_en_w;
    assign picture_mem_we       = picture_mem_we_w;
    assign done                 = done_w; 

    // state transition
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            cur_state <= IDLE;
        end else begin
            cur_state <= next_state;
        end
    end

    // next state logic
    always @(*) begin
        case (cur_state)
            IDLE: begin
                next_state = start? LOAD:IDLE;
            end
            LOAD: begin
                next_state = COMPUTE;
            end
            COMPUTE: begin
                next_state = (picture_mem_base_addr_r == 15)? WAIT:LOAD;
            end
            WAIT: begin
                next_state = WRITE_BACK;
            end
            WRITE_BACK: begin
                next_state = WRITE_BACK_WAIT;
            end
            WRITE_BACK_WAIT: begin
                if (weight_base_addr_r == (194))
                    next_state = IDLE;
                else 
                    next_state = LOAD;
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // output logic
    always @(*) begin
        case (cur_state)
            IDLE: begin
                MAC_norm_mode_w = 2'd0;
                MAC_rst_n_w = start? 1'b0:1'b1;
                MAC_en_w = 1'b0;
                picture_mem_we_w = 1'b0;
                done_w = 1'b0;

                picture_mem_addr_w = 0;
            end
            LOAD: begin
                MAC_norm_mode_w = 2'd2;
                MAC_rst_n_w = 1'b1;
                MAC_en_w = 1'b0;
                picture_mem_we_w = 1'b0;
                done_w = 1'b0;

                picture_mem_addr_w = picture_mem_base_addr_r;
            end
            COMPUTE: begin
                MAC_norm_mode_w = 2'd2;
                MAC_rst_n_w = 1'b1;
                MAC_en_w = 1'b1;
                picture_mem_we_w = 1'b0;
                done_w = 1'b0;

                picture_mem_addr_w = picture_mem_base_addr_r;
            end
            WAIT: begin
                MAC_norm_mode_w = 2'd0;
                MAC_rst_n_w = 1'b1;
                MAC_en_w = 1'b0;
                picture_mem_we_w = 1'b0;
                done_w = 1'b0;

                picture_mem_addr_w = 0;
            end
            WRITE_BACK: begin
                MAC_norm_mode_w = 2'd2;
                MAC_rst_n_w = 1'b1;
                MAC_en_w = 1'b0;
                picture_mem_we_w = 1'b0;
                done_w = 1'b0;

                picture_mem_addr_w = picture_mem_wr_addr_r;
            end
            WRITE_BACK_WAIT: begin
                MAC_norm_mode_w = 2'd2;
                MAC_rst_n_w = 1'b0;
                MAC_en_w = 1'b0;
                picture_mem_we_w = 1'b1;
                if (weight_base_addr_r == (194))
                    done_w = 1'b1;
                else 
                    done_w = 1'b0;

                picture_mem_addr_w = picture_mem_wr_addr_r;
            end
            default: begin
                MAC_norm_mode_w = 2'd2;
                MAC_rst_n_w = 1'b1;
                MAC_en_w = 1'b0;
                picture_mem_we_w = 1'b0;
                done_w = 1'b0;

                picture_mem_addr_w = 0;
            end
        endcase
    end
    
endmodule