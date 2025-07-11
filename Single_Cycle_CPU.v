`define LDM   5'b01100    //LDM
`define MNIST 5'b10111    //MNIST
`define OUT   5'b11100    //outR

module Single_Cycle_CPU
(
    clk,
    rst_n,
    Out_R,
    flag_done,
    ex_iwe,
    ex_iaddr,
    ex_idata,
    ex_dwe,
    ex_daddr,
    ex_ddata
);
//*****************************************************************************
    // I/O Ports Declaration
    input           clk;         // System clock
    input           rst_n;         // All reset
    output [16-1:0] Out_R;
    output          flag_done;

    input           ex_iwe;         //
    input  [3-1:0]  ex_iaddr;       //    3
    input  [16-1:0] ex_idata;       //    16
    input           ex_dwe;
    input  [7-1:0]  ex_daddr;      //    7
    input  [64-1:0] ex_ddata;      //    64

    // Global variables Declaration
    //wire            clk;
    wire            Hlt;

    // ProgramCounter    
    reg  [3-1:0 ]   PC;            // PC address out

    // Instr_Memory
    wire [16-1:0]   instr;         // Instruction data
    wire [16-1:0]   idata;
    wire [3-1:0]    iaddr;

    // Controller
    wire RegWrite;                 // Register Write
    wire OutR;
   
    // Data_Memory from controller
    wire [64 -1:0] data;            // Memory read data
    ////////////////////////////////////////////////////////////////WM.PM
    wire [7 -1:0]  WMaddr; 
    wire [64 -1:0] WMidata; 
    wire           WMwr; 
    wire           PMwr; 
    /////////////////////////// Data_Memory from sleep controller
    wire [7-1:0]   Mdaddr;
    wire [7-1:0]   daddr;

    wire AccDone;
    wire AccBusy;
    wire AccStart;
    wire [3:0]      predict_label;
    
    ///////////////////////////////////////////////////////////////////////////
    // input
    //assign clk = (flag_done) ? 1'b0 : clk_i;

    /////Register File    
    reg signed [ 16-1 : 0 ] RegisterFile;

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) RegisterFile <= 16'd0;              // Next PC value
        else RegisterFile <= (RegWrite)? {{12{1'b0}}, predict_label[3:0]} : RegisterFile; // Present PC value
    end
    //output 
    assign Out_R = (OutR) ? RegisterFile : {16{1'b0}} ;
    assign flag_done = Hlt & rst_n;
    
    //ProgramCounter
    wire   FreezePC;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) PC <= 0;
        else if (!FreezePC) PC <= PC + 1;
    end

    MUX_2to1 #(
        .DATA_WIDTH (3)
    ) u_Instruction_Memory_MUX_2to1(
        .s  (ex_iwe  ),
        .i0 (PC      ),
        .i1 (ex_iaddr ),
        .o  (iaddr  )
    );

    MUX_2to1 #(
        .DATA_WIDTH (16 )
    ) u_Instruction_Latch_MUX_2to1(
        .s  (ex_iwe ),
        .i0 (idata  ),
        .i1 (16'd1  ),
        .o  (instr  )
    );

    // Instruction Memory
    Memory u_Instruction_Memory(
    	.clk   (clk        ),
        .addr  (iaddr      ), // Present PC value
        .idata (ex_idata   ), // Instruction data
        .wr    (ex_iwe     ),
        .odata (idata      )
    );

    MUX_2to1 #(
        .DATA_WIDTH (7)
    ) u_Data_Memory_ADDR_MUX_2to1(
        .s  (ex_dwe  ),
        .i0 (Mdaddr ),
        .i1 (ex_daddr ),
        .o  (daddr  )
    );
    
////Data_Memory//////////////////////////////////////////////////////////////////////////////////////////////////
    ram_1p_128x64 #(
    ) u_Data_Memory_1p_128x64 (
        .clk    (clk        ),
        .rst_n  (rst_n      ),
        .we     (ex_dwe     ),
        .addr   (daddr      ),    //7
        .in     (ex_ddata  ),    //64
        .out    (data       )    //64
    );

////Data_Memory//////////////////////////////////////////////////////////////////////////////////////////////////
    Sleep_Mode_Controller u_Sleep_Mode_Controller(
        .rst_n(rst_n           ),
        .clk(clk               ),
        .DMaddr(Mdaddr         ),     //
        .DModata(data          ),     //DM 讀出資料
        .WMaddr(WMaddr         ),
        .WMidata(WMidata       ),
        .WMwr(WMwr             ),
        .PMwr(PMwr             ),
        .AccDone(AccDone       ),     //加速器完成訊號
        .AccBusy(AccBusy       ),
        .AccStart(AccStart     ),
        .FreezePC(FreezePC     ),     //關閉 PC
        .instr     (instr      ),
        .RegWrite  (RegWrite   ),
        .OutR      (OutR       ),    //output flag
        .Hlt       (Hlt        ) 
    );

    AI_ACCELERATOR #(
        .ADDR_BIT (10)
    ) u_AI_ACCELERATOR(
    .clk(clk ),
    .rst_n(rst_n ),
    .start(AccStart ),
    .picture_ext_we( PMwr ),
    .picture_ext_addr(WMaddr ),
    .picture_ext_data(data),
    .weight_ext_we(WMwr),
    .weight_ext_addr(WMaddr),
    .weight_ext_data(data),
    .predict_label(predict_label),
    .busy(AccBusy),
    .done(AccDone)
    );

endmodule