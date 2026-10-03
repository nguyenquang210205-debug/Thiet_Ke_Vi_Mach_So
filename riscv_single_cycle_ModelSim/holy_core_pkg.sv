/** GÓI LÕI HOLY (HOLY CORE PACKAGE)
*
* T?p này ch?a t?p h?p các giá tr? tín hi?u t? RISC-V và các thông s? k? thu?t ??c thù c?a lõi
*
*
* 12/24
*/

`timescale 1ns/1ps

package holy_core_pkg;

  // CÁC MÃ L?NH (OPCODE) C?A INSTRUCTION
  typedef enum logic [6:0] {
    OPCODE_R_TYPE         = 7'b0110011, // L?nh ki?u R
    OPCODE_I_TYPE_ALU     = 7'b0010011, // L?nh ki?u I (dành cho ALU)
    OPCODE_I_TYPE_LOAD    = 7'b0000011, // L?nh ki?u I (dành cho n?p b? nh? - Load)
    OPCODE_S_TYPE         = 7'b0100011, // L?nh ki?u S (l?u b? nh? - Store)
    OPCODE_B_TYPE         = 7'b1100011, // L?nh ki?u B (r? nhánh - Branch)
    OPCODE_U_TYPE_LUI     = 7'b0110111, // L?nh ki?u U (LUI)
    OPCODE_U_TYPE_AUIPC   = 7'b0010111, // L?nh ki?u U (AUIPC)
    OPCODE_J_TYPE         = 7'b1101111, // L?nh ki?u J (nh?y - JAL)
    OPCODE_J_TYPE_JALR    = 7'b1100111  // L?nh ki?u J (JALR)
  } opcode_t;

  // CÁC LO?I ALU DÀNH CHO B? GI?I MÃ ALU (ALU DECODER)
  typedef enum logic [1:0] {
    ALU_OP_LOAD_STORE     = 2'b00,      // Phép toán n?p/l?u
    ALU_OP_BRANCHES       = 2'b01,      // Phép toán r? nhánh
    ALU_OP_MATH           = 2'b10       // Phép toán s? h?c/logic (Math)
  } alu_op_t ;

  // "MATH" F3 (Các ki?u R và I)
  typedef enum logic [2:0] {
    F3_ADD_SUB = 3'b000,                // C?ng ho?c Tr?
    F3_SLL     = 3'b001,                // D?ch trái logic (Shift Left Logical)
    F3_SLT     = 3'b010,                // ??t n?u nh? h?n (Set Less Than, có d?u)
    F3_SLTU    = 3'b011,                // ??t n?u nh? h?n (không d?u)
    F3_XOR     = 3'b100,                // Phép XOR bitwise
    F3_SRL_SRA = 3'b101,                // D?ch ph?i logic ho?c s? h?c
    F3_OR      = 3'b110,                // Phép OR bitwise
    F3_AND     = 3'b111                 // Phép AND bitwise
  } funct3_t;

  // CÁC MÃ HÀM F3 CHO R? NHÁNH (BRANCHES)
  typedef enum logic [2:0] {
    F3_BEQ  = 3'b000,                   // B?ng nhau (Branch if Equal)
    F3_BNE  = 3'b001,                   // Khác nhau (Branch if Not Equal)
    F3_BLT  = 3'b100,                   // Nh? h?n (Branch if Less Than, có d?u)
    F3_BGE  = 3'b101,                   // L?n h?n ho?c b?ng (có d?u)
    F3_BLTU = 3'b110,                   // Nh? h?n (không d?u)
    F3_BGEU = 3'b111                    // L?n h?n ho?c b?ng (không d?u)
  } branch_funct3_t;

  // CÁC MÃ HÀM F3 CHO N?P & L?U (LOAD & STORE)
  typedef enum logic [2:0] {
    F3_WORD = 3'b010,                   // T? d? li?u 32-bit (Word)
    F3_BYTE = 3'b000,                   // 1 Byte (có m? r?ng d?u)
    F3_BYTE_U = 3'b100,                 // 1 Byte không d?u (Byte Unsigned)
    F3_HALFWORD = 3'b001,               // N?a t? 16-bit (Halfword)
    F3_HALFWORD_U = 3'b101              // N?a t? 16-bit không d?u
  } load_store_funct3_t;

  // F7 cho các l?nh d?ch (shifts)
  typedef enum logic [6:0] {
    F7_SLL_SRL  = 7'b0000000,           // D?ch trái/ph?i logic
    F7_SRA  = 7'b0100000                // D?ch ph?i s? h?c (Shift Right Arithmetic)
  } shifts_f7_t;

  // F7 cho các l?nh ki?u R (R-Types)
  typedef enum logic [6:0] {
    F7_ADD  = 7'b0000000,               // Phép c?ng
    F7_SUB  = 7'b0100000                // Phép tr?
  } rtype_f7_t;

  // ?i?u khi?n phép toán s? h?c ALU
  typedef enum logic [3:0] {
    ALU_ADD = 4'b0000,                  // C?ng
    ALU_SUB = 4'b0001,                  // Tr?
    ALU_AND = 4'b0010,                  // AND
    ALU_OR = 4'b0011,                   // OR
    ALU_SLL = 4'b0100,                  // D?ch trái logic
    ALU_SLT = 4'b0101,                  // Nh? h?n (có d?u)
    ALU_SRL = 4'b0110,                  // D?ch ph?i logic
    ALU_SLTU = 4'b0111,                 // Nh? h?n (không d?u)
    ALU_XOR = 4'b1000,                  // XOR
    ALU_SRA = 4'b1001                   // D?ch ph?i s? h?c
  } alu_control_t;

  // Tín hi?u ghi ?è tr? l?i (Write-back)
  typedef struct packed {
    logic [31:0] data;                  // D? li?u ghi v?
    logic valid;                        // Tín hi?u h?p l?
  } write_back_t;

endpackage