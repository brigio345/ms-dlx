library ieee; 
use ieee.std_logic_1164.all;

-- sum_generator is made up of N_BLOCKS CSBs,
-- each one summing i-th N_BIT_PER_BLOCK bits of A and B
-- Since it is based on CSBs, it needs a carry in every N_BIT_PER_BLOCK as input
-- Last CSB block is a modified one, in order to detect 2's complement overflows
entity sum_generator is
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
end sum_generator;

architecture STRUCTURAL of sum_generator is
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
	GEN_LOOP_CSB: for i in 0 to N_BLOCKS - 2 generate
		CSB_X: CSB_GENERIC
			generic map (
				N => N_BIT_PER_BLOCK
			)
			port map (
				I_A => I_A((((i + 1) * N_BIT_PER_BLOCK) - 1) downto
					(i * N_BIT_PER_BLOCK)),
				I_B => I_B((((i + 1) * N_BIT_PER_BLOCK) - 1) downto
					(i * N_BIT_PER_BLOCK)),
				I_CIN => I_C(i),
				O_S => O_S((((i + 1) * N_BIT_PER_BLOCK) - 1) downto
					(i * N_BIT_PER_BLOCK))
			);
	end generate GEN_LOOP_CSB;

	CSB_OF: CSB_GENERIC_OF
		generic map (
			N => N_BIT_PER_BLOCK
		)
		port map (
			I_A => I_A(((N_BLOCKS * N_BIT_PER_BLOCK) - 1) downto
				((N_BLOCKS - 1) * N_BIT_PER_BLOCK)),
			I_B => I_B(((N_BLOCKS * N_BIT_PER_BLOCK) - 1) downto
				((N_BLOCKS - 1) * N_BIT_PER_BLOCK)),
			I_CIN => I_C(N_BLOCKS - 1),
			O_S => O_S(((N_BLOCKS * N_BIT_PER_BLOCK) - 1) downto
				((N_BLOCKS - 1) * N_BIT_PER_BLOCK)),
			O_OF => O_OF
		);
end STRUCTURAL;

