`timescale 1ns / 1ps
`define auto_init

module tb_Single_Cycle_CPU();

parameter clk_period = 20;
parameter delay_factor = 2;

// Inputs
	reg          clk_i;
	reg          rst_n;

	reg          ex_iwe;
	reg [3-1:0]  ex_iaddr;    // 3
	reg [16-1:0] ex_idata;   // 16
	reg          ex_dwe;
	reg [7-1:0]  ex_daddr;    // 7
	reg [64-1:0] ex_ddata;   // 64

// Output
	wire [15:0] Out_R;
	wire flag_done;

// Bidirs

	/*****************************************************/
	/*                                                   */
	/*                Instantiate the UUT                */
	/*                                                   */
	/*****************************************************/

	Single_Cycle_CPU u_Single_Cycle_CPU(
		.clk     (clk_i     ),
		.rst_n     (rst_n     ),
		.Out_R     (Out_R     ),
		.flag_done (flag_done ),
		.ex_iwe    (ex_iwe    ),
		.ex_iaddr  (ex_iaddr  ),
		.ex_idata  (ex_idata  ),
		.ex_dwe    (ex_dwe    ),
		.ex_daddr  (ex_daddr  ),
		.ex_ddata  (ex_ddata  )
	);
	
	
	/*****************************************************/
	/*                                                   */
	/*                 Initialize Inputs                 */
	/*                                                   */
	/*****************************************************/

	`ifdef auto_init
		initial begin
			clk_i    = 1'b0;   
			rst_n    = 1'b0;
			ex_iwe   = 1'b0;
			ex_dwe   = 1'b0;
			ex_iaddr = 3'd0;
			ex_idata = 16'd0;
			ex_daddr = 7'd0;
			ex_ddata = 64'd0;
		end
	`endif

	/*****************************************************/
	/*                                                   */
	/*             Generate the clock signal             */
	/*                                                   */
	/*****************************************************/

	always begin
		#(clk_period/2) clk_i <= 1'b0;
		#(clk_period/2) clk_i <= 1'b1;
	end

	/*****************************************************/
	/*                                                   */
	/*                   Main Program                    */
	/*                                                   */
	/*****************************************************/
	initial begin
        $dumpfile("./vcd/Single_Cycle_CPU.vcd");
        $dumpvars(0,tb_Single_Cycle_CPU);
    end
	initial begin	
		
		///////////////////////////////////////////////////////////////////////////////////
		//                                                                               //
		//             Find the minimum and maximum from two numbers in memory.          //
		//                                                                               // 
		///////////////////////////////////////////////////////////////////////////////////	
		
		// $readmemb("max_min_test.txt", UUT.u_Instruction_Memory.memory);
		write_imem(3'b000, 16'b0110000000000000) ;   //LDM  
        write_imem(3'b001, 16'b1011100000000000) ;   //MNIST
		write_imem(3'b010, 16'b1110000000000000);    //OUTR R1
		write_imem(3'b011, 16'b1110000000000001) ;   //HLT

		inference_9;

		//start
		#(clk_period) ex_iwe = 1'b0;
		#(clk_period) ex_dwe = 1'b0;
		#(clk_period) rst_n = 1'b1;

		wait(flag_done);
		
		#(clk_period) rst_n = 1'b0;
		
		#100 $finish;
	end

	/*****************************************************/
	/*                                                   */
	/*            Write Instrucion to Memoery            */
	/*                                                   */
	/*****************************************************/
	
	task write_imem;
		input [3-1:0] addr;
		input [16-1:0] data;
		begin
			@(posedge clk_i) #(clk_period/delay_factor) begin
				ex_iwe = 1'b1;
				ex_iaddr = addr;
				ex_idata = data;
			end
		end
	endtask

	/*****************************************************/
	/*                                                   */
	/*               Write Data to Memoery               */
	/*                                                   */
	/*****************************************************/
	
	task write_dmem;
		input [7-1:0] addr;
		input [64-1:0] data;
		begin
			@(posedge clk_i) #(clk_period/delay_factor) begin
				ex_dwe = 1'b1;
				ex_daddr = addr;
				ex_ddata = data;
			end
		end
	endtask

	/*****************************************************/
	/*                                                   */
	/*                      Monitor                      */
	/*                                                   */
	/*****************************************************/
	
	//initial #200000 $finish;
	initial
	$monitor($realtime,"ns, Out_R = %h \n", Out_R);

	task inference_0; begin
write_dmem(7'h00, 64'h0000000000000000);
write_dmem(7'h01, 64'h0000000000000000);
write_dmem(7'h02, 64'h0000000000000000);
write_dmem(7'h03, 64'h0000000000000000);
write_dmem(7'h04, 64'h0000000000000000);
write_dmem(7'h05, 64'h0000000000000000);
write_dmem(7'h06, 64'h0000000000000000);
write_dmem(7'h07, 64'h0000000000000000);
write_dmem(7'h08, 64'h0000000000000000);
write_dmem(7'h09, 64'h0000000000000000);
write_dmem(7'h0A, 64'h0000000000000000);
write_dmem(7'h0B, 64'h0000000000000000);
write_dmem(7'h0C, 64'h0000000000000000);
write_dmem(7'h0D, 64'h0000000000000000);
write_dmem(7'h0E, 64'h0000000000000000);
write_dmem(7'h0F, 64'h00000000001EC7B2);
write_dmem(7'h10, 64'hDC7D050000000000);
write_dmem(7'h11, 64'h0000000000000000);
write_dmem(7'h12, 64'h0000000000000000);
write_dmem(7'h13, 64'h10C7FEFEFEFEBD00);
write_dmem(7'h14, 64'h0000000000000000);
write_dmem(7'h15, 64'h0000000000000000);
write_dmem(7'h16, 64'h00000024F5FEFEC5);
write_dmem(7'h17, 64'h9BE8F34900000000);
write_dmem(7'h18, 64'h0000000000000000);
write_dmem(7'h19, 64'h00000000000008BC);
write_dmem(7'h1A, 64'hFECE38000008A8CC);
write_dmem(7'h1B, 64'h0000000000000000);
write_dmem(7'h1C, 64'h0000000000000000);
write_dmem(7'h1D, 64'h0000BEFEBF140000);
write_dmem(7'h1E, 64'h00002AF428000000);
write_dmem(7'h1F, 64'h0000000000000000);
write_dmem(7'h20, 64'h00000000003AF9F1);
write_dmem(7'h21, 64'h0D00000000002AFE);
write_dmem(7'h22, 64'h7300000000000000);
write_dmem(7'h23, 64'h0000000000000000);
write_dmem(7'h24, 64'h00B0FE8F00000000);
write_dmem(7'h25, 64'h00002AFE73000000);
write_dmem(7'h26, 64'h0000000000000000);
write_dmem(7'h27, 64'h000000000BE0EF1A);
write_dmem(7'h28, 64'h0000000000002AFE);
write_dmem(7'h29, 64'h8C00000000000000);
write_dmem(7'h2A, 64'h0000000000000000);
write_dmem(7'h2B, 64'h8EFE780000000000);
write_dmem(7'h2C, 64'h00001EF273000000);
write_dmem(7'h2D, 64'h0000000000000000);
write_dmem(7'h2E, 64'h0000003BFCFE2300);
write_dmem(7'h2F, 64'h00000000000028FD);
write_dmem(7'h30, 64'hC200000000000000);
write_dmem(7'h31, 64'h0000000000000077);
write_dmem(7'h32, 64'hFEAD000000000000);
write_dmem(7'h33, 64'h00002AFEC5000000);
write_dmem(7'h34, 64'h0000000000000000);
write_dmem(7'h35, 64'h000000C5FE290000);
write_dmem(7'h36, 64'h0000000000002AFE);
write_dmem(7'h37, 64'hC400000000000000);
write_dmem(7'h38, 64'h00000000000000C5);
write_dmem(7'h39, 64'hEC18000000000000);
write_dmem(7'h3A, 64'h000054FEA1000000);
write_dmem(7'h3B, 64'h0000000000000000);
write_dmem(7'h3C, 64'h000000C5D5000000);
write_dmem(7'h3D, 64'h000000000025F3F7);
write_dmem(7'h3E, 64'h4900000000000000);
write_dmem(7'h3F, 64'h00000000000000C5);
write_dmem(7'h40, 64'hD500000000000000);
write_dmem(7'h41, 64'h0CD1FECC00000000);
write_dmem(7'h42, 64'h0000000000000000);
write_dmem(7'h43, 64'h00000071F7220000);
write_dmem(7'h44, 64'h000000047BFEFE78);
write_dmem(7'h45, 64'h0000000000000000);
write_dmem(7'h46, 64'h000000000000000F);
write_dmem(7'h47, 64'hE3740800000018C8);
write_dmem(7'h48, 64'hFEFED41300000000);
write_dmem(7'h49, 64'h0000000000000000);
write_dmem(7'h4A, 64'h000000009DFEE99B);
write_dmem(7'h4B, 64'h9494EFFEFED51C00);
write_dmem(7'h4C, 64'h0000000000000000);
write_dmem(7'h4D, 64'h0000000000000000);
write_dmem(7'h4E, 64'h15CDFEFEFEFEFFFE);
write_dmem(7'h4F, 64'h9C09000000000000);
write_dmem(7'h50, 64'h0000000000000000);
write_dmem(7'h51, 64'h00000000000450D4);
write_dmem(7'h52, 64'hFEFEAC5202000000);
write_dmem(7'h53, 64'h0000000000000000);
write_dmem(7'h54, 64'h0000000000000000);
write_dmem(7'h55, 64'h0000000000000000);
write_dmem(7'h56, 64'h0000000000000000);
write_dmem(7'h57, 64'h0000000000000000);
write_dmem(7'h58, 64'h0000000000000000);
write_dmem(7'h59, 64'h0000000000000000);
write_dmem(7'h5A, 64'h0000000000000000);
write_dmem(7'h5B, 64'h0000000000000000);
write_dmem(7'h5C, 64'h0000000000000000);
write_dmem(7'h5D, 64'h0000000000000000);
write_dmem(7'h5E, 64'h0000000000000000);
write_dmem(7'h5F, 64'h0000000000000000);
write_dmem(7'h60, 64'h0000000000000000);
write_dmem(7'h61, 64'h0000000000000000);
write_dmem(7'h62, 64'h0000000000000000);
write_dmem(7'h63, 64'h0000000000000000);
write_dmem(7'h64, 64'h0D481CE8BE3A19F2);
write_dmem(7'h65, 64'h05E33E291CFFD736);
write_dmem(7'h66, 64'h575648A798EED444);
write_dmem(7'h67, 64'h7F00DDDC0B33CDC4);
write_dmem(7'h68, 64'h195377E734777F72);
write_dmem(7'h69, 64'h42363906F9D9BC86);
write_dmem(7'h6A, 64'h9C9AE1150E01E801);
write_dmem(7'h6B, 64'h03FBF4EFC01A2EE3);
write_dmem(7'h6C, 64'hEC24E7FDD4EEDE06);
write_dmem(7'h6D, 64'h1518AA34EBD6A77F);
write_dmem(7'h6E, 64'hD303000EFDECD6E6);
write_dmem(7'h6F, 64'hEC00DB0AF511FF25);
write_dmem(7'h70, 64'h0724110A02E7F201);
write_dmem(7'h71, 64'h1324DB20FCE2EBEE);
write_dmem(7'h72, 64'h0C17DFC6C9DE09F6);
write_dmem(7'h73, 64'h0AF345F4091104DD);
write_dmem(7'h74, 64'h1FD3F808DA352309);
write_dmem(7'h75, 64'h05FF08FDE6D414EA);
write_dmem(7'h76, 64'hEE16CEC9D6E7E7FD);
write_dmem(7'h77, 64'hD7F3FEF3E70A3131);
write_dmem(7'h78, 64'hFD2F3612FE11F401);
write_dmem(7'h79, 64'h29F609DC0C1AD0CA);
write_dmem(7'h7A, 64'h29C0F7FB06F230FC);
write_dmem(7'h7B, 64'hE711EA0006F71717);
write_dmem(7'h7C, 64'hD7E8FDFB0FE00618);
write_dmem(7'h7D, 64'h07FE27E41107F3CF);
write_dmem(7'h7E, 64'h0FC8000000000000);
write_dmem(7'h7F, 64'h0000000000000000);
	end
	endtask

	task inference_1;
	begin
		write_dmem(7'h00, 64'h0000000000000000);
