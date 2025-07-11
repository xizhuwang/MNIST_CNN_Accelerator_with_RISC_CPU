module AI_ACCELERATOR #(
    parameter   DATA_BIT = 8,
    parameter   ADDR_BIT = 10
) (
    input                   clk,
    input                   rst_n,
    input                   start,
    input                   picture_ext_we,
    input  [ 7 - 1 : 0]     picture_ext_addr,   
    input  [64 - 1 : 0]     picture_ext_data,
    input                   weight_ext_we,
    input  [ 7 - 1 : 0]     weight_ext_addr,
    input  [64 - 1 : 0]     weight_ext_data,
    output [ 4 - 1 : 0]     predict_label,
    output                  busy,
    output                  done
);

    //----------------------------------------------------------------
    //--------------------------CONTROLLER----------------------------
    //----------------------------------------------------------------
    wire                        MAC_rst_n;
    wire                        MAC_en;
    wire    [           1 : 0]  MAC_norm_mode;
    wire                        Comparator_rst_n;    
    wire                        Comparator_en;
    wire                        Comparator_load;
    wire    [ADDR_BIT - 1 : 0]  weight_mem_addr;
    wire    [ADDR_BIT - 1 : 0]  picture_mem_addr;
    wire                        picture_mem_we;
    wire    [           1 : 0]  result_sel;

    wire memory_data_mode;
    
    AI_Controller #(
        .ADDR_BIT(ADDR_BIT)
    ) U_Controller (
        .clk                (clk             ),
        .rst_n              (rst_n           ),
        .start              (start           ),
        .memory_data_mode   (memory_data_mode),
        .MAC_rst_n          (MAC_rst_n       ),
        .MAC_en             (MAC_en          ),
        .MAC_norm_mode      (MAC_norm_mode   ),
        .Comparator_rst_n   (Comparator_rst_n),
        .Comparator_en      (Comparator_en   ),
        .Comparator_load    (Comparator_load ),
        .weight_mem_addr    (weight_mem_addr ),
        .picture_mem_addr   (picture_mem_addr),
        .picture_mem_we     (picture_mem_we  ),
        .result_sel         (result_sel      ),
        .busy               (busy            ),
        .done               (done            )
    );


    //----------------------------------------------------------------
    //--------------------------DATAPATH------------------------------
    //----------------------------------------------------------------
    wire    [DATA_BIT - 1 : 0]  picture;
    wire    [DATA_BIT - 1 : 0]  weight;
    
    wire    [DATA_BIT - 1 : 0]  MAC_result;
    wire    [DATA_BIT - 1 : 0]  relu_result;
    wire    [DATA_BIT - 1 : 0]  Comparator_result;

    reg     [DATA_BIT - 1 : 0]  picture_in;

    MAC #(
        .BIT(DATA_BIT)
    ) U_MAC (
        .clk            (clk),
        .rst_n          (MAC_rst_n&rst_n),
        .accumulator_en (MAC_en),
        .normalizer_mode(MAC_norm_mode),
        .picture        (picture),
        .weight         (weight),
        .conv_result    (MAC_result)
    );

    relu #(
        .BIT(DATA_BIT)
    ) U_relu (
        .in     (picture),
        .out    (relu_result)
    );

    Comparator #(
        .BIT(DATA_BIT)
    ) U_Comparator (
        .clk    (clk),
        .rst_n  (Comparator_rst_n&rst_n),
        .enable (Comparator_en),
        .load   (Comparator_load),
        .in     (picture),
        .out_idx(predict_label),
        .out    (Comparator_result)
    );

    ram #(
    ) picture_memory (
        .clk    (clk  ),
        .rst_n  (rst_n),
        .mode   (memory_data_mode),
        .we     (picture_mem_we|picture_ext_we),
        .ext_addr(picture_ext_addr),
        .ext_data(picture_ext_data),
        .addr   (picture_mem_addr),
        .in     (picture_in),
        .out    (picture)
    );

    ram #(
    ) weight_memory (
        .clk    (clk  ),
        .rst_n  (rst_n),
        .mode   (memory_data_mode),
        .we     (weight_ext_we),
        .ext_addr(weight_ext_addr),
        .ext_data(weight_ext_data),
        .addr   (weight_mem_addr),
        .in     (),
        .out    (weight)
    );

    always @(*) begin
        case (result_sel)
            2'd0: picture_in = MAC_result; 
            2'd1: picture_in = relu_result; 
            2'd2: picture_in = Comparator_result; 
            default: picture_in = 0;
        endcase
    end
    
endmodule