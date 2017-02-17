// `define SLOW_CLOCK

module soc (
	input clkIn,

	output [6:0] hex_0,
	output [6:0] hex_1,
	output [6:0] hex_2,
	output [6:0] hex_3

	//output [15:0] debugPC,
	//output [3:0] debugAluOp,
	//output [2:0] debugAluReg1,
	//output [2:0] debugAluReg2,
	//output [1:0] debugAluOpSource1,
	//output [1:0] debugAluOpSource2,
	//output debugAluDest,

	//output [3:0] debugRegDest,
	//output debugRegSetH,
	//output debugRegSetL,

	//output [2:0] debugRegAddr,
	//output debugMemReadB,
	//output debugMemReadW,
	//output debugMemWriteB,
	//output debugMemWriteW,

	//output [5:0] debugSetRegCond,
	
	//output [15:0] dbg_r0,
	//output [15:0] dbg_r1,
	//output [15:0] dbg_r2,
	//output [15:0] dbg_r3,
	//output [15:0] dbg_r4,
	//output [15:0] dbg_r5,
	//output [15:0] dbg_r6,
	//output [15:0] dbg_r7,
	//output [9:0] dbg_state,
	
	//output dbg_setPC,
	//output [15:0] dbg_setPCValue,
	
	//output [1:0] dbg_statusreg,
	//output dbg_needWait,
	
	//output dbg_re_o,
	//output dbg_we_o,
	//output [23:0] dbg_addr_o,
	//output [15:0] dbg_data_io,
	//output [7:0] dbg_db,

	//output [$bits(alu_signals)-1:0] dbg_ctrl_alu
);

`ifdef SLOW_CLOCK
	reg clk;
	reg [19:0] clkCount;

	always @(posedge clkIn) begin
		clkCount <= clkCount + 20'h1;
		if(clkCount == 0) clk <= ~clk;
	end
`else
	wire clk;
	
	assign clk = clkIn;
`endif

	wire needWait_i;
	wire [23:0] addr_o;
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
		//.dbg_r0(dbg_r0),
		//.dbg_r1(dbg_r1),
		//.dbg_r2(dbg_r2),
		//.dbg_r3(dbg_r3),
		//.dbg_r4(dbg_r4),
		//.dbg_r5(dbg_r5),
		//.dbg_r6(dbg_r6),
		//.dbg_r7(dbg_r7),
		//.dbg_state(dbg_state),
		//.dbg_db(dbg_db),
		//.dbg_setPC(dbg_setPC),
		//.dbg_setPCValue(dbg_setPCValue),
		//.dbg_statusreg(dbg_statusreg),

		//.ctrl_alu_o(dbg_ctrl_alu)
	);

	logic re_dram, re_sram;
	wire [15:0] dram_data;
	wire [15:0] sram_data;

	assign dram_data = re_dram ? 16'b0 : 16'bZ;
	assign sram_data = re_sram ? 16'b0 : 16'bZ;
	ext_memInterface ext_memInterface_inst (
		.clk(clk),

		.addr_i(addr_o),
		.data_io_cpu(data_io),
		.re_i(re_o),
		.we_i(we_o),
		.needWait_o(needWait_i),

		.addr_o_flash(testROM_addr),
		.data_i_flash(testROM_data),
		.re_o_flash(testROM_re),
		.needWait_i_flash(testROM_needWait),

		//.addr_o_dram,
		.data_io_dram(dram_data),
		.re_o_dram(re_dram),
		//.we_o_dram,
		.needWait_i_dram(1'b0),

		//.addr_o_sram,
		.data_io_sram(sram_data),
		.re_o_sram(re_sram),
		//.we_o_sram,
		.needWait_i_sram(1'b0),

		.addr_o_leds(leds_addr),
		.data_io_leds(leds_data),
		.re_o_leds(leds_re),
		.we_o_leds(leds_we),
		.needWait_i_leds(leds_needWait)
	);

	logic [20:0] testROM_addr;
	logic testROM_re;
	wire [15:0] testROM_data;
	logic testROM_needWait;
	testROM testROM_inst (
		.clk(clk),
		.needWait_o(testROM_needWait),
		.addr_i(testROM_addr),
		.re_i(testROM_re),
		.data_io(testROM_data)
	);

	wire [15:0] leds_data;
	wire leds_re, leds_we, leds_addr, leds_needWait;
	test_led_ram test_leds (
		.clk(clk),

		.needWait_o(leds_needWait),
		.addr_i(leds_addr),
		.re_i(leds_re),
		.we_i(leds_we),
		.data_io(leds_data),

		.hex_0(hex_0),
		.hex_1(hex_1),
		.hex_2(hex_2),
		.hex_3(hex_3)
	);
	//assign debugAluOp = ctrl_from_decoder.aluOp;
	//assign debugAluReg1 = ctrl_from_decoder.aluReg1;
	//assign debugAluReg2 = ctrl_from_decoder.aluReg2;
	//assign debugAluOpSource1 = ctrl_from_decoder.aluOpSource1;
	//assign debugAluOpSource2 = ctrl_from_decoder.aluOpSource2;
	//assign debugAluDest = ctrl_from_decoder.aluDest;
	//assign debugRegDest = ctrl_from_decoder.regDest;
	//assign debugRegSetH = ctrl_from_decoder.regSetH;
	//assign debugRegSetL = ctrl_from_decoder.regSetL;
	//assign debugRegAddr = ctrl_from_decoder.regAddr;
	//assign debugMemReadB = ctrl_from_decoder.memReadB;
	//assign debugMemReadW = ctrl_from_decoder.memReadW;
	//assign debugMemWriteB = ctrl_from_decoder.memWriteB;
	//assign debugMemWriteW = ctrl_from_decoder.memWriteW;
	//assign debugSetRegCond = ctrl_from_decoder.setRegCond;

	//assign dbg_needWait = needWait_i;
	//assign dbg_re_o = re_o;
	//assign dbg_we_o = we_o;
	//assign dbg_addr_o = addr_o;
	//assign dbg_data_io = data_io;
endmodule
