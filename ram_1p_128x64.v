
module ram_1p_128x64 #(
) (
    input                           clk,
    input                           rst_n,
    input                           we,
    input       [       7 - 1 : 0]  addr,
    input       [      64 - 1 : 0]  in,
    output      [      64 - 1 : 0]  out
);

    reg         [      64 - 1 : 0]  data    [0 : 128 - 1];
    reg         [      64 - 1 : 0]  out_r;

    assign out = out_r;

    always @(posedge clk) begin
        if (we == 1) begin
            data[addr] <= in;
        end
    end

    always @(posedge clk) begin
        out_r <= data[addr];
    end

endmodule