write_dmem(7'h01, 64'h0000000000000000);
write_dmem(7'h02, 64'h0000000000000000);
write_dmem(7'h03, 64'h0000000000000000);
write_dmem(7'h04, 64'h0000000000000000);
write_dmem(7'h05, 64'h0000000000000000);
write_dmem(7'h06, 64'h0000000000000000);
write_dmem(7'h07, 64'h0000000000000000);
write_dmem(7'h08, 64'h0000000000000000);
write_dmem(7'h09, 64'h0000000000000000);
write_dmem(7'h0A, 64'h0000000000000000);
write_dmem(7'h0B, 64'h0000000000000000);
write_dmem(7'h0C, 64'h0000000000000000);
write_dmem(7'h0D, 64'h0000000000000000);
write_dmem(7'h0E, 64'h0000000000000000);
write_dmem(7'h0F, 64'h0000000000000000);
write_dmem(7'h10, 64'h0000000000000000);
write_dmem(7'h11, 64'h0000000000000000);
write_dmem(7'h12, 64'h000000000000000D);
write_dmem(7'h13, 64'hDAD13E0000000000);
write_dmem(7'h14, 64'h0000000000000000);
write_dmem(7'h15, 64'h0000000000000000);
write_dmem(7'h16, 64'h00000006BDFCB900);
write_dmem(7'h17, 64'h0000000000000000);
write_dmem(7'h18, 64'h0000000000000000);
write_dmem(7'h19, 64'h0000000000000000);
write_dmem(7'h1A, 64'hA9FCD70600000000);
write_dmem(7'h1B, 64'h0000000000000000);
write_dmem(7'h1C, 64'h0000000000000000);
write_dmem(7'h1D, 64'h00000000A9FCFD3F);
write_dmem(7'h1E, 64'h0000000000000000);
write_dmem(7'h1F, 64'h0000000000000000);
write_dmem(7'h20, 64'h0000000000000000);
write_dmem(7'h21, 64'hA9FCFD3F00000000);
write_dmem(7'h22, 64'h0000000000000000);
write_dmem(7'h23, 64'h0000000000000000);
write_dmem(7'h24, 64'h000000006DFDFEA8);
write_dmem(7'h25, 64'h0000000000000000);
write_dmem(7'h26, 64'h0000000000000000);
write_dmem(7'h27, 64'h0000000000000000);
write_dmem(7'h28, 64'h40FCFDA800000000);
write_dmem(7'h29, 64'h0000000000000000);
write_dmem(7'h2A, 64'h0000000000000000);
write_dmem(7'h2B, 64'h000000003BF9FDD2);
write_dmem(7'h2C, 64'h0B00000000000000);
write_dmem(7'h2D, 64'h0000000000000000);
write_dmem(7'h2E, 64'h0000000000000000);
write_dmem(7'h2F, 64'h00D3FDFC15000000);
write_dmem(7'h30, 64'h0000000000000000);
write_dmem(7'h31, 64'h0000000000000000);
write_dmem(7'h32, 64'h0000000000D3FDFC);
write_dmem(7'h33, 64'h1500000000000000);
write_dmem(7'h34, 64'h0000000000000000);
write_dmem(7'h35, 64'h0000000000000000);
write_dmem(7'h36, 64'h00D4FFFD15000000);
write_dmem(7'h37, 64'h0000000000000000);
write_dmem(7'h38, 64'h0000000000000000);
write_dmem(7'h39, 64'h0000000000D3FDFC);
write_dmem(7'h3A, 64'h1500000000000000);
write_dmem(7'h3B, 64'h0000000000000000);
write_dmem(7'h3C, 64'h0000000000000000);
write_dmem(7'h3D, 64'h00D3FDFC15000000);
write_dmem(7'h3E, 64'h0000000000000000);
write_dmem(7'h3F, 64'h0000000000000000);
write_dmem(7'h40, 64'h0000000000A7FDFC);
write_dmem(7'h41, 64'h1500000000000000);
write_dmem(7'h42, 64'h0000000000000000);
write_dmem(7'h43, 64'h0000000000000000);
write_dmem(7'h44, 64'h00D3FDFC15000000);
write_dmem(7'h45, 64'h0000000000000000);
write_dmem(7'h46, 64'h0000000000000000);
write_dmem(7'h47, 64'h0000000000D4FFFD);
write_dmem(7'h48, 64'h1500000000000000);
write_dmem(7'h49, 64'h0000000000000000);
write_dmem(7'h4A, 64'h0000000000000000);
write_dmem(7'h4B, 64'h0083FDFC15000000);
write_dmem(7'h4C, 64'h0000000000000000);
write_dmem(7'h4D, 64'h0000000000000000);
write_dmem(7'h4E, 64'h00000000006AFDFC);
write_dmem(7'h4F, 64'h1500000000000000);
write_dmem(7'h50, 64'h0000000000000000);
write_dmem(7'h51, 64'h0000000000000000);
write_dmem(7'h52, 64'h006AFDFC15000000);
write_dmem(7'h53, 64'h0000000000000000);
write_dmem(7'h54, 64'h0000000000000000);
write_dmem(7'h55, 64'h000000000012D1B6);
write_dmem(7'h56, 64'h0400000000000000);
write_dmem(7'h57, 64'h0000000000000000);
write_dmem(7'h58, 64'h0000000000000000);
write_dmem(7'h59, 64'h0000000000000000);
write_dmem(7'h5A, 64'h0000000000000000);
write_dmem(7'h5B, 64'h0000000000000000);
write_dmem(7'h5C, 64'h0000000000000000);
write_dmem(7'h5D, 64'h0000000000000000);
write_dmem(7'h5E, 64'h0000000000000000);
write_dmem(7'h5F, 64'h0000000000000000);
write_dmem(7'h60, 64'h0000000000000000);
write_dmem(7'h61, 64'h0000000000000000);
write_dmem(7'h62, 64'h0000000000000000);
write_dmem(7'h63, 64'h0000000000000000);
write_dmem(7'h64, 64'h0D481CE8BE3A19F2);
write_dmem(7'h65, 64'h05E33E291CFFD736);
write_dmem(7'h66, 64'h575648A798EED444);
write_dmem(7'h67, 64'h7F00DDDC0B33CDC4);
write_dmem(7'h68, 64'h195377E734777F72);
write_dmem(7'h69, 64'h42363906F9D9BC86);
write_dmem(7'h6A, 64'h9C9AE1150E01E801);
write_dmem(7'h6B, 64'h03FBF4EFC01A2EE3);
write_dmem(7'h6C, 64'hEC24E7FDD4EEDE06);
write_dmem(7'h6D, 64'h1518AA34EBD6A77F);
write_dmem(7'h6E, 64'hD303000EFDECD6E6);
write_dmem(7'h6F, 64'hEC00DB0AF511FF25);
write_dmem(7'h70, 64'h0724110A02E7F201);
write_dmem(7'h71, 64'h1324DB20FCE2EBEE);
write_dmem(7'h72, 64'h0C17DFC6C9DE09F6);
write_dmem(7'h73, 64'h0AF345F4091104DD);
write_dmem(7'h74, 64'h1FD3F808DA352309);
write_dmem(7'h75, 64'h05FF08FDE6D414EA);
write_dmem(7'h76, 64'hEE16CEC9D6E7E7FD);
write_dmem(7'h77, 64'hD7F3FEF3E70A3131);
write_dmem(7'h78, 64'hFD2F3612FE11F401);
write_dmem(7'h79, 64'h29F609DC0C1AD0CA);
write_dmem(7'h7A, 64'h29C0F7FB06F230FC);
write_dmem(7'h7B, 64'hE711EA0006F71717);
write_dmem(7'h7C, 64'hD7E8FDFB0FE00618);
write_dmem(7'h7D, 64'h07FE27E41107F3CF);
write_dmem(7'h7E, 64'h0FC8000000000000);
write_dmem(7'h7F, 64'h0000000000000000);
	end
	endtask
	
	task inference_2;
	begin
		write_dmem(7'h00, 64'h0000000000000000);
