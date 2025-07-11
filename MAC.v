module MAC #(
    parameter   BIT = 8
) (
    input                       clk,
    input                       rst_n,
    input                       accumulator_en,
    input   [      1 : 0]       normalizer_mode,
    input   [BIT - 1 : 0]       picture,
    input   [BIT - 1 : 0]       weight,
    output  [BIT - 1 : 0]       conv_result
);

    wire    [2*BIT - 1 : 0]     mult_result;
    wire    [BIT - 1 : 0]       norm_result;
    wire                        normalizer_out_valid;

    wire    [BIT - 1 : 0]       conv_result_w;
    reg     [BIT - 1 : 0]       conv_result_r;

    multiplier #(
        .BIT(BIT)
    ) U_multiplier (
        .in0        (weight),
        .in1        (picture),
        .out        (mult_result),
        .ZF         ()
    );

    normalizer #(
        .BIT(BIT)
    ) U_normalizer (
        .in         (mult_result),
        .sel        (normalizer_mode),
        .out        (norm_result),
        .out_valid  (normalizer_out_valid)
    );

    accumulator #(
        .BIT(BIT)
    ) U_accumulator (
        .clk        (clk),
        .rst_n      (rst_n),
        .enable     (accumulator_en&normalizer_out_valid),
        .in         (norm_result),
        .out        (conv_result_w)
    );

    always @(posedge clk) begin
        conv_result_r <= conv_result_w;
    end

    assign  conv_result = conv_result_r;
    
endmodule