module multiplier #(
    parameter BIT = 8
) (
    input   signed  [BIT - 1 : 0]       in0,
    input   signed  [BIT - 1 : 0]       in1,
    output  signed  [2*BIT - 1 : 0]     out,
    output                              ZF
);

    assign out = {{BIT{in0[BIT - 1]}}, in0} * {{BIT{1'b0}}, in1};
    assign ZF = (in0 == 0) | (in0 == 1);
    
endmodule