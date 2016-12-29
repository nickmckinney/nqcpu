module alu_stage (
	input clk,
	input en,
	input [15:0] pc_in,
	input [32:0] control_signals_in,
	input [15:0] imm_in,

	// register file
	output [2:0] rf_regA,
	output [2:0] rf_regB,
	output [2:0] rf_regDest,
	output [15:0] rf_dataIn,
	output rf_we,
	output rf_hb,
	output rf_lb,
	input [15:0] rf_dataA,
	input [15:0] rf_dataB,
	
	// memory interface
	input [15:0] memData_in,    // read in from memory
	output reg [15:0] memData_out,  // to write out to memory
	
	output reg [32:0] control_signals_out,
	output reg [15:0] imm_out,
	output reg [15:0] pc_out,

	output [1:0] dbg_statusreg
);
	reg [1:0] statusReg;

	// decode signals
	wire [3:0] aluOp_in;
	wire [2:0] aluReg1_in;
	wire [2:0] aluReg2_in;
	wire [1:0] aluOpSource1_in;
	wire [1:0] aluOpSource2_in;
	wire aluDest_in;
	wire [2:0] regDest_in;
	wire regSetH_in;
	wire regSetL_in;
	wire [2:0] regAddr_in;
	wire memReadB_in;
	wire memReadW_in;
	wire memWriteB_in;
	wire memWriteW_in;
	wire [5:0] setRegCond_in;

	ctrl_decode ctrl_decode_inst (
		.control_signals(control_signals_in),

		.aluOp(aluOp_in),
		.aluReg1(aluReg1_in),
		.aluReg2(aluReg2_in),
		.aluOpSource1(aluOpSource1_in),		// ALU first operand: 0 = reg, 1 = memory read, 2 = imm8, 3 = PC
		.aluOpSource2(aluOpSource2_in),		// ALU second operand: 0 = reg, 1 = ~reg, 2 = PC, 3 = ???
		.aluDest(aluDest_in),					// 0 = reg, 1 = PC

		.regDest(regDest_in),
		.regSetH(regSetH_in),
		.regSetL(regSetL_in),

		.regAddr(regAddr_in),
		.memReadB(memReadB_in),
		.memReadW(memReadW_in),
		.memWriteB(memWriteB_in),
		.memWriteW(memWriteW_in),

		.setRegCond(setRegCond_in)   // {should set when condition is true, Z doesn't matter, S doesn't matter, Z must be this, S must be this}
	);

	wire [15:0] aluSrc1;
	assign aluSrc1 =
		aluOpSource1_in == 2'h0 ? rf_dataA :
		aluOpSource1_in == 2'h1 ? memData_in :
		aluOpSource1_in == 2'h2 ? {imm_in} : pc_in;
		
	wire [15:0] aluSrc2;
	assign aluSrc2 =
		aluOpSource1_in == 2'h0 ? rf_dataB :
		aluOpSource1_in == 2'h1 ? ~rf_dataIn : pc_in;

	wire [15:0] aluResult;
	wire aluZero, aluCarry;
	alu alu_inst (
		.op(aluOp_in),
		.x(aluSrc1),
		.y(aluSrc2),
		.result(aluResult),
		.zero(aluZero),
		.carry(aluCarry)
	);
	
	assign rf_regA = aluReg1_in;
	assign rf_regB = aluReg2_in;
	assign rf_we = en & (regSetH_in | regSetL_in);
	assign rf_hb = regSetH_in;
	assign rf_lb = regSetL_in;
	assign rf_dataIn = aluResult;
	assign rf_regDest = regDest_in;

	always @(posedge clk) begin
		if(en) begin
			control_signals_out <= control_signals_in;
			imm_out <= imm_in;
			memData_out <= aluResult;
			pc_out <= pc_in;
			statusReg <= {aluZero, aluCarry};  // not quite right; should only happen for a few instructions
		end
	end
	
	assign dbg_statusreg = statusReg;

endmodule
