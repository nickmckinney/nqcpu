module ext_memInterface (
	input clk,

	input [23:0] addr_i,
	inout [15:0] data_io_cpu,
	input re_i,
	input we_i,
	output needWait_o,

	// TODO: all memories use 16-bit words for now. need more control lines to just get/set the high byte or low byte

	// 4MB flash memory, mapped to 0x000000 - 0x3FFFFF (2^21 words)
	output [20:0] addr_o_flash,
	input [15:0] data_i_flash,
	output re_o_flash,
	input needWait_i_flash,

	// 8MB SDRAM, mapped to 0x800000 - 0xFFFFFF (2^22 words)
	output [21:0] addr_o_dram,
	inout [15:0] data_io_dram,
	output re_o_dram,
	output we_o_dram,
	input needWait_i_dram,
	
	// 512KB SRAM, mapped to 0x400000 - 0x47FFFF (2^18 words)
	output [17:0] addr_o_sram,
	inout [15:0] data_io_sram,
	output re_o_sram,
	output we_o_sram,
	input needWait_i_sram,
	
	// LEDs, 2 words mapped to 0x480000 - 0x480001
	output addr_o_leds,
	inout [15:0] data_io_leds,
	output re_o_leds,
	output we_o_leds,
	input needWait_i_leds
);

	logic flashSel, sramSel, dramSel, ledSel;
	
	assign dramSel  = addr_i[23];
	assign flashSel = addr_i[23:22] == 2'b00;
	assign sramSel  = addr_i[23:19] == 5'b0100_0;
	assign ledSel   = addr_i[23:19] == 5'b0100_1;
	
	assign addr_o_flash = addr_i[20:0];
	assign addr_o_dram  = addr_i[21:0];
	assign addr_o_sram  = addr_i[17:0];
	assign addr_o_leds  = addr_i[0];
	
	assign data_io_cpu = (re_i & flashSel) ? data_i_flash :
	                     (re_i & dramSel)  ? data_io_dram :
								(re_i & sramSel)  ? data_io_sram :
								(re_i & ledSel)   ? data_io_leds : 16'bZ;

	assign data_io_dram = (we_i & dramSel) ? data_io_cpu : 16'bZ;
	assign data_io_sram = (we_i & sramSel) ? data_io_cpu : 16'bZ;
	assign data_io_leds = (we_i & ledSel)  ? data_io_cpu : 16'bZ;

	assign re_o_flash = re_i & flashSel;
	assign re_o_dram  = re_i & dramSel;
	assign re_o_sram  = re_i & sramSel;
	assign re_o_leds  = re_i & ledSel;

	assign we_o_dram  = we_i & dramSel;
	assign we_o_sram  = we_i & sramSel;
	assign we_o_leds  = we_i & ledSel;

	assign needWait_o = (re_i | we_i) & ((flashSel & needWait_i_flash) |
                                        (dramSel  & needWait_i_dram) |
													 (sramSel  & needWait_i_sram) |
													 (ledSel   & needWait_i_leds));

endmodule
