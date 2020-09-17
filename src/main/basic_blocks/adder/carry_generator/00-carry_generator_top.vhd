library ieee; 
use ieee.std_logic_1164.all;
use work.utilities.all;

entity carry_generator is
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
end carry_generator;

architecture STRUCTURAL of carry_generator is
	type block_type is (
		PG_T,
		G_T,
		PROP_T	-- not a real block: just propagate signal from previous level
	);

	-- check_block: given a position (i, j) and the number of bits per block (N_BIT_PER_BLOCK)
	-- returns the type of block to be inserted in that position
	function check_block (
		i: integer;
		j: integer;
		N_BIT_PER_BLOCK: integer)
	return block_type is
	begin
		-- check if j is less than the minimum value which can require a block
		if (i <= log2(N_BIT_PER_BLOCK) + 1) then
		-- up to level log2(N_BIT_PER_BLOCK) + 1 there are only "standard" blocks
		-- (i.e. one block every two of the previous level)
			if (j + 1 < 2**i) then
				return PROP_T;
			end if;
		else
		-- from level log2(N_BIT_PER_BLOCK) + 2 on there are "additional" blocks too
		-- (i.e. blocks needed to get the desired carries)
			if (j + 1 < 2**(i - 1)) then
				return PROP_T;
			end if;
		end if;

		-- "standard" blocks
		if ((j + 1) mod 2**i = 0) then
			if (j + 1 > 2**i) then
				return PG_T;
			else
				return G_T;
			end if;
		end if;

		-- "additional" blocks
		if ((i > log2(N_BIT_PER_BLOCK) + 1) and
			((j + 1) mod N_BIT_PER_BLOCK = 0) and
			((j + 1) mod 2**i > 2**(i - 1))) then
			if ((j + 1) / 2**i = 0) then
				return G_T;
			else
				return PG_T;
			end if;
		end if;
		
		return PROP_T;
	end function check_block;

	component SMALL_PG_BLOCK is 
		port (
			a: 	in std_logic;
			b: 	in std_logic;
			g:	out std_logic;
			p:	out std_logic
		);
	end component SMALL_PG_BLOCK; 

	component G_BLOCK is 
		port (
			G_ik: 	in std_logic;
			P_ik: 	in std_logic;
			G_k1j:	in std_logic;
			G_ij:	out std_logic
		);
	end component G_BLOCK; 

	component PG_BLOCK is 
		port (
			G_ik: 	in std_logic;
			P_ik: 	in std_logic;
			G_k1j:	in std_logic;
			P_k1j:	in std_logic;
			G_ij:	out std_logic;
			P_ij:	out std_logic
		);
	end component PG_BLOCK; 

	type std_logic_matrix is array (log2(N_BIT) downto 0) of std_logic_vector(N_BIT - 1 downto 0);
	signal P: std_logic_matrix;
	signal G: std_logic_matrix;
	signal g1: std_logic;
begin
	-- pg network: first element is different in order to take care of carry in
	small_pg1_net: SMALL_PG_BLOCK
		port map (
			a => I_A(0),
			b => I_B(0),
			g => g1,
			p => P(0)(0)
		);

	g10_net: G_BLOCK
		port map (
			G_ik => g1,
			P_ik => P(0)(0),
			G_k1j => I_C,
			G_ij => G(0)(0)
		);
			
	-- pg network: all the elements from second to last are equal
	pg_net: for i in 1 to N_BIT - 1 generate
		small_pg_net: SMALL_PG_BLOCK
			port map (
				a => I_A(i),
				b => I_B(i),
				g => G(0)(i),
				p => P(0)(i)
			);
	end generate pg_net;

	-- propagate network:
	--	* every level inputs are taken from previous level outputs (i - 1)
	-- 	* "k - 1" always corresponds to j / 2**(i - 1) * 2**(i - 1) - 1
	level_loop: for i in 1 to log2(N_BIT) generate
		bit_loop: for j in N_BIT - 1 downto 0 generate
			pg_check: if (check_block(i, j, N_BIT_PER_BLOCK) = PG_T) generate
				pg_net: PG_BLOCK
					port map (
						G_ik => G(i - 1)(j),
						P_ik => P(i - 1)(j),
						G_k1j => G(i - 1)(j / 2**(i - 1) * 2**(i - 1) - 1),
						P_k1j => P(i - 1)(j / 2**(i - 1) * 2**(i - 1) - 1),
						G_ij => G(i)(j),
						P_ij => P(i)(j)
					);
			end generate;

			g_check: if (check_block(i, j, N_BIT_PER_BLOCK) = G_T) generate
				g_net: G_BLOCK
					port map (
						G_ik => G(i - 1)(j),
						P_ik => P(i - 1)(j),
						G_k1j => G(i - 1)(j / 2**(i - 1) * 2**(i - 1) - 1),
						G_ij => G(i)(j)
				);
				P(i)(j) <= P(i - 1)(j);
			end generate;

			prop_check: if (check_block(i, j, N_BIT_PER_BLOCK) = PROP_T) generate
				P(i)(j) <= P(i - 1)(j);
				G(i)(j) <= G(i - 1)(j);
			end generate;
		end generate bit_loop;
	end generate level_loop;

	out_map: process(G)
	begin
		-- map one bit every N_BIT_PER_BLOCK of last line of matrix G to Co
		for i in 0 to N_BIT / N_BIT_PER_BLOCK - 1 loop
			O_C(i) <= G(log2(N_BIT))((i + 1) * N_BIT_PER_BLOCK - 1);
		end loop;
	end process out_map;
end STRUCTURAL;

