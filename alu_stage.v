module alu_stage (
	input clk,
	input en,
	input [15:0] pc_in,
	input decoder_signals control_signals_in,
	input [15:0] imm_in,

	// register file
	output [2:0] rf_regA,
	output [2:0] rf_regB,
	output [15:0] rf_dataIn,
	input [15:0] rf_dataA,
	input [15:0] rf_dataB,
	
	// outgoing control signals
	output mem_op_next,           // 1 = memory read or write is needed (not a register; needs to be available sooner so control unit can go to mem state)
	output [41:0] control_signals_out,

	output reg [15:0] imm_out,
	output reg [15:0] pc_out,

	output [1:0] dbg_statusreg
);
	reg [1:0] statusReg;

	reg [15:0] data_out_o;  // to write out to memory
	reg [1:0] reg_write_o;  // {write data_out to high byte, write data_out to low byte}
	reg [2:0] reg_dest_o;   // which register to write to
	reg [1:0] mem_read_o;   // {1 = word;0 = byte, 1 = read}
	reg [1:0] mem_write_o;  // {1 = word;0 = byte, 1 = write}
	reg [15:0] mem_addr_o;  // address of memory read/write
	reg setPC_o;            // write data_out to PC

	wire [15:0] aluSrc1;
	assign aluSrc1 =
		control_signals_in.aluOpSource1 == 2'h0 ? rf_dataA :
		control_signals_in.aluOpSource1 == 2'h2 ? {imm_in} : pc_in;
		
	wire [15:0] aluSrc2;
	assign aluSrc2 =
		control_signals_in.aluOpSource2 == 2'h0 ? rf_dataB :
		control_signals_in.aluOpSource2 == 2'h1 ? ~rf_dataIn : pc_in;

	wire [15:0] aluResult;
	wire aluZero, aluCarry;
	alu alu_inst (
		.op(control_signals_in.aluOp),
		.x(aluSrc1),
		.y(aluSrc2),
		.result(aluResult),
		.zero(aluZero),
		.carry(aluCarry)
	);
	
	wire setRegZCond, setRegCCond, setSomeReg;
	assign setRegZCond = control_signals_in.setRegCond[4] | (control_signals_in.setRegCond[3] == statusReg[1]);
	assign setRegCCond = control_signals_in.setRegCond[1] | (control_signals_in.setRegCond[0] == statusReg[0]);
	assign setSomeReg =
		en &
		control_signals_in.setRegCond[5] &
		(
			control_signals_in.setRegCond[2] ?
				(setRegZCond & setRegCCond) :
				(setRegZCond | setRegCCond)
		);

	assign rf_regA = control_signals_in.aluReg1;
	assign rf_regB = control_signals_in.aluReg2;
	assign rf_dataIn = aluResult;
	
	assign mem_op_next = control_signals_in.memReadB | control_signals_in.memReadW | control_signals_in.memWriteB | control_signals_in.memWriteW;
	assign control_signals_out = {
		data_out_o,   // [41:26]
		reg_write_o,  // [25:24]
		reg_dest_o,   // [23:21]
		setPC_o,      // [20]
		mem_read_o,   // [19:18]
		mem_write_o,  // [17:16]
		mem_addr_o};  // [15:0]

	always @(posedge clk) begin
		if(en) begin
			data_out_o <= aluResult;
			setPC_o <= setSomeReg & control_signals_in.aluDest;
			reg_write_o <= (setSomeReg & !control_signals_in.aluDest) ? {control_signals_in.regSetH, control_signals_in.regSetL} : 2'h0;
			reg_dest_o <= control_signals_in.regDest;
			mem_read_o <= control_signals_in.memReadB ? 2'b01 :
							control_signals_in.memReadW ? 2'b11 : 2'b00;
			mem_write_o <= control_signals_in.memWriteB ? 2'b01 :
							control_signals_in.memWriteW ? 2'b11 : 2'b00;
			mem_addr_o <= (control_signals_in.memWriteB | control_signals_in.memWriteW) ? rf_dataB : rf_dataA;

			imm_out <= imm_in;
			pc_out <= pc_in;
			statusReg <= {aluZero, aluCarry};  // not quite right; should only happen for a few instructions
		end
	end
	
	assign dbg_statusreg = statusReg;

endmodule
