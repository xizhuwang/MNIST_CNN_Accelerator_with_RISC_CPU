module Relu_scheduler #(
    parameter   ADDR_BIT = 10
) (
    input                       clk,
    input                       rst_n,
    input                       start,
    input                       mode,
    output  [ADDR_BIT - 1 : 0]  picture_mem_addr,
    output                      picture_mem_we,
    output                      done
);

    // state
    localparam  [2 - 1 : 0] IDLE        = 0;
    localparam  [2 - 1 : 0] LOAD        = 1;
    localparam  [2 - 1 : 0] COMPUTE     = 2;
    localparam  [2 - 1 : 0] COMPUTE_WAIT = 3;
    
    wire        [ADDR_BIT - 1 : 0]  relu_depth;
    parameter   [ADDR_BIT - 1 : 0]  relu_depth_0   = 575;
    parameter   [ADDR_BIT - 1 : 0]  relu_depth_1   = 63;
    
    reg         [2 - 1 : 0] cur_state;
    reg         [2 - 1 : 0] next_state;

    reg         [ADDR_BIT - 1 : 0]  picture_mem_addr_w;
    reg                             picture_mem_we_w;
    reg                             done_w;

    assign relu_depth = mode? relu_depth_1:relu_depth_0;

    //----------------------------------------------------------------
    //------------------------CONTROLLER------------------------------
    //----------------------------------------------------------------
    reg         [ADDR_BIT - 1 : 0]  address_r;
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            address_r <= 0;
        end else if (cur_state == COMPUTE_WAIT) begin
            address_r <= address_r + 1;
        end
    end

    //----------------------------------------------------------------
    //------------------------CONTROLLER------------------------------
    //----------------------------------------------------------------

    assign picture_mem_addr     = picture_mem_addr_w;
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
                next_state = COMPUTE_WAIT;
            end
            COMPUTE_WAIT: begin
                next_state = (address_r == relu_depth)? IDLE:LOAD;
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
                picture_mem_addr_w = 0;
                picture_mem_we_w = 0;
                done_w = 0;
            end
            LOAD: begin
                picture_mem_addr_w = address_r;
                picture_mem_we_w = 0;
                done_w = 0;
            end
            COMPUTE: begin
                picture_mem_addr_w = address_r;
                picture_mem_we_w = 0;
                done_w = 0;
            end
            COMPUTE_WAIT: begin
                picture_mem_addr_w = address_r;
                picture_mem_we_w = 1;
                done_w = (address_r == relu_depth)? 1:0;
            end
            default: begin
                picture_mem_addr_w = 0;
                picture_mem_we_w = 0;
                done_w = 0;
            end
        endcase
    end
    
endmodule