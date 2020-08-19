library ieee;
use ieee.std_logic_1164.all;
use work.coding.all;
use work.types.all;

entity control_unit is
	port (
		-- from ID stage
		I_OPCODE:	in std_logic_vector(OPCODE_SZ - 1 downto 0);
		I_FUNC:		in std_logic_vector(FUNC_SZ - 1 downto 0);
		I_SRC_A:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
		I_SRC_B:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
		I_DST_R:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
		I_TAKEN:	in std_logic;

		-- from EX stage
		I_DST_EX:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
		I_LD_EX:	in std_logic;

		-- from MEM stage
		I_DST_MEM:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
		I_LD_MEM:	in std_logic;

		-- to ID stage
		O_BRANCH:	out branch_t;
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
end control_unit;

architecture STRUCTURAL of control_unit is
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
	
	component hazard_manager is
		port (
			-- from ID stage
			I_INST_TYPE:	in inst_t;
			I_SRC_A:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
			I_SRC_B:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
			I_TAKEN:	in std_logic;
			I_DST:		in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
			I_STR:		in std_logic;
			I_BRANCH:	in branch_t;

			-- from EX stage
			I_DST_EX:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
			I_LD_EX:	in std_logic;

			-- from MEM stage
			I_DST_MEM:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
			I_LD_MEM:	in std_logic;

			-- to ID stage
			O_SEL_A:	out source_t;
			O_SEL_B:	out source_t;
			O_BRANCH:	out branch_t;
			O_DST:		out std_logic_vector(RF_ADDR_SZ - 1 downto 0);
			O_STR:		out std_logic
		);
	end component hazard_manager;

	signal INST_TYPE:	inst_t;
	signal DST:		std_logic_vector(RF_ADDR_SZ - 1 downto 0);
	signal STR:		std_logic;
	signal BRANCH:		branch_t;
begin
	inst_decoder_0: inst_decoder
		port map (
			I_FUNC		=> I_FUNC,
			I_OPCODE	=> I_OPCODE,
			I_DST_R		=> I_DST_R,
			I_DST_I		=> I_SRC_B,
			O_BRANCH	=> BRANCH,
			O_ALUOP		=> O_ALUOP,
			O_SEL_B_IMM	=> O_SEL_B_IMM,
			O_LD		=> O_LD,
			O_STR		=> STR,
			O_DST		=> DST,
			O_INST_TYPE	=> INST_TYPE
		);

	hazard_manager_0: hazard_manager
		port map (
			I_INST_TYPE	=> INST_TYPE,
			I_SRC_A		=> I_SRC_A,
			I_SRC_B		=> I_SRC_B,
			I_TAKEN		=> I_TAKEN,
			I_DST		=> DST,
			I_STR		=> STR,
			I_BRANCH	=> BRANCH,
			I_DST_EX	=> I_DST_EX,
			I_LD_EX		=> I_LD_EX,
			I_DST_MEM	=> I_DST_MEM,
			I_LD_MEM	=> I_LD_MEM,
			O_SEL_A		=> O_SEL_A,
			O_SEL_B		=> O_SEL_B,
			O_BRANCH	=> O_BRANCH,
			O_DST		=> O_DST,
			O_STR		=> O_STR
		);
end STRUCTURAL;

