module Predict_label_scheduler #(
    parameter   ADDR_BIT = 10
) (
    input                       clk,
    input                       rst_n,
    input                       start,
    output                      Comparator_rst_n,
    output                      Comparator_en,
    output                      Comparator_load,
    output  [ADDR_BIT - 1 : 0]  picture_mem_addr,
    output                      done
);
    
    // state
    localparam  [3 - 1 : 0] IDLE        = 0;
    localparam  [3 - 1 : 0] LOAD_INIT   = 1;
    localparam  [3 - 1 : 0] LOAD        = 2;
    localparam  [3 - 1 : 0] COMPUTE     = 3;
    localparam  [3 - 1 : 0] DONE        = 4;

    reg         [3 - 1 : 0] cur_state;
    reg         [3 - 1 : 0] next_state;

    reg                             Comparator_rst_n_w;
    reg                             Comparator_en_w;
    reg                             Comparator_load_w;
    reg         [ADDR_BIT - 1 : 0]  picture_mem_addr_w;
    reg                             done_w;

    // reg                         done_r;
    // assign done = done_r;
    // always @(posedge clk or negedge rst_n) begin
    //     if (~rst_n) begin
    //         done_r <= 0;
    //     end else begin
    //         done_r <= done_w;
    //     end
    // end

    //----------------------------------------------------------------
    //------------------------CONTROLLER------------------------------
    //----------------------------------------------------------------
    reg         [ADDR_BIT - 1 : 0]  address_r;
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            address_r <= 16;
        end else if ((cur_state == COMPUTE)) begin
            address_r <= address_r + 1;
        end
    end

    //----------------------------------------------------------------
    //------------------------CONTROLLER------------------------------
    //----------------------------------------------------------------

    assign Comparator_rst_n     = Comparator_rst_n_w;
    assign Comparator_en        = Comparator_en_w;
    assign Comparator_load      = Comparator_load_w;
    assign picture_mem_addr     = picture_mem_addr_w;
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
                next_state = start? LOAD_INIT:IDLE;
            end
            LOAD_INIT: begin
                next_state = LOAD;
            end
            LOAD: begin
                next_state = COMPUTE;
            end
            COMPUTE: begin
                next_state = (address_r == 26)? DONE:LOAD;
            end
            DONE: begin
                next_state = IDLE;
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
                Comparator_rst_n_w = start? 0:1;
                Comparator_en_w    = 0;
                Comparator_load_w  = 0;
                picture_mem_addr_w = address_r;
                done_w = 0;
            end
            LOAD_INIT: begin
                Comparator_rst_n_w = 1;
                Comparator_en_w    = 0;
                Comparator_load_w  = 1;
                picture_mem_addr_w = address_r;
                done_w = 0;
            end
            LOAD: begin
                Comparator_rst_n_w = 1;
                Comparator_en_w    = 0;
                Comparator_load_w  = 0;
                picture_mem_addr_w = address_r;
                done_w = 0;
            end
            COMPUTE: begin
                Comparator_rst_n_w = 1;
                Comparator_en_w    = (address_r == 26)? 0:1;
                Comparator_load_w  = 0;
                picture_mem_addr_w = address_r;
                done_w = 0;
            end
            DONE: begin
                Comparator_rst_n_w = 1;
                Comparator_en_w    = 0;
                Comparator_load_w  = 0;
                picture_mem_addr_w = 0;
                done_w = 1;
            end
            default: begin
                Comparator_rst_n_w = 1;
                Comparator_en_w    = 0;
                Comparator_load_w  = 0;
                picture_mem_addr_w = 0;
                done_w = 0;
            end
        endcase
    end
    
endmodule