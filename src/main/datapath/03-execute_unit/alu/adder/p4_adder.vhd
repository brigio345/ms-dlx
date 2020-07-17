library IEEE;
use IEEE.std_logic_1164.all;

-- P4 adder: adder made up of a sum generator connected to a carry generator
entity P4_ADDER is
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
end P4_ADDER;

architecture STRUCTURAL of P4_ADDER is
	component SUM_GENERATOR is
		generic (
			NBIT_PER_BLOCK: integer := 4;
			NBLOCKS:	integer := 8);
		port (
			A:	in	std_logic_vector(NBIT_PER_BLOCK*NBLOCKS-1 downto 0);
			B:	in	std_logic_vector(NBIT_PER_BLOCK*NBLOCKS-1 downto 0);
			Ci:	in	std_logic_vector(NBLOCKS-1 downto 0);
			S:	out	std_logic_vector(NBIT_PER_BLOCK*NBLOCKS-1 downto 0);
			O_OF:	out	std_logic
		);
	end component SUM_GENERATOR;

	component CARRY_GENERATOR is
		generic (
			NBIT :		integer := 32;
			NBIT_PER_BLOCK: integer := 4
		);
		port (
			A	:	in	std_logic_vector(NBIT-1 downto 0);
			B	:	in	std_logic_vector(NBIT-1 downto 0);
			Cin 	:	in	std_logic;
			Co 	:	out	std_logic_vector((NBIT/NBIT_PER_BLOCK)-1 downto 0)
		);
	end component CARRY_GENERATOR;

	signal Cgen: std_logic_vector((NBIT / NBIT_PER_BLOCK) - 1 downto 0);
	signal Csum: std_logic_vector((NBIT / NBIT_PER_BLOCK) - 1 downto 0);
begin
	sum_gen: SUM_GENERATOR
		generic map (
			NBIT_PER_BLOCK => NBIT_PER_BLOCK,
			NBLOCKS => NBIT / NBIT_PER_BLOCK
		)
		port map (
			A => A,
			B => B,
			Ci => Csum, -- map output of carry generator as input of sum generator
			S => S,
			O_OF => O_OF
		);

	carry_gen: CARRY_GENERATOR
		generic map (
			NBIT => NBIT,
			NBIT_PER_BLOCK => NBIT_PER_BLOCK
		)
		port map (
			A => A,
			B => B,
			Cin => Cin,
			Co => Cgen
		);

	-- sum generator requires "global" Cin too, and does not need "global" Cout
	-- (where "global" means the sum on the whole NBIT numbers)
	Csum <= Cgen((NBIT / NBIT_PER_BLOCK) - 2 downto 0) & Cin;

	-- map last generated carry to the carry out of the whole adder
	Cout <= Cgen((NBIT / NBIT_PER_BLOCK) - 1);
end architecture STRUCTURAL;

