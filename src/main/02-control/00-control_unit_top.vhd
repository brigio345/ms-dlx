library ieee;
use ieee.std_logic_1164.all;
use work.coding.all;
use work.types.all;

entity control_unit is
	port (
		I_CLK:		in std_logic;
		I_RST:		in std_logic;

		-- to CU
		I_OPCODE:	in std_logic_vector(OPCODE_SZ - 1 downto 0);
		I_FUNC:		in std_logic_vector(FUNC_SZ - 1 downto 0);

		-- from EX stage
		I_DST_EX:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
		I_LD_EX:	in std_logic;

		-- from MEM stage
		I_DST_MEM:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
		I_LD_MEM:	in std_logic;

		O_ID_IF_EN:	out std_logic;

		-- to ID stage
		O_SEL_A:	out source_t;
		O_SEL_B:	out source_t;

		-- to EX stage
		O_SEL_B_IMM:	out std_logic;
		O_ALUOP:	out aluop_t;

		-- to MEM stage
		O_LD:		out std_logic;
		O_STR:		out std_logic;

		-- to WB stage
		O_WB_DST:	out std_logic_vector(RF_ADDR_SZ - 1 downto 0)
	);
end control_unit;

architecture FSM of control_unit is
	component instr_decoder is
		port (
			-- from ID stage
			I_FUNC:		in std_logic_vector(FUNC_SZ - 1 downto 0);
			I_OPCODE:	in std_logic_vector(OPCODE_SZ - 1 downto 0);

			-- to ID stage
			O_BRANCH:	out branch_t;

			-- to EX stage
			O_ALUOP:	out aluop_t;
			O_SEL_B_IMM:	out std_logic; -- alu op2

			-- to MEM stage
			O_LD:		out std_logic;
			O_STR:		out std_logic;

			-- to WB stage
			O_WB_DST:	out std_logic_vector(R_DST_SZ - 1 downto 0)
		);
	end component instr_decoder;
begin
	inst_decoder_0: inst_decoder
		port map (
			I_FUNC		=> I_FUNC,
			I_OPCODE	=> I_OPCODE,
			O_BRANCH	=> O_BRANCH,
			O_ALUOP		=> O_ALUOP,
			O_SEL_B_IMM	=> O_SEL_B_IMM,
			O_LD		=> O_LD,
			O_STR		=> O_STR,
			O_WB_DST	=> O_WB_DST
		);
end FSM;

