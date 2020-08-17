library ieee;
use ieee.std_logic_1164.all;

package coding is
	-- Instruction fields sizes
	constant INST_SZ:	integer := 32;
	constant OPCODE_SZ:	integer := 6;
	constant RF_ADDR_SZ:	integer := 5;
	constant RF_DATA_SZ:	integer := 5;

	constant OPCODE_START:	integer := 0;
	constant OPCODE_END:	integer := OPCODE_START + OPCODE_SZ - 1;

	-- Register-register instructions
	constant FUNC_SZ:	integer := 11;

	constant OPCODE_RTYPE:	std_logic_vector(OPCODE_SZ - 1 downto 0) := "000000";

	constant R_SRC1_START:	integer := OPCODE_END + 1;
	constant R_SRC1_END:	integer := R_SRC1_START + RF_ADDR_SZ - 1;

	constant R_SRC2_START:	integer := R_SRC1_END + 1;
	constant R_SRC2_END:	integer := R_SRC2_START + RF_ADDR_SZ - 1;

	constant R_DST_START:	integer := R_SRC2_END + 1;
	constant R_DST_END:	integer := R_DST_START + RF_ADDR_SZ - 1;

	constant FUNC_START:	integer := R_DST_END - 1;
	constant FUNC_END:	integer := FUNC_START + FUNC_SZ - 1;

	constant FUNC_SLL:	std_logic_vector(FUNC_SZ - 1 downto 0) := "00000000100"; -- r, 0x04
	constant FUNC_SRL:	std_logic_vector(FUNC_SZ - 1 downto 0) := "00000000110"; -- r, 0x06
	constant FUNC_SRA:	std_logic_vector(FUNC_SZ - 1 downto 0) := "00000000111"; -- r, 0x07
	constant FUNC_ADD:	std_logic_vector(FUNC_SZ - 1 downto 0) := "00000100000"; -- r, 0x20
	constant FUNC_ADDU:	std_logic_vector(FUNC_SZ - 1 downto 0) := "00000100001"; -- r, 0x21
	constant FUNC_SUB:	std_logic_vector(FUNC_SZ - 1 downto 0) := "00000100010"; -- r, 0x22
	constant FUNC_SUBU:	std_logic_vector(FUNC_SZ - 1 downto 0) := "00000100011"; -- r, 0x23
	constant FUNC_AND:	std_logic_vector(FUNC_SZ - 1 downto 0) := "00000100100"; -- r, 0x24
	constant FUNC_OR:	std_logic_vector(FUNC_SZ - 1 downto 0) := "00000100101"; -- r, 0x25
	constant FUNC_XOR:	std_logic_vector(FUNC_SZ - 1 downto 0) := "00000100110"; -- r, 0x26
	constant FUNC_SEQ:	std_logic_vector(FUNC_SZ - 1 downto 0) := "00000101000"; -- r, 0x28
	constant FUNC_SNE:	std_logic_vector(FUNC_SZ - 1 downto 0) := "00000101001"; -- r, 0x29
	constant FUNC_SLT:	std_logic_vector(FUNC_SZ - 1 downto 0) := "00000101010"; -- r, 0x2A
	constant FUNC_SGT:	std_logic_vector(FUNC_SZ - 1 downto 0) := "00000101011"; -- r, 0x2B
	constant FUNC_SLE:	std_logic_vector(FUNC_SZ - 1 downto 0) := "00000101100"; -- r, 0x2C
	constant FUNC_SGE:	std_logic_vector(FUNC_SZ - 1 downto 0) := "00000101101"; -- r, 0x2D
	constant FUNC_MOVI2S:	std_logic_vector(FUNC_SZ - 1 downto 0) := "00000110000"; -- r2, 0x30
	constant FUNC_MOVS2I:	std_logic_vector(FUNC_SZ - 1 downto 0) := "00000110001"; -- r2, 0x31
	constant FUNC_MOVF:	std_logic_vector(FUNC_SZ - 1 downto 0) := "00000110010"; -- r2, 0x32
	constant FUNC_MOVD:	std_logic_vector(FUNC_SZ - 1 downto 0) := "00000110011"; -- r2, 0x33
	constant FUNC_MOVFP2I:	std_logic_vector(FUNC_SZ - 1 downto 0) := "00000110100"; -- r2, 0x34
	constant FUNC_MOVI2FP:	std_logic_vector(FUNC_SZ - 1 downto 0) := "00000110101"; -- r2, 0x35
	constant FUNC_MOVI2T:	std_logic_vector(FUNC_SZ - 1 downto 0) := "00000110110"; -- r, 0x36
	constant FUNC_MOVT2I:	std_logic_vector(FUNC_SZ - 1 downto 0) := "00000110111"; -- r, 0x37
	constant FUNC_SLTU:	std_logic_vector(FUNC_SZ - 1 downto 0) := "00000111010"; -- r, 0x3A
	constant FUNC_SGTU:	std_logic_vector(FUNC_SZ - 1 downto 0) := "00000111011"; -- r, 0x3B
	constant FUNC_SLEU:	std_logic_vector(FUNC_SZ - 1 downto 0) := "00000111100"; -- r, 0x3C
	constant FUNC_SGEU:	std_logic_vector(FUNC_SZ - 1 downto 0) := "00000111101"; -- r, 0x3D

	-- Register-immediate instructions
	constant IMM_SZ:	integer := 16;

	constant I_SRC1_START:	integer := OPCODE_END + 1;
	constant I_SRC1_END:	integer := I_SRC1_START + RF_ADDR_SZ - 1;

	constant I_DST_START:	integer := I_SRC1_END + 1;
	constant I_DST_END:	integer := I_DST_START + RF_ADDR_SZ - 1;

	constant I_IMM_START:	integer := I_DST_END + 1;
	constant I_IMM_END:	integer := I_IMM_START + IMM_SZ - 1;

	constant OPCODE_ADDI:	std_logic_vector(OPCODE_SZ - 1 downto 0) := "001000"; -- i, 0x08
	constant OPCODE_ADDUI:	std_logic_vector(OPCODE_SZ - 1 downto 0) := "001001"; -- i, 0x09
	constant OPCODE_SUBI:	std_logic_vector(OPCODE_SZ - 1 downto 0) := "001010"; -- i, 0x0A
	constant OPCODE_SUBUI:	std_logic_vector(OPCODE_SZ - 1 downto 0) := "001011"; -- i, 0x0B
	constant OPCODE_ANDI:	std_logic_vector(OPCODE_SZ - 1 downto 0) := "001100"; -- i, 0x0C
	constant OPCODE_ORI:	std_logic_vector(OPCODE_SZ - 1 downto 0) := "001101"; -- i, 0x0D
	constant OPCODE_XORI:	std_logic_vector(OPCODE_SZ - 1 downto 0) := "001110"; -- i, 0x0E
	constant OPCODE_LHI:	std_logic_vector(OPCODE_SZ - 1 downto 0) := "001111"; -- i1, 0x0F
	constant OPCODE_SLLI:	std_logic_vector(OPCODE_SZ - 1 downto 0) := "010100"; -- i, 0x14
	constant OPCODE_SRLI:	std_logic_vector(OPCODE_SZ - 1 downto 0) := "010110"; -- i, 0x16
	constant OPCODE_SRAI:	std_logic_vector(OPCODE_SZ - 1 downto 0) := "010111"; -- i, 0x17
	constant OPCODE_SEQI:	std_logic_vector(OPCODE_SZ - 1 downto 0) := "011000"; -- i, 0x18
	constant OPCODE_SNEI:	std_logic_vector(OPCODE_SZ - 1 downto 0) := "011001"; -- i, 0x19
	constant OPCODE_SLTI:	std_logic_vector(OPCODE_SZ - 1 downto 0) := "011010"; -- i, 0x1A
	constant OPCODE_SGTI:	std_logic_vector(OPCODE_SZ - 1 downto 0) := "011011"; -- i, 0x1B
	constant OPCODE_SLEI:	std_logic_vector(OPCODE_SZ - 1 downto 0) := "011100"; -- i, 0x1C
	constant OPCODE_SGEI:	std_logic_vector(OPCODE_SZ - 1 downto 0) := "011101"; -- i, 0x1D
	constant OPCODE_SLTUI:	std_logic_vector(OPCODE_SZ - 1 downto 0) := "111010"; -- i, 0x3A
	constant OPCODE_SGTUI:	std_logic_vector(OPCODE_SZ - 1 downto 0) := "111011"; -- i, 0x3B
	constant OPCODE_SLEUI:	std_logic_vector(OPCODE_SZ - 1 downto 0) := "111100"; -- i, 0x3C
	constant OPCODE_SGEUI:	std_logic_vector(OPCODE_SZ - 1 downto 0) := "111101"; -- i, 0x3D

	-- Load & store instructions (register-immediate instructions subset)
	constant OPCODE_LB:	std_logic_vector(OPCODE_SZ - 1 downto 0) := "100000"; -- l, 0x20
	constant OPCODE_LH:	std_logic_vector(OPCODE_SZ - 1 downto 0) := "100001"; -- l, 0x21
	constant OPCODE_LW:	std_logic_vector(OPCODE_SZ - 1 downto 0) := "100011"; -- l, 0x23
	constant OPCODE_LBU:	std_logic_vector(OPCODE_SZ - 1 downto 0) := "100100"; -- l, 0x24
	constant OPCODE_LHU:	std_logic_vector(OPCODE_SZ - 1 downto 0) := "100101"; -- l, 0x25
	constant OPCODE_LF:	std_logic_vector(OPCODE_SZ - 1 downto 0) := "100110"; -- l, 0x26
	constant OPCODE_LD:	std_logic_vector(OPCODE_SZ - 1 downto 0) := "100111"; -- l, 0x27
	constant OPCODE_SB:	std_logic_vector(OPCODE_SZ - 1 downto 0) := "101000"; -- s, 0x28
	constant OPCODE_SH:	std_logic_vector(OPCODE_SZ - 1 downto 0) := "101001"; -- s, 0x29
	constant OPCODE_SW:	std_logic_vector(OPCODE_SZ - 1 downto 0) := "101011"; -- s, 0x2B
	constant OPCODE_SF:	std_logic_vector(OPCODE_SZ - 1 downto 0) := "101110"; -- s, 0x2E
	constant OPCODE_SD:	std_logic_vector(OPCODE_SZ - 1 downto 0) := "101111"; -- s, 0x2F

	-- Jump instructions
	constant OFF_SZ:	integer := 26;

	constant J_OFF_START:	integer := OPCODE_END + 1;
	constant J_OFF_END:	integer := J_OFF_START + OFF_SZ - 1;

	constant OPCODE_J:	std_logic_vector(OPCODE_SZ - 1 downto 0) := "000010"; -- j, 0x02
	constant OPCODE_JAL:	std_logic_vector(OPCODE_SZ - 1 downto 0) := "000011"; -- j, 0x03
	constant OPCODE_BEQZ:	std_logic_vector(OPCODE_SZ - 1 downto 0) := "000100"; -- b, 0x04
	constant OPCODE_BNEZ:	std_logic_vector(OPCODE_SZ - 1 downto 0) := "000101"; -- b, 0x05
	constant OPCODE_BFPT:	std_logic_vector(OPCODE_SZ - 1 downto 0) := "000110"; -- b0, 0x06
	constant OPCODE_BFPF:	std_logic_vector(OPCODE_SZ - 1 downto 0) := "000111"; -- b0, 0x07
	constant OPCODE_JR:	std_logic_vector(OPCODE_SZ - 1 downto 0) := "010010"; -- jr, 0x12
	constant OPCODE_JALR:	std_logic_vector(OPCODE_SZ - 1 downto 0) := "010011"; -- jalr, 0x13

	-- General instructions
	constant OPCODE_RFE:	std_logic_vector(OPCODE_SZ - 1 downto 0) := "010000"; -- n, 0x10
	constant OPCODE_TRAP:	std_logic_vector(OPCODE_SZ - 1 downto 0) := "010001"; -- t, 0x11
	constant OPCODE_NOP:	std_logic_vector(OPCODE_SZ - 1 downto 0) := "010101"; -- n, 0x15
	constant OPCODE_ITLB:	std_logic_vector(OPCODE_SZ - 1 downto 0) := "111000"; -- n, 0x38
end coding;

