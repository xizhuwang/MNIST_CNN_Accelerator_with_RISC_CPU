module accumulator #(
    parameter BIT = 8
) (
    input                           clk,
    input                           rst_n,
    input                           enable,
    input   signed  [BIT - 1 : 0]   in,
    output  signed  [BIT - 1 : 0]   out
);

    reg     signed  [BIT - 1 : 0]   out_r;

    assign out = out_r;

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            out_r <= 0;
        end else if (enable == 1) begin
            out_r <= out_r + in;
        end else begin
            out_r <= out_r;
        end
    end
    
endmodule