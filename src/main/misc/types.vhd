package types is
	type aluop_t is (
		ALUOP_SLL,
		ALUOP_SRL,
		ALUOP_SRA,
		ALUOP_ADD,
		ALUOP_SUB,
		ALUOP_AND,
		ALUOP_OR,
		ALUOP_XOR,
		ALUOP_SEQ,
		ALUOP_SNE,
		ALUOP_SLT,
		ALUOP_SGT,
		ALUOP_SLE,
		ALUOP_SGE,
		ALUOP_SLTU,
		ALUOP_SGTU,
		ALUOP_SLEU,
		ALUOP_SGEU
	);

	type branch_t is (
		BRANCH_NO,
		BRANCH_U_R,
		BRANCH_U_A,
		BRANCH_EQ0,
		BRANCH_NE0
	);

	type result_t is (
		RES_EX,
		RES_LD
	);
end types;

