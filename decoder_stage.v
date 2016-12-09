module decoder_stage (
	input clk,
	input en,

	input [15:0] instr_in,
	
	output reg [3:0] aluOp_out,
	output reg [2:0] aluReg1_out,
	output reg [2:0] aluReg2_out,
	output reg [1:0] aluOpSource1_out,		// ALU first operand: 0 = reg, 1 = memory read, 2 = imm8, 3 = PC
	output reg [1:0] aluOpSource2_out,		// ALU second operand: 0 = reg, 1 = ~reg, 2 = PC, 3 = ???
	output reg aluDest_out,					// 0 = reg, 1 = PC

	output reg [2:0] regDest_out,
	output reg regSetH_out,
	output reg regSetL_out,
	
	output reg [2:0] regAddr_out,
	output reg memReadB_out,
	output reg memReadW_out,
	output reg memWriteB_out,
	output reg memWriteW_out,
	
	output reg [4:0] setRegCond_out,   // {should set when condition is true, Z doesn't matter, S doesn't matter, Z must be this, S must be this}
	
	output reg [15:0] imm_out
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
	
	always @(posedge clk) begin
		if(en) begin
			aluOp_out <= aluOp_next;
			aluReg1_out <= aluReg1_next;
			aluReg2_out <= aluReg2_next;
			aluOpSource1_out <= aluOpSource1_next;
			aluOpSource2_out <= aluOpSource2_next;
			aluDest_out <= aluDest_next;
			regDest_out <= regDest_next;
			regSetH_out <= regSetH_next;
			regSetL_out <= regSetL_next;
			regAddr_out <= regAddr_next;
			memReadB_out <= memReadB_next;
			memReadW_out <= memReadW_next;
			memWriteB_out <= memWriteB_next;
			memWriteW_out <= memWriteW_next;
			setRegCond_out <= setRegCond_next;
			imm_out <= imm_next;
		end
	end
endmodule
