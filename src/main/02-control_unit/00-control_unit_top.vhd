library ieee;
use ieee.std_logic_1164.all;
use work.coding.all;
use work.types.all;

-- control_unit:
--	* connect all the control unit components in a single entity
entity control_unit is
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
end control_unit;

architecture STRUCTURAL of control_unit is
	component config_register is
		port (
			I_RST:			in std_logic;
			I_LD:			in std_logic;

			I_ENDIAN:		in std_logic;
			I_I_MEM_SZ:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);
			I_D_MEM_SZ:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);

			O_ENDIAN:		out std_logic;
			O_I_MEM_SZ:		out std_logic_vector(RF_DATA_SZ - 1 downto 0);
			O_D_MEM_SZ:		out std_logic_vector(RF_DATA_SZ - 1 downto 0)
		);
	end component config_register;

	component inst_decoder is
		port (
			-- from ID stage
			I_FUNC:		in std_logic_vector(FUNC_SZ - 1 downto 0);
			I_OPCODE:	in std_logic_vector(OPCODE_SZ - 1 downto 0);
			I_ZERO:		in std_logic;

			-- to ID stage
			O_TAKEN:	out std_logic;
			O_SEL_JMP:	out jump_t;
			O_IMM_SIGN:	out std_logic;

			-- to EX stage
			O_ALUOP:	out std_logic_vector(FUNC_SZ - 1 downto 0);
			O_SEL_B_IMM:	out std_logic;

			-- to MEM stage
			O_LD:		out std_logic_vector(1 downto 0);
			O_LD_SIGN:	out std_logic;
			O_STR:		out std_logic_vector(1 downto 0);

			-- to WB stage
			O_SEL_DST:	out dest_t;

			-- to CU
			O_A_NEEDED_ID:	out std_logic;
			O_A_NEEDED_EX:	out std_logic;
			O_B_NEEDED_EX:	out std_logic
		);
	end component inst_decoder;

	component stall_generator is
		port (
			I_TAKEN:	in std_logic;
			I_SEL_DST:	in dest_t;
			I_STR:		in std_logic_vector(1 downto 0);
			I_SEL_A:	in source_t;
			I_SEL_B:	in source_t;
			I_A_NEEDED_ID:	in std_logic;
			I_A_NEEDED_EX:	in std_logic;
			I_B_NEEDED_EX:	in std_logic;
			I_TAKEN_PREV:	in std_logic;

			O_IF_EN:	out std_logic;
			O_TAKEN:	out std_logic;
			O_STR:		out std_logic_vector(1 downto 0);
			O_SEL_DST:	out dest_t
		);
	end component stall_generator;
	
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

	signal TAKEN:		std_logic;
	signal SEL_DST:		dest_t;
	signal STR:		std_logic_vector(1 downto 0);
	signal SEL_A:		source_t;
	signal SEL_B:		source_t;
	signal A_NEEDED_ID:	std_logic;
	signal A_NEEDED_EX:	std_logic;
	signal B_NEEDED_EX:	std_logic;
begin
	config_register_0: config_register
		port map (
			I_RST		=> '0',
			I_LD		=> I_CFG,
			I_ENDIAN	=> I_ENDIAN,
			I_I_MEM_SZ	=> I_I_MEM_SZ,
			I_D_MEM_SZ	=> I_D_MEM_SZ,
			O_ENDIAN	=> O_ENDIAN,
			O_I_MEM_SZ	=> O_I_MEM_SZ,
			O_D_MEM_SZ	=> O_D_MEM_SZ
		);

	inst_decoder_0: inst_decoder
		port map (
			I_FUNC		=> I_FUNC,
			I_OPCODE	=> I_OPCODE,
			I_ZERO		=> I_ZERO,
			O_TAKEN		=> TAKEN,
			O_SEL_JMP	=> O_SEL_JMP,
			O_IMM_SIGN	=> O_IMM_SIGN,
			O_ALUOP		=> O_ALUOP,
			O_SEL_B_IMM	=> O_SEL_B_IMM,
			O_LD		=> O_LD,
			O_LD_SIGN	=> O_LD_SIGN,
			O_STR		=> STR,
			O_SEL_DST	=> SEL_DST,
			O_A_NEEDED_ID	=> A_NEEDED_ID,
			O_A_NEEDED_EX	=> A_NEEDED_EX,
			O_B_NEEDED_EX	=> B_NEEDED_EX
		);

	data_forwarder_0: data_forwarder
		port map (
			I_ZERO_SRC_A		=> I_ZERO_SRC_A,
			I_ZERO_SRC_B		=> I_ZERO_SRC_B,
			I_SRC_A_EQ_DST_EX	=> I_SRC_A_EQ_DST_EX,
			I_SRC_B_EQ_DST_EX	=> I_SRC_B_EQ_DST_EX,
			I_SRC_A_EQ_DST_MEM	=> I_SRC_A_EQ_DST_MEM,
			I_SRC_B_EQ_DST_MEM	=> I_SRC_B_EQ_DST_MEM,
			I_SRC_A_EQ_DST_WB	=> I_SRC_A_EQ_DST_WB,
			I_SRC_B_EQ_DST_WB	=> I_SRC_B_EQ_DST_WB,
			I_LD_EX			=> I_LD_EX,
			I_LD_MEM		=> I_LD_MEM,
			I_LD_WB			=> I_LD_WB,
			O_SEL_A			=> SEL_A,
			O_SEL_B			=> SEL_B
		);

	O_SEL_A <= SEL_A;
	O_SEL_B <= SEL_B;

	stall_generator_0: stall_generator
		port map (
			I_TAKEN		=> TAKEN,
			I_SEL_DST	=> SEL_DST,
			I_STR		=> STR,
			I_SEL_A		=> SEL_A,
			I_SEL_B		=> SEL_B,
			I_A_NEEDED_ID	=> A_NEEDED_ID,
			I_A_NEEDED_EX	=> A_NEEDED_EX,
			I_B_NEEDED_EX	=> B_NEEDED_EX,
			I_TAKEN_PREV	=> I_TAKEN_PREV,
			O_IF_EN		=> O_IF_EN,
			O_TAKEN		=> O_TAKEN,
			O_STR		=> O_STR,
			O_SEL_DST	=> O_SEL_DST
		);
end STRUCTURAL;

