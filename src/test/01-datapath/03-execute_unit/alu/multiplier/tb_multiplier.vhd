library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_multiplier is
end tb_multiplier;

architecture TB_ARCH of tb_multiplier is
	component boothmul is
		generic (
			N_BIT:	integer := 32
		);
		port (
			I_A:	in std_logic_vector(N_BIT - 1 downto 0);      
			I_B:	in std_logic_vector(N_BIT - 1 downto 0);      

			O_P:	out std_logic_vector(2 * N_BIT - 1 downto 0)
		);  
	end component boothmul;

	component lfsr is 
		generic (
			N_BIT:	integer := 16
		);
		port ( 
			I_CLK:		in std_logic;
			I_RST:		in std_logic;
			I_LD:		in std_logic;
			I_EN:		in std_logic;

			I_SEED:		in std_logic_vector (N_BIT - 1 downto 0);

			O_RANDOM:	out std_logic_vector (N_BIT - 1 downto 0)
		);
	end component lfsr;

	constant N_BIT:		integer := 16;
	constant N_TESTS:	integer := 1023;
	constant CLK_PERIOD:	time := 2 ns;

	signal A:	std_logic_vector(N_BIT - 1 downto 0);
	signal B:	std_logic_vector(N_BIT - 1 downto 0);
	signal P:	std_logic_vector(N_BIT * 2 - 1 downto 0);

	signal CLK:	std_logic;
	signal RST:	std_logic;
	signal LD:	std_logic;
	signal EN:	std_logic;
	signal SEED_A:	std_logic_vector(N_BIT - 1 downto 0);
	signal SEED_B:	std_logic_vector(N_BIT - 1 downto 0);
begin
	dut: boothmul
		generic map (
			N_BIT	=> N_BIT
		)
		port map (
			I_A	=> A,
			I_B	=> B,
			O_P	=> P
		);

	lfsr_a: lfsr
		generic map (
			N_BIT	=> N_BIT
		)
		port map (
			I_CLK	=> CLK,
			I_RST	=> RST,
			I_LD	=> LD,
			I_EN	=> EN,
			I_SEED	=> SEED_A,
			O_RANDOM=> A
		);

	lfsr_b: lfsr
		generic map (
			N_BIT	=> N_BIT
		)
		port map (
			I_CLK	=> CLK,
			I_RST	=> RST,
			I_LD	=> LD,
			I_EN	=> EN,
			I_SEED	=> SEED_B,
			O_RANDOM=> B
		);

	clk_gen: process
	begin
		CLK	<= '0';
		wait for CLK_PERIOD / 2;
		CLK	<= '1';
		wait for CLK_PERIOD / 2;
	end process clk_gen;

	stimuli: process
	begin
		RST	<= '1';
		LD	<= '0';
		EN	<= '0';
		SEED_A	<= (others => '0');
		SEED_B	<= (others => '0');

		wait for CLK_PERIOD;

		RST	<= '0';
		LD	<= '1';
		EN	<= '0';
		SEED_A	<= x"ABCD";
		SEED_B	<= x"FACA";

		wait for CLK_PERIOD;

		LD	<= '0';
		EN	<= '1';

		for i in 0 to N_TESTS loop
			wait for CLK_PERIOD;

			assert (P = std_logic_vector(signed(A) * signed(B)))
				report "wrong product detected";
		end loop;

		wait;
	end process stimuli;
end TB_ARCH;

