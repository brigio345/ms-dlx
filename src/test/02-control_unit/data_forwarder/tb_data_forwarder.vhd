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
			I_ZERO_SRC_A:		in std_logic;
			I_ZERO_SRC_B:		in std_logic;
			I_SRC_A_EQ_DST_EX:	in std_logic;
			I_SRC_B_EQ_DST_EX:	in std_logic;
			I_SRC_A_EQ_DST_MEM:	in std_logic;
			I_SRC_B_EQ_DST_MEM:	in std_logic;
			I_SRC_A_EQ_DST_WB:	in std_logic;
			I_SRC_B_EQ_DST_WB:	in std_logic;

			-- from EX stage
			I_LD_EX:		in std_logic_vector(1 downto 0);

			-- from MEM stage
			I_LD_MEM:		in std_logic_vector(1 downto 0);

			-- from WB stage
			I_LD_WB:		in std_logic_vector(1 downto 0);

			O_SEL_A:		out source_t;
			O_SEL_B:		out source_t
		);
	end component data_forwarder;

	constant WAIT_TIME:	time := 2 ns;

	signal ZERO_SRC_A:	std_logic;
	signal ZERO_SRC_B:	std_logic;
	signal SRC_A_EQ_DST_EX:	std_logic;
	signal SRC_B_EQ_DST_EX:	std_logic;
	signal SRC_A_EQ_DST_MEM:std_logic;
	signal SRC_B_EQ_DST_MEM:std_logic;
	signal SRC_A_EQ_DST_WB:	std_logic;
	signal SRC_B_EQ_DST_WB:	std_logic;
	signal LD_EX:		std_logic_vector(1 downto 0);
	signal LD_MEM:		std_logic_vector(1 downto 0);
	signal LD_WB:		std_logic_vector(1 downto 0);
	signal SEL_A:		source_t;
	signal SEL_B:		source_t;
begin
	dut: data_forwarder
		port map (
			I_ZERO_SRC_A		=> ZERO_SRC_A,
			I_ZERO_SRC_B		=> ZERO_SRC_B,
			I_SRC_A_EQ_DST_EX	=> SRC_A_EQ_DST_EX,
			I_SRC_B_EQ_DST_EX	=> SRC_B_EQ_DST_EX,
			I_SRC_A_EQ_DST_MEM	=> SRC_A_EQ_DST_MEM,
			I_SRC_B_EQ_DST_MEM	=> SRC_B_EQ_DST_MEM,
			I_SRC_A_EQ_DST_WB	=> SRC_A_EQ_DST_WB,
			I_SRC_B_EQ_DST_WB	=> SRC_B_EQ_DST_WB,
			I_LD_EX			=> LD_EX,
			I_LD_MEM		=> LD_MEM,
			I_LD_WB			=> LD_WB,
			O_SEL_A			=> SEL_A,
			O_SEL_B			=> SEL_B
		);

	stimuli: process
	begin
		ZERO_SRC_A	<= '1';
		ZERO_SRC_B	<= '1';
		SRC_A_EQ_DST_EX	<= '0';
		SRC_B_EQ_DST_EX	<= '0';
		SRC_A_EQ_DST_MEM<= '0';
		SRC_B_EQ_DST_MEM<= '0';
		SRC_A_EQ_DST_WB	<= '0';
		SRC_B_EQ_DST_WB	<= '0';
		LD_EX		<= "00";
		LD_MEM		<= "00";
		LD_WB		<= "00";
		
		wait for WAIT_TIME;

		assert ((SEL_A = SRC_RF) AND (SEL_B = SRC_RF))
			report "unexpected source selection";

		ZERO_SRC_A	<= '0';
		ZERO_SRC_B	<= '0';
		SRC_A_EQ_DST_EX	<= '1';
		SRC_B_EQ_DST_EX	<= '1';
		SRC_A_EQ_DST_MEM<= '1';
		SRC_B_EQ_DST_MEM<= '1';
		SRC_A_EQ_DST_WB	<= '1';
		SRC_B_EQ_DST_WB	<= '1';
		LD_EX		<= "00";
		LD_MEM		<= "00";
		LD_WB		<= "00";
		
		wait for WAIT_TIME;

		assert ((SEL_A = SRC_ALU_EX) AND (SEL_B = SRC_ALU_EX))
			report "unexpected source selection";

		ZERO_SRC_A	<= '0';
		ZERO_SRC_B	<= '1';
		SRC_A_EQ_DST_EX	<= '0';
		SRC_B_EQ_DST_EX	<= '1';
		SRC_A_EQ_DST_MEM<= '1';
		SRC_B_EQ_DST_MEM<= '0';
		SRC_A_EQ_DST_WB	<= '0';
		SRC_B_EQ_DST_WB	<= '1';
		LD_EX		<= "10";
		LD_MEM		<= "10";
		LD_WB		<= "00";
		
		wait for WAIT_TIME;

		assert ((SEL_A = SRC_LD_MEM) AND (SEL_B  = SRC_RF))
			report "unexpected source selection";

		ZERO_SRC_A	<= '0';
		ZERO_SRC_B	<= '0';
		SRC_A_EQ_DST_EX	<= '0';
		SRC_B_EQ_DST_EX	<= '0';
		SRC_A_EQ_DST_MEM<= '1';
		SRC_B_EQ_DST_MEM<= '0';
		SRC_A_EQ_DST_WB	<= '0';
		SRC_B_EQ_DST_WB	<= '1';
		LD_EX		<= "10";
		LD_MEM		<= "01";
		LD_WB		<= "00";
		
		wait for WAIT_TIME;

		assert ((SEL_A = SRC_LD_MEM) AND (SEL_B =  SRC_ALU_WB))
			report "unexpected source selection";

		ZERO_SRC_A	<= '0';
		ZERO_SRC_B	<= '0';
		SRC_A_EQ_DST_EX	<= '1';
		SRC_B_EQ_DST_EX	<= '0';
		SRC_A_EQ_DST_MEM<= '1';
		SRC_B_EQ_DST_MEM<= '0';
		SRC_A_EQ_DST_WB	<= '0';
		SRC_B_EQ_DST_WB	<= '1';
		LD_EX		<= "01";
		LD_MEM		<= "00";
		LD_WB		<= "11";
		
		wait for WAIT_TIME;

		assert ((SEL_A = SRC_LD_EX) AND (SEL_B = SRC_LD_WB))
			report "unexpected source selection";

		ZERO_SRC_A	<= '0';
		ZERO_SRC_B	<= '0';
		SRC_A_EQ_DST_EX	<= '0';
		SRC_B_EQ_DST_EX	<= '1';
		SRC_A_EQ_DST_MEM<= '1';
		SRC_B_EQ_DST_MEM<= '1';
		SRC_A_EQ_DST_WB	<= '0';
		SRC_B_EQ_DST_WB	<= '1';
		LD_EX		<= "11";
		LD_MEM		<= "00";
		LD_WB		<= "00";
		
		wait for WAIT_TIME;

		assert ((SEL_A = SRC_ALU_MEM) AND (SEL_B  = SRC_LD_EX))
			report "unexpected source selection";

		wait;
	end process stimuli;
end TB_ARCH;

