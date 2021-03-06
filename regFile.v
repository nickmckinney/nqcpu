/*
 * 0-7: general purpose registers
 * 8: {program bank, data bank}
 */

module regFile (
	input clk,
	input [2:0] regA,
	input [2:0] regB,
	input [3:0] regDest,
	input [15:0] dataIn,
	input we,
	input hb,
	input lb,
	output [15:0] dataA,
	output [15:0] dataB,

	output [7:0] progBank,
	output [7:0] dataBank,

	output [15:0] dbg_r0,
	output [15:0] dbg_r1,
	output [15:0] dbg_r2,
	output [15:0] dbg_r3,
	output [15:0] dbg_r4,
	output [15:0] dbg_r5,
	output [15:0] dbg_r6,
	output [15:0] dbg_r7
);

	reg [15:0] register[16];
	
	assign dataA = register[regA];
	assign dataB = register[regB];

	assign progBank = register[8][15:8];
	assign dataBank = register[8][7:0];

	initial begin
		for(int i = 0; i < 16; i++) begin
			register[i] = 16'h0;
		end
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
