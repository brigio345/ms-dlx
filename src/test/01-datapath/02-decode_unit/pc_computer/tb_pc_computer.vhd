library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.coding.all;
use work.types.all;

entity tb_pc_computer is
end tb_pc_computer;

architecture TB_ARCH of tb_pc_computer is
	component pc_computer is
		port (
			I_BRANCH:	in branch_t;
			I_NPC:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);
			I_A:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);
			I_IMM:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);
			I_OFF:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);

			O_TARGET:	out std_logic_vector(RF_DATA_SZ - 1 downto 0);
			O_TAKEN:	out std_logic
		);
	end component pc_computer;

	constant WAIT_TIME:	time := 2 ns;

	signal BRANCH:	branch_t;
	signal NPC:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal A:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal IMM:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal OFF:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal TARGET:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal TAKEN:	std_logic;
begin
	dut: pc_computer
		port map (
			I_BRANCH	=> BRANCH,
			I_NPC		=> NPC,
			I_A		=> A,
			I_IMM		=> IMM,
			I_OFF		=> OFF,
			O_TARGET	=> TARGET,
			O_TAKEN		=> TAKEN
		);

	stimuli: process
	begin
		BRANCH	<= BR_NO;
		NPC	<= x"00000040";
		A	<= x"00000020";
		IMM	<= x"00000008";
		OFF	<= x"00000004";

		wait for WAIT_TIME;

		assert ((TARGET = NPC) AND (TAKEN = '0'))
			report "error detected with BRANCH_NO";

		BRANCH	<= BR_UNC_REL;
		NPC	<= x"00000040";
		A	<= x"00000020";
		IMM	<= x"00000008";
		OFF	<= x"00000004";

		wait for WAIT_TIME;

		assert ((TARGET = std_logic_vector(unsigned(NPC) + unsigned(OFF)))
				AND (TAKEN = '1'))
			report "error detected with BR_UNC_REL";

		BRANCH 	<= BR_UNC_ABS;
		NPC	<= x"00000040";
		A	<= x"00000020";
		IMM	<= x"00000008";
		OFF	<= x"00000004";

		wait for WAIT_TIME;

		assert ((TARGET = A) AND (TAKEN = '1'))
			report "error detected with BR_UNC_ABS";

		BRANCH	<= BR_EQ0_REL;
		NPC	<= x"00000040";
		A	<= x"00000020";
		IMM	<= x"00000008";
		OFF	<= x"00000004";

		wait for WAIT_TIME;

		assert ((TARGET = NPC) AND (TAKEN = '0'))
			report "error detected with untaken BR_EQ0_REL";

		BRANCH	<= BR_NE0_REL;
		NPC	<= x"00000040";
		A	<= x"00000020";
		IMM	<= x"00000008";
		OFF	<= x"00000004";

		wait for WAIT_TIME;

		assert ((TARGET = std_logic_vector(unsigned(NPC) + unsigned(IMM)))
				AND (TAKEN = '1'))
			report "error detected with taken BR_NE0_REL";

		wait;
	end process stimuli;
end TB_ARCH;