write_dmem(7'h01, 64'h0000000000000000);
write_dmem(7'h02, 64'h0000000000000000);
write_dmem(7'h03, 64'h0000000000000000);
write_dmem(7'h04, 64'h0000000000000000);
write_dmem(7'h05, 64'h0000000000000000);
write_dmem(7'h06, 64'h0000000000000000);
write_dmem(7'h07, 64'h0000000000000000);
write_dmem(7'h08, 64'h0000000000000000);
write_dmem(7'h09, 64'h0000000000000000);
write_dmem(7'h0A, 64'h0000000000000000);
write_dmem(7'h0B, 64'h0000000000000000);
write_dmem(7'h0C, 64'h0000000000000000);
write_dmem(7'h0D, 64'h0000000000000000);
write_dmem(7'h0E, 64'h0000000000000000);
write_dmem(7'h0F, 64'h000000000032AAFE);
write_dmem(7'h10, 64'h3B00000000000000);
write_dmem(7'h11, 64'h0000000000000000);
write_dmem(7'h12, 64'h0000000000000024);
write_dmem(7'h13, 64'hBFF5FEFEAF000000);
write_dmem(7'h14, 64'h0000000000000000);
write_dmem(7'h15, 64'h0000000000000000);
write_dmem(7'h16, 64'h000346F2FEEBE9FE);
write_dmem(7'h17, 64'hB600000000000000);
write_dmem(7'h18, 64'h0000000000000000);
write_dmem(7'h19, 64'h0000000017B8FEF3);
write_dmem(7'h1A, 64'h631B6EFEB6000000);
write_dmem(7'h1B, 64'h0000000000000000);
write_dmem(7'h1C, 64'h0000000000000014);
write_dmem(7'h1D, 64'hCDF7621A00006EFE);
write_dmem(7'h1E, 64'h9500000000000000);
write_dmem(7'h1F, 64'h0000000000000000);
write_dmem(7'h20, 64'h0000002868140000);
write_dmem(7'h21, 64'h00006EFE21000000);
write_dmem(7'h22, 64'h0000000000000000);
write_dmem(7'h23, 64'h0000000000000000);
write_dmem(7'h24, 64'h0000000000006EEA);
write_dmem(7'h25, 64'h0000000000000000);
write_dmem(7'h26, 64'h0000000000000000);
write_dmem(7'h27, 64'h0000000000000000);
write_dmem(7'h28, 64'h0020D69500000000);
write_dmem(7'h29, 64'h0000000000000000);
write_dmem(7'h2A, 64'h0000000000000000);
write_dmem(7'h2B, 64'h000000000086C810);
write_dmem(7'h2C, 64'h0000000000000000);
write_dmem(7'h2D, 64'h0000000000000000);
write_dmem(7'h2E, 64'h0000000000000000);
write_dmem(7'h2F, 64'h14E7900000000000);
write_dmem(7'h30, 64'h0000000000000000);
write_dmem(7'h31, 64'h0000000000000000);
write_dmem(7'h32, 64'h0000000092F44800);
write_dmem(7'h33, 64'h0000000000000000);
write_dmem(7'h34, 64'h0000000000000000);
write_dmem(7'h35, 64'h0000000000000010);
write_dmem(7'h36, 64'hC984000000000000);
write_dmem(7'h37, 64'h0000000000000000);
write_dmem(7'h38, 64'h0000000000000000);
write_dmem(7'h39, 64'h000000A4E21F0000);
write_dmem(7'h3A, 64'h00000000000B7ACD);
write_dmem(7'h3B, 64'h2F00000000000000);
write_dmem(7'h3C, 64'h0000000000004FFF);
write_dmem(7'h3D, 64'h800000000000000F);
write_dmem(7'h3E, 64'h54D8FA900C000000);
write_dmem(7'h3F, 64'h0000000000000000);
write_dmem(7'h40, 64'h0007CFE425000000);
write_dmem(7'h41, 64'h001488EEFEE43F00);
write_dmem(7'h42, 64'h0000000000000000);
write_dmem(7'h43, 64'h000000000087FE42);
write_dmem(7'h44, 64'h00000035BEFEFEC5);
write_dmem(7'h45, 64'h7500000000000000);
write_dmem(7'h46, 64'h0000000000000000);
write_dmem(7'h47, 64'h15E7B6002065B8F9);
write_dmem(7'h48, 64'hEFB3600400000000);
write_dmem(7'h49, 64'h0000000000000000);
write_dmem(7'h4A, 64'h0000000080FE6380);
write_dmem(7'h4B, 64'hE8FEFBB93B000000);
write_dmem(7'h4C, 64'h0000000000000000);
write_dmem(7'h4D, 64'h0000000000000004);
write_dmem(7'h4E, 64'hDDFEFEFEFEC04600);
write_dmem(7'h4F, 64'h0000000000000000);
write_dmem(7'h50, 64'h0000000000000000);
write_dmem(7'h51, 64'h00000037FEFEBC69);
write_dmem(7'h52, 64'h480B000000000000);
write_dmem(7'h53, 64'h0000000000000000);
write_dmem(7'h54, 64'h0000000000000000);
write_dmem(7'h55, 64'h0000000000000000);
write_dmem(7'h56, 64'h0000000000000000);
write_dmem(7'h57, 64'h0000000000000000);
write_dmem(7'h58, 64'h0000000000000000);
write_dmem(7'h59, 64'h0000000000000000);
write_dmem(7'h5A, 64'h0000000000000000);
write_dmem(7'h5B, 64'h0000000000000000);
write_dmem(7'h5C, 64'h0000000000000000);
write_dmem(7'h5D, 64'h0000000000000000);
write_dmem(7'h5E, 64'h0000000000000000);
write_dmem(7'h5F, 64'h0000000000000000);
write_dmem(7'h60, 64'h0000000000000000);
write_dmem(7'h61, 64'h0000000000000000);
write_dmem(7'h62, 64'h0000000000000000);
write_dmem(7'h63, 64'h0000000000000000);
write_dmem(7'h64, 64'h0D481CE8BE3A19F2);
write_dmem(7'h65, 64'h05E33E291CFFD736);
write_dmem(7'h66, 64'h575648A798EED444);
write_dmem(7'h67, 64'h7F00DDDC0B33CDC4);
write_dmem(7'h68, 64'h195377E734777F72);
write_dmem(7'h69, 64'h42363906F9D9BC86);
write_dmem(7'h6A, 64'h9C9AE1150E01E801);
write_dmem(7'h6B, 64'h03FBF4EFC01A2EE3);
write_dmem(7'h6C, 64'hEC24E7FDD4EEDE06);
write_dmem(7'h6D, 64'h1518AA34EBD6A77F);
write_dmem(7'h6E, 64'hD303000EFDECD6E6);
write_dmem(7'h6F, 64'hEC00DB0AF511FF25);
write_dmem(7'h70, 64'h0724110A02E7F201);
write_dmem(7'h71, 64'h1324DB20FCE2EBEE);
write_dmem(7'h72, 64'h0C17DFC6C9DE09F6);
write_dmem(7'h73, 64'h0AF345F4091104DD);
write_dmem(7'h74, 64'h1FD3F808DA352309);
write_dmem(7'h75, 64'h05FF08FDE6D414EA);
write_dmem(7'h76, 64'hEE16CEC9D6E7E7FD);
write_dmem(7'h77, 64'hD7F3FEF3E70A3131);
write_dmem(7'h78, 64'hFD2F3612FE11F401);
write_dmem(7'h79, 64'h29F609DC0C1AD0CA);
write_dmem(7'h7A, 64'h29C0F7FB06F230FC);
write_dmem(7'h7B, 64'hE711EA0006F71717);
write_dmem(7'h7C, 64'hD7E8FDFB0FE00618);
write_dmem(7'h7D, 64'h07FE27E41107F3CF);
write_dmem(7'h7E, 64'h0FC8000000000000);
write_dmem(7'h7F, 64'h0000000000000000);
	end
	endtask
	
	task inference_3;
	begin
		write_dmem(7'h00, 64'h0000000000000000);
