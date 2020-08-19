library ieee;
use ieee.std_logic_1164.all;
use work.coding.all;
use work.types.all;

entity tb_datapath is
end tb_datapath;

architecture TB_ARCH of tb_datapath is
	component datapath is
		port (
			I_CLK:		in std_logic;
			I_RST:		in std_logic;

			-- I_ENDIAN: specify endianness of data and instruction memories
			--	- '0' => BIG endian
			--	- '1' => LITTLE endian
			I_ENDIAN:	in std_logic;

			-- from i-memory
			I_INST:		in std_logic_vector(INST_SZ - 1 downto 0);

			-- from d-memory
			I_D_RD_DATA:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);

			-- from CU, to ID stage
			I_BRANCH:	in branch_t;
			I_SEL_A:	in source_t;
			I_SEL_B:	in source_t;

			-- from CU, to EX stage
			I_SEL_B_IMM:	in std_logic;
			I_ALUOP:	in std_logic_vector(FUNC_SZ - 1 downto 0);

			-- from CU, to MEM stage
			I_LD:		in std_logic;
			I_STR:		in std_logic;

			-- from CU, to WB stage
			I_DST:		in std_logic_vector(RF_ADDR_SZ - 1 downto 0);

			-- to i-memory
			O_PC:		out std_logic_vector(RF_DATA_SZ - 1 downto 0);

			-- to d-memory
			O_D_ADDR:	out std_logic_vector(RF_DATA_SZ - 1 downto 0);
			O_D_RD:		out std_logic;
			O_D_WR:		out std_logic;
			O_D_WR_DATA:	out std_logic_vector(RF_DATA_SZ - 1 downto 0);

			-- to CU, from ID stage
			O_OPCODE:	out std_logic_vector(OPCODE_SZ - 1 downto 0);
			O_FUNC:		out std_logic_vector(FUNC_SZ - 1 downto 0);
			O_SRC_A:	out std_logic_vector(RF_ADDR_SZ - 1 downto 0);
			O_SRC_B:	out std_logic_vector(RF_ADDR_SZ - 1 downto 0);
			O_DST_ID:	out std_logic_vector(RF_ADDR_SZ - 1 downto 0);
			O_TAKEN:	out std_logic;

			-- to CU, from EX stage
			O_DST_EX:	out std_logic_vector(RF_ADDR_SZ - 1 downto 0);
			O_LD_EX:	out std_logic;

			-- to CU, from MEM stage
			O_DST_MEM:	out std_logic_vector(RF_ADDR_SZ - 1 downto 0);
			O_LD_MEM:	out std_logic
		);
	end component datapath;

	constant CLK_PERIOD:	time := 2 ns;

	signal CLK:		std_logic;
	signal RST:		std_logic;
	signal ENDIAN:		std_logic;
	signal INST:		std_logic_vector(INST_SZ - 1 downto 0);
	signal D_RD_DATA:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal BRANCH:		branch_t;
	signal SEL_A:		source_t;
	signal SEL_B:		source_t;
	signal SEL_B_IMM:	std_logic;
	signal ALUOP:		std_logic_vector(FUNC_SZ - 1 downto 0);
	signal LD:		std_logic;
	signal STR:		std_logic;
	signal DST:		std_logic_vector(RF_ADDR_SZ - 1 downto 0);
	signal PC:		std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal D_ADDR:		std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal D_RD:		std_logic;
	signal D_WR:		std_logic;
	signal D_WR_DATA:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal OPCODE:		std_logic_vector(OPCODE_SZ - 1 downto 0);
	signal FUNC:		std_logic_vector(FUNC_SZ - 1 downto 0);
	signal SRC_A:		std_logic_vector(RF_ADDR_SZ - 1 downto 0);
	signal SRC_B:		std_logic_vector(RF_ADDR_SZ - 1 downto 0);
	signal DST_ID:		std_logic_vector(RF_ADDR_SZ - 1 downto 0);
	signal TAKEN:		std_logic;
	signal DST_EX:		std_logic_vector(RF_ADDR_SZ - 1 downto 0);
	signal LD_EX:		std_logic;
	signal DST_MEM:		std_logic_vector(RF_ADDR_SZ - 1 downto 0);
	signal LD_MEM:		std_logic;
begin
	dut: datapath
		port map (
			I_CLK		=> CLK,
			I_RST		=> RST,
			I_ENDIAN	=> ENDIAN,
			I_INST		=> INST,
			I_D_RD_DATA	=> D_RD_DATA,
			I_BRANCH	=> BRANCH,
			I_SEL_A		=> SEL_A,
			I_SEL_B		=> SEL_B,
			I_SEL_B_IMM	=> SEL_B_IMM,
			I_ALUOP		=> ALUOP,
			I_LD		=> LD,
			I_STR		=> STR,
			I_DST		=> DST,
			O_PC		=> PC,
			O_D_ADDR	=> D_ADDR,
			O_D_RD		=> D_RD,
			O_D_WR		=> D_WR,
			O_D_WR_DATA	=> D_WR_DATA,
			O_OPCODE	=> OPCODE,
			O_FUNC		=> FUNC,
			O_SRC_A		=> SRC_A,
			O_SRC_B		=> SRC_B,
			O_DST_ID	=> DST_ID,
			O_TAKEN		=> TAKEN,
			O_DST_EX	=> DST_EX,
			O_LD_EX		=> LD_EX,
			O_DST_MEM	=> DST_MEM,
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
		BRANCH		<= BRANCH_NO;
		SEL_A		<= SRC_RF;
		SEL_B		<= SRC_RF;
		SEL_B_IMM	<= '0';
		ALUOP		<= FUNC_ADD;
		LD		<= '0';
		STR		<= '0';
		DST		<= (others => '0');

		wait for CLK_PERIOD;

		RST		<= '0';

		wait for CLK_PERIOD;

		wait for CLK_PERIOD;

		wait for CLK_PERIOD;

		wait;
	end process stimuli;
end TB_ARCH;

