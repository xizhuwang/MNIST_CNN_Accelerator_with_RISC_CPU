`timescale 10ns / 1ns

`define LDM   5'b01100    // LDM
`define MNIST 5'b10111    // MNIST
`define OUT   5'b11100    // OutR

module Sleep_Mode_Controller(
    input  wire          rst_n,
    input  wire          clk,
    output reg  [7 -1:0] DMaddr,      // 從DM讀出地址
    input  wire [64 -1:0]DModata,     // 從DM讀出資料
    output reg  [7 -1:0] WMaddr,      // 寫入地址
    output reg  [64 -1:0]WMidata,     // 寫入資料
    output reg           WMwr,        // WM_en  
    output reg           PMwr,        // PM_en
    
    input  wire          AccDone,      // 加速器完成訊號
    input  wire          AccBusy,      // 加速器運算
    output reg           AccStart,     // 加速器開始
    
    output               FreezePC,     // 關閉 PC
    input  wire [16-1:0] instr,        // Instruction
    output reg           RegWrite  ,   // RFwr MNIST會用到
    output reg           OutR      ,   //  output flag
    output reg           Hlt           //  stop
);
    //搬移筆數與偏移量
    localparam integer PM_COUNT_MAX    = 100;
    localparam integer WM_COUNT_MAX    = 128;

    //狀態機與計數器
    reg [1:0]  MemState;
    reg [7:0]  counter;
    reg [7:0]  counter1; 

    //FreezePC
    wire busy_ldm   = (instr[15:11]==`LDM)   && (MemState != 2'b10);
    wire busy_mnist = (instr[15:11]==`MNIST) && !AccDone;
    assign FreezePC = busy_ldm || busy_mnist;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            //重置所有輸出與狀態
            DMaddr    <= 7'd0;
            WMaddr    <= 7'd0;
            WMidata   <= 64'd0;
            WMwr      <= 1'b0;
            PMwr      <= 1'b0;
            AccStart  <= 1'b0;
            MemState  <= 2'b00;
            counter   <= 8'd0;
            counter1  <= 8'd0;

            RegWrite  <= 1'b0;   // RF MNIST會用到
            OutR      <= 1'b0;
            Hlt       <= 1'b0;
        end else begin
            case (instr[15:11])
                `LDM: begin
                    //進入記憶體搬移模式，凍結 PC
                    OutR      <= 1'b0;
                    Hlt       <= 1'b0;
                    RegWrite  <= 1'b0;
                    case (MemState)
                        2'b00: begin  //DM → PM
                            if (counter == 0) begin
                                DMaddr    <= 0;                       //讀 DM
                                WMaddr    <= 0;                      //寫 PM
                                WMidata   <= 0;
                                PMwr      <= 1'b0;
                                WMwr      <= 1'b0;
                                counter   <= counter + 1;
                            end else if (counter < PM_COUNT_MAX) begin
                                DMaddr    <= counter;                       //讀 DM
                                WMaddr    <= counter - 1;                      //寫 PM
                                WMidata   <= DModata;
                                PMwr      <= 1'b1;
                                WMwr      <= 1'b0;
                                counter   <= counter + 1;
                            end else begin
                                DMaddr    <= counter;                       //讀 DM
                                WMaddr    <= counter - 1;                      //寫 PM
                                WMidata   <= DModata;
                                PMwr      <= 1'b1;
                                WMwr      <= 1'b0;
                                counter   <= counter;
                                MemState  <= 2'b01;
                            end
                        end
                        2'b01: begin  //DM → WM
                            if (counter == PM_COUNT_MAX) begin
                                DMaddr    <= counter;                       //讀 DM
                                WMaddr    <= (counter - PM_COUNT_MAX);      //寫 WM
                                WMidata   <= DModata;
                                WMwr      <= 1'b0;
                                PMwr      <= 1'b0;
                                counter   <= counter + 1;
                            end else if (counter < WM_COUNT_MAX) begin
                                DMaddr    <= counter;                       //讀 DM
                                WMaddr    <= (counter - PM_COUNT_MAX - 1);      //寫 WM
                                WMidata   <= DModata;
                                WMwr      <= 1'b1;
                                PMwr      <= 1'b0;
                                counter   <= counter + 1;
                            end else if (counter == WM_COUNT_MAX) begin
                                DMaddr    <= counter;                       //讀 DM
                                WMaddr    <= (counter - PM_COUNT_MAX - 1);      //寫 WM
                                WMidata   <= DModata;
                                WMwr      <= 1'b0;
                                PMwr      <= 1'b0;
                                counter   <= counter + 1;
                            end else begin
                                counter   <= 8'd0;
                                MemState  <= 2'b10;
                            end
                        end
                        2'b10: begin
                            //搬移結束復原PC，回到初始狀態
                            MemState   <= 2'b00;
                            counter    <= 8'd0;
                            counter1   <= 8'd0;
                            WMwr       <= 1'b0;
                            PMwr       <= 1'b0;                          
                        end
                        default:;

                    endcase
                end

                `MNIST: begin
                    //加速器模式，根據 AccDone 啟動並凍結 PC
                    DMaddr    <= 7'd0;
                    WMaddr    <= 7'd0;
                    WMidata   <= 64'd0;
                    WMwr      <= 1'b0;
                    PMwr      <= 1'b0;
                
                    OutR        <= 1'b0;
                    Hlt         <= 1'b0;
                    RegWrite    <= 1'b1;  //寫回
                    AccStart    <= 1'b1;

                    if(AccDone & ~AccBusy)begin
                       AccStart <= 1'b0;
                       RegWrite <= 1'b0;
                    end
                end

                `OUT: begin
                    //OutR
                    DMaddr    <= 7'd0;
                    WMaddr    <= 7'd0;
                    WMidata   <= 64'd0;
                    WMwr      <= 1'b0;
                    PMwr      <= 1'b0;

                    RegWrite  <=  1'b0;
                    WMwr      <=  1'b0;
                    PMwr      <=  1'b0;
                    AccStart  <=  1'b0;

                    OutR      <= ~instr[0];
                    Hlt       <=  instr[0];
                end

                default: begin
                    DMaddr    <= 7'd0;
                    WMaddr    <= 7'd0;
                    WMidata   <= 64'd0;
                    WMwr      <= 1'b0;
                    PMwr      <= 1'b0;     
                    AccStart  <= 1'b0;

                    counter   <= 8'b0;
                    counter1  <= 8'd0;
                    RegWrite  <= 1'b0;

                    OutR      <= 1'b0;
                    Hlt       <= 1'b0;
                end
            endcase
        end
    end

endmodule
