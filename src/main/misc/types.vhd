package types is
	type jump_t is (
		JMP_ABS,
		JMP_REL_IMM,
		JMP_REL_OFF
	);
	
	type source_t is (
		SRC_RF,
		SRC_ALU_EX,
		SRC_LD_EX,
		SRC_ALU_MEM,
		SRC_LD_MEM,
		SRC_ALU_WB,
		SRC_LD_WB
	);

	type dest_t is (
		DST_NO,
		DST_REG,
		DST_IMM,
		DST_LINK
	);
end types;

