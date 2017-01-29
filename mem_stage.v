module mem_stage (
	input clk,
	input en,
	
	input alu_signals ctrl_i,
	
	output [15:0] mem_addr_o,
	output mem_re_o,
	output mem_we_o,
	input [15:0] mem_data_i,
	output [15:0] mem_data_o,

	output alu_signals ctrl_o
);

	assign mem_re_o = en & ctrl_i.mem_read[0];
	assign mem_we_o = en & ctrl_i.mem_write[0];
	assign mem_addr_o = ctrl_i.mem_addr;
	assign mem_data_o = ctrl_i.data_out;
	
	// if address is odd, then the byte being read in is the LSB (big-endian), otherwise MSB
	assign mem_byte_in = ctrl_i.mem_addr[0] ? mem_data_i[7:0] : mem_data_i[15:8];

	always @(posedge clk) begin
		if(en) begin
			ctrl_o <= ctrl_i;
			// if reading memory, replace data from ALU with whatever got read
			if(ctrl_i.mem_read[0]) begin
				ctrl_o.data_out <= ctrl_i.mem_read[1] ? mem_data_i : {8'h0, mem_byte_in};
			end
		end
	end

endmodule
