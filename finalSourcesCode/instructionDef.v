// OP
`define RTYPE_OP      6'b000000
`define LW_OP         6'b100011
`define SW_OP         6'b101011
`define ORI_OP        6'b001101  
`define BEQ_OP        6'b000100
`define JAL_OP        6'b000011
`define LUI_OP        6'b001111
`define ADDI_OP       6'b001000
`define ADDIU_OP      6'b001001
`define J_OP          6'b000010
`define JAL_OP        6'b000011
`define LB_OP         6'b100000
`define LBU_OP        6'b100100
`define LH_OP         6'b100001
`define LHU_OP        6'b100101
`define SB_OP         6'b101000
`define SH_OP         6'b101001
`define SLTI_OP       6'b001010
`define ANDI_OP       6'b001100
`define XORI_OP       6'b001110
`define SLTIU_OP      6'b001011
`define BNE_OP        6'b000101
`define BLEZ_OP       6'b000110
`define BGTZ_OP       6'b000111
`define TWOBZ_OP      6'b000001

// Funct
`define ADDU_FUNCT    6'b100001
`define SUBU_FUNCT    6'b100011
`define SLT_FUNCT     6'b101010
`define JR_FUNCT      6'b001000
`define ADD_FUNCT     6'b100000
`define SUB_FUNCT     6'b100010
`define SLL_FUNCT     6'b000000
`define SRL_FUNCT     6'b000010
`define SRA_FUNCT     6'b000011
`define SLLV_FUNCT    6'b000100
`define SRLV_FUNCT    6'b000110
`define SRAV_FUNCT    6'b000111
`define AND_FUNCT     6'b100100
`define OR_FUNCT      6'b100101
`define XOR_FUNCT     6'b100110
`define NOR_FUNCT     6'b100111
`define JALR_FUNCT    6'b001001
`define MULT_FUNCT    6'b011000
`define MULTU_FUNCT   6'b011001
`define DIV_FUNCT     6'b011010
`define DIVU_FUNCT    6'b011011
`define MFHI_FUNCT    6'b010000
`define MFLO_FUNCT    6'b010010
`define MTHI_FUNCT    6'b010001
`define MTLO_FUNCT    6'b010011

`define BLTZ_BZ       5'b00000
`define BGEZ_BZ       5'b00001