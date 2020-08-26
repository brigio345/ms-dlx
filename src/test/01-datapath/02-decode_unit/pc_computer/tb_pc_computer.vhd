library ieee;
use ieee.std_logic_1164.all;
use work.coding.all;

entity tb_pc_computer is
end tb_pc_computer;

architecture TB_ARCH of tb_pc_computer is
	component pc_computer is
		port (
			I_SEL_JMP_OP1:	in std_logic;
			I_SEL_JMP_OP2:	in std_logic_vector(1 downto 0);
			I_NPC:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);
			-- I_A: value loaded from rf
			I_A:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);
			-- I_IMM: offset extracted by I-type instruction
			I_IMM:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);
			-- I_OFF: offset extracted by J-type instruction
			I_OFF:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);

			O_TARGET:	out std_logic_vector(RF_DATA_SZ - 1 downto 0)
		);
	end component pc_computer;

	constant WAIT_TIME:	time := 2 ns;

	signal SEL_JMP_OP1:	std_logic;
	signal SEL_JMP_OP2:	std_logic_vector(1 downto 0);
	signal NPC:		std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal A:		std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal IMM:		std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal OFF:		std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal TARGET:		std_logic_vector(RF_DATA_SZ - 1 downto 0);
begin
	dut: pc_computer
		port map (
			I_SEL_JMP_OP1	=> SEL_JMP_OP1,
			I_SEL_JMP_OP2	=> SEL_JMP_OP2,
			I_NPC		=> NPC,
			I_A		=> A,
			I_IMM		=> IMM,
			I_OFF		=> OFF,
			O_TARGET	=> TARGET
		);

	stimuli: process
	begin
		SEL_JMP_OP1	<= '0';
		SEL_JMP_OP2	<= "00";
		NPC	<= x"00000040";
		A	<= x"00000020";
		IMM	<= x"00000008";
		OFF	<= x"00000004";

		wait for WAIT_TIME;

		assert (TARGET = NPC) report "error detected with";

		wait;
	end process stimuli;
end TB_ARCH;