write_dmem(7'h01, 64'h0000000000000000);
write_dmem(7'h02, 64'h0000000000000000);
write_dmem(7'h03, 64'h0000000000000000);
write_dmem(7'h04, 64'h0000000000000000);
write_dmem(7'h05, 64'h0000000000000000);
write_dmem(7'h06, 64'h0000000000000000);
write_dmem(7'h07, 64'h0000000000000000);
write_dmem(7'h08, 64'h0000000000000000);
write_dmem(7'h09, 64'h0000000000000000);
write_dmem(7'h0A, 64'h0000000000000000);
write_dmem(7'h0B, 64'h0000000000000000);
write_dmem(7'h0C, 64'h0000000000000000);
write_dmem(7'h0D, 64'h0000000000000000);
write_dmem(7'h0E, 64'h0000000000000000);
write_dmem(7'h0F, 64'h0000000000000000);
write_dmem(7'h10, 64'h0000000000000000);
write_dmem(7'h11, 64'h0000000000000000);
write_dmem(7'h12, 64'h0000000000000000);
write_dmem(7'h13, 64'h1573C4FEFEFE9C11);
write_dmem(7'h14, 64'h0000000000000000);
write_dmem(7'h15, 64'h0000000000000000);
write_dmem(7'h16, 64'h00000041CBFDFDFB);
write_dmem(7'h17, 64'hF8FDFD9F01000000);
write_dmem(7'h18, 64'h0000000000000000);
write_dmem(7'h19, 64'h00000000000889F9);
write_dmem(7'h1A, 64'hFDF193442975F6FD);
write_dmem(7'h1B, 64'h1400000000000000);
write_dmem(7'h1C, 64'h0000000000000000);
write_dmem(7'h1D, 64'h006DFDF29D1D0000);
write_dmem(7'h1E, 64'h0273FAF712000000);
write_dmem(7'h1F, 64'h0000000000000000);
write_dmem(7'h20, 64'h0000000000169124);
write_dmem(7'h21, 64'h000000002DFDFD6A);
write_dmem(7'h22, 64'h0000000000000000);
write_dmem(7'h23, 64'h0000000000000000);
write_dmem(7'h24, 64'h0000000000066F99);
write_dmem(7'h25, 64'hF0FDDB0700000000);
write_dmem(7'h26, 64'h0000000000000000);
write_dmem(7'h27, 64'h0000000000000000);
write_dmem(7'h28, 64'h0054FDFDFDE62F00);
write_dmem(7'h29, 64'h0000000000000000);
write_dmem(7'h2A, 64'h0000000000000000);
write_dmem(7'h2B, 64'h00000094EFF8FDFD);
write_dmem(7'h2C, 64'hFDFA630000000000);
write_dmem(7'h2D, 64'h0000000000000000);
write_dmem(7'h2E, 64'h00000000000000EF);
write_dmem(7'h2F, 64'hFDFDFCB5FDFDF85F);
write_dmem(7'h30, 64'h0000000000000000);
write_dmem(7'h31, 64'h0000000000000000);
write_dmem(7'h32, 64'h000000042C040401);
write_dmem(7'h33, 64'h32B8FDFC4E000000);
write_dmem(7'h34, 64'h0000000000000000);
write_dmem(7'h35, 64'h0000000000000000);
write_dmem(7'h36, 64'h00000000000EE4FD);
write_dmem(7'h37, 64'h7900000000000000);
write_dmem(7'h38, 64'h0000000000000000);
write_dmem(7'h39, 64'h0000000000000000);
write_dmem(7'h3A, 64'h00007EFDDB000000);
write_dmem(7'h3B, 64'h0000000000000000);
write_dmem(7'h3C, 64'h0000000000000000);
write_dmem(7'h3D, 64'h00000000000082FD);
write_dmem(7'h3E, 64'hD500000000000000);
write_dmem(7'h3F, 64'h000000000000006C);
write_dmem(7'h40, 64'h5D00000000000000);
write_dmem(7'h41, 64'h0000E0FD78000000);
write_dmem(7'h42, 64'h0000000000000000);
write_dmem(7'h43, 64'h000020ECA7000000);
write_dmem(7'h44, 64'h000000000278FAFD);
write_dmem(7'h45, 64'h4600000000000000);
write_dmem(7'h46, 64'h00000000000041FD);
write_dmem(7'h47, 64'hB200000000000000);
write_dmem(7'h48, 64'h2FFDFDA506000000);
write_dmem(7'h49, 64'h0000000000000000);
write_dmem(7'h4A, 64'h00001FEBB2000000);
write_dmem(7'h4B, 64'h0000119EF3FDCB06);
write_dmem(7'h4C, 64'h0000000000000000);
write_dmem(7'h4D, 64'h00000000000000DB);
write_dmem(7'h4E, 64'hEB8A5A5A5B95D8FD);
write_dmem(7'h4F, 64'hF8A3130000000000);
write_dmem(7'h50, 64'h0000000000000000);
write_dmem(7'h51, 64'h000000A2FDFDFDFD);
write_dmem(7'h52, 64'hFEFDEB9218000000);
write_dmem(7'h53, 64'h0000000000000000);
write_dmem(7'h54, 64'h000000000000001A);
write_dmem(7'h55, 64'h7BA5FDC699862000);
write_dmem(7'h56, 64'h0000000000000000);
write_dmem(7'h57, 64'h0000000000000000);
write_dmem(7'h58, 64'h0000000000000000);
write_dmem(7'h59, 64'h0000000000000000);
write_dmem(7'h5A, 64'h0000000000000000);
write_dmem(7'h5B, 64'h0000000000000000);
write_dmem(7'h5C, 64'h0000000000000000);
write_dmem(7'h5D, 64'h0000000000000000);
write_dmem(7'h5E, 64'h0000000000000000);
write_dmem(7'h5F, 64'h0000000000000000);
write_dmem(7'h60, 64'h0000000000000000);
write_dmem(7'h61, 64'h0000000000000000);
write_dmem(7'h62, 64'h0000000000000000);
write_dmem(7'h63, 64'h0000000000000000);
write_dmem(7'h64, 64'h0D481CE8BE3A19F2);
write_dmem(7'h65, 64'h05E33E291CFFD736);
write_dmem(7'h66, 64'h575648A798EED444);
write_dmem(7'h67, 64'h7F00DDDC0B33CDC4);
write_dmem(7'h68, 64'h195377E734777F72);
write_dmem(7'h69, 64'h42363906F9D9BC86);
write_dmem(7'h6A, 64'h9C9AE1150E01E801);
write_dmem(7'h6B, 64'h03FBF4EFC01A2EE3);
write_dmem(7'h6C, 64'hEC24E7FDD4EEDE06);
write_dmem(7'h6D, 64'h1518AA34EBD6A77F);
write_dmem(7'h6E, 64'hD303000EFDECD6E6);
write_dmem(7'h6F, 64'hEC00DB0AF511FF25);
write_dmem(7'h70, 64'h0724110A02E7F201);
write_dmem(7'h71, 64'h1324DB20FCE2EBEE);
write_dmem(7'h72, 64'h0C17DFC6C9DE09F6);
write_dmem(7'h73, 64'h0AF345F4091104DD);
write_dmem(7'h74, 64'h1FD3F808DA352309);
write_dmem(7'h75, 64'h05FF08FDE6D414EA);
write_dmem(7'h76, 64'hEE16CEC9D6E7E7FD);
write_dmem(7'h77, 64'hD7F3FEF3E70A3131);
write_dmem(7'h78, 64'hFD2F3612FE11F401);
write_dmem(7'h79, 64'h29F609DC0C1AD0CA);
write_dmem(7'h7A, 64'h29C0F7FB06F230FC);
write_dmem(7'h7B, 64'hE711EA0006F71717);
write_dmem(7'h7C, 64'hD7E8FDFB0FE00618);
write_dmem(7'h7D, 64'h07FE27E41107F3CF);
write_dmem(7'h7E, 64'h0FC8000000000000);
write_dmem(7'h7F, 64'h0000000000000000);
	end
	endtask
	
	task inference_4;
	begin
		write_dmem(7'h00, 64'h0000000000000000);
write_dmem(7'h01, 64'h0000000000000000);
write_dmem(7'h02, 64'h0000000000000000);
write_dmem(7'h03, 64'h0000000000000000);
write_dmem(7'h04, 64'h0000000000000000);
write_dmem(7'h05, 64'h0000000000000000);
write_dmem(7'h06, 64'h0000000000000000);
write_dmem(7'h07, 64'h0000000000000000);
write_dmem(7'h08, 64'h0000000000000000);
write_dmem(7'h09, 64'h0000000000000000);
write_dmem(7'h0A, 64'h0000000000000000);
write_dmem(7'h0B, 64'h0000000000000000);
write_dmem(7'h0C, 64'h0000000000000000);
write_dmem(7'h0D, 64'h0000000000000000);
write_dmem(7'h0E, 64'h0000000000000000);
write_dmem(7'h0F, 64'h0000000000000000);
write_dmem(7'h10, 64'h0000000000000000);
write_dmem(7'h11, 64'h0000000000000000);
write_dmem(7'h12, 64'h00000000000032E0);
write_dmem(7'h13, 64'h0000000000000046);
write_dmem(7'h14, 64'h1D00000000000000);
write_dmem(7'h15, 64'h0000000000000000);
write_dmem(7'h16, 64'h000079E700000000);
write_dmem(7'h17, 64'h00000094A8000000);
write_dmem(7'h18, 64'h0000000000000000);
write_dmem(7'h19, 64'h000000000004C3E7);
write_dmem(7'h1A, 64'h0000000000000060);
write_dmem(7'h1B, 64'hD20B000000000000);
write_dmem(7'h1C, 64'h0000000000000000);
write_dmem(7'h1D, 64'h0045FC8600000000);
write_dmem(7'h1E, 64'h00000072FC150000);
write_dmem(7'h1F, 64'h0000000000000000);
write_dmem(7'h20, 64'h000000002DECD90C);
write_dmem(7'h21, 64'h00000000000000C0);
write_dmem(7'h22, 64'hFC15000000000000);
write_dmem(7'h23, 64'h0000000000000000);
write_dmem(7'h24, 64'hA8F7350000000000);
write_dmem(7'h25, 64'h000012FFFD150000);
write_dmem(7'h26, 64'h0000000000000000);
write_dmem(7'h27, 64'h00000054F2D30000);
write_dmem(7'h28, 64'h0000000000008DFD);
write_dmem(7'h29, 64'hBD05000000000000);
write_dmem(7'h2A, 64'h00000000000000A9);
write_dmem(7'h2B, 64'hFC6A000000000000);
write_dmem(7'h2C, 64'h0020E8FA42000000);
write_dmem(7'h2D, 64'h0000000000000000);
write_dmem(7'h2E, 64'h00000FE1FC000000);
write_dmem(7'h2F, 64'h000000000086FCD3);
write_dmem(7'h30, 64'h0000000000000000);
write_dmem(7'h31, 64'h00000000000016FC);
write_dmem(7'h32, 64'hA400000000000000);
write_dmem(7'h33, 64'h00A9FCA700000000);
write_dmem(7'h34, 64'h0000000000000000);
write_dmem(7'h35, 64'h000009CCD1120000);
write_dmem(7'h36, 64'h0000000016FDFD6B);
write_dmem(7'h37, 64'h0000000000000000);
write_dmem(7'h38, 64'h00000000000000A9);
write_dmem(7'h39, 64'hFCC75555555581A4);
write_dmem(7'h3A, 64'hC3FCFC6A00000000);
write_dmem(7'h3B, 64'h0000000000000000);
write_dmem(7'h3C, 64'h00000029AAF5FCFC);
write_dmem(7'h3D, 64'hFCFCE8E7FBFCFC09);
write_dmem(7'h3E, 64'h0000000000000000);
write_dmem(7'h3F, 64'h0000000000000000);
write_dmem(7'h40, 64'h0031545454540000);
write_dmem(7'h41, 64'hA1FCFC0000000000);
write_dmem(7'h42, 64'h0000000000000000);
write_dmem(7'h43, 64'h0000000000000000);
write_dmem(7'h44, 64'h000000007FFCFC2D);
write_dmem(7'h45, 64'h0000000000000000);
write_dmem(7'h46, 64'h0000000000000000);
write_dmem(7'h47, 64'h0000000000000000);
write_dmem(7'h48, 64'h80FDFD0000000000);
write_dmem(7'h49, 64'h0000000000000000);
write_dmem(7'h4A, 64'h0000000000000000);
write_dmem(7'h4B, 64'h000000007FFCFC00);
write_dmem(7'h4C, 64'h0000000000000000);
write_dmem(7'h4D, 64'h0000000000000000);
write_dmem(7'h4E, 64'h0000000000000000);
write_dmem(7'h4F, 64'h87FCF40000000000);
write_dmem(7'h50, 64'h0000000000000000);
write_dmem(7'h51, 64'h0000000000000000);
write_dmem(7'h52, 64'h00000000E8EC6F00);
write_dmem(7'h53, 64'h0000000000000000);
write_dmem(7'h54, 64'h0000000000000000);
write_dmem(7'h55, 64'h0000000000000000);
write_dmem(7'h56, 64'hB342000000000000);
write_dmem(7'h57, 64'h0000000000000000);
write_dmem(7'h58, 64'h0000000000000000);
write_dmem(7'h59, 64'h0000000000000000);
write_dmem(7'h5A, 64'h0000000000000000);
write_dmem(7'h5B, 64'h0000000000000000);
write_dmem(7'h5C, 64'h0000000000000000);
write_dmem(7'h5D, 64'h0000000000000000);
write_dmem(7'h5E, 64'h0000000000000000);
write_dmem(7'h5F, 64'h0000000000000000);
write_dmem(7'h60, 64'h0000000000000000);
write_dmem(7'h61, 64'h0000000000000000);
write_dmem(7'h62, 64'h0000000000000000);
write_dmem(7'h63, 64'h0000000000000000);
write_dmem(7'h64, 64'h0D481CE8BE3A19F2);
write_dmem(7'h65, 64'h05E33E291CFFD736);
write_dmem(7'h66, 64'h575648A798EED444);
write_dmem(7'h67, 64'h7F00DDDC0B33CDC4);
write_dmem(7'h68, 64'h195377E734777F72);
write_dmem(7'h69, 64'h42363906F9D9BC86);
write_dmem(7'h6A, 64'h9C9AE1150E01E801);
write_dmem(7'h6B, 64'h03FBF4EFC01A2EE3);
write_dmem(7'h6C, 64'hEC24E7FDD4EEDE06);
write_dmem(7'h6D, 64'h1518AA34EBD6A77F);
write_dmem(7'h6E, 64'hD303000EFDECD6E6);
write_dmem(7'h6F, 64'hEC00DB0AF511FF25);
write_dmem(7'h70, 64'h0724110A02E7F201);
write_dmem(7'h71, 64'h1324DB20FCE2EBEE);
write_dmem(7'h72, 64'h0C17DFC6C9DE09F6);
write_dmem(7'h73, 64'h0AF345F4091104DD);
write_dmem(7'h74, 64'h1FD3F808DA352309);
write_dmem(7'h75, 64'h05FF08FDE6D414EA);
write_dmem(7'h76, 64'hEE16CEC9D6E7E7FD);
write_dmem(7'h77, 64'hD7F3FEF3E70A3131);
write_dmem(7'h78, 64'hFD2F3612FE11F401);
write_dmem(7'h79, 64'h29F609DC0C1AD0CA);
write_dmem(7'h7A, 64'h29C0F7FB06F230FC);
write_dmem(7'h7B, 64'hE711EA0006F71717);
write_dmem(7'h7C, 64'hD7E8FDFB0FE00618);
write_dmem(7'h7D, 64'h07FE27E41107F3CF);
write_dmem(7'h7E, 64'h0FC8000000000000);
write_dmem(7'h7F, 64'h0000000000000000);
	end
	endtask
	
	task inference_5;
	begin
		write_dmem(7'h00, 64'h0000000000000000);
