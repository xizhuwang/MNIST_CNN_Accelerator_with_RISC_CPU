module normalizer #(
    parameter BIT = 8
) (
    input   signed  [2*BIT - 1 : 0]     in,
    input           [        1 : 0]     sel,
    output  signed  [  BIT - 1 : 0]     out,
    output                              out_valid
);
    reg     signed  [  BIT - 1 : 0]     out_w;

    reg     signed    [2*BIT - 1 : 0]   out0_w;
    reg     signed    [2*BIT - 1 : 0]   out1_w;
    reg     signed    [2*BIT - 1 : 0]   out2_w;
    reg                                 out_valid_w;

    assign out          = out_w;
    assign out_valid    = out_valid_w;

    always @(*) begin
        out0_w      = in >>> 10;
        out1_w      = in >>> 9;
        out2_w      = in >>> 8;

        case (sel)
            2'b00: begin
                out_w = out0_w[BIT - 1 : 0];
                out_valid_w = 1;
            end 
            2'b01: begin
                out_w = out1_w[BIT - 1 : 0];
                out_valid_w = 1;
            end 
            2'b10: begin
                out_w = out2_w[BIT - 1 : 0];
                out_valid_w = 1;
            end 
            2'b11: begin
                out_w = 0;
                out_valid_w = 0;
            end 
            default: begin
                out_w = 0;
                out_valid_w = 0;
            end
        endcase
    end
    
endmodule