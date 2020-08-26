library ieee;
use ieee.std_logic_1164.all;
use work.coding.all;

entity tb_inst_decoder is
end tb_inst_decoder;

architecture TB_ARCH of tb_inst_decoder is
	component inst_decoder is
		port (
			-- from ID stage
			I_FUNC:		in std_logic_vector(FUNC_SZ - 1 downto 0);
			I_OPCODE:	in std_logic_vector(OPCODE_SZ - 1 downto 0);
			I_DST_R:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
			I_DST_I:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);

			-- to ID stage
			O_SIGNED:	out std_logic;

			-- to EX stage
			O_ALUOP:	out std_logic_vector(FUNC_SZ - 1 downto 0);
			O_SEL_B_IMM:	out std_logic;

			-- to MEM stage
			O_LD:		out std_logic_vector(1 downto 0);
			O_STR:		out std_logic_vector(1 downto 0);

			-- to WB stage
			O_DST:		out std_logic_vector(RF_ADDR_SZ - 1 downto 0);

			-- to CU
			O_A_NEEDED:	out std_logic;
			O_B_NEEDED:	out std_logic
		);
	end component inst_decoder;

	constant WAIT_TIME:	time := 2 ns;

	signal FUNC:		std_logic_vector(FUNC_SZ - 1 downto 0);
	signal OPCODE:		std_logic_vector(OPCODE_SZ - 1 downto 0);
	signal DST_R:		std_logic_vector(RF_ADDR_SZ - 1 downto 0);
	signal DST_I:		std_logic_vector(RF_ADDR_SZ - 1 downto 0);
	signal ALUOP:		std_logic_vector(FUNC_SZ - 1 downto 0);
	signal S_SIGNED:	std_logic;
	signal SEL_B_IMM:	std_logic;
	signal LD:		std_logic_vector(1 downto 0);
	signal STR:		std_logic_vector(1 downto 0);
	signal DST:		std_logic_vector(RF_ADDR_SZ - 1 downto 0);
	signal A_NEEDED:	std_logic;
	signal B_NEEDED:	std_logic;
begin
	dut: inst_decoder
		port map (
			I_FUNC		=> FUNC,
			I_OPCODE	=> OPCODE,
			I_DST_R		=> DST_R,
			I_DST_I		=> DST_I,
			O_ALUOP		=> ALUOP,
			O_SIGNED	=> S_SIGNED,
			O_SEL_B_IMM	=> SEL_B_IMM,
			O_LD		=> LD,
			O_STR		=> STR,
			O_DST		=> DST,
			O_A_NEEDED	=> A_NEEDED,
			O_B_NEEDED	=> B_NEEDED
		);

	stimuli: process
	begin
		FUNC	<= FUNC_ADD;
		OPCODE	<= OPCODE_RTYPE;
		DST_R	<= "00001";
		DST_I	<= "00010";

		wait for WAIT_TIME;
		assert ((ALUOP = FUNC) AND (SEL_B_IMM = '0') AND (LD = "00") AND
				(STR = "00") AND (DST = DST_R) AND
				(A_NEEDED = '1') AND (B_NEEDED = '1'))
			report "wrong outputs with R-type ADD";

		FUNC	<= (others => '0');
		OPCODE	<= OPCODE_ADDI;

		wait for WAIT_TIME;
		assert ((S_SIGNED = '1') AND (ALUOP = FUNC_ADD) AND
				(SEL_B_IMM = '1') AND (LD = "00") AND
				(STR = "00") AND (DST = DST_I) AND
				(A_NEEDED = '1') AND (B_NEEDED = '0'))
			report "wrong outputs with I-type ADD";

		FUNC	<= (others => '0');
		OPCODE	<= OPCODE_BNEZ;

		wait for WAIT_TIME;
		assert ((S_SIGNED = '1') AND (ALUOP = FUNC_ADD) AND
				(SEL_B_IMM = '1') AND (LD = "00") AND
				(STR = "00") AND (DST = (DST'range => '0')) AND
				(A_NEEDED = '1') AND (B_NEEDED = '0'))
			report "wrong outputs with BNEZ";

		FUNC	<= (others => '0');
		OPCODE	<= OPCODE_J;

		wait for WAIT_TIME;
		assert ((LD = "00") AND (STR = "00") AND
				(DST = (DST'range => '0')) AND
				(A_NEEDED = '0') AND (B_NEEDED = '0'))
			report "wrong outputs with J";

		wait;
	end process stimuli;
end TB_ARCH;

