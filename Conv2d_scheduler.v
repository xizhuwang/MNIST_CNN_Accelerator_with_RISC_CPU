module Conv2d_schedular #(
    parameter   ADDR_BIT = 10
) (
    input                       clk,
    input                       rst_n,
    input                       start,
    input                       mode,
    output  [           1 : 0]  MAC_norm_mode,
    output                      MAC_rst_n,
    output                      MAC_en,
    output  [ADDR_BIT - 1 : 0]  picture_mem_addr,
    output                      picture_mem_we,
    output  [ADDR_BIT - 1 : 0]  weight_mem_addr,
    // output                      weight_mem_we,
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
    // define picture output dimension by mode (mode also means layer)
    // if mode == 0, then transform input dim 28x28 to output dim 24x24
    // if mode == 1, then transform input dim 12x12 to output dim 8x8
    wire        [ADDR_BIT - 1 : 0]  picture_out_dim;
    parameter   [ADDR_BIT - 1 : 0]  picture_dim_l0   = 24;
    parameter   [ADDR_BIT - 1 : 0]  picture_dim_l1   = 8;

    assign picture_out_dim = mode? picture_dim_l1 : picture_dim_l0;

    // define weight base address by mode (mode also means layer)
    // if mode == 0, then weight base address is 0
    // if mode == 1, then weight base address is 25
    wire        [ADDR_BIT - 1 : 0]  weight_base_addr;
    parameter   [ADDR_BIT - 1 : 0]  weight_base_addr_l0   = 0;
    parameter   [ADDR_BIT - 1 : 0]  weight_base_addr_l1   = 25;

    assign weight_base_addr = mode? weight_base_addr_l1 : weight_base_addr_l0;

    //----------------------------------------------------------------
    //-----------------------Memory POINTER---------------------------
    //----------------------------------------------------------------

    //----------------------------------------------------------------
    //-----------------------WEIGHT POINTER---------------------------
    //----------------------------------------------------------------
    // weight relative address
    reg         [ADDR_BIT - 1 : 0]  weight_mem_rela_addr_r;
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            weight_mem_rela_addr_r <= 0;
        end else if (cur_state == COMPUTE) begin
            weight_mem_rela_addr_r <= weight_mem_rela_addr_r + 1;
        end else if (cur_state == LOAD)begin
            weight_mem_rela_addr_r <= weight_mem_rela_addr_r;
        end else begin
            weight_mem_rela_addr_r <= 0;
        end
    end
    // weight address
    assign weight_mem_addr = weight_base_addr + weight_mem_rela_addr_r;

    //----------------------------------------------------------------
    //-----------------------PICTURE POINTER--------------------------
    //----------------------------------------------------------------
    // picture address counter
    // x base address
    reg         [ADDR_BIT - 1 : 0]  picture_mem_x_base_addr_r;
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            picture_mem_x_base_addr_r <= 0;
        end else if ((cur_state == WRITE_BACK_WAIT)) begin
            picture_mem_x_base_addr_r <= picture_mem_x_base_addr_r + 1;
        end else if ((cur_state == LOAD) && (picture_mem_x_base_addr_r == picture_out_dim)) begin
            picture_mem_x_base_addr_r <= 0;
        end else begin
            picture_mem_x_base_addr_r <= picture_mem_x_base_addr_r;
        end
    end

    // y base address
    reg         [ADDR_BIT - 1 : 0]  picture_mem_y_base_addr_r;
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            picture_mem_y_base_addr_r <= 0;
        end else if ((cur_state == WRITE_BACK_WAIT) && (picture_mem_x_base_addr_r == (picture_out_dim-1))) begin
            picture_mem_y_base_addr_r <= picture_mem_y_base_addr_r + 1;
        end else begin
            picture_mem_y_base_addr_r <= picture_mem_y_base_addr_r;
        end
    end

    // relative x address
    reg         [ADDR_BIT - 1 : 0]  picture_mem_x_rela_addr_r;
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            picture_mem_x_rela_addr_r <= 0;
        end  else if ((cur_state == COMPUTE) && (picture_mem_x_rela_addr_r != 4)) begin
            picture_mem_x_rela_addr_r <= picture_mem_x_rela_addr_r + 1;
        end else if (((cur_state == COMPUTE) && (picture_mem_x_rela_addr_r == 4)) || (cur_state == WRITE_BACK_WAIT)) begin
            picture_mem_x_rela_addr_r <= 0;
        end else begin
            picture_mem_x_rela_addr_r <= picture_mem_x_rela_addr_r;
        end
    end

    // relative y address
    reg         [ADDR_BIT - 1 : 0]  picture_mem_y_rela_addr_r;
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            picture_mem_y_rela_addr_r <= 0;
        end else if ((cur_state == COMPUTE) && (picture_mem_x_rela_addr_r == 4) && (picture_mem_y_rela_addr_r != 4)) begin
            picture_mem_y_rela_addr_r <= picture_mem_y_rela_addr_r + 1;
        end else if (((cur_state == COMPUTE) && (picture_mem_y_rela_addr_r == 4) && (picture_mem_x_rela_addr_r == 4)) || (cur_state == WRITE_BACK_WAIT)) begin
            picture_mem_y_rela_addr_r <= 0;
        end else begin
            picture_mem_y_rela_addr_r <= picture_mem_y_rela_addr_r;
        end
    end

    // picture x address
    wire        [ADDR_BIT - 1 : 0]  picture_mem_x_addr_w;
    assign picture_mem_x_addr_w = picture_mem_x_base_addr_r + picture_mem_x_rela_addr_r;

    // picture y address
    wire        [ADDR_BIT - 1 : 0]  picture_mem_y_addr_w;
    assign picture_mem_y_addr_w = picture_mem_y_base_addr_r + picture_mem_y_rela_addr_r;

    //----------------------------------------------------------------
    //-----------------------PICTURE POINTER--------------------------
    //--------------------------FOR WRITE-----------------------------
    //----------------------------------------------------------------
    reg         [ADDR_BIT - 1 : 0]  picture_mem_x_wr_addr_r;
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            picture_mem_x_wr_addr_r <= 0;
        end else if ((cur_state == WRITE_BACK_WAIT) && (picture_mem_x_wr_addr_r != picture_out_dim)) begin
            picture_mem_x_wr_addr_r <= picture_mem_x_wr_addr_r + 1;
        end else if ((picture_mem_x_wr_addr_r == picture_out_dim)) begin
            picture_mem_x_wr_addr_r <= 0;
        end else begin
            picture_mem_x_wr_addr_r <= picture_mem_x_wr_addr_r;
        end
    end

    reg         [ADDR_BIT - 1 : 0]  picture_mem_y_wr_addr_r;
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            picture_mem_y_wr_addr_r <= 0;
        end else if ((picture_mem_x_wr_addr_r == picture_out_dim)) begin
            picture_mem_y_wr_addr_r <= picture_mem_y_wr_addr_r + 1;
        end else begin
            picture_mem_y_wr_addr_r <= picture_mem_y_wr_addr_r;
        end
    end

    //----------------------------------------------------------------
    //------------------------CONTROLLER------------------------------
    //----------------------------------------------------------------

    // address
    reg  [ADDR_BIT - 1 : 0] picture_mem_addr_w;

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
                // next_state = (picture_mem_x_rela_addr_r == 4) && (picture_mem_y_rela_addr_r == 4)? WAIT:COMPUTE;
            end
            COMPUTE: begin
                next_state = (picture_mem_x_rela_addr_r == 4) && (picture_mem_y_rela_addr_r == 4)? WAIT:LOAD;
                // next_state = LOAD;
            end
            WAIT: begin
                next_state = WRITE_BACK;
            end
            WRITE_BACK: begin
                next_state = WRITE_BACK_WAIT;
            end
            WRITE_BACK_WAIT: begin
                if ((picture_mem_x_wr_addr_r == (picture_out_dim - 1)) && (picture_mem_y_wr_addr_r == (picture_out_dim - 1)))
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
                MAC_norm_mode_w = 2'd0;
                MAC_rst_n_w = 1'b1;
                MAC_en_w = 1'b0;
                picture_mem_we_w = 1'b0;
                done_w = 1'b0;
                
                picture_mem_addr_w = picture_mem_x_addr_w + picture_mem_y_addr_w * (picture_out_dim + 4);
            end
            COMPUTE: begin
                if (~mode) begin
                    MAC_norm_mode_w = 2'd0;
                    MAC_rst_n_w = 1'b1;
                    MAC_en_w = 1'b1;
                    picture_mem_we_w = 1'b0;
                    done_w = 1'b0;
                end else begin
                    MAC_norm_mode_w = 2'd1;
                    MAC_rst_n_w = 1'b1;
                    MAC_en_w = 1'b1;
                    picture_mem_we_w = 1'b0;
                    done_w = 1'b0;
                end

                picture_mem_addr_w = picture_mem_x_addr_w + picture_mem_y_addr_w * (picture_out_dim + 4);
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
                MAC_norm_mode_w = 2'd0;
                MAC_rst_n_w = 1'b1;
                MAC_en_w = 1'b0;
                picture_mem_we_w = 1'b0;
                done_w = 1'b0;

                picture_mem_addr_w = picture_mem_x_wr_addr_r + picture_mem_y_wr_addr_r * (picture_out_dim);
            end
            WRITE_BACK_WAIT: begin
                MAC_norm_mode_w = 2'd0;
                MAC_rst_n_w = 1'b0;
                MAC_en_w = 1'b0;
                picture_mem_we_w = 1'b1;
                if ((picture_mem_x_wr_addr_r == (picture_out_dim - 1)) && (picture_mem_y_wr_addr_r == (picture_out_dim - 1)))
                    done_w = 1'b1;
                else 
                    done_w = 1'b0;

                picture_mem_addr_w = picture_mem_x_wr_addr_r + picture_mem_y_wr_addr_r * (picture_out_dim);
            end
            default: begin
                MAC_norm_mode_w = 2'd0;
                MAC_rst_n_w = 1'b1;
                MAC_en_w = 1'b0;
                picture_mem_we_w = 1'b0;
                done_w = 1'b0;

                picture_mem_addr_w = 0;
            end
        endcase
    end
    
endmodule