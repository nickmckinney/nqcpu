module mem_stage (
	input clk,
	input en,
	
	input [41:0] ctrl_i,
	
	output [15:0] mem_addr_o,
	output mem_re_o,
	output mem_we_o,
	input [15:0] mem_data_i,
	output [15:0] mem_data_o,

	output reg [21:0] ctrl_o
);

	wire [1:0] mem_read;   // {1 = word;0 = byte, 1 = read}
	wire [1:0] mem_write;  // {1 = word;0 = byte, 1 = write}
	wire [15:0] mem_addr;  // address of memory read/write
	wire [15:0] data_from_alu;
	wire [7:0] mem_byte_in;

	assign {mem_read, mem_write, mem_addr} = ctrl_i[19:0];
	assign data_from_alu = ctrl_i[41:26];
	
	assign mem_re_o = en & mem_read[0];
	assign mem_we_o = en & mem_write[0];
	assign mem_addr_o = mem_addr;
	assign mem_data_o = data_from_alu;
	
	// if address is odd, then the byte being read in is the LSB (big-endian), otherwise MSB
	assign mem_byte_in = mem_addr[0] ? mem_data_i[7:0] : mem_data_i[15:8];

	always @(posedge clk) begin
		if(en) begin
			// if reading memory, replace data from ALU with whatever got read
			ctrl_o <=
				!mem_read[0] ? ctrl_i[41:20] :
				mem_read[1] ? {mem_data_i, ctrl_i[25:20]} : {8'h0, mem_byte_in, ctrl_i[25:20]};
		end
	end

endmodule
