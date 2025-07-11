module Comparator #(
    parameter   BIT = 8
) (
    input                               clk,
    input                               rst_n,
    input                               enable,
    input                               load,
    input   signed  [BIT - 1 : 0]       in,
    output          [ 4  - 1 : 0]       out_idx,
    output          [BIT - 1 : 0]       out
);

    wire    signed  [BIT - 1 : 0]       max_val;
    reg             [BIT - 1 : 0]       out_r1;
    reg     signed  [BIT - 1 : 0]       out_r;

    reg             [BIT - 1 : 0]       index_counter;
    reg             [BIT - 1 : 0]       index;
    
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            index_counter <= 0;
        end else if (enable) begin
            index_counter <= index_counter + 1;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            index <= 0;
        end else if (enable && (in > out_r)) begin
            index <= index_counter;
        end else begin
            index <= index;
        end
    end

    assign out_idx = index;

    assign max_val = (enable && (in > out_r))? in:out_r;

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            out_r <= 0;
        end else if (load) begin 
            out_r <= in;
        end else begin
            out_r <= max_val;
        end
    end

    always @(posedge clk) begin
        out_r1 <= out_r;
    end

    assign out = out_r1;
    
endmodule