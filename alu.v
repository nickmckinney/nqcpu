module alu (
	input [3:0] op,
	input [15:0] x,
	input [15:0] y,
	output [15:0] result,
	output zero,
	output carry
);

// op:
//  0000: result = x + y
//  0001: result = x - y
//  0010: result = x * y
//  0011: result = x / y
//  0100: result = x & y
//  0101: result = x | y
//  0110: result = x ^ y
//  0111: result = x
//  1000: result = x << y (zero extend)
//  1001: result = x << y (one extend)
//  1010: result = x << y (extend with last bit)
//  1011: result = x << y (barrel shift)
//  1100: result = x >> y (zero extend)
//  1101: result = x >> y (one extend)
//  1110: result = x >> y (extend with sign bit)
//  1111: result = x >> y (barrel shift)

	wire [16:0] sum;
	wire [16:0] diff;
	wire [16:0] prod;
	wire [16:0] quot;
	wire [15:0] anded;
	wire [15:0] ored;
	wire [15:0] xored;
	wire [15:0] shifted;
	
	assign sum = x + y;
	assign diff = x - y;
	assign prod = x * y;
	assign quot = x / y;
	assign anded = x & y;
	assign ored = x | y;
	assign xored = x ^ y;
	
	shifter shifter_inst (
		.v(x),
		.by(y),
		.dir(op[2]),
		.extend(op[1:0]),
		.result(shifted)
	);
	
	assign result =
		op == 4'b0000 ? sum[15:0] :
		op == 4'b0001 ? diff[15:0] :
		op == 4'b0010 ? prod[15:0] :
		op == 4'b0011 ? quot[15:0] :
		op == 4'b0100 ? anded :
		op == 4'b0101 ? ored :
		op == 4'b0110 ? xored :
		op == 4'b0111 ? x :
		shifted;
	
	assign zero = ~(|result);
	assign carry =
		op == 4'b0000 ? sum[16] :
		op == 4'b0001 ? diff[16] : 1'b0;

endmodule
