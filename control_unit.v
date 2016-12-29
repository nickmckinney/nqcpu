module control_unit (
	input clk,
	
	input needWait,
	
	output fetch_en,
	output decode_en,
	output alu_en,
	
	output incr_pc,
	
	output [9:0] dbg_state
);

	reg [9:0] current_state;
	
	initial begin
		current_state = 10'b1;
	end
	
	assign fetch_en = current_state[0];
	assign decode_en = current_state[1];
	assign alu_en = current_state[2];
	
	assign incr_pc = current_state[1];
	
	always @(posedge clk) begin
		if(!needWait) begin
			case(current_state)
				10'b1: current_state <= 10'b10;
				10'b10: current_state <= 10'b100;
				10'b100: current_state <= 10'b1;
			endcase
		end
	end
	
	assign dbg_state = current_state;
endmodule
