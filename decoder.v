typedef struct packed {
	logic [3:0] aluOp;
	logic [2:0] aluReg1;
	logic [2:0] aluReg2;
	logic [1:0] aluOpSource1;		// ALU first operand: 0 = reg, 1 = memory read, 2 = imm8, 3 = PC
	logic [1:0] aluOpSource2;		// ALU second operand: 0 = reg, 1 = ~reg, 2 = PC, 3 = ???
	logic aluDest;					// 0 = reg, 1 = PC

	logic [3:0] regDest;
	logic regSetH;
	logic regSetL;

	logic [2:0] regAddr;
	logic memReadB;
	logic memReadW;
	logic memWriteB;
	logic memWriteW;

	logic [5:0] setRegCond;   // {should set when condition is true, Z doesn't matter, S doesn't matter, Z must be this, S must be this}
} decoder_signals;

module decoder (
	input [15:0] instr,
	
	output decoder_signals signals_out,
	output [15:0] imm
);

	localparam [3:0] ALU_ADD = 4'h0;
	localparam [3:0] ALU_SUB = 4'h1;
	localparam [3:0] ALU_MULT = 4'h2;
	localparam [3:0] ALU_DIV = 4'h3;
	localparam [3:0] ALU_AND = 4'h4;
	localparam [3:0] ALU_OR = 4'h5;
	localparam [3:0] ALU_XOR = 4'h6;
	localparam [3:0] ALU_JUSTX = 4'h7;
	localparam [3:0] ALU_SHL_ZE = 4'h8;  // zero extend
	localparam [3:0] ALU_SHL_OE = 4'h9;  // one extend
	localparam [3:0] ALU_SHL_SE = 4'hA;  // sign (last bit) extend
	localparam [3:0] ALU_SHL_BE = 4'hB;  // barrel shift
	localparam [3:0] ALU_SHR_ZE = 4'hC;
	localparam [3:0] ALU_SHR_OE = 4'hD;
	localparam [3:0] ALU_SHR_SE = 4'hE;
	localparam [3:0] ALU_SHR_BE = 4'hF;

// instructions
//  add (reg0 <- reg1 + reg2)
//  addpc (reg0 <- PC + imm8)
//  sub (reg0 <- reg1 - reg2)
//  mul (reg0 <- reg1 * reg2)
//  div (reg0 <- reg1 / reg2)
//  shl (reg0 <- reg1 >> reg2, sign extend)
//  shr (reg0 <- reg1 << reg2, zero extend)  <-- could maybe be one instruction with a direction and extend flags
//  and (reg0 <- reg1 & reg2)
//  or  (reg0 <- reg1 | reg2)
//  xor (reg0 <- reg1 ^ reg2)
//  not (reg0 <- ~reg2)
//  neg (reg0 <- -reg2)
//  bts (reg2 <- reg0, reg0 <- (reg0 | reg1 (if setting) OR reg0 & ~reg1 (if resetting)))
//  mov (reg0 <- reg1, *reg0 <- reg1, reg0 <- *reg1, imm8 -> reg0H, imm8 -> reg0L)
//  b** (relative branch: ne, eq, gt, lt, ge, le, always)
//  jmp (absolute branch)

// WISH LIST:
//  inc/dec for adding 1 and -1 in one instruction
//  cmp, which is sub without actually storing the result
//  cmpi, which is cmp with a sign-extended immediate argument

// 8 registers, 3 bits per register argument
// 4 bits for instruction
// instr with 3 reg params is 13 bits

// add/sub/mul/div/and/or/xor
//  0000 + [reg0] + [op-msb] + [reg1] + [reg2] + [op-2lsb]
//    op:  0 00 add
//         0 01 sub
//         0 10 mul
//         0 11 div
//         1 00 and
//         1 01 or
//         1 10 xor
//         1 11 ???

// addpc
//  1000 + [reg0] + 0 + [imm]
//  adds the immediate value (signed) to the current value of PC and puts the result in reg0

// shl/slr
//  0001 + [reg0] + [dir] + [reg1] + [reg2] + [extend]
//    dir:     0 = left, 1 = right
//    extend:  00 zero
//             01 one
//             10 sign/last bit  (copy bit on the end)
//             11 barrel shift

// not/neg
//  0010 + [reg0] + [which] + 000 + [reg2] + 00
//    which:   0 = not, 1 = neg

// bts -- NOT IMPLEMENTED YET
//  0011 + [reg0] + [set or reset] + [reg1] + 00000
//    set or reset: 0 = reset, 1 = set

// mov
//  reg0 <- reg1:   0100 + [reg0] + 0 + [reg1] + 000 + 1 + 0


// mov
//  *reg2 <- reg1:  0100 + 000 + 1 + [reg1] + [reg2] + [byte or word] + 0
//  reg0 <- *reg1:  0100 + [reg0] + 1 + [reg1] + [dest byte] + 0 + 0 + [byte or word] + 1
//    byte or word: 0 = byte, 1 = word
//                     for mem operations, word ops must be word-aligned (lsb must be 0)
//    dest byte: 0 = low byte, 1 = high byte (ignored for word operations)


// mov
//  reg0L <- imm8:  0101 + [reg0] + [high or low] + [immediate value]


// b**
//  0110 + [which] + 0 + [immediate offset]
//    which:  000 eq   (Z = 1 and C = 0)
//            001 ne   (Z = 0 and C = x)
//            010 gt   (Z = 0 and C = 0)
//            011 ge   (Z = 1 or C = 0)
//            100 lt   (Z = 0 and C = 1)
//            101 le   (Z = 1 or C = 1)
//            110 ??
//            111 always  (Z = x, C = x)

