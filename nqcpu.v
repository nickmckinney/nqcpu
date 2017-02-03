module nqcpu (
	input clk,
	
	input needWait_i,
	
	output [23:0] addr_o,
	output re_o, we_o,
	inout [15:0] data_io,

	output [15:0] debugPC,
	output [9:0] dbg_state,
	output decoder_signals debugCtrl,
	output [15:0] dbg_r0,
	output [15:0] dbg_r1,
	output [15:0] dbg_r2,
	output [15:0] dbg_r3,
	output [15:0] dbg_r4,
	output [15:0] dbg_r5,
	output [15:0] dbg_r6,
	output [15:0] dbg_r7,
	
	output dbg_setPC,
	output [15:0] dbg_setPCValue,
	
	output [1:0] dbg_statusreg,
	output alu_signals ctrl_alu_o
);

	wire [15:0] data_i;
	reg [15:0] pc;
	
	initial begin
		pc = 16'h0;
	end

	wire fetch_en, decode_en, alu_en, mem_en, regWrite_en, incr_pc, setPC;
	wire [15:0] setPCValue;
	wire ctrl_needWait;

	wire fetch_re;
	wire [15:0] fetched_instr;
	wire [15:0] pc_from_fetch;
	wire [15:0] fetch_addr;
	fetch_stage fetch_inst (
		.clk(clk),
		.en(fetch_en),

		.addr_in(pc),
		.mem_re(fetch_re),
		.mem_addr(fetch_addr),
		.mem_data(data_i),
		.instr_out(fetched_instr),
		.pc_out(pc_from_fetch)
	);

	wire [15:0] mc_mem_addr;
	wire mc_mem_re, mc_mem_we;
	wire [15:0] mc_mem_dataOut;

	cpu_memctl memctl_inst (
		.fetch_en(fetch_en),
		.fetch_addr(fetch_addr),
		.fetch_re(fetch_re),

		.mem_en(mem_en),
		.mem_addr(mc_mem_addr),
		.mem_re(mc_mem_re),
		.mem_we(mc_mem_we),
		.mem_dataOut(mc_mem_dataOut),
		
		.needWait_o(ctrl_needWait),
		.dataRead(data_i),

		.addr_o(addr_o),
		.re_o(re_o),
		.we_o(we_o),
		.data_io(data_io),
		.needWait_i(needWait_i)
	);

	always @(posedge clk) begin
		if(incr_pc) begin
			pc <= pc + 16'h2;
		end
		else if (setPC & regWrite_en) begin
			pc <= setPCValue;
		end
	end

	decoder_signals ctrl_from_decoder;
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

	alu_signals ctrl_from_alu;
	wire [15:0] imm_from_alu;
	wire [15:0] pc_from_alu;
	wire mem_op_next;
	alu_stage alu_inst (
		.clk(clk),
		.en(alu_en),
		.pc_in(pc_from_decoder),
		.control_signals_in(ctrl_from_decoder),
		.imm_in(imm_from_decoder),

		// register file
		.rf_regA(rf_regA),
		.rf_regB(rf_regB),
		.rf_dataA(rf_dataA),
		.rf_dataB(rf_dataB),

		.mem_op_next(mem_op_next),
		.control_signals_out(ctrl_from_alu),
		.imm_out(imm_from_alu),
		.pc_out(pc_from_alu),

		.dbg_statusreg(dbg_statusreg)
	);

	alu_signals ctrl_from_mem;
	mem_stage memStage_inst (
		.clk(clk),
		.en(mem_en),

		.ctrl_i(ctrl_from_alu),

		.mem_addr_o(mc_mem_addr),
		.mem_re_o(mc_mem_re),
		.mem_we_o(mc_mem_we),
		.mem_data_i(data_i),
		.mem_data_o(mc_mem_dataOut),

		.ctrl_o(ctrl_from_mem)
	);

	wire did_mem_op = ctrl_from_alu.mem_read[0] | ctrl_from_alu.mem_write[0];
	regWrite_stage regWrite_inst (
		.clk(clk),
		.en(regWrite_en),
		
		.ctrl_i(did_mem_op ? ctrl_from_mem : ctrl_from_alu),
		
		.rf_regDest(rf_regDest),
		.rf_dataIn(rf_dataIn),
		.rf_we(rf_we),
		.rf_hb(rf_hb),
		.rf_lb(rf_lb),

		.setPC_o(setPC),
		.setPCValue_o(setPCValue)
	);

	control_unit control_unit_inst (
		.clk(clk),
		
		.needWait(ctrl_needWait),
		.mem_op_next(mem_op_next),
		
		.fetch_en(fetch_en),
		.decode_en(decode_en),
		.alu_en(alu_en),
		.mem_en(mem_en),
		.reg_write_en(regWrite_en),
		
		.incr_pc(incr_pc),
		
		.dbg_state(dbg_state)
	);

	assign debugCtrl = ctrl_from_decoder;
	assign debugPC = pc;
	assign dbg_setPC = setPC;
	assign dbg_setPCValue = setPCValue;
	assign ctrl_alu_o = ctrl_from_alu;
endmodule
