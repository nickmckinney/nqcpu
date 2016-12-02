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
	output [15:0] dataB
);

	reg [15:0] register[7];
	
	assign dataA = register[regA];
	assign dataB = register[regB];
	
	always @(posedge clk) begin
		if(we) begin
			register[regDest] <= {
				hb ? dataIn[15:8] : register[regDest][15:8],
				lb ? dataIn[7:0] : register[regDest][7:0]
			};
		end
	end
endmodule
