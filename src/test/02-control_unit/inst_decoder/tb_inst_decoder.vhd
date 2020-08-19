library ieee;
use ieee.std_logic_1164.all;
use work.coding.all;
use work.types.all;

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
			O_BRANCH:	out branch_t;

			-- to EX stage
			O_ALUOP:	out std_logic_vector(FUNC_SZ - 1 downto 0);
			O_SEL_B_IMM:	out std_logic;

			-- to MEM stage
			O_LD:		out std_logic;
			O_STR:		out std_logic;

			-- to WB stage
			O_DST:		out std_logic_vector(RF_ADDR_SZ - 1 downto 0);

			-- to CU
			O_INST_TYPE:	out inst_t
		);
	end component inst_decoder;

	constant WAIT_TIME:	time := 2 ns;

	signal FUNC:		std_logic_vector(FUNC_SZ - 1 downto 0);
	signal OPCODE:		std_logic_vector(OPCODE_SZ - 1 downto 0);
	signal DST_R:		std_logic_vector(RF_ADDR_SZ - 1 downto 0);
	signal DST_I:		std_logic_vector(RF_ADDR_SZ - 1 downto 0);
	signal BRANCH:		branch_t;
	signal ALUOP:		std_logic_vector(FUNC_SZ - 1 downto 0);
	signal SEL_B_IMM:	std_logic;
	signal LD:		std_logic;
	signal STR:		std_logic;
	signal DST:		std_logic_vector(RF_ADDR_SZ - 1 downto 0);
	signal INST_TYPE:	inst_t;
begin
	dut: inst_decoder
		port map (
			I_FUNC		=> FUNC,
			I_OPCODE	=> OPCODE,
			I_DST_R		=> DST_R,
			I_DST_I		=> DST_I,
			O_BRANCH	=> BRANCH,
			O_ALUOP		=> ALUOP,
			O_SEL_B_IMM	=> SEL_B_IMM,
			O_LD		=> LD,
			O_STR		=> STR,
			O_DST		=> DST,
			O_INST_TYPE	=> INST_TYPE
		);

	stimuli: process
	begin
		FUNC	<= FUNC_ADD;
		OPCODE	<= OPCODE_RTYPE;
		DST_R	<= "00001";
		DST_I	<= "00010";

		wait for WAIT_TIME;
		assert ((BRANCH = BRANCH_NO) AND (ALUOP = FUNC) AND
				(SEL_B_IMM = '0') AND (LD = '0') AND
				(STR = '0') AND (DST = DST_R) AND
				(INST_TYPE = INST_REG))
			report "wrong outputs with R-type ADD";

		FUNC	<= (others => '0');
		OPCODE	<= OPCODE_ADDI;

		wait for WAIT_TIME;
		assert ((BRANCH = BRANCH_NO) AND (ALUOP = FUNC_ADD) AND
				(SEL_B_IMM = '1') AND (LD = '0') AND
				(STR = '0') AND (DST = DST_I) AND
				(INST_TYPE = INST_IMM))
			report "wrong outputs with I-type ADD";

		wait;
	end process stimuli;
end TB_ARCH;

