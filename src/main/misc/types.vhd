package types is
	type inst_t is (
		INST_REG,
		INST_IMM,
		INST_JMP
	);

	type branch_t is (
		BRANCH_NO,
		BRANCH_U_R,
		BRANCH_U_A,
		BRANCH_EQ0,
		BRANCH_NE0
	);

	type source_t is (
		SRC_RF,
		SRC_ALU_EX,
		SRC_ALU_MEM,
		SRC_LD_EX,
		SRC_LD_MEM
	);
end types;

