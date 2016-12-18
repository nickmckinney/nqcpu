module ctrl_decode (
	input [31:0] control_signals,

	output [3:0] aluOp,
	output [2:0] aluReg1,
	output [2:0] aluReg2,
	output [1:0] aluOpSource1,		// ALU first operand: 0 = reg, 1 = memory read, 2 = imm8, 3 = PC
	output [1:0] aluOpSource2,		// ALU second operand: 0 = reg, 1 = ~reg, 2 = PC, 3 = ???
	output aluDest,					// 0 = reg, 1 = PC

	output [2:0] regDest,
	output regSetH,
	output regSetL,

	output [2:0] regAddr,
	output memReadB,
	output memReadW,
	output memWriteB,
	output memWriteW,

	output [4:0] setRegCond   // {should set when condition is true, Z doesn't matter, S doesn't matter, Z must be this, S must be this}
);

	assign {
				aluOp,
				aluReg1,
				aluReg2,
				aluOpSource1,
				aluOpSource2,
				aluDest,
				regDest,
				regSetH,
				regSetL,
				regAddr,
				memReadB,
				memReadW,
				memWriteB,
				memWriteW,
				setRegCond
			} = control_signals;
endmodule
