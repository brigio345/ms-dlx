library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity TB_P4_ADDER is
end TB_P4_ADDER;

architecture TB_ARCH of TB_P4_ADDER is
	component P4_ADDER is
		generic (
			NBIT:		integer := 32;
			NBIT_PER_BLOCK:	integer := 4);
		port (
			A :	in	std_logic_vector(NBIT-1 downto 0);
			B :	in	std_logic_vector(NBIT-1 downto 0);
			Cin :	in	std_logic;
			S :	out	std_logic_vector(NBIT-1 downto 0);
			Cout :	out	std_logic;
			O_OF:	out	std_logic
		);
	end component;

	component LFSR is 
		generic (
			NBIT:	integer := 16
		);
		port ( 
			CLK:	in std_logic;
			RESET:	in std_logic;
			LD:	in std_logic;
			EN:	in std_logic;
			DIN:	in std_logic_vector (NBIT - 1 downto 0);
			PRN:	out std_logic_vector (NBIT - 1 downto 0)
		);
	end component LFSR;

	constant NBIT: integer := 32;
	constant NBIT_PER_BLOCK: integer := 4;
	constant CLK_PERIOD: 	time := 10 ns;

	signal CLK:	std_logic;
	signal RESET:	std_logic;
	signal LD:	std_logic;
	signal EN:	std_logic;
	signal DIN_A:	std_logic_vector (NBIT - 1 downto 0);
	signal DIN_B:	std_logic_vector (NBIT - 1 downto 0);
	
	signal A:	std_logic_vector(NBIT - 1 downto 0);
	signal B:	std_logic_vector(NBIT - 1 downto 0);
	signal Cin:	std_logic;
	signal S:	std_logic_vector(NBIT - 1 downto 0);
	signal Cout:	std_logic;
	signal O_OF:	std_logic;
begin
	DUT: P4_ADDER
		generic map (
			NBIT => NBIT,
			NBIT_PER_BLOCK => NBIT_PER_BLOCK
		)
		port map (
			A => A,
			B => B,
			Cin => Cin,
			S => S,
			Cout => Cout,
			O_OF => O_OF
		);

	-- connect A to a pseudo-random data generator
	RANDOM_A: LFSR
		generic map (
			NBIT => NBIT
		)
		port map (
			CLK => CLK,
			RESET => RESET,
			LD => LD,
			EN => EN,
			DIN => DIN_A,
			PRN => A
		);

	-- connect B to a pseudo-random data generator
	RANDOM_B: LFSR
		generic map (
			NBIT => NBIT
		)
		port map (
			CLK => CLK,
			RESET => RESET,
			LD => LD,
			EN => EN,
			DIN => DIN_B,
			PRN => B
		);

	CLOCK: process
	begin
		CLK <= '0';
		wait for CLK_PERIOD / 2;
		CLK <= '1';
		wait for CLK_PERIOD / 2;
	end process CLOCK;

	STIMULI: process
		variable S_exp: unsigned(NBIT downto 0);
	begin
		-- initialize the LFSR
		RESET <= '1';
		LD <= '0';
		EN <= '0';
		DIN_A <= (NBIT - 1 downto 1 => '0') & '1';
		DIN_B <= (NBIT - 1 downto 2 => '0') & "10";
		Cin <= '0';

		wait until CLK = '1' and CLK'event;
		wait until CLK = '1' and CLK'event;

		RESET <= '0';
		LD <= '1';

		wait until CLK = '1' and CLK'event;

		LD <= '0';
		EN <= '1';

		-- test an infinite number of sums between random data
		while true loop
			wait until CLK = '0' and CLK'event;

			S_exp := unsigned('0' & A) + unsigned('0' & B) +
				unsigned(std_logic_vector'('0' & Cin));

			assert S = std_logic_vector(S_exp(NBIT - 1 downto 0)) and
			Cout = S_exp(NBIT)
			report "wrong output detected";

			-- toggle carry after every test
			Cin <= not Cin;
		end loop;
	end process STIMULI;
end TB_ARCH;

