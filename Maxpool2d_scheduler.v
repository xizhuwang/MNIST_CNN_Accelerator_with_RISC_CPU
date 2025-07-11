module Maxpool2d_scheduler #(
    parameter   ADDR_BIT = 10
) (
    input                       clk,
    input                       rst_n,
    input                       start,
    input                       mode,
    output                      Maxpool2d_rst_n,
    output                      Maxpool2d_en,
    output  [ADDR_BIT - 1 : 0]  picture_mem_addr,
    output                      picture_mem_we,
    output                      done
);

    // define picture output dimension by mode (mode also means layer)
    // if mode == 0, then transform input dim 28x28 to output dim 24x24
    // if mode == 1, then transform input dim 12x12 to output dim 8x8
    wire        [ADDR_BIT - 1 : 0]  picture_in_dim;
    parameter   [ADDR_BIT - 1 : 0]  picture_in_dim_l0   = 24;
    parameter   [ADDR_BIT - 1 : 0]  picture_in_dim_l1   = 8;
    assign picture_in_dim = mode? picture_in_dim_l1 : picture_in_dim_l0;

    wire        [ADDR_BIT - 1 : 0]  picture_out_dim;
    parameter   [ADDR_BIT - 1 : 0]  picture_dim_l0   = 12;
    parameter   [ADDR_BIT - 1 : 0]  picture_dim_l1   = 4;

    assign picture_out_dim = mode? picture_dim_l1 : picture_dim_l0;

    
    // state
    localparam  [3 - 1 : 0] IDLE        = 0;
    localparam  [3 - 1 : 0] LOAD        = 1;
    localparam  [3 - 1 : 0] COMPUTE     = 2;
    localparam  [3 - 1 : 0] WAIT        = 3;
    localparam  [3 - 1 : 0] WRITE_BACK  = 4;
    localparam  [3 - 1 : 0] WRITE_BACK_WAIT  = 5;

    reg         [3 - 1 : 0] cur_state;
    reg         [3 - 1 : 0] next_state;

    // address
    reg  [ADDR_BIT - 1 : 0] picture_mem_addr_w;

    // control logic
    reg                     Maxpool2d_rst_n_w;
    reg                     Maxpool2d_en_w;
    reg                     picture_mem_we_w;
    reg                     done_w;

    //----------------------------------------------------------------
    //-----------------------PICTURE POINTER--------------------------
    //----------------------------------------------------------------
    // picture address counter
    // x base address
    reg         [ADDR_BIT - 1 : 0]  picture_mem_x_base_addr_r;
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            picture_mem_x_base_addr_r <= 0;
        end else if ((cur_state == WRITE_BACK_WAIT && (picture_mem_x_base_addr_r != (picture_in_dim-2)))) begin
            picture_mem_x_base_addr_r <= picture_mem_x_base_addr_r + 2;
        end else if ((cur_state == WRITE_BACK_WAIT) && (picture_mem_x_base_addr_r == (picture_in_dim-2))) begin
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
        end else if ((cur_state == WRITE_BACK_WAIT) && (picture_mem_x_base_addr_r == (picture_in_dim-2))) begin
            picture_mem_y_base_addr_r <= picture_mem_y_base_addr_r + 2;
        end else begin
            picture_mem_y_base_addr_r <= picture_mem_y_base_addr_r;
        end
    end

    // relative x address
    reg         [ADDR_BIT - 1 : 0]  picture_mem_x_rela_addr_r;
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            picture_mem_x_rela_addr_r <= 0;
        end  else if ((cur_state == COMPUTE) && (picture_mem_x_rela_addr_r != 1)) begin
            picture_mem_x_rela_addr_r <= picture_mem_x_rela_addr_r + 1;
        end else if (((cur_state == COMPUTE) && (picture_mem_x_rela_addr_r == 1)) || (cur_state == WRITE_BACK_WAIT)) begin
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
        end else if ((cur_state == COMPUTE) && (picture_mem_x_rela_addr_r == 1) && (picture_mem_y_rela_addr_r != 1)) begin
            picture_mem_y_rela_addr_r <= picture_mem_y_rela_addr_r + 1;
        end else if (((cur_state == COMPUTE) && (picture_mem_y_rela_addr_r == 1) && (picture_mem_x_rela_addr_r == 1)) || (cur_state == WRITE_BACK_WAIT)) begin
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

    assign picture_mem_addr = picture_mem_addr_w;

    // connect output wire
    assign Maxpool2d_rst_n      = Maxpool2d_rst_n_w;
    assign Maxpool2d_en         = Maxpool2d_en_w;
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
                next_state = (picture_mem_x_rela_addr_r == 1) && (picture_mem_y_rela_addr_r == 1)? WAIT:LOAD;
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
                Maxpool2d_rst_n_w = start? 1'b0:1'b1;
                Maxpool2d_en_w    = 1'b0;
                picture_mem_we_w = 1'b0;
                done_w = 1'b0;

                picture_mem_addr_w = 0;
            end
            LOAD: begin
                Maxpool2d_rst_n_w = 1'b1;
                Maxpool2d_en_w    = 1'b0;
                picture_mem_we_w = 1'b0;
                done_w = 1'b0;

                picture_mem_addr_w = picture_mem_x_addr_w + picture_mem_y_addr_w * (picture_out_dim << 1);
            end
            COMPUTE: begin
                Maxpool2d_rst_n_w = 1'b1;
                Maxpool2d_en_w    = 1'b1;
                picture_mem_we_w = 1'b0;
                done_w = 1'b0;

                picture_mem_addr_w = picture_mem_x_addr_w + picture_mem_y_addr_w * (picture_out_dim << 1);
            end
            WAIT: begin
                Maxpool2d_rst_n_w = 1'b1;
                Maxpool2d_en_w    = 1'b0;
                picture_mem_we_w = 1'b0;
                done_w = 1'b0;

                picture_mem_addr_w = 0;
            end
            WRITE_BACK: begin
                Maxpool2d_rst_n_w = 1'b1;
                Maxpool2d_en_w    = 1'b0;
                picture_mem_we_w = 1'b0;
                done_w = 1'b0;

                picture_mem_addr_w = picture_mem_x_wr_addr_r + picture_mem_y_wr_addr_r * (picture_out_dim);
            end
            WRITE_BACK_WAIT: begin
                Maxpool2d_rst_n_w = 1'b0;
                Maxpool2d_en_w    = 1'b0;
                picture_mem_we_w = 1'b1;
                if ((picture_mem_x_wr_addr_r == (picture_out_dim - 1)) && (picture_mem_y_wr_addr_r == (picture_out_dim - 1)))
                    done_w = 1'b1;
                else 
                    done_w = 1'b0;

                picture_mem_addr_w = picture_mem_x_wr_addr_r + picture_mem_y_wr_addr_r * (picture_out_dim);
            end
            default: begin
                Maxpool2d_rst_n_w = 1'b0;
                Maxpool2d_en_w    = 1'b0;
                picture_mem_we_w = 1'b0;
                done_w = 1'b0;

                picture_mem_addr_w = 0;
            end
        endcase
    end


    
endmodule