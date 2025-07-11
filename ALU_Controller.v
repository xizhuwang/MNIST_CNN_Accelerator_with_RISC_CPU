//*****************************************************************************
// Module declaration
module ALU_Conrtoller
(
    opcode,
    ALU_op,
    Sub,
    Cin_en
);
//*****************************************************************************
    // I/O Port
    input  [4:0] opcode;   // 5 bits simplified function code
    input  [1:0] ALU_op;   // 2 bits ALU opcode
    output reg   Sub;
    output wire  Cin_en;

//*****************************************************************************
// Block : ALU control decode

    assign Cin_en = (opcode == 5'b00000) ? ALU_op[0] : 1'b0;

    always @(*)
    begin
        case(opcode) // ALU opcode decode
        ///////////////////////////////////////////////////////////////////////
        // Solve the truth table
        ///////////////////////////////////////////////////////////////////////
        // opcode | ALU_op|       |  SUB  |  Cin
        // -------+-------+-------+-------+-------
        //  00000 |    00 |   ADD |     0 |   
        //  00000 |    01 |   ADC |     0 |   C
        //  00000 |    10 |   SBB |     1 |   
        //  00000 |    11 |   SUB |     1 |  ~C
        //  00110 |    xx |   CMP |     1 |
        //  01000 |    xx |  SUBI |     1 |
        ///////////////////////////////////////////////////////////////////////

            5'b00000:
            begin
                case(ALU_op[1:0])
                    2'b00:  Sub = 1'b0;
                    2'b01:  Sub = 1'b0;
                    2'b10:  Sub = 1'b1;
                    2'b11:  Sub = 1'b1;
                    default:Sub = 1'b0;
                endcase
            end
            5'b00110:       Sub = 1'b1;
            5'b01000:
                            Sub = 1'b1;
            default:        Sub = 1'b0;
        endcase
    end
//*****************************************************************************
endmodule