package types is
	type inst_t is (
		INST_REG,
		INST_IMM,
		INST_JMP_REL,	-- J, JAL
		INST_JMP_ABS,	-- JR, JALR
		INST_NOP
	);

	type branch_t is (
		BR_NO,
		BR_UNC_REL,	-- J, JAL
		BR_UNC_ABS,	-- JR, JALR
		BR_EQ0_REL,	-- BEQZ
		BR_NE0_REL	-- BNEZ
	);

	type source_t is (
		SRC_RF,
		SRC_ALU_EX,
		SRC_ALU_MEM,
		SRC_LD_EX,
		SRC_LD_MEM
	);
end types;

