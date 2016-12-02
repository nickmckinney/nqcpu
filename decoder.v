module decoder (
);

// instructions
//  add (reg0 <- reg1 + reg2)
//  sub (reg0 <- reg1 - reg2)
//  mul (reg0 <- reg1 * reg2)
//  div (reg0 <- reg1 / reg2)
//  shl (reg0 <- reg1 >> reg2, sign extend)
//  shr (reg0 <- reg1 << reg2, zero extend)  <-- could maybe be one instruction with a direction and extend flags
//  and (reg0 <- reg1 & reg2)
//  or  (reg0 <- reg1 | reg2)
//  xor (reg0 <- reg1 ^ reg2)
//  not (reg0 <- !reg1)
//  neg (reg0 <- -reg1)  <-- could maybe be another mode of not instruction where it also adds 1.
//  bts (reg1th bit of reg0 moved to "zero" status bit, reg1th bit of reg0 is set or reset)
//  mov (reg0 <- reg1, *reg0 <- reg1, reg0 <- *reg1, imm8 -> reg0H, imm8 -> reg0L)
//  b** (relative branch: ne, eq, gt, lt, ge, le, always)
//  jmp (absolute branch)

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

// shl/slr
//  0001 + [reg0] + [dir] + [reg1] + [reg2] + [extend]
//    dir:     0 = left, 1 = right
//    extend:  00 zero
//             01 one
//             10 sign/last bit  (copy bit on the end)
//             11 barrel shift

// not/neg
//  0010 + [reg0] + [which] + [reg1] + 000 + 00
//    which:   0 = not, 1 = neg

// bts
//  0011 + [reg0] + [set or reset] + [reg1] + 00000
//    set or reset: 0 = reset, 1 = set

// mov
//  reg0 <- reg1:   0100 + [reg0] + 0 + [reg1] + [dest byte] + [src byte] + [byte or word] + 00
//  *reg0 <- reg1:  0100 + [reg0] + 1 + [reg1] + 0 + [src byte] + [byte or word] + 0 + 0
//  reg0 <- *reg1:  0100 + [reg0] + 1 + [reg1] + [dest byte] + 0 + [byte or word] + 0 + 1
//  reg0L <- imm8:  0101 + [reg0] + 0 + [immediate value]
//  reg0H <- imm8:  0101 + [reg0] + 1 + [immediate value]
//    byte or word: 0 = word, 1 = byte
//                     for mem operations, word ops must be word-aligned (lsb must be 0)
//    src/dest byte: 0 = low byte, 1 = high byte (ignored for word operations)

// b**
//  0110 + [which] + 0 + [immediate offset]
//    which:  000 eq
//            001 ne
//            010 gt
//            011 ge
//            100 lt
//            101 le
//            110 ??
//            111 always

// jmp
//  0111 + [reg0] + 0 + 00000000
//    basically moves reg0 to pc

endmodule
