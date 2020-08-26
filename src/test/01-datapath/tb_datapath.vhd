library ieee;
use ieee.std_logic_1164.all;
use work.coding.all;
use work.types.all;

entity tb_datapath is
end tb_datapath;

architecture TB_ARCH of tb_datapath is
	component datapath is
		port (
			I_CLK:			in std_logic;
			I_RST:			in std_logic;

			-- I_ENDIAN: specify endianness of data and instruction memories
			--	- '0' => BIG endian
			--	- '1' => LITTLE endian
			I_ENDIAN:		in std_logic;

			-- from i-memory
			I_INST:			in std_logic_vector(INST_SZ - 1 downto 0);

			-- from d-memory
			I_D_RD_DATA:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);

			-- from CU, to IF stage
			I_IF_EN:		in std_logic;

			-- from CU, to ID stage
			I_TAKEN:		in std_logic;
			I_SEL_JMP_OP1:		in std_logic;
			I_SEL_JMP_OP2:		in std_logic_vector(1 downto 0);
			I_SIGNED:		in std_logic;
			I_SEL_A:		in source_t;
			I_SEL_B:		in source_t;

			-- from CU, to EX stage
			I_SEL_B_IMM:		in std_logic;
			I_ALUOP:		in std_logic_vector(FUNC_SZ - 1 downto 0);

			-- from CU, to MEM stage
			I_LD:			in std_logic_vector(1 downto 0);
			I_STR:			in std_logic_vector(1 downto 0);

			-- from CU, to WB stage
			I_SEL_DST:		in dest_t;

			-- to i-memory
			O_PC:			out std_logic_vector(RF_DATA_SZ - 1 downto 0);

			-- to d-memory
			O_D_ADDR:		out std_logic_vector(RF_DATA_SZ - 1 downto 0);
			O_D_RD:			out std_logic_vector(1 downto 0);
			O_D_WR:			out std_logic_vector(1 downto 0);
			O_D_WR_DATA:		out std_logic_vector(RF_DATA_SZ - 1 downto 0);

			-- to CU, from ID stage
			O_ZERO:			out std_logic;
			O_OPCODE:		out std_logic_vector(OPCODE_SZ - 1 downto 0);
			O_FUNC:			out std_logic_vector(FUNC_SZ - 1 downto 0);
			O_ZERO_SRC_A:		out std_logic;
			O_ZERO_SRC_B:		out std_logic;
			O_SRC_A_EQ_DST_EX:	out std_logic;
			O_SRC_B_EQ_DST_EX:	out std_logic;
			O_SRC_A_EQ_DST_MEM:	out std_logic;
			O_SRC_B_EQ_DST_MEM:	out std_logic;
			O_TAKEN_PREV:		out std_logic;

			-- to CU, from EX stage
			O_LD_EX:		out std_logic_vector(1 downto 0);

			-- to CU, from MEM stage
			O_LD_MEM:		out std_logic_vector(1 downto 0)
		);
	end component datapath;

	constant CLK_PERIOD:	time := 2 ns;

	signal CLK:		std_logic;
	signal RST:		std_logic;
	signal ENDIAN:		std_logic;
	signal INST:		std_logic_vector(INST_SZ - 1 downto 0);
	signal D_RD_DATA:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal IF_EN:		std_logic;
	signal TAKEN:		std_logic;
	signal SEL_JMP_OP1:	std_logic;
	signal SEL_JMP_OP2:	std_logic_vector(1 downto 0);
	signal S_SIGNED:	std_logic;
	signal SEL_A:		source_t;
	signal SEL_B:		source_t;
	signal SEL_B_IMM:	std_logic;
	signal ALUOP:		std_logic_vector(FUNC_SZ - 1 downto 0);
	signal LD:		std_logic_vector(1 downto 0);
	signal STR:		std_logic_vector(1 downto 0);
	signal SEL_DST:		dest_t;
	signal PC:		std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal D_ADDR:		std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal D_RD:		std_logic_vector(1 downto 0);
	signal D_WR:		std_logic_vector(1 downto 0);
	signal D_WR_DATA:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal ZERO:		std_logic;
	signal OPCODE:		std_logic_vector(OPCODE_SZ - 1 downto 0);
	signal FUNC:		std_logic_vector(FUNC_SZ - 1 downto 0);
	signal ZERO_SRC_A:	std_logic;
	signal ZERO_SRC_B:	std_logic;
	signal SRC_A_EQ_DST_EX:	std_logic;
	signal SRC_B_EQ_DST_EX:	std_logic;
	signal SRC_A_EQ_DST_MEM:std_logic;
	signal SRC_B_EQ_DST_MEM:std_logic;
	signal TAKEN_PREV:	std_logic;
	signal LD_EX:		std_logic_vector(1 downto 0);
	signal LD_MEM:		std_logic_vector(1 downto 0);
begin
	dut: datapath
		port map (
			I_CLK		=> CLK,
			I_RST		=> RST,
			I_ENDIAN	=> ENDIAN,
			I_INST		=> INST,
			I_D_RD_DATA	=> D_RD_DATA,
			I_IF_EN		=> IF_EN,
			I_TAKEN		=> TAKEN,
			I_SEL_JMP_OP1	=> SEL_JMP_OP1,
			I_SEL_JMP_OP2	=> SEL_JMP_OP2,
			I_SIGNED	=> S_SIGNED,
			I_SEL_A		=> SEL_A,
			I_SEL_B		=> SEL_B,
			I_SEL_B_IMM	=> SEL_B_IMM,
			I_ALUOP		=> ALUOP,
			I_LD		=> LD,
			I_STR		=> STR,
			I_SEL_DST	=> SEL_DST,
			O_PC		=> PC,
			O_D_ADDR	=> D_ADDR,
			O_D_RD		=> D_RD,
			O_D_WR		=> D_WR,
			O_D_WR_DATA	=> D_WR_DATA,
			O_ZERO		=> ZERO,
			O_OPCODE	=> OPCODE,
			O_FUNC		=> FUNC,
			O_ZERO_SRC_A	=> ZERO_SRC_A,
			O_ZERO_SRC_B	=> ZERO_SRC_B,
			O_SRC_A_EQ_DST_EX	=> SRC_A_EQ_DST_EX,
			O_SRC_B_EQ_DST_EX	=> SRC_B_EQ_DST_EX,
			O_SRC_A_EQ_DST_MEM	=> SRC_A_EQ_DST_MEM,
			O_SRC_B_EQ_DST_MEM	=> SRC_B_EQ_DST_MEM,
			O_TAKEN_PREV	=> TAKEN_PREV,
			O_LD_EX		=> LD_EX,
			O_LD_MEM	=> LD_MEM
		);

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
		ENDIAN		<= '0';
		INST		<= (others => '0');
		D_RD_DATA	<= (others => '0');
		IF_EN		<= '1';
		TAKEN		<= '0';
		SEL_JMP_OP1	<= '0';
		SEL_JMP_OP2	<= "00";
		S_SIGNED	<= '0';
		SEL_A		<= SRC_RF;
		SEL_B		<= SRC_RF;
		SEL_B_IMM	<= '0';
		ALUOP		<= FUNC_ADD;
		LD		<= "00";
		STR		<= "00";
		SEL_DST		<= DST_NO;

		wait for CLK_PERIOD;

		RST		<= '0';

		wait for CLK_PERIOD;

		wait for CLK_PERIOD;

		wait for CLK_PERIOD;

		wait;
	end process stimuli;
end TB_ARCH;

