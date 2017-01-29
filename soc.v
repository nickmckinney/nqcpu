module soc (
	input clk,

	//output [15:0] debugPC,
	output [3:0] debugAluOp,
	output [2:0] debugAluReg1,
	output [2:0] debugAluReg2,
	output [1:0] debugAluOpSource1,
	output [1:0] debugAluOpSource2,
	output debugAluDest,

	output [2:0] debugRegDest,
	output debugRegSetH,
	output debugRegSetL,

	output [2:0] debugRegAddr,
	output debugMemReadB,
	output debugMemReadW,
	output debugMemWriteB,
	output debugMemWriteW,

	output [5:0] debugSetRegCond,
	
	output [15:0] dbg_r0,
	output [15:0] dbg_r1,
	output [15:0] dbg_r2,
	output [15:0] dbg_r3,
	output [15:0] dbg_r4,
	output [15:0] dbg_r5,
	output [15:0] dbg_r6,
	output [15:0] dbg_r7,
	output [9:0] dbg_state,
	
	//output dbg_setPC,
	//output [15:0] dbg_setPCValue,
	
	output [1:0] dbg_statusreg,
	output dbg_needWait,
	
	output dbg_re_o,
	output dbg_we_o,
	output [15:0] dbg_addr_o,
	output [15:0] dbg_data_io,

	output [41:0] dbg_ctrl_alu
);

	wire needWait_i;
	wire [15:0] addr_o;
	wire re_o, we_o;
	wire [15:0] data_io;
	decoder_signals ctrl_from_decoder;

	nqcpu cpu_inst (
		.clk(clk),
		.needWait_i(needWait_i),
		.addr_o(addr_o),
		.re_o(re_o),
		.we_o(we_o),
		.data_io(data_io),

		.debugCtrl(ctrl_from_decoder),
		//.debugPC(debugPC),
		.dbg_r0(dbg_r0),
		.dbg_r1(dbg_r1),
		.dbg_r2(dbg_r2),
		.dbg_r3(dbg_r3),
		.dbg_r4(dbg_r4),
		.dbg_r5(dbg_r5),
		.dbg_r6(dbg_r6),
		.dbg_r7(dbg_r7),
		.dbg_state(dbg_state),
		//.dbg_setPC(dbg_setPC),
		//.dbg_setPCValue(dbg_setPCValue),
		.dbg_statusreg(dbg_statusreg),

		.ctrl_alu_o(dbg_ctrl_alu)
	);

	testROM testROM_inst (
		.clk(clk),
		.needWait_o(needWait_i),
		.addr_i(addr_o),
		.re_i(re_o),
		.data_io(data_io)
	);

	assign debugAluOp = ctrl_from_decoder.aluOp;
	assign debugAluReg1 = ctrl_from_decoder.aluReg1;
	assign debugAluReg2 = ctrl_from_decoder.aluReg2;
	assign debugAluOpSource1 = ctrl_from_decoder.aluOpSource1;
	assign debugAluOpSource2 = ctrl_from_decoder.aluOpSource2;
	assign debugAluDest = ctrl_from_decoder.aluDest;
	assign debugRegDest = ctrl_from_decoder.regDest;
	assign debugRegSetH = ctrl_from_decoder.regSetH;
	assign debugRegSetL = ctrl_from_decoder.regSetL;
	assign debugRegAddr = ctrl_from_decoder.regAddr;
	assign debugMemReadB = ctrl_from_decoder.memReadB;
	assign debugMemReadW = ctrl_from_decoder.memReadW;
	assign debugMemWriteB = ctrl_from_decoder.memWriteB;
	assign debugMemWriteW = ctrl_from_decoder.memWriteW;
	assign debugSetRegCond = ctrl_from_decoder.setRegCond;

	assign dbg_needWait = needWait_i;
	assign dbg_re_o = re_o;
	assign dbg_we_o = we_o;
	assign dbg_addr_o = addr_o;
	assign dbg_data_io = data_io;
endmodule
