module shifter (
	input [15:0] v,      // number to shift
	input [15:0] by,     // bits to shift by
	input dir,           // 0 = left shift, 1 = right shift
	input [1:0] extend,  // 0 = zero extend, 1 = one extend, 2 = sign extend (or last bit), 3 = barrel shift
	output [15:0] result
);

	wire [47:0] x;
	
	assign x = {
		extend == 2'b00 ? 16'h0 :
		extend == 2'b01 ? 16'hFFFF :
		extend == 2'b10 ? {16{v[15]}} : v,

		v,

		extend == 2'b00 ? 16'h0 :
		extend == 2'b01 ? 16'hFFFF :
		extend == 2'b10 ? {16{v[0]}} : v
	};

	wire [15:0] barrelResult;
	wire [15:0] otherResult;

	wire [4:0] dirAndAmount;
	assign dirAndAmount = {dir, by[3:0]};
	
	assign barrelResult =
		|(by[15:4]) ? (dir == 1'b1 ? x[47:32] : x[15:0]) :
		dirAndAmount == 5'h1F ? x[46:31] :
		dirAndAmount == 5'h1E ? x[45:30] :
		dirAndAmount == 5'h1D ? x[44:29] :
		dirAndAmount == 5'h1C ? x[43:28] :
		dirAndAmount == 5'h1B ? x[42:27] :
		dirAndAmount == 5'h1A ? x[41:26] :
		dirAndAmount == 5'h19 ? x[40:25] :
		dirAndAmount == 5'h18 ? x[39:24] :
		dirAndAmount == 5'h17 ? x[38:23] :
		dirAndAmount == 5'h16 ? x[37:22] :
		dirAndAmount == 5'h15 ? x[36:21] :
		dirAndAmount == 5'h14 ? x[35:20] :
		dirAndAmount == 5'h13 ? x[34:19] :
		dirAndAmount == 5'h12 ? x[33:18] :
		dirAndAmount == 5'h11 ? x[32:17] :
		// zero shift is handled at the bottom
		dirAndAmount == 5'h01 ? x[30:15] :
		dirAndAmount == 5'h02 ? x[29:14] :
		dirAndAmount == 5'h03 ? x[28:13] :
		dirAndAmount == 5'h04 ? x[27:12] :
		dirAndAmount == 5'h05 ? x[26:11] :
		dirAndAmount == 5'h06 ? x[25:10] :
		dirAndAmount == 5'h07 ? x[24:9] :
		dirAndAmount == 5'h08 ? x[23:8] :
		dirAndAmount == 5'h09 ? x[22:7] :
		dirAndAmount == 5'h0A ? x[21:6] :
		dirAndAmount == 5'h0B ? x[20:5] :
		dirAndAmount == 5'h0C ? x[19:4] :
		dirAndAmount == 5'h0D ? x[18:3] :
		dirAndAmount == 5'h0E ? x[17:2] :
		dirAndAmount == 5'h0F ? x[16:1] :
		x[31:16];
		
	assign otherResult =
		|(by[15:4]) ? (dir == 1'b1 ? x[47:32] : x[15:0]) : barrelResult;
		
	assign result = extend == 2'b11 ? barrelResult : otherResult;
endmodule
