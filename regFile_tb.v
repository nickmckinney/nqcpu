`timescale 1 ns / 100 ps

module regFile_tb ();

	reg clk;
	reg [2:0] regA;
	reg [2:0] regB;
	reg [2:0] regDest;
	reg [15:0] dataIn;
	reg we, hb, lb;
	wire [15:0] dataA;
	wire [15:0] dataB;
	
	initial begin
		clk = 1'b0;
		
		regA = 3'h0;
		regB = 3'h0;
		regDest = 3'h0;
		we = 1'b0;
		hb = 1'b0;
		lb = 1'b0;
		dataIn = 16'h0;
		
		#2
		regA = 3'h1;
		regDest = 3'h1;
		dataIn = 16'hDEAD;
		we = 1'b1;
		hb = 1'b1;
		lb = 1'b1;
		
		#2
		regB = 3'h1;
		regA = 3'h2;
		dataIn = 16'hBEEF;
		lb = 1'b0;
		
		#2
		lb = 1'b1;
		
		#2
		regDest = 3'h2;
		hb = 1'b0;
		dataIn = 16'h9876;
		
		#2
		hb = 1'b1;
		lb = 1'b0;
		dataIn = 16'h2345;
		
		#2
		regB = 3'h7;
		regDest = 3'h7;
		lb = 1'b0;
		hb = 1'b0;
		we = 1'b1;
		dataIn = 16'hFFCC;
		
		#2
		lb = 1'b1;
		hb = 1'b1;
		we = 1'b0;
		
		#5
		$stop;
	end
	
	always #1 clk = !clk;
	
	regFile regFile_inst (
		.clk(clk),
		.regA(regA),
		.regB(regB),
		.regDest(regDest),
		.dataIn(dataIn),
		.we(we),
		.hb(hb),
		.lb(lb),
		.dataA(dataA),
		.dataB(dataB)
	);
endmodule
