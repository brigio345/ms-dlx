library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.coding.all;
use work.types.all;

entity tb_target_computer is
end tb_target_computer;

architecture TB_ARCH of tb_target_computer is
	component target_computer is
		port (
			I_SEL_JMP:	in jump_t;
			I_NPC:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);
			-- I_A: value loaded from rf
			I_A:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);
			-- I_IMM: offset extracted by I-type instruction
			I_IMM:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);
			-- I_OFF: offset extracted by J-type instruction
			I_OFF:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);

			O_TARGET:	out std_logic_vector(RF_DATA_SZ - 1 downto 0)
		);
	end component target_computer;

	constant WAIT_TIME:	time := 2 ns;

	signal SEL_JMP:	jump_t;
	signal NPC:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal A:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal IMM:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal OFF:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal TARGET:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
begin
	dut: target_computer
		port map (
			I_SEL_JMP	=> SEL_JMP,
			I_NPC		=> NPC,
			I_A		=> A,
			I_IMM		=> IMM,
			I_OFF		=> OFF,
			O_TARGET	=> TARGET
		);

	stimuli: process
	begin
		SEL_JMP	<= JMP_ABS;
		NPC	<= x"11111111";
		A	<= x"AAAAAAAA";
		IMM	<= x"22222222";
		OFF	<= x"33333333";

		wait for WAIT_TIME;

		assert (TARGET = A) report "error detected with JMP_ABS";

		SEL_JMP	<= JMP_REL_IMM;

		wait for WAIT_TIME;

		assert (TARGET = std_logic_vector(signed(NPC) + signed(IMM)))
			report "error detected with JMP_REL_IMM";


		SEL_JMP	<= JMP_REL_OFF;

		wait for WAIT_TIME;

		assert (TARGET = std_logic_vector(signed(NPC) + signed(OFF)))
			report "error detected with JMP_REL_OFF";

		wait;
	end process stimuli;
end TB_ARCH;

