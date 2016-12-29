module nqcpu (
	input clk,
	
	output [15:0] debugPC,
	output [3:0] debugAluOp,
	output [2:0] debugAluReg1,
	output [2:0] debugAluReg2,
	output [1:0] debugAluOpSource1,		// ALU first operand: 0 = reg, 1 = memory read, 2 = imm8, 3 = PC
	output [1:0] debugAluOpSource2,		// ALU second operand: 0 = reg, 1 = ~reg, 2 = PC, 3 = ???
	output debugAluDest,					// 0 = reg, 1 = PC

	output [2:0] debugRegDest,
	output debugRegSetH,
	output debugRegSetL,

	output [2:0] debugRegAddr,
	output debugMemReadB,
	output debugMemReadW,
	output debugMemWriteB,
	output debugMemWriteW,

	output [5:0] debugSetRegCond,   // {should set when condition is true, Z doesn't matter, S doesn't matter, Z must be this, S must be this}
	
	output [15:0] dbg_r0,
	output [15:0] dbg_r1,
	output [15:0] dbg_r2,
	output [15:0] dbg_r3,
	output [15:0] dbg_r4,
	output [15:0] dbg_r5,
	output [15:0] dbg_r6,
	output [15:0] dbg_r7,
	output [9:0] dbg_state,
	
	output [1:0] dbg_statusreg
);

	reg [15:0] pc;
	
	initial begin
		pc = 16'h0;
	end

	wire fetch_en, decode_en, alu_en, incr_pc;

	wire fetch_ready;
	wire [15:0] fetched_instr;
	wire [15:0] pc_from_fetch;
	fetch_stage fetch_inst (
		.clk(clk),
		.en(fetch_en),
		.addr_in(pc),
		.ready(fetch_ready),
		.instr_out(fetched_instr),
		.pc_out(pc_from_fetch)
	);

	always @(posedge clk) begin
		if(incr_pc) begin
			pc <= pc + 16'h2;
		end
	end

	wire [32:0] ctrl_from_decoder;
	wire [15:0] imm_from_decoder;
	wire [15:0] pc_from_decoder;

	decoder_stage decoder_inst (
		.clk(clk),
		.en(decode_en),
		.instr_in(fetched_instr),
		.pc_in(pc_from_fetch),
		.control_signals_out(ctrl_from_decoder),
		.imm_out(imm_from_decoder),
		.pc_out(pc_from_decoder)
	);
	
	wire [2:0] rf_regA;
	wire [2:0] rf_regB;
	wire [2:0] rf_regDest;
	wire [15:0] rf_dataIn;
	wire rf_we;
	wire rf_hb;
	wire rf_lb;
	wire [15:0] rf_dataA;
	wire [15:0] rf_dataB;
	regFile regFile_inst (
		.clk(clk),
		.regA(rf_regA),
		.regB(rf_regB),
		.regDest(rf_regDest),
		.dataIn(rf_dataIn),
		.we(rf_we),
		.hb(rf_hb),
		.lb(rf_lb),
		.dataA(rf_dataA),
		.dataB(rf_dataB),

		.dbg_r0(dbg_r0),
		.dbg_r1(dbg_r1),
		.dbg_r2(dbg_r2),
		.dbg_r3(dbg_r3),
		.dbg_r4(dbg_r4),
		.dbg_r5(dbg_r5),
		.dbg_r6(dbg_r6),
		.dbg_r7(dbg_r7)
	);

	wire [32:0] ctrl_from_alu;
	wire [15:0] imm_from_alu;
	wire [15:0] pc_from_alu;
	alu_stage alu_inst (
		.clk(clk),
		.en(alu_en),
		.pc_in(pc_from_decoder),
		.control_signals_in(ctrl_from_decoder),
		.imm_in(imm_from_decoder),

		// register file
		.rf_regA(rf_regA),
		.rf_regB(rf_regB),
		.rf_regDest(rf_regDest),
		.rf_dataIn(rf_dataIn),
		.rf_we(rf_we),
		.rf_hb(rf_hb),
		.rf_lb(rf_lb),
		.rf_dataA(rf_dataA),
		.rf_dataB(rf_dataB),
		
		// memory interface
		.memData_in(16'hDEAD),    // read in from memory
		//.memData_out(??),  // to write out to memory
		
		.control_signals_out(ctrl_from_alu),
		.imm_out(imm_from_alu),
		.pc_out(pc_from_alu),
		
		.dbg_statusreg(dbg_statusreg)
	);

	control_unit control_unit_inst (
		.clk(clk),
		
		.fetch_ready(fetch_ready),
		
		.fetch_en(fetch_en),
		.decode_en(decode_en),
		.alu_en(alu_en),
		
		.incr_pc(incr_pc),
		
		.dbg_state(dbg_state)
	);

	ctrl_decode debug_decode (
		.control_signals(ctrl_from_alu),

		.aluOp(debugAluOp),
		.aluReg1(debugAluReg1),
		.aluReg2(debugAluReg2),
		.aluOpSource1(debugAluOpSource1),
		.aluOpSource2(debugAluOpSource2),
		.aluDest(debugAluDest),

		.regDest(debugRegDest),
		.regSetH(debugRegSetH),
		.regSetL(debugRegSetL),

		.regAddr(debugRegAddr),
		.memReadB(debugMemReadB),
		.memReadW(debugMemReadW),
		.memWriteB(debugMemWriteB),
		.memWriteW(debugMemWriteW),

		.setRegCond(debugSetRegCond)
	);
	
	assign debugPC = pc_from_alu;

endmodule
