package types is
	type inst_t is (
		INST_REG,
		INST_IMM,
		INST_JMP_REL,	-- J, JAL
		INST_JMP_ABS,	-- JR, JALR
		INST_NOP
	);

	type source_t is (
		SRC_RF,
		SRC_ALU_EX,
		SRC_ALU_MEM,
		SRC_LD_EX,
		SRC_LD_MEM
	);
end types;

