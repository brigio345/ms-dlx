library ieee;
use ieee.std_logic_1164.all;
use work.coding.all;

entity tb_dlx is
end tb_dlx;

architecture TB_ARCH of tb_dlx is
	component dlx is
		port (
			I_CLK:		in std_logic;
			I_RST:		in std_logic;
			I_ENDIAN:	in std_logic;

			I_I_RD_DATA:	in std_logic_vector(INST_SZ - 1 downto 0);
			I_D_RD_DATA:	in std_logic_vector(INST_SZ - 1 downto 0);

			O_I_RD_ADDR:	out std_logic_vector(RF_DATA_SZ - 1 downto 0);

			O_D_ADDR:	out std_logic_vector(RF_DATA_SZ - 1 downto 0);
			O_D_RD:		out std_logic_vector(1 downto 0);
			O_D_WR:		out std_logic_vector(1 downto 0);
			O_D_WR_DATA:	out std_logic_vector(RF_DATA_SZ - 1 downto 0)
		);
	end component dlx;

	component inst_mem is
		generic (
			RAM_DEPTH:	integer := 48;
			I_SIZE:		integer := 32
		);
		port (
			I_RST:	in std_logic;
			I_ADDR:	in std_logic_vector(I_SIZE - 1 downto 0);
			O_DATA:	out std_logic_vector(I_SIZE - 1 downto 0)
		);
	end component inst_mem;

	component data_mem is
		generic (
			DATA_SZ:	integer := 32
		);
		port (
			I_RST:	in std_logic;

			I_ADDR:	in std_logic_vector(31 downto 0);
			I_DATA:	in std_logic_vector(DATA_SZ - 1 downto 0);
			I_RD:	in std_logic_vector(1 downto 0);
			I_WR:	in std_logic_vector(1 downto 0);

			O_DATA:	out std_logic_vector(DATA_SZ - 1 downto 0)
		);
	end component data_mem;

	constant CLK_PERIOD:	time := 2 ns;

	signal CLK:		std_logic;
	signal RST:		std_logic;
	signal ENDIAN:		std_logic;
	signal I_RD_DATA:	std_logic_vector(INST_SZ - 1 downto 0);
	signal D_RD_DATA:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal I_RD_ADDR:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal D_ADDR:		std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal D_RD:		std_logic_vector(1 downto 0);
	signal D_WR:		std_logic_vector(1 downto 0);
	signal D_WR_DATA:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
begin
	dut: dlx
		port map (
			I_CLK		=> CLK,
			I_RST		=> RST,
			I_ENDIAN	=> ENDIAN,
			I_I_RD_DATA	=> I_RD_DATA,
			I_D_RD_DATA	=> D_RD_DATA,
			O_I_RD_ADDR	=> I_RD_ADDR,
			O_D_ADDR	=> D_ADDR,
			O_D_RD		=> D_RD,
			O_D_WR		=> D_WR,
			O_D_WR_DATA	=> D_WR_DATA
		);

	inst_mem_0: inst_mem
		generic map (
			RAM_DEPTH	=> 48,
			I_SIZE		=> RF_DATA_SZ
		)
		port map (
			I_RST	=> RST,
			I_ADDR	=> I_RD_ADDR,
			O_DATA	=> I_RD_DATA
		);

--	data_mem_0: data_mem
--		generic map (
--			DATA_SZ	=> 32
--		)
--		port map (
--			I_RST	=> RST,
--			I_ADDR	=> D_ADDR,
--			I_DATA	=> D_WR_DATA,
--			I_RD	=> D_RD,
--			I_WR	=> D_WR,
--			O_DATA	=> D_RD_DATA
--		);

	clock: process
	begin
		CLK <= '0';
		wait for CLK_PERIOD / 2;
		CLK <= '1';
		wait for CLK_PERIOD / 2;
	end process clock;

	stimuli: process
	begin
		RST		<= '1';
		ENDIAN		<= '1';
		D_RD_DATA	<= x"40ABCDEF";


		wait for CLK_PERIOD;

		RST		<= '0';

		wait;
	end process stimuli;
end TB_ARCH;

