module Memory
(
    clk,
    addr,
    idata,
    wr,
    odata
);
//*****************************************************************************
    // I/O Ports Declaration
    input           clk;    // System clock
    input  [3-1:0]  addr;   // Memory address
    input  [16-1:0] idata;  // 32 bits memory write data
    input           wr;     // Memory write control signal
    output [16-1:0] odata;  // 32 bits memory read data

    // Global variables Declaration
    // System
    wire   [16-1:0] odata;
    reg    [15:0] memory[0:3]; //32 words Memory

    // System conection
    // Output
    assign odata = memory[addr];

//*****************************************************************************
    always@(posedge clk) begin
        if(wr)
        begin
            memory[addr] <= idata;
        end
    end
//*****************************************************************************
endmodule
