module relu #(
    parameter   BIT = 8
) (
    input       [BIT - 1 : 0]   in,
    output      [BIT - 1 : 0]   out
);

    assign out = {BIT{~in[BIT - 1]}} & in;
    
endmodule