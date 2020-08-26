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
			I_TAKEN_PREV:		in std_logic;

			-- from EX stage
			I_LD_EX:		in std_logic_vector(1 downto 0);

			-- from MEM stage
			I_LD_MEM:		in std_logic_vector(1 downto 0);

			-- to IF stage
			O_IF_EN:		out std_logic;
			O_ENDIAN:		out std_logic;

			-- to ID stage
			O_TAKEN:		out std_logic;
			O_SEL_JMP_OP1:		out std_logic;
			O_SEL_JMP_OP2:		out std_logic_vector(1 downto 0);
			O_SIGNED:		out std_logic;
			O_SEL_A:		out source_t;
			O_SEL_B:		out source_t;

			-- to EX stage
			O_SEL_B_IMM:		out std_logic;
			O_ALUOP:		out std_logic_vector(FUNC_SZ - 1 downto 0);

			-- to MEM stage
			O_LD:			out std_logic_vector(1 downto 0);
			O_STR:			out std_logic_vector(1 downto 0);

			-- to WB stage
			O_SEL_DST:		out dest_t
		);
	end component control_unit;

	constant WAIT_TIME:	time := 2 ns;

	signal CFG:		std_logic;
	signal I_ENDIAN:	std_logic;
	signal OPCODE:		std_logic_vector(OPCODE_SZ - 1 downto 0);
	signal FUNC:		std_logic_vector(FUNC_SZ - 1 downto 0);
	signal ZERO:		std_logic;
	signal ZERO_SRC_A:	std_logic;
	signal ZERO_SRC_B:	std_logic;
	signal SRC_A_EQ_DST_EX:	std_logic;
	signal SRC_B_EQ_DST_EX:	std_logic;
	signal SRC_A_EQ_DST_MEM:std_logic;
	signal SRC_B_EQ_DST_MEM:std_logic;
	signal TAKEN_PREV:	std_logic;
	signal LD_EX:		std_logic_vector(1 downto 0);
	signal LD_MEM:		std_logic_vector(1 downto 0);
	signal IF_EN:		std_logic;
	signal O_ENDIAN:	std_logic;
	signal TAKEN:		std_logic;
	signal SEL_JMP_OP1:	std_logic;
	signal SEL_JMP_OP2:	std_logic_vector(1 downto 0);
	signal S_SIGNED:	std_logic;
	signal SEL_A:		source_t;
	signal SEL_B:		source_t;
	signal SEL_B_IMM:	std_logic;
	signal ALUOP:		std_logic_vector(FUNC_SZ - 1 downto 0);
	signal LD:		std_logic_vector(1 downto 0);
	signal STR:		std_logic_vector(1 downto 0);
	signal SEL_DST:		dest_t;
begin
	dut: control_unit
		port map (
			I_CFG		=> CFG,
			I_ENDIAN	=> I_ENDIAN,
			I_OPCODE	=> OPCODE,
			I_FUNC		=> FUNC,
			I_ZERO		=> ZERO,
			I_ZERO_SRC_A	=> ZERO_SRC_A,
			I_ZERO_SRC_B	=> ZERO_SRC_B,
			I_SRC_A_EQ_DST_EX	=> SRC_A_EQ_DST_EX,
			I_SRC_B_EQ_DST_EX	=> SRC_B_EQ_DST_EX,
			I_SRC_A_EQ_DST_MEM	=> SRC_A_EQ_DST_MEM,
			I_SRC_B_EQ_DST_MEM	=> SRC_B_EQ_DST_MEM,
			I_TAKEN_PREV	=> TAKEN_PREV,
			I_LD_EX		=> LD_EX,
			I_LD_MEM	=> LD_MEM,
			O_IF_EN		=> IF_EN,
			O_ENDIAN	=> O_ENDIAN,
			O_TAKEN		=> TAKEN,
			O_SEL_JMP_OP1	=> SEL_JMP_OP1,
			O_SEL_JMP_OP2	=> SEL_JMP_OP2,
			O_SIGNED	=> S_SIGNED,
			O_SEL_A		=> SEL_A,
			O_SEL_B		=> SEL_B,
			O_SEL_B_IMM	=> SEL_B_IMM,
			O_ALUOP		=> ALUOP,
			O_LD		=> LD,
			O_STR		=> STR,
			O_SEL_DST	=> SEL_DST
		);

	stimuli: process
	begin
		CFG		<= '1';
		I_ENDIAN	<= '0';

		wait for WAIT_TIME;

		CFG		<= '0';
		OPCODE		<= (others => '0');
		FUNC		<= (others => '0');
		ZERO		<= '0';
		ZERO_SRC_A	<= '0';
		ZERO_SRC_B	<= '0';
		SRC_A_EQ_DST_EX	<= '0';
		SRC_B_EQ_DST_EX	<= '0';
		SRC_A_EQ_DST_MEM<= '0';
		SRC_B_EQ_DST_MEM<= '0';
		TAKEN_PREV	<= '0';
		LD_EX		<= "00";
		LD_MEM		<= "00";

		wait for WAIT_TIME;

		wait;
	end process stimuli;
end TB_ARCH;

