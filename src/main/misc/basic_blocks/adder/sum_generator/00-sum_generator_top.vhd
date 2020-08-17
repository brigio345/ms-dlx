library ieee; 
use ieee.std_logic_1164.all;

-- SUM_GENERATOR is made up of NBLOCKS CSBs,
-- each one summing i-th NBIT_PER_BLOCK bits of A and B
-- Since it is based on CSBs, it needs a carry in every NBIT_PER_BLOCK as input
-- Last CSB block is a modified one, in order to detect 2's complement overflows
entity SUM_GENERATOR is
	generic (
		NBIT_PER_BLOCK: integer := 4;
		NBLOCKS:	integer := 8);
	port (
		A:	in	std_logic_vector(NBIT_PER_BLOCK*NBLOCKS-1 downto 0);
		B:	in	std_logic_vector(NBIT_PER_BLOCK*NBLOCKS-1 downto 0);
		Ci:	in	std_logic_vector(NBLOCKS-1 downto 0);
		S:	out	std_logic_vector(NBIT_PER_BLOCK*NBLOCKS-1 downto 0);
		O_OF:	out 	std_logic
	);
end SUM_GENERATOR;

architecture STRUCTURAL of SUM_GENERATOR is
	component CSB_GENERIC is
		generic (
			N:	integer := 8
		);
		port (	
			I_A:	in std_logic_vector(N - 1 downto 0);
			I_B:	in std_logic_vector(N - 1 downto 0);
			I_CIN:	in std_logic;

			O_S:	out std_logic_vector(N - 1 downto 0)
		);
	end component CSB_GENERIC;

	component CSB_GENERIC_OF is
		generic (
			N:	integer := 8
		);
		port (	
			I_A:	in std_logic_vector(N - 1 downto 0);
			I_B:	in std_logic_vector(N - 1 downto 0);
			I_CIN:	in std_logic;

			O_S:	out std_logic_vector(N - 1 downto 0);
			O_OF:	out std_logic
		);
	end component CSB_GENERIC_OF;
begin
	GEN_LOOP_CSB: for i in 0 to NBLOCKS - 2 generate
		CSB_X: CSB_GENERIC
			generic map (
				N => NBIT_PER_BLOCK
			)
			port map (
				I_A => A((((i + 1) * NBIT_PER_BLOCK) - 1) downto (i * NBIT_PER_BLOCK)),
				I_B => B((((i + 1) * NBIT_PER_BLOCK) - 1) downto (i * NBIT_PER_BLOCK)),
				I_CIN => Ci(i),
				O_S => S((((i + 1) * NBIT_PER_BLOCK) - 1) downto (i * NBIT_PER_BLOCK))
			);
	end generate GEN_LOOP_CSB;

	CSB_OF: CSB_GENERIC_OF
		generic map (
			N => NBIT_PER_BLOCK
		)
		port map (
			I_A => A(((NBLOCKS * NBIT_PER_BLOCK) - 1) downto ((NBLOCKS - 1) * NBIT_PER_BLOCK)),
			I_B => B(((NBLOCKS * NBIT_PER_BLOCK) - 1) downto ((NBLOCKS - 1) * NBIT_PER_BLOCK)),
			I_CIN => Ci(NBLOCKS - 1),
			O_S => S(((NBLOCKS * NBIT_PER_BLOCK) - 1) downto ((NBLOCKS - 1) * NBIT_PER_BLOCK)),
			O_OF => O_OF
		);
end STRUCTURAL;

