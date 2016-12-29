module regFile (
	input clk,
	input [2:0] regA,
	input [2:0] regB,
	input [2:0] regDest,
	input [15:0] dataIn,
	input we,
	input hb,
	input lb,
	output [15:0] dataA,
	output [15:0] dataB,
	
	output [15:0] dbg_r0,
	output [15:0] dbg_r1,
	output [15:0] dbg_r2,
	output [15:0] dbg_r3,
	output [15:0] dbg_r4,
	output [15:0] dbg_r5,
	output [15:0] dbg_r6,
	output [15:0] dbg_r7
);

	reg [15:0] register[8];
	
	assign dataA = register[regA];
	assign dataB = register[regB];
	
	initial begin
		register[0] = 16'h0;
		register[1] = 16'h0;
		register[2] = 16'h0;
		register[3] = 16'h0;
		register[4] = 16'h0;
		register[5] = 16'h0;
		register[6] = 16'h0;
		register[7] = 16'h0;
	end
	
	always @(posedge clk) begin
		if(we) begin
			register[regDest] <= {
				hb ? dataIn[15:8] : register[regDest][15:8],
				lb ? dataIn[7:0] : register[regDest][7:0]
			};
		end
	end
	
	assign dbg_r0 = register[0];
	assign dbg_r1 = register[1];
	assign dbg_r2 = register[2];
	assign dbg_r3 = register[3];
	assign dbg_r4 = register[4];
	assign dbg_r5 = register[5];
	assign dbg_r6 = register[6];
	assign dbg_r7 = register[7];
endmodule
