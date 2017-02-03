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
				15'h00: romData <= 16'h0bb6;
				15'h01: romData <= 16'h0102;
				15'h02: romData <= 16'h0326;
				15'h03: romData <= 16'h054a;
				15'h04: romData <= 16'h0dda;
				15'h05: romData <= 16'h5d01;
				15'h06: romData <= 16'h4dc3;
				15'h07: romData <= 16'h42c2;
				15'h08: romData <= 16'h5300;
				15'h09: romData <= 16'h5a08;
				15'h0a: romData <= 16'h15d4;
				15'h0b: romData <= 16'h0bb6;
				15'h0c: romData <= 16'h0aa0;
				15'h0d: romData <= 16'h0004;
				15'h0e: romData <= 16'h0809;
				15'h0f: romData <= 16'h6afa;
				15'h10: romData <= 16'h9148;
				15'h11: romData <= 16'h0dda;
				15'h12: romData <= 16'h41ba;
				15'h13: romData <= 16'h6e00;
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
