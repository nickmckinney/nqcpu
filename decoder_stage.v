module decoder_stage (
	input clk,
	input en,

	input [15:0] instr_in,
	input [15:0] pc_in,
	
	output reg [31:0] control_signals_out,
	output reg [15:0] imm_out,
	output reg [15:0] pc_out
);

	wire [3:0] aluOp_next;
	wire [2:0] aluReg1_next;
	wire [2:0] aluReg2_next;
	wire [1:0] aluOpSource1_next;
	wire [1:0] aluOpSource2_next;
	wire aluDest_next;
	wire [2:0] regDest_next;
	wire regSetH_next;
	wire regSetL_next;
	wire [2:0] regAddr_next;
	wire memReadB_next;
	wire memReadW_next;
	wire memWriteB_next;
	wire memWriteW_next;
	wire [4:0] setRegCond_next;
	wire [15:0] imm_next;

	decoder decoder_inst (
		.instr(instr_in),
		.aluOp(aluOp_next),
		.aluReg1(aluReg1_next),
		.aluReg2(aluReg2_next),
		.aluOpSource1(aluOpSource1_next),
		.aluOpSource2(aluOpSource2_next),
		.aluDest(aluDest_next),
		.regDest(regDest_next),
		.regSetH(regSetH_next),
		.regSetL(regSetL_next),
		.regAddr(regAddr_next),
		.memReadB(memReadB_next),
		.memReadW(memReadW_next),
		.memWriteB(memWriteB_next),
		.memWriteW(memWriteW_next),
		.setRegCond(setRegCond_next),
		.imm(imm_next)
	);
	
	wire [31:0] control_signals_next;
	
	ctrl_encode encode_inst (
		.aluOp(aluOp_next),
		.aluReg1(aluReg1_next),
		.aluReg2(aluReg2_next),
		.aluOpSource1(aluOpSource1_next),
		.aluOpSource2(aluOpSource2_next),
		.aluDest(aluDest_next),
		.regDest(regDest_next),
		.regSetH(regSetH_next),
		.regSetL(regSetL_next),
		.regAddr(regAddr_next),
		.memReadB(memReadB_next),
		.memReadW(memReadW_next),
		.memWriteB(memWriteB_next),
		.memWriteW(memWriteW_next),
		.setRegCond(setRegCond_next),
		.control_signals(control_signals_next)
	);
	
	always @(posedge clk) begin
		if(en) begin
			control_signals_out <= control_signals_next;
			imm_out <= imm_next;
			pc_out <= pc_in;
		end
	end
endmodule
