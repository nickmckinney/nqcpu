module testROM (
	input clk,
	
	output needWait_o,
	input [15:0] addr_i,
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
				15'h0: romData <= 16'h0bb6;
				15'h1: romData <= 16'h0102;
				15'h2: romData <= 16'h0326;
				15'h3: romData <= 16'h054a;
				15'h4: romData <= 16'h5c0a;
				15'h5: romData <= 16'h5d00;
				15'h6: romData <= 16'h44c2;
				15'h7: romData <= 16'h5201;
				15'h8: romData <= 16'h0aa0;
				15'h9: romData <= 16'h0004;
				15'ha: romData <= 16'h0809;
				15'hb: romData <= 16'h6afa;
				15'hc: romData <= 16'h6e00;
				default: romData <= 16'hf000;
			endcase
		end
		else begin
			read_finished <= 1'b0;
		end
	end

endmodule
