module decoder_stage (
	input clk,
	input en,

	input [15:0] instr_in,
	input [15:0] pc_in,
	
	output decoder_signals control_signals_out,
	output reg [15:0] imm_out,
	output reg [15:0] pc_out
);

	wire [15:0] imm_next;
	decoder_signals sig_next;

	decoder decoder_inst (
		.instr(instr_in),
		.signals_out(sig_next),
		.imm(imm_next)
	);
	
	always @(posedge clk) begin
		if(en) begin
			control_signals_out <= sig_next;
			imm_out <= imm_next;
			pc_out <= pc_in;
		end
	end
endmodule
