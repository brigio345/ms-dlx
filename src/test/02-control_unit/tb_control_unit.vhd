library ieee;
use ieee.std_logic_1164.all;
use work.coding.all;
use work.types.all;

entity tb_control_unit is
end tb_control_unit;

architecture TB_ARCH of tb_control_unit is
	component control_unit is
		port (
			-- from environment
			I_CFG:			in std_logic;
			I_ENDIAN:		in std_logic;
			I_I_MEM_SZ:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);
			I_D_MEM_SZ:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);

			-- from ID stage
			I_OPCODE:		in std_logic_vector(OPCODE_SZ - 1 downto 0);
			I_FUNC:			in std_logic_vector(FUNC_SZ - 1 downto 0);
			I_ZERO:			in std_logic;
			I_ZERO_SRC_A:		in std_logic;
			I_ZERO_SRC_B:		in std_logic;
			I_SRC_A_EQ_DST_EX:	in std_logic;
			I_SRC_B_EQ_DST_EX:	in std_logic;
			I_SRC_A_EQ_DST_MEM:	in std_logic;
			I_SRC_B_EQ_DST_MEM:	in std_logic;
			I_SRC_A_EQ_DST_WB:	in std_logic;
			I_SRC_B_EQ_DST_WB:	in std_logic;
			I_TAKEN_PREV:		in std_logic;

			-- from EX stage
			I_LD_EX:		in std_logic_vector(1 downto 0);

			-- from MEM stage
			I_LD_MEM:		in std_logic_vector(1 downto 0);

			-- from WB stage
			I_LD_WB:		in std_logic_vector(1 downto 0);

			-- to IF stage
			O_IF_EN:		out std_logic;
			O_ENDIAN:		out std_logic;
			O_I_MEM_SZ:		out std_logic_vector(RF_DATA_SZ - 1 downto 0);
			O_D_MEM_SZ:		out std_logic_vector(RF_DATA_SZ - 1 downto 0);

			-- to ID stage
			O_TAKEN:		out std_logic;
			O_SEL_JMP:		out jump_t;
			O_IMM_SIGN:		out std_logic;
			O_SEL_A:		out source_t;
			O_SEL_B:		out source_t;

			-- to EX stage
			O_SEL_B_IMM:		out std_logic;
			O_ALUOP:		out std_logic_vector(FUNC_SZ - 1 downto 0);

			-- to MEM stage
			O_LD:			out std_logic_vector(1 downto 0);
			O_LD_SIGN:		out std_logic;
			O_STR:			out std_logic_vector(1 downto 0);

			-- to WB stage
			O_SEL_DST:		out dest_t
		);
	end component control_unit;

	constant WAIT_TIME:	time := 2 ns;

	signal CFG:		std_logic;
	signal ENDIAN_IN:	std_logic;
	signal I_MEM_SZ_IN:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal D_MEM_SZ_IN:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal OPCODE:		std_logic_vector(OPCODE_SZ - 1 downto 0);
	signal FUNC:		std_logic_vector(FUNC_SZ - 1 downto 0);
	signal ZERO:		std_logic;
	signal ZERO_SRC_A:	std_logic;
	signal ZERO_SRC_B:	std_logic;
	signal SRC_A_EQ_DST_EX:	std_logic;
	signal SRC_B_EQ_DST_EX:	std_logic;
	signal SRC_A_EQ_DST_MEM:std_logic;
	signal SRC_B_EQ_DST_MEM:std_logic;
	signal SRC_A_EQ_DST_WB:	std_logic;
	signal SRC_B_EQ_DST_WB:	std_logic;
	signal TAKEN_PREV:	std_logic;
	signal LD_EX:		std_logic_vector(1 downto 0);
	signal LD_MEM:		std_logic_vector(1 downto 0);
	signal LD_WB:		std_logic_vector(1 downto 0);
	signal IF_EN:		std_logic;
	signal ENDIAN_OUT:	std_logic;
	signal I_MEM_SZ_OUT:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal D_MEM_SZ_OUT:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal TAKEN:		std_logic;
	signal SEL_JMP:		jump_t;
	signal IMM_SIGN:	std_logic;
	signal SEL_A:		source_t;
	signal SEL_B:		source_t;
	signal SEL_B_IMM:	std_logic;
	signal ALUOP:		std_logic_vector(FUNC_SZ - 1 downto 0);
	signal LD:		std_logic_vector(1 downto 0);
	signal LD_SIGN:		std_logic;
	signal STR:		std_logic_vector(1 downto 0);
	signal SEL_DST:		dest_t;
