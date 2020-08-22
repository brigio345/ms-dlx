library ieee;
use ieee.std_logic_1164.all;
use work.coding.all;
use work.types.all;

entity tb_data_forwarder is
end tb_data_forwarder;

architecture TB_ARCH of tb_data_forwarder is
	component data_forwarder is
		port (
			-- from ID stage
			I_SRC_A:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
			I_SRC_B:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);

			-- from EX stage
			I_DST_EX:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
			I_LD_EX:	in std_logic;

			-- from MEM stage
			I_DST_MEM:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
			I_LD_MEM:	in std_logic;

			O_SEL_A:	out source_t;
			O_SEL_B:	out source_t
		);
	end component data_forwarder;

	constant WAIT_TIME:	time := 2 ns;

	signal SRC_A:		std_logic_vector(RF_ADDR_SZ - 1 downto 0);
	signal SRC_B:		std_logic_vector(RF_ADDR_SZ - 1 downto 0);
	signal DST_EX:		std_logic_vector(RF_ADDR_SZ - 1 downto 0);
	signal LD_EX:		std_logic;
	signal DST_MEM:		std_logic_vector(RF_ADDR_SZ - 1 downto 0);
	signal LD_MEM:		std_logic;
	signal SEL_A:		source_t;
	signal SEL_B:		source_t;
begin
	dut: data_forwarder
		port map (
			I_SRC_A		=> SRC_A,
			I_SRC_B		=> SRC_B,
			I_DST_EX	=> DST_EX,
			I_LD_EX		=> LD_EX,
			I_DST_MEM	=> DST_MEM,
			I_LD_MEM	=> LD_MEM,
			O_SEL_A		=> SEL_A,
			O_SEL_B		=> SEL_B
		);

	stimuli: process
	begin
		SRC_A	<= (others => '0');
		SRC_B	<= (others => '0');
		DST_EX	<= (others => '0');
		LD_EX	<= '0';
		DST_MEM	<= (others => '0');
		LD_MEM	<= '0';

		wait for WAIT_TIME;
		assert ((SEL_A = SRC_RF) AND (SEL_B = SRC_RF))
			report "error detected";

		SRC_A	<= "00001";
		SRC_B	<= (others => '0');
		DST_EX	<= (others => '0');
		LD_EX	<= '0';
		DST_MEM	<= "00001";
		LD_MEM	<= '0';

		wait for WAIT_TIME;
		assert ((SEL_A = SRC_ALU_MEM) AND (SEL_B = SRC_RF))
			report "error detected";

		SRC_A	<= "00001";
		SRC_B	<= (others => '0');
		DST_EX	<= (others => '0');
		LD_EX	<= '1';
		DST_MEM	<= "00001";
		LD_MEM	<= '1';

		wait for WAIT_TIME;
		assert ((SEL_A = SRC_LD_MEM) AND (SEL_B = SRC_RF))
			report "error detected";

		SRC_A	<= "00001";
		SRC_B	<= (others => '0');
		DST_EX	<= "00001";
		LD_EX	<= '0';
		DST_MEM	<= "00001";
		LD_MEM	<= '1';

		wait for WAIT_TIME;
		assert ((SEL_A = SRC_ALU_EX) AND (SEL_B = SRC_RF))
			report "error detected";

		wait;
	end process stimuli;
end TB_ARCH;