write_dmem(7'h01, 64'h0000000000000000);
write_dmem(7'h02, 64'h0000000000000000);
write_dmem(7'h03, 64'h0000000000000000);
write_dmem(7'h04, 64'h0000000000000000);
write_dmem(7'h05, 64'h0000000000000000);
write_dmem(7'h06, 64'h0000000000000000);
write_dmem(7'h07, 64'h0000000000000000);
write_dmem(7'h08, 64'h0000000000000000);
write_dmem(7'h09, 64'h0000000000000000);
write_dmem(7'h0A, 64'h0000000000000000);
write_dmem(7'h0B, 64'h0000000000000000);
write_dmem(7'h0C, 64'h0000000000000000);
write_dmem(7'h0D, 64'h0000000000000000);
write_dmem(7'h0E, 64'h0000000000000000);
write_dmem(7'h0F, 64'h0000000000000000);
write_dmem(7'h10, 64'h0000000000000000);
write_dmem(7'h11, 64'h0000000000000000);
write_dmem(7'h12, 64'h0000000000000000);
write_dmem(7'h13, 64'hA3C1985C33333333);
write_dmem(7'h14, 64'h1F00000000000000);
write_dmem(7'h15, 64'h0000000000000000);
write_dmem(7'h16, 64'h00000015DFFDFCFD);
write_dmem(7'h17, 64'hFCFDFCFDC0520000);
write_dmem(7'h18, 64'h0000000000000000);
write_dmem(7'h19, 64'h0000000000000033);
write_dmem(7'h1A, 64'hFD660015663E6666);
write_dmem(7'h1B, 64'h3DB7280000000000);
write_dmem(7'h1C, 64'h0000000000000000);
write_dmem(7'h1D, 64'h00000033FC660000);
write_dmem(7'h1E, 64'h00000000003D0000);
write_dmem(7'h1F, 64'h0000000000000000);
write_dmem(7'h20, 64'h0000000000000033);
write_dmem(7'h21, 64'hFD66000000000000);
write_dmem(7'h22, 64'h0000000000000000);
write_dmem(7'h23, 64'h0000000000000000);
write_dmem(7'h24, 64'h0000005CFC660000);
write_dmem(7'h25, 64'h0000000000000000);
write_dmem(7'h26, 64'h0000000000000000);
write_dmem(7'h27, 64'h00000000000000AD);
write_dmem(7'h28, 64'hFD66000000000000);
write_dmem(7'h29, 64'h0000000000000000);
write_dmem(7'h2A, 64'h0000000000000000);
write_dmem(7'h2B, 64'h000000FDFCDFCBCB);
write_dmem(7'h2C, 64'hCB52000000000000);
write_dmem(7'h2D, 64'h0000000000000000);
write_dmem(7'h2E, 64'h0000000000007BFE);
write_dmem(7'h2F, 64'hFDE0CBCBDFFE4700);
write_dmem(7'h30, 64'h0000000000000000);
write_dmem(7'h31, 64'h0000000000000000);
write_dmem(7'h32, 64'h0029F3FD82140000);
write_dmem(7'h33, 64'h14FDE82900000000);
write_dmem(7'h34, 64'h0000000000000000);
write_dmem(7'h35, 64'h000000000098FDB7);
write_dmem(7'h36, 64'h000000000084FD66);
write_dmem(7'h37, 64'h0000000000000000);
write_dmem(7'h38, 64'h0000000000000000);
write_dmem(7'h39, 64'h0033971400000000);
write_dmem(7'h3A, 64'h0033FC6600000000);
write_dmem(7'h3B, 64'h0000000000000000);
write_dmem(7'h3C, 64'h0000000000150000);
write_dmem(7'h3D, 64'h000000000071FD66);
write_dmem(7'h3E, 64'h0000000000000000);
write_dmem(7'h3F, 64'h0000000000000000);
write_dmem(7'h40, 64'h52B7000000000000);
write_dmem(7'h41, 64'h00C1FC6600000000);
write_dmem(7'h42, 64'h0000000000000000);
write_dmem(7'h43, 64'h00000000CBB70000);
write_dmem(7'h44, 64'h0000000015FEFD29);
write_dmem(7'h45, 64'h0000000000000000);
write_dmem(7'h46, 64'h0000000000000015);
write_dmem(7'h47, 64'hDF66000000000015);
write_dmem(7'h48, 64'hCBFD820000000000);
write_dmem(7'h49, 64'h0000000000000000);
write_dmem(7'h4A, 64'h00000000CC7B0000);
write_dmem(7'h4B, 64'h000029ADFDCB1400);
write_dmem(7'h4C, 64'h0000000000000000);
write_dmem(7'h4D, 64'h0000000000000000);
write_dmem(7'h4E, 64'hA2DF661566A3F3FD);
write_dmem(7'h4F, 64'hAB14000000000000);
write_dmem(7'h50, 64'h0000000000000000);
write_dmem(7'h51, 64'h0000000029EAFDFF);
write_dmem(7'h52, 64'hFDFFAC5200000000);
write_dmem(7'h53, 64'h0000000000000000);
write_dmem(7'h54, 64'h0000000000000000);
write_dmem(7'h55, 64'h001E83C06F320A00);
write_dmem(7'h56, 64'h0000000000000000);
write_dmem(7'h57, 64'h0000000000000000);
write_dmem(7'h58, 64'h0000000000000000);
write_dmem(7'h59, 64'h0000000000000000);
write_dmem(7'h5A, 64'h0000000000000000);
write_dmem(7'h5B, 64'h0000000000000000);
write_dmem(7'h5C, 64'h0000000000000000);
write_dmem(7'h5D, 64'h0000000000000000);
write_dmem(7'h5E, 64'h0000000000000000);
write_dmem(7'h5F, 64'h0000000000000000);
write_dmem(7'h60, 64'h0000000000000000);
write_dmem(7'h61, 64'h0000000000000000);
write_dmem(7'h62, 64'h0000000000000000);
write_dmem(7'h63, 64'h0000000000000000);
write_dmem(7'h64, 64'h0D481CE8BE3A19F2);
write_dmem(7'h65, 64'h05E33E291CFFD736);
write_dmem(7'h66, 64'h575648A798EED444);
write_dmem(7'h67, 64'h7F00DDDC0B33CDC4);
write_dmem(7'h68, 64'h195377E734777F72);
write_dmem(7'h69, 64'h42363906F9D9BC86);
write_dmem(7'h6A, 64'h9C9AE1150E01E801);
write_dmem(7'h6B, 64'h03FBF4EFC01A2EE3);
write_dmem(7'h6C, 64'hEC24E7FDD4EEDE06);
write_dmem(7'h6D, 64'h1518AA34EBD6A77F);
write_dmem(7'h6E, 64'hD303000EFDECD6E6);
write_dmem(7'h6F, 64'hEC00DB0AF511FF25);
write_dmem(7'h70, 64'h0724110A02E7F201);
write_dmem(7'h71, 64'h1324DB20FCE2EBEE);
write_dmem(7'h72, 64'h0C17DFC6C9DE09F6);
write_dmem(7'h73, 64'h0AF345F4091104DD);
write_dmem(7'h74, 64'h1FD3F808DA352309);
write_dmem(7'h75, 64'h05FF08FDE6D414EA);
write_dmem(7'h76, 64'hEE16CEC9D6E7E7FD);
write_dmem(7'h77, 64'hD7F3FEF3E70A3131);
write_dmem(7'h78, 64'hFD2F3612FE11F401);
write_dmem(7'h79, 64'h29F609DC0C1AD0CA);
write_dmem(7'h7A, 64'h29C0F7FB06F230FC);
write_dmem(7'h7B, 64'hE711EA0006F71717);
write_dmem(7'h7C, 64'hD7E8FDFB0FE00618);
write_dmem(7'h7D, 64'h07FE27E41107F3CF);
write_dmem(7'h7E, 64'h0FC8000000000000);
write_dmem(7'h7F, 64'h0000000000000000);
	end
	endtask
	
	task inference_6;
	begin
		write_dmem(7'h00, 64'h0000000000000000);
