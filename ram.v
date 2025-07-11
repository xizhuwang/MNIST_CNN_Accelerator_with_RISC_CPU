module ram #(
) ( 
    input                   clk,
    input                   rst_n,
    input                   we,
    
    input                   mode,       // if mode == 1, then address line is 9-bit and write data as 16-bit/1 word. if mode == 0, then address line is 10-bit and write data as 8-bit/1 word
    input   [ 7 - 1 : 0]    ext_addr,
    input   [64 - 1 : 0]    ext_data,

    input   [10 - 1 : 0]    addr,
    input   [ 8 - 1 : 0]    in,
    output  [ 8 - 1 : 0]    out
);

    reg [ 7 - 1 : 0]    ram_addr;
    reg [ 3 - 1 : 0]    block_position;

    reg [ 7 - 1 : 0]    ram_addr_in;

    reg [64 - 1 : 0]    ram_in;
    wire[64 - 1 : 0]    ram_out;
    reg [64 - 1 : 0]    ram_out_synchronized;

    reg [ 8 - 1 : 0]    out_w;

    assign out = out_w;

    always @(*) begin
        {ram_addr, block_position} = addr;
        ram_addr_in = mode? ext_addr:ram_addr;
        if (~mode) begin
            if (we) begin
                case (block_position)
                    3'b000: begin
                        ram_in = {in, ram_out_synchronized[55:0]};
                    end 
                    3'b001: begin
                        ram_in = {ram_out_synchronized[63:56], in, ram_out_synchronized[47:0]};
                    end 
                    3'b010: begin
                        ram_in = {ram_out_synchronized[63:48], in, ram_out_synchronized[39:0]};
                    end 
                    3'b011: begin
                        ram_in = {ram_out_synchronized[63:40], in, ram_out_synchronized[31:0]};
                    end 
                    3'b100: begin
                        ram_in = {ram_out_synchronized[63:32], in, ram_out_synchronized[23:0]};
                    end 
                    3'b101: begin
                        ram_in = {ram_out_synchronized[63:24], in, ram_out_synchronized[15:0]};
                    end 
                    3'b110: begin
                        ram_in = {ram_out_synchronized[63:16], in, ram_out_synchronized[7:0]};
                    end 
                    3'b111: begin
                        ram_in = {ram_out_synchronized[63:8], in};
                    end 
                    default: begin
                        ram_in = ram_out_synchronized;
                    end
                endcase
            end else begin
                ram_in = ram_out_synchronized;
            end
        end else begin
            ram_in = ext_data;
        end

        out_w = ram_out_synchronized[(63 - block_position*8) -: 8];
    end

    ram_1p_128x64 #(
    ) U_ram_1p_128x64 (
        .clk    (clk        ),
        .rst_n  (rst_n      ),
        .we     (we         ),
        .addr   (ram_addr_in),
        .in     (ram_in     ),
        .out    (ram_out    )
    );

    always @(*) begin
        ram_out_synchronized = ram_out;
    end
    
endmodule