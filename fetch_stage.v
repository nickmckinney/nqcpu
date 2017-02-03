module fetch_stage (
	input clk,
	input en,

	input [15:0] addr_in,
	output mem_re,
	output [23:0] mem_addr,
	input [15:0] mem_data,
	
	output reg [15:0] instr_out,
	output reg [15:0] pc_out
);

	assign mem_re = en;

	always @(posedge clk) begin
		if(en) begin
			instr_out <= mem_data;
			pc_out <= addr_in;
		end
	end
	
	assign mem_addr = {8'h0, addr_in};  // TODO: use program bank number instead

endmodule