write_dmem(7'h01, 64'h0000000000000000);
write_dmem(7'h02, 64'h0000000000000000);
write_dmem(7'h03, 64'h0000000000000000);
write_dmem(7'h04, 64'h0000000000000000);
write_dmem(7'h05, 64'h0000000000000000);
write_dmem(7'h06, 64'h0000000000000000);
write_dmem(7'h07, 64'h0000000000000000);
write_dmem(7'h08, 64'h0000000265930000);
write_dmem(7'h09, 64'h0000000000000000);
write_dmem(7'h0A, 64'h0000000000000000);
write_dmem(7'h0B, 64'h0000000000000028);
write_dmem(7'h0C, 64'hFCAF000000000000);
write_dmem(7'h0D, 64'h0000000000000000);
write_dmem(7'h0E, 64'h0000000000000000);
write_dmem(7'h0F, 64'h000000D5FC840000);
write_dmem(7'h10, 64'h0000000000000000);
write_dmem(7'h11, 64'h0000000000000000);
write_dmem(7'h12, 64'h00000000000593FA);
write_dmem(7'h13, 64'h8F03000000000000);
write_dmem(7'h14, 64'h0000000000000000);
write_dmem(7'h15, 64'h0000000000000000);
write_dmem(7'h16, 64'h0050FC6200000000);
write_dmem(7'h17, 64'h0000000000000000);
write_dmem(7'h18, 64'h0000000000000000);
write_dmem(7'h19, 64'h0000000000A5DD0E);
write_dmem(7'h1A, 64'h0000000000000014);
write_dmem(7'h1B, 64'h1300000000000000);
write_dmem(7'h1C, 64'h0000000000000000);
write_dmem(7'h1D, 64'h4AF36E0000000000);
write_dmem(7'h1E, 64'h000A7FECECAD0000);
write_dmem(7'h1F, 64'h0000000000000000);
write_dmem(7'h20, 64'h0000000097C50000);
write_dmem(7'h21, 64'h000000003CECFCFC);
write_dmem(7'h22, 64'hFCF83D0000000000);
write_dmem(7'h23, 64'h0000000000000000);
write_dmem(7'h24, 64'hF2A300000000000B);
write_dmem(7'h25, 64'hC7FCA842D4F94500);
write_dmem(7'h26, 64'h0000000000000000);
write_dmem(7'h27, 64'h0000002CE30C0000);
write_dmem(7'h28, 64'h000000B1FCA60200);
write_dmem(7'h29, 64'hC6F1000000000000);
write_dmem(7'h2A, 64'h00000000000000A2);
write_dmem(7'h2B, 64'hD900000000003FFF);
write_dmem(7'h2C, 64'hC913000097F20000);
write_dmem(7'h2D, 64'h0000000000000000);
write_dmem(7'h2E, 64'h000000D195000000);
write_dmem(7'h2F, 64'h0000BBFD4D000000);
write_dmem(7'h30, 64'hC6A4000000000000);
write_dmem(7'h31, 64'h00000000000000D1);
write_dmem(7'h32, 64'hBB0000000000DCE2);
write_dmem(7'h33, 64'h0D00002EF3830000);
write_dmem(7'h34, 64'h0000000000000000);
write_dmem(7'h35, 64'h000000D179000000);
write_dmem(7'h36, 64'h0029EDD300000CCE);
write_dmem(7'h37, 64'hFC1A000000000000);
write_dmem(7'h38, 64'h00000000000000D1);
write_dmem(7'h39, 64'hC0000000004EFC6F);
write_dmem(7'h3A, 64'h000077FCAA080000);
write_dmem(7'h3B, 64'h0000000000000000);
write_dmem(7'h3C, 64'h000000D1E6000000);
write_dmem(7'h3D, 64'h004EFC6F004FFAFC);
write_dmem(7'h3E, 64'h3700000000000000);
write_dmem(7'h3F, 64'h0000000000000069);
write_dmem(7'h40, 64'hFA840000004EFCA4);
write_dmem(7'h41, 64'h28DDED3C05000000);
write_dmem(7'h42, 64'h0000000000000000);
write_dmem(7'h43, 64'h00000000AFE79A0D);
write_dmem(7'h44, 64'h0061FCFDFCFC7900);
write_dmem(7'h45, 64'h0000000000000000);
write_dmem(7'h46, 64'h0000000000000000);
write_dmem(7'h47, 64'h5CE2FCC1BBECFCFD);
write_dmem(7'h48, 64'hFCFC570000000000);
write_dmem(7'h49, 64'h0000000000000000);
write_dmem(7'h4A, 64'h00000000002E8EF3);
write_dmem(7'h4B, 64'hFCDB8E9DDF640200);
write_dmem(7'h4C, 64'h0000000000000000);
write_dmem(7'h4D, 64'h0000000000000000);
write_dmem(7'h4E, 64'h0000000000000000);
write_dmem(7'h4F, 64'h0000000000000000);
write_dmem(7'h50, 64'h0000000000000000);
write_dmem(7'h51, 64'h0000000000000000);
write_dmem(7'h52, 64'h0000000000000000);
write_dmem(7'h53, 64'h0000000000000000);
write_dmem(7'h54, 64'h0000000000000000);
write_dmem(7'h55, 64'h0000000000000000);
write_dmem(7'h56, 64'h0000000000000000);
write_dmem(7'h57, 64'h0000000000000000);
write_dmem(7'h58, 64'h0000000000000000);
write_dmem(7'h59, 64'h0000000000000000);
write_dmem(7'h5A, 64'h0000000000000000);
write_dmem(7'h5B, 64'h0000000000000000);
write_dmem(7'h5C, 64'h0000000000000000);
write_dmem(7'h5D, 64'h0000000000000000);
write_dmem(7'h5E, 64'h0000000000000000);
write_dmem(7'h5F, 64'h0000000000000000);
write_dmem(7'h60, 64'h0000000000000000);
write_dmem(7'h61, 64'h0000000000000000);
write_dmem(7'h62, 64'h0000000000000000);
write_dmem(7'h63, 64'h0000000000000000);
write_dmem(7'h64, 64'h0D481CE8BE3A19F2);
write_dmem(7'h65, 64'h05E33E291CFFD736);
write_dmem(7'h66, 64'h575648A798EED444);
write_dmem(7'h67, 64'h7F00DDDC0B33CDC4);
write_dmem(7'h68, 64'h195377E734777F72);
write_dmem(7'h69, 64'h42363906F9D9BC86);
write_dmem(7'h6A, 64'h9C9AE1150E01E801);
write_dmem(7'h6B, 64'h03FBF4EFC01A2EE3);
write_dmem(7'h6C, 64'hEC24E7FDD4EEDE06);
write_dmem(7'h6D, 64'h1518AA34EBD6A77F);
write_dmem(7'h6E, 64'hD303000EFDECD6E6);
write_dmem(7'h6F, 64'hEC00DB0AF511FF25);
write_dmem(7'h70, 64'h0724110A02E7F201);
write_dmem(7'h71, 64'h1324DB20FCE2EBEE);
write_dmem(7'h72, 64'h0C17DFC6C9DE09F6);
write_dmem(7'h73, 64'h0AF345F4091104DD);
write_dmem(7'h74, 64'h1FD3F808DA352309);
write_dmem(7'h75, 64'h05FF08FDE6D414EA);
write_dmem(7'h76, 64'hEE16CEC9D6E7E7FD);
write_dmem(7'h77, 64'hD7F3FEF3E70A3131);
write_dmem(7'h78, 64'hFD2F3612FE11F401);
write_dmem(7'h79, 64'h29F609DC0C1AD0CA);
write_dmem(7'h7A, 64'h29C0F7FB06F230FC);
write_dmem(7'h7B, 64'hE711EA0006F71717);
write_dmem(7'h7C, 64'hD7E8FDFB0FE00618);
write_dmem(7'h7D, 64'h07FE27E41107F3CF);
write_dmem(7'h7E, 64'h0FC8000000000000);
write_dmem(7'h7F, 64'h0000000000000000);
	end
	endtask
	
	task inference_7;
	begin
		write_dmem(7'h00, 64'h0000000000000000);
