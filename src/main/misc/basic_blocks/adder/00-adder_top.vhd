library ieee;
use ieee.std_logic_1164.all;

-- p4_adder: adder made up of a sum generator connected to a carry generator
entity p4_adder is
	generic (
		N_BIT:			integer := 32;
		N_BIT_PER_BLOCK:	integer := 4
	);
	port (
		I_A:	in std_logic_vector(N_BIT-1 downto 0);
		I_B:	in std_logic_vector(N_BIT-1 downto 0);
		I_C:	in std_logic;

		O_S:	out std_logic_vector(N_BIT-1 downto 0);
		O_C:	out std_logic;
		O_OF:	out std_logic
	);
end p4_adder;

architecture STRUCTURAL of p4_adder is
	component sum_generator is
		generic (
			N_BIT_PER_BLOCK: 	integer := 4;
			N_BLOCKS:		integer := 8
		);
		port (
			I_A:	in std_logic_vector((N_BIT_PER_BLOCK * N_BLOCKS - 1) downto 0);
			I_B:	in std_logic_vector((N_BIT_PER_BLOCK * N_BLOCKS - 1) downto 0);
			I_C:	in std_logic_vector((N_BLOCKS - 1) downto 0);
			O_S:	out std_logic_vector((N_BIT_PER_BLOCK * N_BLOCKS - 1) downto 0);
			O_OF:	out std_logic
		);
	end component sum_generator;

	component carry_generator is
		generic (
			N_BIT:			integer := 32;
			N_BIT_PER_BLOCK: 	integer := 4
		);
		port (
			I_A:	in std_logic_vector(N_BIT - 1 downto 0);
			I_B:	in std_logic_vector(N_BIT - 1 downto 0);
			I_C:	in std_logic;

			O_C:	out std_logic_vector((N_BIT / N_BIT_PER_BLOCK) - 1 downto 0)
		);
	end component carry_generator;

	signal C_GEN: std_logic_vector((N_BIT / N_BIT_PER_BLOCK) - 1 downto 0);
	signal C_SUM: std_logic_vector((N_BIT / N_BIT_PER_BLOCK) - 1 downto 0);
begin
	sum_gen: sum_generator
		generic map (
			N_BIT_PER_BLOCK => N_BIT_PER_BLOCK,
			N_BLOCKS => N_BIT / N_BIT_PER_BLOCK
		)
		port map (
			I_A => I_A,
			I_B => I_B,
			I_C => C_SUM, -- map output of carry generator as input of sum generator
			O_S => O_S,
			O_OF => O_OF
		);

	carry_gen: carry_generator
		generic map (
			N_BIT => N_BIT,
			N_BIT_PER_BLOCK => N_BIT_PER_BLOCK
		)
		port map (
			I_A => I_A,
			I_B => I_B,
			I_C => I_C,
			O_C => C_GEN
		);

	-- sum generator requires "global" Cin too, and does not need "global" Cout
	-- (where "global" means the sum on the whole N_BIT numbers)
	C_SUM <= C_GEN((N_BIT / N_BIT_PER_BLOCK) - 2 downto 0) & I_C;

	-- map last generated carry to the carry out of the whole adder
	O_C <= C_GEN((N_BIT / N_BIT_PER_BLOCK) - 1);
end architecture STRUCTURAL;

