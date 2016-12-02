`timescale 1 ns / 100 ps

module shifter_tb ();
	reg [15:0] v;
	reg [15:0] by;
	reg dir;
	reg [1:0] extend;
	wire [15:0] result;
	reg [15:0] expected_result;
	
	// xxxxxxxxxxxxxxxx1111101000001010xxxxxxxxxxxxxxxx

	initial begin
		v = 16'hFA0A;
		by = 16'h0;
		dir = 1'b0;
		extend = 2'h0;
		expected_result = 16'hFA0A;

		#2
		by = 16'h1;
		expected_result = 16'hF414; // 1111 0100 0001 0100

		#2
		by = 16'h2;
		expected_result = 16'hE828; // 1110 1000 0010 1000

		#2
		dir = 1'b1;
		expected_result = 16'h3E82; // 0011 1110 1000 0010

		#2
		by = 16'h4;
		expected_result = 16'h0FA0; // 0000 1111 1010 0000

		#2
		dir = 1'b0;
		expected_result = 16'hA0A0; // 1010 0000 1010 0000

		#2
		extend = 2'h1;
		expected_result = 16'hA0AF; // 1010 0000 1010 1111

		#2
		dir = 1'b1;
		expected_result = 16'hFFA0; // 1111 1111 1010 0000

		#2
		extend = 2'h2;
		dir = 1'b0;
		expected_result = 16'hA0A0; // 1010 0000 1010 0000

		#2
		dir = 1'b1;
		expected_result = 16'hFFA0; // 1111 1111 1010 0000

		#2
		extend = 2'h3;
		expected_result = 16'hAFA0; // 1010 1111 1010 0000

		#2
		dir = 1'b0;
		expected_result = 16'hA0AF; // 1010 0000 1010 1111

		#2
		v = 16'h0001;
		extend = 2'h2;
		dir = 1'b0;
		by = 16'hE;
		expected_result = 16'h7FFF;
		
		#2
		by = 16'h10;
		expected_result = 16'hFFFF;
		
		#2
		dir = 1'b1;
		expected_result = 16'h0000;
		
		#2
		dir = 1'b0;
		by = 16'h1000;
		expected_result = 16'hFFFF;

		#2
		dir = 1'b1;
		expected_result = 16'h0000;
		
		#5
		$stop;
	end
	
	shifter shifter_inst (
		.v(v),
		.by(by),
		.dir(dir),
		.extend(extend),
		.result(result)
	);
endmodule
