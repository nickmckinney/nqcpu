module fetch_stage (
	input clk,
	input en,

	input [15:0] addr_in,
	output mem_re,
	output [15:0] mem_addr,
	input [15:0] mem_data,
	
	output reg [15:0] instr_out,
	output reg [15:0] pc_out
);

	assign mem_re = en;

	always @(posedge clk) begin
		if(en) begin
			instr_out <= mem_data;
			pc_out <= addr_in;
		end
	end
	
	assign mem_addr = addr_in;

/*
	always @(posedge clk) begin
		if(en) begin
			ready <= 1'b1;
			
			// sample proggy:
			case(addr_in[15:1])
//				15'h0: instr_out <= 16'b0000_000_1_000_000_10;	// xor r0,r0,r0
//				15'h1: instr_out <= 16'b0000_001_1_001_001_10;	// xor r1,r1,r1
//				15'h2: instr_out <= 16'b0101_000_0_00010010;		// mov rl0,$12
//				15'h3: instr_out <= 16'b0101_001_0_00110100;		// mov rl1,$34
//				15'h4: instr_out <= 16'b0000_010_0_000_001_00;	// add r2,r0,r1
//				15'h5: instr_out <= 16'b0000_011_0_001_000_01;	// sub r3,r1,r0
//				15'h6: instr_out <= 16'b0100_000_0_011_00100;	// mov r0,r3
//				15'h7: instr_out <= 16'b0000_100_1_100_100_10;	// xor r4,r4,r4
//				15'h8: instr_out <= 16'b0111_00000_100_00000;	// jmp r4

				15'h0: instr_out <= 16'h0BB6;
				15'h1: instr_out <= 16'h0102;
				15'h2: instr_out <= 16'h0326;
				15'h3: instr_out <= 16'h054A;
				15'h4: instr_out <= 16'h5201;
				15'h5: instr_out <= 16'h540A;
				15'h6: instr_out <= 16'h0AA0;
				15'h7: instr_out <= 16'h0004;
				15'h8: instr_out <= 16'h0809;
				15'h9: instr_out <= 16'h6AFA;
				15'hA: instr_out <= 16'h6E00;
				default: instr_out <= 16'b1111_000000000000;		// nop
			endcase
			
			pc_out <= addr_in;
		end
		else begin
			ready <= 1'b0;
		end
	end
*/

endmodule