write_dmem(7'h01, 64'h0000000000000000);
write_dmem(7'h02, 64'h0000000000000000);
write_dmem(7'h03, 64'h0000000000000000);
write_dmem(7'h04, 64'h0000000000000000);
write_dmem(7'h05, 64'h0000000000000000);
write_dmem(7'h06, 64'h0000000000000000);
write_dmem(7'h07, 64'h0000000000000000);
write_dmem(7'h08, 64'h0000000000000000);
write_dmem(7'h09, 64'h0000000000000000);
write_dmem(7'h0A, 64'h0000000000000000);
write_dmem(7'h0B, 64'h0000000000000000);
write_dmem(7'h0C, 64'h0000000000000000);
write_dmem(7'h0D, 64'h0000000000000000);
write_dmem(7'h0E, 64'h0000000000000000);
write_dmem(7'h0F, 64'h0000000000000000);
write_dmem(7'h10, 64'h0000000000000000);
write_dmem(7'h11, 64'h0000000000000000);
write_dmem(7'h12, 64'h0000000000000000);
write_dmem(7'h13, 64'h0000000000000000);
write_dmem(7'h14, 64'h0000000000000000);
write_dmem(7'h15, 64'h0000000000000000);
write_dmem(7'h16, 64'h0000000000000000);
write_dmem(7'h17, 64'h0000000000000000);
write_dmem(7'h18, 64'h0000000000000027);
write_dmem(7'h19, 64'hFADD8C3030240000);
write_dmem(7'h1A, 64'h0000000000000000);
write_dmem(7'h1B, 64'h0000000000000000);
write_dmem(7'h1C, 64'h000000007EFEFEFE);
write_dmem(7'h1D, 64'hFEF1C6C6C6C6C6C6);
write_dmem(7'h1E, 64'hC6C6C6C223000000);
write_dmem(7'h1F, 64'h0000000000000000);
write_dmem(7'h20, 64'h022C728FDAE3FFFE);
write_dmem(7'h21, 64'hFEDBDADADAFBFEEE);
write_dmem(7'h22, 64'h5000000000000000);
write_dmem(7'h23, 64'h0000000000000000);
write_dmem(7'h24, 64'h0011434343020000);
write_dmem(7'h25, 64'h00E5FE6A00000000);
write_dmem(7'h26, 64'h0000000000000000);
write_dmem(7'h27, 64'h0000000000000000);
write_dmem(7'h28, 64'h0000000000E5FE24);
write_dmem(7'h29, 64'h0000000000000000);
write_dmem(7'h2A, 64'h0000000000000000);
write_dmem(7'h2B, 64'h0000000000000000);
write_dmem(7'h2C, 64'h37F7EB1A00000000);
write_dmem(7'h2D, 64'h0000000000000000);
write_dmem(7'h2E, 64'h0000000000000000);
write_dmem(7'h2F, 64'h0000000080FE8900);
write_dmem(7'h30, 64'h0000000000000000);
write_dmem(7'h31, 64'h0000000000000000);
write_dmem(7'h32, 64'h0000000000000015);
write_dmem(7'h33, 64'hE6FE530000000000);
write_dmem(7'h34, 64'h0000000000000000);
write_dmem(7'h35, 64'h0000000000000000);
write_dmem(7'h36, 64'h00000020FEFE5100);
write_dmem(7'h37, 64'h0000000000000000);
write_dmem(7'h38, 64'h0000000000000000);
write_dmem(7'h39, 64'h0000000000000020);
write_dmem(7'h3A, 64'hFEEA000000000000);
write_dmem(7'h3B, 64'h0000000000000000);
write_dmem(7'h3C, 64'h0000000000000000);
write_dmem(7'h3D, 64'h00000049FE960000);
write_dmem(7'h3E, 64'h0000000000000000);
write_dmem(7'h3F, 64'h0000000000000000);
write_dmem(7'h40, 64'h0000000000000098);
write_dmem(7'h41, 64'hFE46000000000000);
write_dmem(7'h42, 64'h0000000000000000);
write_dmem(7'h43, 64'h0000000000000000);
write_dmem(7'h44, 64'h00001FF5FE1A0000);
write_dmem(7'h45, 64'h0000000000000000);
write_dmem(7'h46, 64'h0000000000000000);
write_dmem(7'h47, 64'h00000000000059FE);
write_dmem(7'h48, 64'hF516000000000000);
write_dmem(7'h49, 64'h0000000000000000);
write_dmem(7'h4A, 64'h0000000000000000);
write_dmem(7'h4B, 64'h000059FEB0000000);
write_dmem(7'h4C, 64'h0000000000000000);
write_dmem(7'h4D, 64'h0000000000000000);
write_dmem(7'h4E, 64'h00000000000059FE);
write_dmem(7'h4F, 64'hB000000000000000);
write_dmem(7'h50, 64'h0000000000000000);
write_dmem(7'h51, 64'h0000000000000000);
write_dmem(7'h52, 64'h000059FEC5070000);
write_dmem(7'h53, 64'h0000000000000000);
write_dmem(7'h54, 64'h0000000000000000);
write_dmem(7'h55, 64'h00000000000059FE);
write_dmem(7'h56, 64'hFE1A000000000000);
write_dmem(7'h57, 64'h0000000000000000);
write_dmem(7'h58, 64'h0000000000000000);
write_dmem(7'h59, 64'h000045FBFE1A0000);
write_dmem(7'h5A, 64'h0000000000000000);
write_dmem(7'h5B, 64'h0000000000000000);
write_dmem(7'h5C, 64'h0000000000000064);
write_dmem(7'h5D, 64'hC10F000000000000);
write_dmem(7'h5E, 64'h0000000000000000);
write_dmem(7'h5F, 64'h0000000000000000);
write_dmem(7'h60, 64'h0000000000000000);
write_dmem(7'h61, 64'h0000000000000000);
write_dmem(7'h62, 64'h0000000000000000);
write_dmem(7'h63, 64'h0000000000000000);
write_dmem(7'h64, 64'h0D481CE8BE3A19F2);
write_dmem(7'h65, 64'h05E33E291CFFD736);
write_dmem(7'h66, 64'h575648A798EED444);
write_dmem(7'h67, 64'h7F00DDDC0B33CDC4);
write_dmem(7'h68, 64'h195377E734777F72);
write_dmem(7'h69, 64'h42363906F9D9BC86);
write_dmem(7'h6A, 64'h9C9AE1150E01E801);
write_dmem(7'h6B, 64'h03FBF4EFC01A2EE3);
write_dmem(7'h6C, 64'hEC24E7FDD4EEDE06);
write_dmem(7'h6D, 64'h1518AA34EBD6A77F);
write_dmem(7'h6E, 64'hD303000EFDECD6E6);
write_dmem(7'h6F, 64'hEC00DB0AF511FF25);
write_dmem(7'h70, 64'h0724110A02E7F201);
write_dmem(7'h71, 64'h1324DB20FCE2EBEE);
write_dmem(7'h72, 64'h0C17DFC6C9DE09F6);
write_dmem(7'h73, 64'h0AF345F4091104DD);
write_dmem(7'h74, 64'h1FD3F808DA352309);
write_dmem(7'h75, 64'h05FF08FDE6D414EA);
write_dmem(7'h76, 64'hEE16CEC9D6E7E7FD);
write_dmem(7'h77, 64'hD7F3FEF3E70A3131);
write_dmem(7'h78, 64'hFD2F3612FE11F401);
write_dmem(7'h79, 64'h29F609DC0C1AD0CA);
write_dmem(7'h7A, 64'h29C0F7FB06F230FC);
write_dmem(7'h7B, 64'hE711EA0006F71717);
write_dmem(7'h7C, 64'hD7E8FDFB0FE00618);
write_dmem(7'h7D, 64'h07FE27E41107F3CF);
write_dmem(7'h7E, 64'h0FC8000000000000);
write_dmem(7'h7F, 64'h0000000000000000);
	end
	endtask
	
	task inference_8;
	begin
		write_dmem(7'h00, 64'h0000000000000000);
write_dmem(7'h01, 64'h0000000000000000);
write_dmem(7'h02, 64'h0000000000000000);
write_dmem(7'h03, 64'h0000000000000000);
write_dmem(7'h04, 64'h0000000000000000);
write_dmem(7'h05, 64'h0000000000000000);
write_dmem(7'h06, 64'h0000000000000000);
write_dmem(7'h07, 64'h0000000000000000);
write_dmem(7'h08, 64'h0000000000000000);
write_dmem(7'h09, 64'h0000000000000000);
write_dmem(7'h0A, 64'h0000000000000000);
write_dmem(7'h0B, 64'h0000000000000000);
write_dmem(7'h0C, 64'h0000000000000000);
write_dmem(7'h0D, 64'h0000000000000000);
write_dmem(7'h0E, 64'h0000000000000000);
write_dmem(7'h0F, 64'h0000000000000000);
write_dmem(7'h10, 64'h0000000000000000);
write_dmem(7'h11, 64'h0000000000000000);
write_dmem(7'h12, 64'h0000000000000000);
write_dmem(7'h13, 64'h00002B94F5FD6800);
write_dmem(7'h14, 64'h0000000000000000);
write_dmem(7'h15, 64'h0000000000000000);
write_dmem(7'h16, 64'h747400000074E3FC);
write_dmem(7'h17, 64'hFCFCE20000000000);
write_dmem(7'h18, 64'h0000000000000000);
write_dmem(7'h19, 64'h000000009EFAC51E);
write_dmem(7'h1A, 64'hA2F0D67E7ED2F400);
write_dmem(7'h1B, 64'h0000000000000000);
write_dmem(7'h1C, 64'h0000000000000000);
write_dmem(7'h1D, 64'h23E3FCFC8B310000);
write_dmem(7'h1E, 64'h06BE930000000000);
write_dmem(7'h1F, 64'h0000000000000000);
write_dmem(7'h20, 64'h00000000002AE2FC);
write_dmem(7'h21, 64'h8000000099FC9300);
write_dmem(7'h22, 64'h0000000000000000);
write_dmem(7'h23, 64'h0000000000000000);
write_dmem(7'h24, 64'h000024E0FD68000F);
write_dmem(7'h25, 64'hEDC7120000000000);
write_dmem(7'h26, 64'h0000000000000000);
write_dmem(7'h27, 64'h0000000000000029);
write_dmem(7'h28, 64'hE0E255B9FC540000);
write_dmem(7'h29, 64'h0000000000000000);
write_dmem(7'h2A, 64'h0000000000000000);
write_dmem(7'h2B, 64'h000000006FF9FDFC);
write_dmem(7'h2C, 64'hE007000000000000);
write_dmem(7'h2D, 64'h0000000000000000);
write_dmem(7'h2E, 64'h0000000000000000);
write_dmem(7'h2F, 64'h00D3FDFC38000000);
write_dmem(7'h30, 64'h0000000000000000);
write_dmem(7'h31, 64'h0000000000000000);
write_dmem(7'h32, 64'h0000000062F6FDFC);
write_dmem(7'h33, 64'h9800000000000000);
write_dmem(7'h34, 64'h0000000000000000);
write_dmem(7'h35, 64'h0000000000000065);
write_dmem(7'h36, 64'hFDEC96C7FD540000);
write_dmem(7'h37, 64'h0000000000000000);
write_dmem(7'h38, 64'h0000000000000000);
write_dmem(7'h39, 64'h00001DEFFC700015);
write_dmem(7'h3A, 64'hEDA3000000000000);
write_dmem(7'h3B, 64'h0000000000000000);
write_dmem(7'h3C, 64'h000000000016D5FC);
write_dmem(7'h3D, 64'h8D0400007FF75C00);
write_dmem(7'h3E, 64'h0000000000000000);
write_dmem(7'h3F, 64'h0000000000000000);
write_dmem(7'h40, 64'h0045FC8D1C000000);
write_dmem(7'h41, 64'h07C4AD0000000000);
write_dmem(7'h42, 64'h0000000000000000);
write_dmem(7'h43, 64'h0000000000C0FC15);
write_dmem(7'h44, 64'h00000000007EFC00);
write_dmem(7'h45, 64'h0000000000000000);
write_dmem(7'h46, 64'h0000000000000000);
write_dmem(7'h47, 64'h00FF970000000000);
write_dmem(7'h48, 64'h0052FD5900000000);
write_dmem(7'h49, 64'h0000000000000000);
write_dmem(7'h4A, 64'h0000000000FD6200);
write_dmem(7'h4B, 64'h0000000008C5D900);
write_dmem(7'h4C, 64'h0000000000000000);
write_dmem(7'h4D, 64'h0000000000000000);
write_dmem(7'h4E, 64'h0093D21C00000D39);
write_dmem(7'h4F, 64'hB5FC8A0000000000);
write_dmem(7'h50, 64'h0000000000000000);
write_dmem(7'h51, 64'h00000000000EA3F0);
write_dmem(7'h52, 64'hA9A9DAFCDD770E00);
write_dmem(7'h53, 64'h0000000000000000);
write_dmem(7'h54, 64'h0000000000000000);
write_dmem(7'h55, 64'h0000005C93BF9344);
write_dmem(7'h56, 64'h1500000000000000);
write_dmem(7'h57, 64'h0000000000000000);
write_dmem(7'h58, 64'h0000000000000000);
write_dmem(7'h59, 64'h0000000000000000);
write_dmem(7'h5A, 64'h0000000000000000);
write_dmem(7'h5B, 64'h0000000000000000);
write_dmem(7'h5C, 64'h0000000000000000);
write_dmem(7'h5D, 64'h0000000000000000);
write_dmem(7'h5E, 64'h0000000000000000);
write_dmem(7'h5F, 64'h0000000000000000);
write_dmem(7'h60, 64'h0000000000000000);
write_dmem(7'h61, 64'h0000000000000000);
write_dmem(7'h62, 64'h0000000000000000);
write_dmem(7'h63, 64'h0000000000000000);
write_dmem(7'h64, 64'h0D481CE8BE3A19F2);
write_dmem(7'h65, 64'h05E33E291CFFD736);
write_dmem(7'h66, 64'h575648A798EED444);
write_dmem(7'h67, 64'h7F00DDDC0B33CDC4);
write_dmem(7'h68, 64'h195377E734777F72);
write_dmem(7'h69, 64'h42363906F9D9BC86);
write_dmem(7'h6A, 64'h9C9AE1150E01E801);
write_dmem(7'h6B, 64'h03FBF4EFC01A2EE3);
write_dmem(7'h6C, 64'hEC24E7FDD4EEDE06);
write_dmem(7'h6D, 64'h1518AA34EBD6A77F);
write_dmem(7'h6E, 64'hD303000EFDECD6E6);
write_dmem(7'h6F, 64'hEC00DB0AF511FF25);
write_dmem(7'h70, 64'h0724110A02E7F201);
write_dmem(7'h71, 64'h1324DB20FCE2EBEE);
write_dmem(7'h72, 64'h0C17DFC6C9DE09F6);
write_dmem(7'h73, 64'h0AF345F4091104DD);
write_dmem(7'h74, 64'h1FD3F808DA352309);
write_dmem(7'h75, 64'h05FF08FDE6D414EA);
write_dmem(7'h76, 64'hEE16CEC9D6E7E7FD);
write_dmem(7'h77, 64'hD7F3FEF3E70A3131);
write_dmem(7'h78, 64'hFD2F3612FE11F401);
write_dmem(7'h79, 64'h29F609DC0C1AD0CA);
write_dmem(7'h7A, 64'h29C0F7FB06F230FC);
write_dmem(7'h7B, 64'hE711EA0006F71717);
write_dmem(7'h7C, 64'hD7E8FDFB0FE00618);
write_dmem(7'h7D, 64'h07FE27E41107F3CF);
write_dmem(7'h7E, 64'h0FC8000000000000);
write_dmem(7'h7F, 64'h0000000000000000);
	end
	endtask

	task inference_9;
	begin
		write_dmem(7'h00, 64'h0000000000000000);