begin
	dut: control_unit
		port map (
			I_CFG			=> CFG,
			I_ENDIAN		=> ENDIAN_IN,
			I_I_MEM_SZ		=> I_MEM_SZ_IN,
			I_D_MEM_SZ		=> D_MEM_SZ_IN,
			I_OPCODE		=> OPCODE,
			I_FUNC			=> FUNC,
			I_ZERO			=> ZERO,
			I_ZERO_SRC_A		=> ZERO_SRC_A,
			I_ZERO_SRC_B		=> ZERO_SRC_B,
			I_SRC_A_EQ_DST_EX	=> SRC_A_EQ_DST_EX,
			I_SRC_B_EQ_DST_EX	=> SRC_B_EQ_DST_EX,
			I_SRC_A_EQ_DST_MEM	=> SRC_A_EQ_DST_MEM,
			I_SRC_B_EQ_DST_MEM	=> SRC_B_EQ_DST_MEM,
			I_SRC_A_EQ_DST_WB	=> SRC_A_EQ_DST_WB,
			I_SRC_B_EQ_DST_WB	=> SRC_B_EQ_DST_WB,
			I_TAKEN_PREV		=> TAKEN_PREV,
			I_LD_EX			=> LD_EX,
			I_LD_MEM		=> LD_MEM,
			I_LD_WB			=> LD_WB,
			O_IF_EN			=> IF_EN,
			O_ENDIAN		=> ENDIAN_OUT,
			O_I_MEM_SZ		=> I_MEM_SZ_OUT,
			O_D_MEM_SZ		=> D_MEM_SZ_OUT,
			O_TAKEN			=> TAKEN,
			O_SEL_JMP		=> SEL_JMP,
			O_IMM_SIGN		=> IMM_SIGN,
			O_SEL_A			=> SEL_A,
			O_SEL_B			=> SEL_B,
			O_SEL_B_IMM		=> SEL_B_IMM,
			O_ALUOP			=> ALUOP,
			O_LD			=> LD,
			O_LD_SIGN		=> LD_SIGN,
			O_STR			=> STR,
			O_SEL_DST		=> SEL_DST
		);

	stimuli: process
	begin
		CFG			<= '1';
		ENDIAN_IN		<= '0';
		I_MEM_SZ_IN		<= x"10000000";
		D_MEM_SZ_IN		<= x"10000000";
		OPCODE			<= OPCODE_NOP;
		FUNC			<= FUNC_ADD;
		ZERO			<= '0';
		ZERO_SRC_A		<= '1';
		ZERO_SRC_B		<= '1';
		SRC_A_EQ_DST_EX		<= '0';
		SRC_B_EQ_DST_EX		<= '0';
		SRC_A_EQ_DST_MEM	<= '0';
		SRC_B_EQ_DST_MEM	<= '0';
		SRC_A_EQ_DST_WB		<= '0';
		SRC_B_EQ_DST_WB		<= '0';
		TAKEN_PREV		<= '0';
		LD_EX			<= "00";
		LD_MEM			<= "00";
		LD_WB			<= "00";

		wait for WAIT_TIME;

		assert ((ENDIAN_OUT = '0') AND (I_MEM_SZ_OUT = x"10000000") AND
				(D_MEM_SZ_OUT = x"10000000"))
			report "unexpected stored configuration values";

		CFG			<= '0';
		ENDIAN_IN		<= '0';
		I_MEM_SZ_IN		<= x"10000000";
		D_MEM_SZ_IN		<= x"10000000";
		OPCODE			<= OPCODE_RTYPE;
		FUNC			<= FUNC_ADD;
		ZERO			<= '0';
		ZERO_SRC_A		<= '1';
		ZERO_SRC_B		<= '1';
		SRC_A_EQ_DST_EX		<= '0';
		SRC_B_EQ_DST_EX		<= '0';
		SRC_A_EQ_DST_MEM	<= '0';
		SRC_B_EQ_DST_MEM	<= '0';
		SRC_A_EQ_DST_WB		<= '0';
		SRC_B_EQ_DST_WB		<= '0';
		TAKEN_PREV		<= '1';
		LD_EX			<= "00";
		LD_MEM			<= "00";
		LD_WB			<= "00";

		wait for WAIT_TIME;

		assert ((IF_EN = '1') AND (TAKEN = '0') AND (STR = "00") AND
				(SEL_DST = DST_NO))
			report "expected stall due to TAKEN_PREV = '1' not generated";

		CFG			<= '0';
		ENDIAN_IN		<= '0';
		I_MEM_SZ_IN		<= x"10000000";
		D_MEM_SZ_IN		<= x"10000000";
		OPCODE			<= OPCODE_RTYPE;
		FUNC			<= FUNC_ADD;
		ZERO			<= '0';
		ZERO_SRC_A		<= '0';
		ZERO_SRC_B		<= '0';
		SRC_A_EQ_DST_EX		<= '1';
		SRC_B_EQ_DST_EX		<= '0';
		SRC_A_EQ_DST_MEM	<= '0';
		SRC_B_EQ_DST_MEM	<= '0';
		SRC_A_EQ_DST_WB		<= '0';
		SRC_B_EQ_DST_WB		<= '0';
		TAKEN_PREV		<= '0';
		LD_EX			<= "10";
		LD_MEM			<= "00";
		LD_WB			<= "00";

		wait for WAIT_TIME;

		assert ((IF_EN = '0') AND (TAKEN = '0') AND (STR = "00") AND
				(SEL_DST = DST_NO))
			report "expected stall due to data not ready not generated";

		wait;
	end process stimuli;
end TB_ARCH;

