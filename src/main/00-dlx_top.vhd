library IEEE;
use IEEE.std_logic_1164.all;
use work.coding.all;
use work.types.all;

entity dlx is
	port (
		I_CLK:		in std_logic;
		I_RST:		in std_logic;

		-- I_ENDIAN: specify endianness of data and instruction memories
		--	- '0' => BIG endian
		--	- '1' => LITTLE endian
		I_ENDIAN:	in std_logic;

		I_I_RD_DATA:	in std_logic_vector(INST_SZ - 1 downto 0);
		I_D_RD_DATA:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);

		O_I_RD_ADDR:	out std_logic_vector(RF_DATA_SZ - 1 downto 0);

		O_D_ADDR:	out std_logic_vector(RF_DATA_SZ - 1 downto 0);
		O_D_RD:		out std_logic;
		O_D_WR:		out std_logic;
		O_D_WR_DATA:	out std_logic_vector(RF_DATA_SZ - 1 downto 0)
	);
end dlx;

architecture STRUCTURAL of dlx is
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

			-- from CU, to IF stage
			I_IF_EN:	in std_logic;

			-- from CU, to ID stage
			I_BRANCH:	in branch_t;
			I_SIGNED:	in std_logic;
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
			O_TAKEN_PREV:	out std_logic;

			-- to CU, from EX stage
			O_DST_EX:	out std_logic_vector(RF_ADDR_SZ - 1 downto 0);
			O_LD_EX:	out std_logic;

			-- to CU, from MEM stage
			O_DST_MEM:	out std_logic_vector(RF_ADDR_SZ - 1 downto 0);
			O_LD_MEM:	out std_logic
		);
	end component datapath;

	component control_unit is
		port (
			-- from ID stage
			I_OPCODE:	in std_logic_vector(OPCODE_SZ - 1 downto 0);
			I_FUNC:		in std_logic_vector(FUNC_SZ - 1 downto 0);
			I_SRC_A:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
			I_SRC_B:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
			I_DST_R:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
			I_TAKEN_PREV:	in std_logic;

			-- from EX stage
			I_DST_EX:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
			I_LD_EX:	in std_logic;

			-- from MEM stage
			I_DST_MEM:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
			I_LD_MEM:	in std_logic;

			-- to IF stage
			O_IF_EN:	out std_logic;

			-- to ID stage
			O_BRANCH:	out branch_t;
			O_SIGNED:	out std_logic;
			O_SEL_A:	out source_t;
			O_SEL_B:	out source_t;

			-- to EX stage
			O_SEL_B_IMM:	out std_logic;
			O_ALUOP:	out std_logic_vector(FUNC_SZ - 1 downto 0);

			-- to MEM stage
			O_LD:		out std_logic;
			O_STR:		out std_logic;

			-- to WB stage
			O_DST:		out std_logic_vector(RF_ADDR_SZ - 1 downto 0)
		);
	end component control_unit;

	component config_register is
		port (
			I_CLK:		in std_logic;
			I_RST:		in std_logic;
			I_LD:		in std_logic;

			I_ENDIAN:	in std_logic;

			O_ENDIAN:	out std_logic
		);
	end component config_register;

	signal ENDIAN:		std_logic;
	signal IF_EN:		std_logic;
	signal BRANCH:		branch_t;
	signal S_SIGNED:	std_logic;
	signal SEL_A:		source_t;
	signal SEL_B:		source_t;
	signal SEL_B_IMM:	std_logic;
	signal ALUOP:		std_logic_vector(FUNC_SZ - 1 downto 0);
	signal LD:		std_logic;
	signal STR:		std_logic;
	signal DST:		std_logic_vector(RF_ADDR_SZ - 1 downto 0);
	signal OPCODE:		std_logic_vector(OPCODE_SZ - 1 downto 0);
	signal FUNC:		std_logic_vector(FUNC_SZ - 1 downto 0);
	signal SRC_A:		std_logic_vector(RF_ADDR_SZ - 1 downto 0);
	signal SRC_B:		std_logic_vector(RF_ADDR_SZ - 1 downto 0);
	signal DST_ID:		std_logic_vector(RF_ADDR_SZ - 1 downto 0);
	signal TAKEN_PREV:	std_logic;
	signal DST_EX:		std_logic_vector(RF_ADDR_SZ - 1 downto 0);
	signal LD_EX:		std_logic;
	signal DST_MEM:		std_logic_vector(RF_ADDR_SZ - 1 downto 0);
	signal LD_MEM:		std_logic;
begin
	datapath_0: datapath
		port map (
			I_CLK		=> I_CLK,
			I_RST		=> I_RST,
			I_ENDIAN	=> ENDIAN,
			I_INST		=> I_I_RD_DATA,
			I_D_RD_DATA	=> I_D_RD_DATA,
			I_IF_EN		=> IF_EN,
			I_BRANCH	=> BRANCH,
			I_SIGNED	=> S_SIGNED,
			I_SEL_A		=> SEL_A,
			I_SEL_B		=> SEL_B,
			I_SEL_B_IMM	=> SEL_B_IMM,
			I_ALUOP		=> ALUOP,
			I_LD		=> LD,
			I_STR		=> STR,
			I_DST		=> DST,
			O_PC		=> O_I_RD_ADDR,
			O_D_ADDR	=> O_D_ADDR,
			O_D_RD		=> O_D_RD,
			O_D_WR		=> O_D_WR,
			O_D_WR_DATA	=> O_D_WR_DATA,
			O_OPCODE	=> OPCODE,
			O_FUNC		=> FUNC,
			O_SRC_A		=> SRC_A,
			O_SRC_B		=> SRC_B,
			O_DST_ID	=> DST_ID,
			O_TAKEN_PREV	=> TAKEN_PREV,
			O_DST_EX	=> DST_EX,
			O_LD_EX		=> LD_EX,
			O_DST_MEM	=> DST_MEM,
			O_LD_MEM	=> LD_MEM
		);
	
	control_unit_0: control_unit
		port map (
			I_OPCODE	=> OPCODE,
			I_FUNC		=> FUNC,
			I_SRC_A		=> SRC_A,
			I_SRC_B		=> SRC_B,
			I_DST_R		=> DST_ID,
			I_TAKEN_PREV	=> TAKEN_PREV,
			I_DST_EX	=> DST_EX,
			I_LD_EX		=> LD_EX,
			I_DST_MEM	=> DST_MEM,
			I_LD_MEM	=> LD_MEM,
			O_IF_EN		=> IF_EN,
			O_BRANCH	=> BRANCH,
			O_SIGNED	=> S_SIGNED,
			O_SEL_A		=> SEL_A,
			O_SEL_B		=> SEL_B,
			O_SEL_B_IMM	=> SEL_B_IMM,
			O_ALUOP		=> ALUOP,
			O_LD		=> LD,
			O_STR		=> STR,
			O_DST		=> DST
		);

	-- loaded during reset
	config_register_0: config_register
		port map (
			I_CLK	=> I_CLK,
			I_RST	=> '0',
			I_LD	=> I_RST,
			I_ENDIAN=> I_ENDIAN,
			O_ENDIAN=> ENDIAN
		);
end STRUCTURAL;