// jmp
//  0111 + 00000 + [reg1] + 00000
//    basically moves reg1 to pc

// nop
//  1111 + xxxx xxxx xxxx

	// instruction decode
	wire [3:0] which_instr = instr[15:12];
	wire instr_math, instr_shift, instr_notneg, instr_bts, instr_mov, instr_movimm, instr_branch, instr_jmp, instr_addpc, instr_nop;
	assign {instr_math, instr_shift, instr_notneg, instr_bts, instr_mov, instr_movimm, instr_branch, instr_jmp, instr_addpc, instr_nop} =
		which_instr == 4'h0 ? 10'b1000000000 :
		which_instr == 4'h1 ? 10'b0100000000 :
		which_instr == 4'h2 ? 10'b0010000000 :
		which_instr == 4'h3 ? 10'b0001000000 :
		which_instr == 4'h4 ? 10'b0000100000 :
		which_instr == 4'h5 ? 10'b0000010000 :
		which_instr == 4'h6 ? 10'b0000001000 :
		which_instr == 4'h7 ? 10'b0000000100 : 
		which_instr == 4'h8 ? 10'b0000000010 : 10'b0000000001;

	// src/dest registers
	wire [2:0] reg0 = instr[11:9];
	wire [2:0] reg1 = instr[7:5];
	wire [2:0] reg2 = instr[4:2];
	
	wire [7:0] imm_param = instr[7:0];
	wire [15:0] ext_imm_param = {{8{instr[7]}}, instr[7:0]};  // sign-extended immediate parameter

	// for instr_math
	wire [2:0] math_op = {instr[8], instr[1:0]};

	// for instr_shift
	wire shift_dir = instr[8];
	wire [1:0] shift_extend = instr[1:0];

	// for instr_notneg
	wire notneg_is_neg = instr[8];

	// for instr_mov
	wire mov_dest_byte_high = instr[4];
	wire mov_word = instr[1];
	wire mov_mem = instr[8];
	wire mov_mem_read = instr[0];

	// for instr_movimm
	wire movimm_high = instr[8];
	wire [7:0] movimm_imm = imm_param;

	// for instr_branch
	wire [2:0] branch_cond = instr[11:9];
	wire [7:0] branch_offset = instr[7:0];
	wire [5:0] branch_set_cond =
		branch_cond == 3'h0 ? 6'b1_01_1_00 :		// EQ
		branch_cond == 3'h1 ? 6'b1_00_1_10 :		// NE
		branch_cond == 3'h2 ? 6'b1_00_1_00 :		// GT
		branch_cond == 3'h3 ? 6'b1_01_0_00 :		// GE
		branch_cond == 3'h4 ? 6'b1_00_1_01 :		// LT
		branch_cond == 3'h5 ? 6'b1_01_0_01 :		// LE
			6'b1_10_0_10;

	assign signals_out.aluOp =
		instr_math ? {1'b0, math_op} :
		instr_shift ? {1'b1, shift_dir, shift_extend} :
		instr_notneg ? ALU_ADD :
		instr_mov ? ALU_JUSTX :
		instr_movimm ? ALU_JUSTX :
			ALU_ADD;

	assign signals_out.aluReg1 = reg1;
	assign signals_out.aluReg2 = reg2;

	assign signals_out.aluOpSource1 =
		instr_mov ? ((mov_mem & mov_mem_read) ? 2'h1 : 2'h0) :
		instr_notneg ? 2'h2 :
		instr_movimm ? 2'h2 :
		instr_branch ? 2'h2 :
			2'h0;

	assign signals_out.aluOpSource2 =
		instr_notneg ? 2'h1 :
		instr_branch ? 2'h2 :
			2'h0;

	assign signals_out.aluDest =
		instr_branch ? 1'b1 :
		instr_jmp ? 1'b1 :
			1'b0;

	assign signals_out.regDest = {1'b0, reg0};
	
	assign signals_out.regSetH =
		instr_mov ? (mov_word | mov_dest_byte_high) :
		instr_movimm ? movimm_high :
			1'b1;

	assign signals_out.regSetL =
		instr_mov ? (mov_word | !mov_dest_byte_high) :
		instr_movimm ? !movimm_high :
			1'b1;

	assign signals_out.regAddr = mov_mem_read ? reg1 : reg2;  // for all other instructions, this is a don't-care
	assign signals_out.memReadB = instr_mov ? (mov_mem & (mov_mem_read & !mov_word)) : 1'b0;
	assign signals_out.memReadW = instr_mov ? (mov_mem & (mov_mem_read & mov_word)) : 1'b0;
	assign signals_out.memWriteB = instr_mov ? (mov_mem & (!mov_mem_read & !mov_word)) : 1'b0;
	assign signals_out.memWriteW = instr_mov ? (mov_mem & (!mov_mem_read & mov_word)) : 1'b0;
	
	assign signals_out.setRegCond =
		instr_mov ? ((!mov_mem | mov_mem_read) ? 6'b1_10_0_10 : 6'b000000) :
		instr_branch ? branch_set_cond :
		instr_nop ? 6'b000000 :
			6'b1_10_0_10;

	assign imm =
		instr_notneg ? {15'b0, notneg_is_neg} :
		instr_branch ? ext_imm_param :
		instr_addpc ? ext_imm_param :
			{movimm_imm, movimm_imm};

endmodule
