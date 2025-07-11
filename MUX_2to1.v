module MUX_2to1#(
    parameter DATA_WIDTH = 16
)(
    s,   // Select
    i0,  // Mux Data 0
    i1,  // Mux Data 1
    o    // Mux output
);
//*****************************************************************************
    // I/O port declaration
    input           s; // Select
    input  [DATA_WIDTH-1:0] i0;  // Mux Data 0
    input  [DATA_WIDTH-1:0] i1;  // Mux Data 1
    output [DATA_WIDTH-1:0] o;   // Mux output

    // System conection
    // Output
    assign o = (s) ? i1 : i0;
//*****************************************************************************
endmodule