module ctrl_encode (
	input [3:0] aluOp,
	input [2:0] aluReg1,
	input [2:0] aluReg2,
	input [1:0] aluOpSource1,		// ALU first operand: 0 = reg, 1 = memory read, 2 = imm8, 3 = PC
	input [1:0] aluOpSource2,		// ALU second operand: 0 = reg, 1 = ~reg, 2 = PC, 3 = ???
	input aluDest,					// 0 = reg, 1 = PC

	input [2:0] regDest,
	input regSetH,
	input regSetL,

	input [2:0] regAddr,
	input memReadB,
	input memReadW,
	input memWriteB,
	input memWriteW,

	input [5:0] setRegCond,   // {should set when condition is true, Z doesn't matter, S doesn't matter, Z must be this, S must be this}

	output [32:0] control_signals
);

	assign control_signals = {
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
			};
endmodule
