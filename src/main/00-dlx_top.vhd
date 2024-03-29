library IEEE;
use IEEE.std_logic_1164.all;
use work.coding.all;
use work.types.all;

-- dlx: top-level entity of the DLX core; connect control unit and datapath
entity dlx is
	port (
		I_CLK:		in std_logic;
		I_RST:		in std_logic;

		-- I_ENDIAN: specify endianness of data and instruction memories
		--	- '0' => BIG endian
		--	- '1' => LITTLE endian
		I_ENDIAN:	in std_logic;
		I_I_MEM_SZ:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);
		I_D_MEM_SZ:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);

		I_I_RD_DATA:	in std_logic_vector(INST_SZ - 1 downto 0);
		I_D_RD_DATA:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);

		O_I_RD_ADDR:	out std_logic_vector(RF_DATA_SZ - 1 downto 0);

		O_D_ADDR:	out std_logic_vector(RF_DATA_SZ - 1 downto 0);
		O_D_RD:		out std_logic_vector(1 downto 0);
		O_D_WR:		out std_logic_vector(1 downto 0);
		O_D_WR_DATA:	out std_logic_vector(RF_DATA_SZ - 1 downto 0)
	);
end dlx;

architecture STRUCTURAL of dlx is
	component datapath is
		port (
			I_CLK:			in std_logic;
			I_RST:			in std_logic;

			-- I_ENDIAN: specify endianness of data and instruction memories
			--	- '0' => BIG endian
			--	- '1' => LITTLE endian
			I_ENDIAN:		in std_logic;
			I_I_MEM_SZ:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);
			I_D_MEM_SZ:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);

			-- from i-memory
			I_INST:			in std_logic_vector(INST_SZ - 1 downto 0);

			-- from d-memory
			I_D_RD_DATA:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);

			-- from CU, to IF stage
			I_IF_EN:		in std_logic;

			-- from CU, to ID stage
			I_TAKEN:		in std_logic;
			I_SEL_JMP:		in jump_t;
			I_IMM_SIGN:		in std_logic;
			I_SEL_A:		in source_t;
			I_SEL_B:		in source_t;

			-- from CU, to EX stage
			I_SEL_B_IMM:		in std_logic;
			I_ALUOP:		in std_logic_vector(FUNC_SZ - 1 downto 0);

			-- from CU, to MEM stage
			I_LD:			in std_logic_vector(1 downto 0);
			I_LD_SIGN:		in std_logic;
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
			O_SRC_A_EQ_DST_WB:	out std_logic;
			O_SRC_B_EQ_DST_WB:	out std_logic;
			O_TAKEN_PREV:		out std_logic;

			-- to CU, from EX stage
			O_LD_EX:		out std_logic_vector(1 downto 0);

			-- to CU, from MEM stage
			O_LD_MEM:		out std_logic_vector(1 downto 0);

			-- to CU, from WB stage
			O_LD_WB:		out std_logic_vector(1 downto 0)
		);
	end component datapath;

	component control_unit is
		port (
			-- from environment
			I_CFG:			in std_logic;
			I_ENDIAN:		in std_logic;
			I_I_MEM_SZ:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);
			I_D_MEM_SZ:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);

			-- from ID stage
			I_OPCODE:		in std_logic_vector(OPCODE_SZ - 1 downto 0);
			I_FUNC:			in std_logic_vector(FUNC_SZ - 1 downto 0);
			I_ZERO:			in std_logic;
			I_ZERO_SRC_A:		in std_logic;
			I_ZERO_SRC_B:		in std_logic;
			I_SRC_A_EQ_DST_EX:	in std_logic;
			I_SRC_B_EQ_DST_EX:	in std_logic;
			I_SRC_A_EQ_DST_MEM:	in std_logic;
			I_SRC_B_EQ_DST_MEM:	in std_logic;
			I_SRC_A_EQ_DST_WB:	in std_logic;
			I_SRC_B_EQ_DST_WB:	in std_logic;
			I_TAKEN_PREV:		in std_logic;

			-- from EX stage
			I_LD_EX:		in std_logic_vector(1 downto 0);

			-- from MEM stage
			I_LD_MEM:		in std_logic_vector(1 downto 0);

			-- from WB stage
			I_LD_WB:		in std_logic_vector(1 downto 0);

			-- to IF stage
			O_IF_EN:		out std_logic;
			O_ENDIAN:		out std_logic;
			O_I_MEM_SZ:		out std_logic_vector(RF_DATA_SZ - 1 downto 0);
			O_D_MEM_SZ:		out std_logic_vector(RF_DATA_SZ - 1 downto 0);

			-- to ID stage
			O_TAKEN:		out std_logic;
			O_SEL_JMP:		out jump_t;
			O_IMM_SIGN:		out std_logic;
			O_SEL_A:		out source_t;
			O_SEL_B:		out source_t;

			-- to EX stage
			O_SEL_B_IMM:		out std_logic;
			O_ALUOP:		out std_logic_vector(FUNC_SZ - 1 downto 0);

			-- to MEM stage
			O_LD:			out std_logic_vector(1 downto 0);
			O_LD_SIGN:		out std_logic;
			O_STR:			out std_logic_vector(1 downto 0);

			-- to WB stage
			O_SEL_DST:		out dest_t
		);
	end component control_unit;

	signal ENDIAN:		std_logic;
	signal D_MEM_SZ:	std_logic_vector(I_D_MEM_SZ'range);
	signal I_MEM_SZ:	std_logic_vector(I_I_MEM_SZ'range);
	signal IF_EN:		std_logic;
	signal IMM_SIGN:	std_logic;
	signal SEL_A:		source_t;
	signal SEL_B:		source_t;
	signal SEL_B_IMM:	std_logic;
	signal ALUOP:		std_logic_vector(FUNC_SZ - 1 downto 0);
	signal LD:		std_logic_vector(1 downto 0);
	signal LD_SIGN:		std_logic;
	signal STR:		std_logic_vector(1 downto 0);
	signal SEL_DST:		dest_t;
	signal OPCODE_ID:	std_logic_vector(OPCODE_SZ - 1 downto 0);
	signal FUNC:		std_logic_vector(FUNC_SZ - 1 downto 0);
	signal ZERO_SRC_A:	std_logic;
	signal ZERO_SRC_B:	std_logic;
	signal SRC_A_EQ_DST_EX:	std_logic;
	signal SRC_B_EQ_DST_EX:	std_logic;
	signal SRC_A_EQ_DST_MEM:std_logic;
	signal SRC_B_EQ_DST_MEM:std_logic;
	signal SRC_A_EQ_DST_WB:	std_logic;
	signal SRC_B_EQ_DST_WB:	std_logic;
	signal TAKEN_PREV:	std_logic;
	signal LD_EX:		std_logic_vector(1 downto 0);
	signal LD_MEM:		std_logic_vector(1 downto 0);
	signal LD_WB:		std_logic_vector(1 downto 0);
	signal ZERO:		std_logic;
	signal TAKEN:		std_logic;
	signal SEL_JMP:		jump_t;
begin
	datapath_0: datapath
		port map (
			I_CLK			=> I_CLK,
			I_RST			=> I_RST,
			I_ENDIAN		=> ENDIAN,
			I_I_MEM_SZ		=> I_MEM_SZ,
			I_D_MEM_SZ		=> D_MEM_SZ,
			I_INST			=> I_I_RD_DATA,
			I_D_RD_DATA		=> I_D_RD_DATA,
			I_IF_EN			=> IF_EN,
			I_TAKEN			=> TAKEN,
			I_SEL_JMP		=> SEL_JMP,
			I_IMM_SIGN		=> IMM_SIGN,
			I_SEL_A			=> SEL_A,
			I_SEL_B			=> SEL_B,
			I_SEL_B_IMM		=> SEL_B_IMM,
			I_ALUOP			=> ALUOP,
			I_LD			=> LD,
			I_LD_SIGN		=> LD_SIGN,
			I_STR			=> STR,
			I_SEL_DST		=> SEL_DST,
			O_PC			=> O_I_RD_ADDR,
			O_D_ADDR		=> O_D_ADDR,
			O_D_RD			=> O_D_RD,
			O_D_WR			=> O_D_WR,
			O_D_WR_DATA		=> O_D_WR_DATA,
			O_ZERO			=> ZERO,
			O_OPCODE		=> OPCODE_ID,
			O_FUNC			=> FUNC,
			O_ZERO_SRC_A		=> ZERO_SRC_A,
			O_ZERO_SRC_B		=> ZERO_SRC_B,
			O_SRC_A_EQ_DST_EX	=> SRC_A_EQ_DST_EX,
			O_SRC_B_EQ_DST_EX	=> SRC_B_EQ_DST_EX,
			O_SRC_A_EQ_DST_MEM	=> SRC_A_EQ_DST_MEM,
			O_SRC_B_EQ_DST_MEM	=> SRC_B_EQ_DST_MEM,
			O_SRC_A_EQ_DST_WB	=> SRC_A_EQ_DST_WB,
			O_SRC_B_EQ_DST_WB	=> SRC_B_EQ_DST_WB,
			O_TAKEN_PREV		=> TAKEN_PREV,
			O_LD_EX			=> LD_EX,
			O_LD_MEM		=> LD_MEM,
			O_LD_WB			=> LD_WB
		);
	
	control_unit_0: control_unit
		port map (
			I_CFG			=> I_RST,
			I_ENDIAN		=> I_ENDIAN,
			I_I_MEM_SZ		=> I_I_MEM_SZ,
			I_D_MEM_SZ		=> I_D_MEM_SZ,
			I_OPCODE		=> OPCODE_ID,
			I_FUNC			=> FUNC,
			I_ZERO			=> ZERO,
			I_ZERO_SRC_A		=> ZERO_SRC_A,
			I_ZERO_SRC_B		=> ZERO_SRC_B,
			I_SRC_A_EQ_DST_EX	=> SRC_A_EQ_DST_EX,
			I_SRC_B_EQ_DST_EX	=> SRC_B_EQ_DST_EX,
			I_SRC_A_EQ_DST_MEM	=> SRC_A_EQ_DST_MEM,
			I_SRC_B_EQ_DST_MEM	=> SRC_B_EQ_DST_MEM,
			I_SRC_A_EQ_DST_WB	=> SRC_A_EQ_DST_WB,
			I_SRC_B_EQ_DST_WB	=> SRC_B_EQ_DST_WB,
			I_TAKEN_PREV		=> TAKEN_PREV,
			I_LD_EX			=> LD_EX,
			I_LD_MEM		=> LD_MEM,
			I_LD_WB			=> LD_WB,
			O_IF_EN			=> IF_EN,
			O_ENDIAN		=> ENDIAN,
			O_I_MEM_SZ		=> I_MEM_SZ,
			O_D_MEM_SZ		=> D_MEM_SZ,
			O_TAKEN			=> TAKEN,
			O_SEL_JMP		=> SEL_JMP,
			O_IMM_SIGN		=> IMM_SIGN,
			O_SEL_A			=> SEL_A,
			O_SEL_B			=> SEL_B,
			O_SEL_B_IMM		=> SEL_B_IMM,
			O_ALUOP			=> ALUOP,
			O_LD			=> LD,
			O_LD_SIGN		=> LD_SIGN,
			O_STR			=> STR,
			O_SEL_DST		=> SEL_DST
		);
end STRUCTURAL;

