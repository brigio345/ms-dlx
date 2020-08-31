library ieee;
use ieee.std_logic_1164.all;
use work.coding.all;
use work.types.all;

-- target_computer: compute next PC, according to the current branch type
entity target_computer is
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
end target_computer;

architecture MIXED of target_computer is
	component p4_adder is
		generic (
			N_BIT:			integer := 32;
			N_BIT_PER_BLOCK:	integer := 4
		);
		port (
			I_A:	in std_logic_vector(N_BIT - 1 downto 0);
			I_B:	in std_logic_vector(N_BIT - 1 downto 0);
			I_C:	in std_logic;
			O_S:	out std_logic_vector(N_BIT - 1 downto 0);
			O_C:	out std_logic;
			O_OF:	out std_logic
		);
	end component p4_adder;

	signal OP1:	std_logic_vector(O_TARGET'range);
	signal OP2:	std_logic_vector(O_TARGET'range);
begin
	adder: p4_adder
		generic map (
			N_BIT		=> RF_DATA_SZ,
			N_BIT_PER_BLOCK	=> 4
		)
		port map (
			I_A	=> OP1,
			I_B	=> OP2,
			I_C	=> '0',
			O_S	=> O_TARGET,
			O_C	=> open,
			O_OF	=> open
		);
	
	with I_SEL_JMP select OP1 <=
		I_A	when JMP_ABS,
		I_NPC	when others;
	
	with I_SEL_JMP select OP2 <=
		I_IMM		when JMP_REL_IMM,
		I_OFF		when JMP_REL_OFF,
		(others => '0')	when others;
end MIXED;

