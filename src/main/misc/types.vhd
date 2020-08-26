package types is
	type source_t is (
		SRC_RF,
		SRC_ALU_EX,
		SRC_ALU_MEM,
		SRC_LD_EX,
		SRC_LD_MEM
	);

	type dest_t is (
		DST_NO,
		DST_REG,
		DST_IMM,
		DST_LINK
	);
end types;

