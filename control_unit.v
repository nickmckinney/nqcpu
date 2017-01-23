module control_unit (
	input clk,
	
	input needWait,
	input mem_op_next,

	output fetch_en,
	output decode_en,
	output alu_en,
	output mem_en,
	output reg_write_en,
	
	output incr_pc,
	
	output [9:0] dbg_state
);

	localparam FETCH = 10'h1;
	localparam DECODE = 10'h2;
	localparam ALU = 10'h4;
	localparam MEM = 10'h8;
	localparam REG_WRITE = 10'h10;

	reg [9:0] current_state;
	
	initial begin
		current_state = FETCH;
	end
	
	assign fetch_en = current_state[0];
	assign decode_en = current_state[1];
	assign alu_en = current_state[2];
	assign mem_en = current_state[3];
	assign reg_write_en = current_state[4];

	assign incr_pc = current_state[1];
	
	always @(posedge clk) begin
		if(!needWait) begin
			case(current_state)
				FETCH: current_state <= DECODE;
				DECODE: current_state <= ALU;
				ALU: current_state <= mem_op_next ? MEM : REG_WRITE;
				MEM: current_state <= REG_WRITE;
				REG_WRITE: current_state <= FETCH;
			endcase
		end
	end
	
	assign dbg_state = current_state;
endmodule
