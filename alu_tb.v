`timescale 1 ns / 100 ps

module alu_tb ();
	reg [3:0] op;
	reg [15:0] x;
	reg [15:0] y;
	wire [15:0] result;
	reg [15:0] expected_result;
	wire zero;
	reg expected_zero;
	wire carry;
	reg expected_carry;

	initial begin
		x = 16'h0123;
		y = 16'h1234;
		
		op = 4'h0;  // add
		expected_result = 16'h1357;
		expected_zero = 1'b0;
		expected_carry = 1'b0;
		
		#2
		op = 4'h1;  // subtract
		expected_result = 16'hEEEF;
		expected_carry = 1'b1;
		expected_zero = 1'b0;
		
		#2
		y = 16'h0123;
		expected_result = 16'h0;
		expected_zero = 1'b1;
		expected_carry = 1'b0;
		
		#2
		y = 16'h1234;
		op = 4'h2;  // multiply
		expected_result = 16'hB11C;
		expected_zero = 1'b0;
		expected_carry = 1'b0;
		
		#2
		x = 16'h3E58;
		y = 16'h0078;
		op = 4'h3;  // divide
		expected_result = 16'h0085;
		
		#2
		x = 16'hAF74;
		y = 16'h7CC7;
		op = 4'h4;  // and
		expected_result = 16'h2C44;
		
		#2
		op = 4'h5;  // or
		expected_result = 16'hFFF7;
		
		#2
		op = 4'h6;  // xor
		expected_result = 16'hD3B3;
		
		#5
		$stop;
	end

	alu alu_inst (
		.op(op),
		.x(x),
		.y(y),
		.result(result),
		.zero(zero),
		.carry(carry)
	);
endmodule
