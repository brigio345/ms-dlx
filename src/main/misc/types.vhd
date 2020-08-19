package types is
	type inst_t is (
		INST_REG,
		INST_IMM,
		INST_JMP,
		INST_NOP
	);

	type branch_t is (
		BRANCH_NO,
		BRANCH_U_R,	-- J, JAL
		BRANCH_U_A,	-- JR, JALR
		BRANCH_EQ0,	-- BEQZ
		BRANCH_NE0	-- BNEZ
	);

	type source_t is (
		SRC_RF,
		SRC_ALU_EX,
		SRC_ALU_MEM,
		SRC_LD_EX,
		SRC_LD_MEM
	);
end types;

