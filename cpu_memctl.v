module cpu_memctl (
	input fetch_en,
	input [15:0] fetch_addr,
	input fetch_re,

	input mem_en,
	input [15:0] mem_addr,
	input mem_re,
	input mem_we,
	input [15:0] mem_dataOut,
	
	output needWait_o,
	output [15:0] dataRead,

	output [15:0] addr_o,
	output re_o, we_o,
	inout [15:0] data_io,
	input needWait_i
);

	//-- handle data line tristate --
	wire [15:0] data_i;
	wire [15:0] data_o;

	assign data_i = we_o ? 16'h0 : data_io;
	assign data_io = we_o ? data_o : 16'hZZZZ;
	//-------------------------------

	assign addr_o = fetch_en ? fetch_addr : mem_en;
	assign re_o = fetch_en ? fetch_re : (mem_en & mem_re);
	assign we_o = mem_en & mem_we;
	assign data_o = mem_dataOut;

	assign needWait_o = needWait_i & (fetch_en | mem_en);
	assign dataRead = data_i;

endmodule
