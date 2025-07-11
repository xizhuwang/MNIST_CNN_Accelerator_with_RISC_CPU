//*****************************************************************************
// Module declaration
module ALU
(
    A,
    B,
    Cin,
    Sum,
    Sub,
    Cin_en,
    NZVC
);
//*****************************************************************************
    // I/O port declaration
    input  [16-1:0] A;      // 16 bits addend A
    input  [16-1:0] B;      // 16 bits addend B
    input           Cin;
    input           Cin_en;
    input           Sub;    // Sub Ctrl
    output [16-1:0] Sum;    // 16 bits ALU operation result
    output [ 4-1:0] NZVC;   // N: Negative, Z: Zero, V: oVerflow,  C: Carry

    // Global variable declaration
    wire   [  16:0] result; 
    wire            Ci;
    // System conection
    assign Sum = result[15:0];

    assign NZVC[3]   = result[15];                          
    assign NZVC[2]   = ~(|result[15:0]);                                                                
    assign NZVC[1]   = (~A[15] & ~B[15] &  result[15]) | (A[15] & B[15] &  ~result[15]);
    assign NZVC[0]   = result[16]; 
                           
    assign Ci = (Cin_en) ? Cin : 1'b0;

    assign result = (Sub) ? ((Cin_en) ? ({1'b0, A} + {1'b0, ~B} + 1'b1 + {16{~Ci}}) 
                                      : ({1'b0, A} + {1'b0, ~B} + 1'b1))
                          : ((Cin_en) ? ({1'b0, A} + {1'b0,  B} + {{15{1'b0}}, Ci}) 
                                      : ({1'b0, A} + {1'b0,  B}));
                  
//*****************************************************************************
endmodule