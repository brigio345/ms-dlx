library ieee;
use ieee.std_logic_1164.all;
use work.coding.all;
use work.types.all;

entity control_unit is
	port (
		-- from environment
		I_CFG:		in std_logic;
		I_ENDIAN:	in std_logic;

		-- from ID stage
		I_OPCODE:	in std_logic_vector(OPCODE_SZ - 1 downto 0);
		I_FUNC:		in std_logic_vector(FUNC_SZ - 1 downto 0);
		I_SRC_A:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
		I_SRC_B:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
		I_DST_R:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
		I_TAKEN_PREV:	in std_logic;

		-- from EX stage
		I_DST_EX:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
		I_LD_EX:	in std_logic_vector(1 downto 0);

		-- from MEM stage
		I_DST_MEM:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
		I_LD_MEM:	in std_logic_vector(1 downto 0);

		-- to IF stage
		O_IF_EN:	out std_logic;
		O_ENDIAN:	out std_logic;

		-- to ID stage
		O_BRANCH:	out branch_t;
		O_SIGNED:	out std_logic;
		O_SEL_A:	out source_t;
		O_SEL_B:	out source_t;

		-- to EX stage
		O_SEL_B_IMM:	out std_logic;
		O_ALUOP:	out std_logic_vector(FUNC_SZ - 1 downto 0);

		-- to MEM stage
		O_LD:		out std_logic_vector(1 downto 0);
		O_STR:		out std_logic_vector(1 downto 0);

		-- to WB stage
		O_DST:		out std_logic_vector(RF_ADDR_SZ - 1 downto 0)
	);
end control_unit;

architecture MIXED of control_unit is
	component config_register is
		port (
			I_RST:		in std_logic;
			I_LD:		in std_logic;

			I_ENDIAN:	in std_logic;

			O_ENDIAN:	out std_logic
		);
	end component config_register;

	component inst_decoder is
		port (
			-- from ID stage
			I_FUNC:		in std_logic_vector(FUNC_SZ - 1 downto 0);
			I_OPCODE:	in std_logic_vector(OPCODE_SZ - 1 downto 0);
			I_DST_R:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
			I_DST_I:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);

			-- to ID stage
			O_BRANCH:	out branch_t;
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
			O_INST_TYPE:	out inst_t
		);
	end component inst_decoder;
	
	component data_forwarder is
		port (
			-- from ID stage
			I_SRC_A:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
			I_SRC_B:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);

			-- from EX stage
			I_DST_EX:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
			I_LD_EX:	in std_logic_vector(1 downto 0);

			-- from MEM stage
			I_DST_MEM:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
			I_LD_MEM:	in std_logic_vector(1 downto 0);

			O_SEL_A:	out source_t;
			O_SEL_B:	out source_t
		);
	end component data_forwarder;

	signal INST_TYPE:	inst_t;
	signal DST:		std_logic_vector(RF_ADDR_SZ - 1 downto 0);
	signal STR:		std_logic_vector(1 downto 0);
	signal BRANCH:		branch_t;
	signal SEL_A:		source_t;
	signal SEL_B:		source_t;
	signal A_NEEDED:	std_logic;
	signal B_NEEDED:	std_logic;
	signal DATA_HAZ:	std_logic;
begin
	config_register_0: config_register
		port map (
			I_RST	=> '0',
			I_LD	=> I_CFG,
			I_ENDIAN=> I_ENDIAN,
			O_ENDIAN=> O_ENDIAN
		);

	inst_decoder_0: inst_decoder
		port map (
			I_FUNC		=> I_FUNC,
			I_OPCODE	=> I_OPCODE,
			I_DST_R		=> I_DST_R,
			I_DST_I		=> I_SRC_B,
			O_BRANCH	=> BRANCH,
			O_SIGNED	=> O_SIGNED,
			O_ALUOP		=> O_ALUOP,
			O_SEL_B_IMM	=> O_SEL_B_IMM,
			O_LD		=> O_LD,
			O_STR		=> STR,
			O_DST		=> DST,
			O_INST_TYPE	=> INST_TYPE
		);

	data_forwarder_0: data_forwarder
		port map (
			I_SRC_A		=> I_SRC_A,
			I_SRC_B		=> I_SRC_B,
			I_DST_EX	=> I_DST_EX,
			I_LD_EX		=> I_LD_EX,
			I_DST_MEM	=> I_DST_MEM,
			I_LD_MEM	=> I_LD_MEM,
			O_SEL_A		=> SEL_A,
			O_SEL_B		=> SEL_B
		);

	O_SEL_A <= SEL_A;
	O_SEL_B <= SEL_B;

	A_NEEDED <= '1' when (INST_TYPE /= INST_JMP_ABS) else '0';
	B_NEEDED <= '1' when (INST_TYPE = INST_REG) else '0';

	-- data hazard occurs when a needed source operand has to be loaded
	-- by the instruction which currently is in EX stage
	DATA_HAZ <= '1' when (((SEL_A = SRC_LD_EX) AND (A_NEEDED = '1')) OR
		    ((SEL_B = SRC_LD_EX) AND (B_NEEDED = '1')))
		    else '0';

	stall_gen: process (I_TAKEN_PREV, DATA_HAZ, BRANCH, STR, DST)
	begin
		if (I_TAKEN_PREV = '1') then
			-- stall: disable branches and writes (to memory and rf)
			--	so that current instruction will not have any
			--	effect
			-- 	IF can proceed, since PC has been updated with
			--	the right instruction
			O_BRANCH	<= BR_NO;
			O_STR		<= "00";
			O_DST		<= (others => '0');
			O_IF_EN		<= '1';
		elsif (DATA_HAZ = '1') then
			-- stall: disable branches and writes (to memory and rf)
			--	so that current instruction will not have any
			--	effect
			--	IF cannot proceed, since current instruction
			--	must wait for its operands and then executed
			O_BRANCH	<= BR_NO;
			O_STR		<= "00";
			O_DST		<= (others => '0');
			O_IF_EN		<= '0';
		else
			-- no stall: output decoded data
			O_BRANCH	<= BRANCH;
			O_STR		<= STR;
			O_DST		<= DST;
			O_IF_EN		<= '1';
		end if;
	end process stall_gen;
end MIXED;