write_dmem(7'h01, 64'h0000000000000000);
write_dmem(7'h02, 64'h0000000000000000);
write_dmem(7'h03, 64'h0000000000000000);
write_dmem(7'h04, 64'h0000000000000000);
write_dmem(7'h05, 64'h0000000000000000);
write_dmem(7'h06, 64'h0000000000000000);
write_dmem(7'h07, 64'h0000000000000000);
write_dmem(7'h08, 64'h0000000000000000);
write_dmem(7'h09, 64'h0000000000000000);
write_dmem(7'h0A, 64'h0000000000000000);
write_dmem(7'h0B, 64'h0000000000000000);
write_dmem(7'h0C, 64'h0000000000000000);
write_dmem(7'h0D, 64'h0000000000000000);
write_dmem(7'h0E, 64'h0000000000000000);
write_dmem(7'h0F, 64'h0000000000000000);
write_dmem(7'h10, 64'h0000000000000000);
write_dmem(7'h11, 64'h0000000000000000);
write_dmem(7'h12, 64'h0000000000000000);
write_dmem(7'h13, 64'h0000000000000000);
write_dmem(7'h14, 64'h0000000000000000);
write_dmem(7'h15, 64'h0000000000000000);
write_dmem(7'h16, 64'h0000000000000046);
write_dmem(7'h17, 64'hCAFF7E0200000000);
write_dmem(7'h18, 64'h0000000000000000);
write_dmem(7'h19, 64'h0000000000000000);
write_dmem(7'h1A, 64'h000048EFFDFDFD0A);
write_dmem(7'h1B, 64'h0000000000000000);
write_dmem(7'h1C, 64'h0000000000000000);
write_dmem(7'h1D, 64'h000000000011F2FD);
write_dmem(7'h1E, 64'hC1A6FD0D00000000);
write_dmem(7'h1F, 64'h0000000000000000);
write_dmem(7'h20, 64'h0000000000000000);
write_dmem(7'h21, 64'h34CAFDB4073CFD77);
write_dmem(7'h22, 64'h0000000000000000);
write_dmem(7'h23, 64'h0000000000000000);
write_dmem(7'h24, 64'h00000048D3F8670E);
write_dmem(7'h25, 64'h003CFD9900000000);
write_dmem(7'h26, 64'h0000000000000000);
write_dmem(7'h27, 64'h00000000000042F4);
write_dmem(7'h28, 64'hFA8600097BE9FDAF);
write_dmem(7'h29, 64'h0000000000000000);
write_dmem(7'h2A, 64'h0000000000000000);
write_dmem(7'h2B, 64'h0010E8FD92349DE9);
write_dmem(7'h2C, 64'hFDFDFD3400000000);
write_dmem(7'h2D, 64'h0000000000000000);
write_dmem(7'h2E, 64'h000000000036F5FD);
write_dmem(7'h2F, 64'hD0F9FDFDFDFDDC07);
write_dmem(7'h30, 64'h0000000000000000);
write_dmem(7'h31, 64'h0000000000000000);
write_dmem(7'h32, 64'h0000DCFDFDF0FDFD);
write_dmem(7'h33, 64'hFCBA0D0000000000);
write_dmem(7'h34, 64'h0000000000000000);
write_dmem(7'h35, 64'h0000000000002B5C);
write_dmem(7'h36, 64'h5C2FFDFD8B000000);
write_dmem(7'h37, 64'h0000000000000000);
write_dmem(7'h38, 64'h0000000000000000);
write_dmem(7'h39, 64'h0000000000A4FD8D);
write_dmem(7'h3A, 64'h0400000000000000);
write_dmem(7'h3B, 64'h0000000000000000);
write_dmem(7'h3C, 64'h0000000000000000);
write_dmem(7'h3D, 64'h52FCFD3600000000);
write_dmem(7'h3E, 64'h0000000000000000);
write_dmem(7'h3F, 64'h0000000000000000);
write_dmem(7'h40, 64'h000000009EFDD912);
write_dmem(7'h41, 64'h0000000000000000);
write_dmem(7'h42, 64'h0000000000000000);
write_dmem(7'h43, 64'h0000000000000028);
write_dmem(7'h44, 64'hF2F74D0000000000);
write_dmem(7'h45, 64'h0000000000000000);
write_dmem(7'h46, 64'h0000000000000000);
write_dmem(7'h47, 64'h00000099FDE20000);
write_dmem(7'h48, 64'h0000000000000000);
write_dmem(7'h49, 64'h0000000000000000);
write_dmem(7'h4A, 64'h00000000000008DF);
write_dmem(7'h4B, 64'hFD66000000000000);
write_dmem(7'h4C, 64'h0000000000000000);
write_dmem(7'h4D, 64'h0000000000000000);
write_dmem(7'h4E, 64'h00000BFDFD150000);
write_dmem(7'h4F, 64'h0000000000000000);
write_dmem(7'h50, 64'h0000000000000000);
write_dmem(7'h51, 64'h00000000000076FD);
write_dmem(7'h52, 64'hFD3A763600000000);
write_dmem(7'h53, 64'h0000000000000000);
write_dmem(7'h54, 64'h0000000000000000);
write_dmem(7'h55, 64'h00002BFDFDFDEE27);
write_dmem(7'h56, 64'h0000000000000000);
write_dmem(7'h57, 64'h0000000000000000);
write_dmem(7'h58, 64'h00000000000002AB);
write_dmem(7'h59, 64'hFDC8440000000000);
write_dmem(7'h5A, 64'h0000000000000000);
write_dmem(7'h5B, 64'h0000000000000000);
write_dmem(7'h5C, 64'h0000000000000000);
write_dmem(7'h5D, 64'h0000000000000000);
write_dmem(7'h5E, 64'h0000000000000000);
write_dmem(7'h5F, 64'h0000000000000000);
write_dmem(7'h60, 64'h0000000000000000);
write_dmem(7'h61, 64'h0000000000000000);
write_dmem(7'h62, 64'h0000000000000000);
write_dmem(7'h63, 64'h0000000000000000);
write_dmem(7'h64, 64'h0D481CE8BE3A19F2);
write_dmem(7'h65, 64'h05E33E291CFFD736);
write_dmem(7'h66, 64'h575648A798EED444);
write_dmem(7'h67, 64'h7F00DDDC0B33CDC4);
write_dmem(7'h68, 64'h195377E734777F72);
write_dmem(7'h69, 64'h42363906F9D9BC86);
write_dmem(7'h6A, 64'h9C9AE1150E01E801);
write_dmem(7'h6B, 64'h03FBF4EFC01A2EE3);
write_dmem(7'h6C, 64'hEC24E7FDD4EEDE06);
write_dmem(7'h6D, 64'h1518AA34EBD6A77F);
write_dmem(7'h6E, 64'hD303000EFDECD6E6);
write_dmem(7'h6F, 64'hEC00DB0AF511FF25);
write_dmem(7'h70, 64'h0724110A02E7F201);
write_dmem(7'h71, 64'h1324DB20FCE2EBEE);
write_dmem(7'h72, 64'h0C17DFC6C9DE09F6);
write_dmem(7'h73, 64'h0AF345F4091104DD);
write_dmem(7'h74, 64'h1FD3F808DA352309);
write_dmem(7'h75, 64'h05FF08FDE6D414EA);
write_dmem(7'h76, 64'hEE16CEC9D6E7E7FD);
write_dmem(7'h77, 64'hD7F3FEF3E70A3131);
write_dmem(7'h78, 64'hFD2F3612FE11F401);
write_dmem(7'h79, 64'h29F609DC0C1AD0CA);
write_dmem(7'h7A, 64'h29C0F7FB06F230FC);
write_dmem(7'h7B, 64'hE711EA0006F71717);
write_dmem(7'h7C, 64'hD7E8FDFB0FE00618);
write_dmem(7'h7D, 64'h07FE27E41107F3CF);
write_dmem(7'h7E, 64'h0FC8000000000000);
write_dmem(7'h7F, 64'h0000000000000000);
	end
	endtask
endmodule