module control_unit (
	input clk,
	
	input needWait,
	
	output fetch_en,
	output decode_en,
	output alu_en,
	
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
	
	assign incr_pc = current_state[1];
	
	always @(posedge clk) begin
		if(!needWait) begin
			case(current_state)
				FETCH: current_state <= DECODE;
				DECODE: current_state <= ALU;
				ALU: current_state <= FETCH;
			endcase
		end
	end
	
	assign dbg_state = current_state;
endmodule
