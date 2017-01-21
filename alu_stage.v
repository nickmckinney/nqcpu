module alu_stage (
	input clk,
	input en,
	input [15:0] pc_in,
	input [32:0] control_signals_in,
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

	// decode signals
	wire [3:0] aluOp_in;
	wire [2:0] aluReg1_in;
	wire [2:0] aluReg2_in;
	wire [1:0] aluOpSource1_in;
	wire [1:0] aluOpSource2_in;
	wire aluDest_in;
	wire [2:0] regDest_in;
	wire regSetH_in;
	wire regSetL_in;
	wire [2:0] regAddr_in;
	wire memReadB_in;
	wire memReadW_in;
	wire memWriteB_in;
	wire memWriteW_in;
	wire [5:0] setRegCond_in;

	ctrl_decode ctrl_decode_inst (
		.control_signals(control_signals_in),

		.aluOp(aluOp_in),
		.aluReg1(aluReg1_in),
		.aluReg2(aluReg2_in),
		.aluOpSource1(aluOpSource1_in),		// ALU first operand: 0 = reg, 1 = memory read, 2 = imm8, 3 = PC
		.aluOpSource2(aluOpSource2_in),		// ALU second operand: 0 = reg, 1 = ~reg, 2 = PC, 3 = ???
		.aluDest(aluDest_in),					// 0 = reg, 1 = PC

		.regDest(regDest_in),
		.regSetH(regSetH_in),
		.regSetL(regSetL_in),

		.regAddr(regAddr_in),
		.memReadB(memReadB_in),
		.memReadW(memReadW_in),
		.memWriteB(memWriteB_in),
		.memWriteW(memWriteW_in),

		.setRegCond(setRegCond_in)   // {should set when condition is true, Z doesn't matter, S doesn't matter, Z must be this, S must be this}
	);

	wire [15:0] aluSrc1;
	assign aluSrc1 =
		aluOpSource1_in == 2'h0 ? rf_dataA :
		aluOpSource1_in == 2'h2 ? {imm_in} : pc_in;
		
	wire [15:0] aluSrc2;
	assign aluSrc2 =
		aluOpSource2_in == 2'h0 ? rf_dataB :
		aluOpSource2_in == 2'h1 ? ~rf_dataIn : pc_in;

	wire [15:0] aluResult;
	wire aluZero, aluCarry;
	alu alu_inst (
		.op(aluOp_in),
		.x(aluSrc1),
		.y(aluSrc2),
		.result(aluResult),
		.zero(aluZero),
		.carry(aluCarry)
	);
	
	wire setRegZCond, setRegCCond, setSomeReg;
	assign setRegZCond = setRegCond_in[4] | (setRegCond_in[3] == statusReg[1]);
	assign setRegCCond = setRegCond_in[1] | (setRegCond_in[0] == statusReg[0]);
	assign setSomeReg =
		en &
		setRegCond_in[5] &
		(
			setRegCond_in[2] ?
				(setRegZCond & setRegCCond) :
				(setRegZCond | setRegCCond)
		);

	assign rf_regA = aluReg1_in;
	assign rf_regB = aluReg2_in;
	assign rf_dataIn = aluResult;
	
	assign mem_op_next = memReadB_in | memReadW_in | memWriteB_in | memWriteW_in;
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
			setPC_o <= setSomeReg & aluDest_in;
			reg_write_o <= (setSomeReg & !aluDest_in) ? {regSetH_in, regSetL_in} : 2'h0;
			reg_dest_o <= regDest_in;
			mem_read_o <= memReadB_in ? 2'b01 :
							memReadW_in ? 2'b11 : 2'b00;
			mem_write_o <= memWriteB_in ? 2'b01 :
							memWriteW_in ? 2'b11 : 2'b00;
			mem_addr_o <= (memWriteB_in | memWriteW_in) ? rf_dataB : rf_dataA;

			imm_out <= imm_in;
			pc_out <= pc_in;
			statusReg <= {aluZero, aluCarry};  // not quite right; should only happen for a few instructions
		end
	end
	
	assign dbg_statusreg = statusReg;

endmodule
