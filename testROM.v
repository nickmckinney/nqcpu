module testROM (
	input clk,
	
	output needWait_o,
	input [20:0] addr_i,
	input re_i,
	inout [15:0] data_io
);

	reg read_finished;
	reg [15:0] romData;

	assign needWait_o = re_i & !read_finished;
	assign data_io = re_i ? romData : 16'hZZZZ;

	initial begin
		read_finished = 1'b0;
		romData = 16'h0;
	end

	always @(posedge clk) begin
		if(re_i) begin
			read_finished <= 1'b1;

			case(addr_i[15:1])
				15'h00: romData <= 16'h0bb6;  // 00
				15'h01: romData <= 16'h0102;  // 02
				15'h02: romData <= 16'h0326;  // 04
				15'h03: romData <= 16'h054a;  // 06
				15'h04: romData <= 16'h0dda;  // 08
				15'h05: romData <= 16'h5d01;  // 0A
				15'h06: romData <= 16'h4dc3;  // 0C
				15'h07: romData <= 16'h42c2;  // 0E
				15'h08: romData <= 16'h5300;  // 10
				15'h09: romData <= 16'h5a08;  // 12
				15'h0a: romData <= 16'h15d4;  // 14
				15'h0b: romData <= 16'h0bb6;  // 16
				15'h0c: romData <= 16'h0aa0;  // 18
				15'h0d: romData <= 16'h0004;  // 1A
				15'h0e: romData <= 16'h0809;  // 1C
				15'h0f: romData <= 16'h6afa;  // 1E
				15'h10: romData <= 16'h9148;  // 20
				15'h11: romData <= 16'h0dda;  // 22
				15'h12: romData <= 16'h41ba;  // 24
				15'h13: romData <= 16'h6e00;  // 26
				15'h14: romData <= 16'hf000;

				15'h80: romData <= 16'h1001;

				default: romData <= 16'hf000;
			endcase
		end
		else begin
			read_finished <= 1'b0;
		end
	end

endmodule
