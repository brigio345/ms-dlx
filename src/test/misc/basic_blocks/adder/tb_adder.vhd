library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_adder is
end tb_adder;

architecture TB_ARCH of tb_adder is
	component p4_adder is
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
	end component p4_adder;

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

	constant N_BIT:			integer := 32;
	constant N_BIT_PER_BLOCK:	integer := 4;
	constant CLK_PERIOD: 		time := 10 ns;

	signal CLK:	std_logic;
	signal RST:	std_logic;
	signal LD:	std_logic;
	signal EN:	std_logic;
	signal SEED_A:	std_logic_vector (N_BIT - 1 downto 0);
	signal SEED_B:	std_logic_vector (N_BIT - 1 downto 0);
	
	signal A:	std_logic_vector(N_BIT - 1 downto 0);
	signal B:	std_logic_vector(N_BIT - 1 downto 0);
	signal C_IN:	std_logic;
	signal S:	std_logic_vector(N_BIT - 1 downto 0);
	signal C_OUT:	std_logic;
	signal O_OF:	std_logic;
begin
	dut: p4_adder
		generic map (
			N_BIT		=> N_BIT,
			N_BIT_PER_BLOCK	=> N_BIT_PER_BLOCK
		)
		port map (
			I_A 	=> A,
			I_B 	=> B,
			I_C 	=> C_IN,
			O_S 	=> S,
			O_C	=> C_OUT,
			O_OF	=> O_OF
		);

	-- connect A to a pseudo-random data generator
	random_a: lfsr
		generic map (
			N_BIT => N_BIT
		)
		port map (
			I_CLK		=> CLK,
			I_RST 		=> RST,
			I_LD 		=> LD,
			I_EN 		=> EN,
			I_SEED 		=> SEED_A,
			O_RANDOM	=> A
		);

	-- connect B to a pseudo-random data generator
	random_b: lfsr
		generic map (
			N_BIT => N_BIT
		)
		port map (
			I_CLK		=> CLK,
			I_RST 		=> RST,
			I_LD 		=> LD,
			I_EN 		=> EN,
			I_SEED 		=> SEED_B,
			O_RANDOM	=> B
		);

	clock: process
	begin
		CLK <= '0';
		wait for CLK_PERIOD / 2;
		CLK <= '1';
		wait for CLK_PERIOD / 2;
	end process clock;

	stimuli: process
		variable S_EXP: unsigned(N_BIT downto 0);
	begin
		-- initialize the LFSR
		RST	<= '1';
		LD 	<= '0';
		EN 	<= '0';
		SEED_A	<= (N_BIT - 1 downto 1 => '0') & '1';
		SEED_B	<= (N_BIT - 1 downto 2 => '0') & "10";
		C_IN	<= '0';

		wait until CLK = '1' and CLK'event;
		wait until CLK = '1' and CLK'event;

		RST <= '0';
		LD <= '1';

		wait until CLK = '1' and CLK'event;

		LD <= '0';
		EN <= '1';

		-- test an infinite number of sums between random data
		while true loop
			wait until CLK = '0' and CLK'event;

			S_EXP := unsigned('0' & A) + unsigned('0' & B) +
				unsigned(std_logic_vector'('0' & C_IN));

			assert S = std_logic_vector(S_EXP(N_BIT - 1 downto 0)) and
			C_OUT = S_EXP(N_BIT)
			report "wrong sum detected";

			-- toggle carry after every test
			C_IN <= not C_IN;
		end loop;
	end process stimuli;
end TB_ARCH;

