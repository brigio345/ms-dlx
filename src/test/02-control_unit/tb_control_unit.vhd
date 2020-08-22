library ieee;
use ieee.std_logic_1164.all;
use work.coding.all;
use work.types.all;

entity tb_control_unit is
end tb_control_unit;

architecture TB_ARCH of tb_control_unit is
	component control_unit is
		port (
			-- from ID stage
			I_OPCODE:	in std_logic_vector(OPCODE_SZ - 1 downto 0);
			I_FUNC:		in std_logic_vector(FUNC_SZ - 1 downto 0);
			I_SRC_A:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
			I_SRC_B:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
			I_DST_R:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
			I_TAKEN_PREV:	in std_logic;

			-- from EX stage
			I_DST_EX:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
			I_LD_EX:	in std_logic;

			-- from MEM stage
			I_DST_MEM:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
			I_LD_MEM:	in std_logic;

			-- to IF stage
			O_IF_EN:	out std_logic;

			-- to ID stage
			O_BRANCH:	out branch_t;
			O_SIGNED:	out std_logic;
			O_SEL_A:	out source_t;
			O_SEL_B:	out source_t;

			-- to EX stage
			O_SEL_B_IMM:	out std_logic;
			O_ALUOP:	out std_logic_vector(FUNC_SZ - 1 downto 0);

			-- to MEM stage
			O_LD:		out std_logic;
			O_STR:		out std_logic;

			-- to WB stage
			O_DST:		out std_logic_vector(RF_ADDR_SZ - 1 downto 0)
		);
	end component control_unit;

	constant WAIT_TIME:	time := 2 ns;

	signal OPCODE:		std_logic_vector(OPCODE_SZ - 1 downto 0);
	signal FUNC:		std_logic_vector(FUNC_SZ - 1 downto 0);
	signal SRC_A:		std_logic_vector(RF_ADDR_SZ - 1 downto 0);
	signal SRC_B:		std_logic_vector(RF_ADDR_SZ - 1 downto 0);
	signal DST_R:		std_logic_vector(RF_ADDR_SZ - 1 downto 0);
	signal TAKEN_PREV:	std_logic;
	signal DST_EX:		std_logic_vector(RF_ADDR_SZ - 1 downto 0);
	signal LD_EX:		std_logic;
	signal DST_MEM:		std_logic_vector(RF_ADDR_SZ - 1 downto 0);
	signal LD_MEM:		std_logic;
	signal BRANCH:		branch_t;
	signal S_SIGNED:	std_logic;
	signal SEL_A:		source_t;
	signal SEL_B:		source_t;
	signal SEL_B_IMM:	std_logic;
	signal ALUOP:		std_logic_vector(FUNC_SZ - 1 downto 0);
	signal LD:		std_logic;
	signal STR:		std_logic;
	signal DST:		std_logic_vector(RF_ADDR_SZ - 1 downto 0);
begin
	dut: control_unit
		port map (
			I_OPCODE	=> OPCODE,
			I_FUNC		=> FUNC,
			I_SRC_A		=> SRC_A,
			I_SRC_B		=> SRC_B,
			I_DST_R		=> DST_R,
			I_TAKEN_PREV	=> TAKEN_PREV,
			I_DST_EX	=> DST_EX,
			I_LD_EX		=> LD_EX,
			I_DST_MEM	=> DST_MEM,
			I_LD_MEM	=> LD_MEM,
			O_BRANCH	=> BRANCH,
			O_SIGNED	=> S_SIGNED,
			O_SEL_A		=> SEL_A,
			O_SEL_B		=> SEL_B,
			O_SEL_B_IMM	=> SEL_B_IMM,
			O_ALUOP		=> ALUOP,
			O_LD		=> LD,
			O_STR		=> STR,
			O_DST		=> DST
		);

	stimuli: process
	begin
		OPCODE		<= (others => '0');
		FUNC		<= (others => '0');
		SRC_A		<= (others => '0');
		SRC_B		<= (others => '0');
		DST_R		<= (others => '0');
		TAKEN_PREV	<= '0';
		DST_EX		<= (others => '0');
		LD_EX		<= '0';
		DST_MEM		<= (others => '0');
		LD_MEM		<= '0';

		wait for WAIT_TIME;

		wait;
	end process stimuli;
end TB_ARCH;

