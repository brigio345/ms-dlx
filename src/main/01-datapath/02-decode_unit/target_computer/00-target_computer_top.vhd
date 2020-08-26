library ieee;
use ieee.std_logic_1164.all;
use work.coding.all;

-- target_computer: compute next PC, according to the current branch type
entity target_computer is
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
end target_computer;

architecture MIXED of target_computer is
	component P4_ADDER is
		generic (
			NBIT:		integer := 32;
			NBIT_PER_BLOCK:	integer := 4
		);
		port (
			A:	in	std_logic_vector(NBIT-1 downto 0);
			B:	in	std_logic_vector(NBIT-1 downto 0);
			Cin:	in	std_logic;
			S:	out	std_logic_vector(NBIT-1 downto 0);
			Cout:	out	std_logic;
			O_OF:	out	std_logic
		);
	end component P4_ADDER;

	signal OP1:	std_logic_vector(O_TARGET'range);
	signal OP2:	std_logic_vector(O_TARGET'range);
begin
	adder: p4_adder
		generic map (
			NBIT		=> RF_DATA_SZ,
			NBIT_PER_BLOCK	=> 4
		)
		port map (
			A	=> OP1,
			B	=> OP2,
			Cin	=> '0',
			S	=> O_TARGET,
			Cout	=> open,
			O_OF	=> open
		);
	
	with I_SEL_JMP_OP1 select OP1 <=
		I_A	when '1',
		I_NPC	when others;
	
	with I_SEL_JMP_OP2 select OP2 <=
		I_IMM		when "01",
		I_OFF		when "10",
		(others => '0')	when others;
end MIXED;

