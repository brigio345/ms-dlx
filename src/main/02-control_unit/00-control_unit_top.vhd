library ieee;
use ieee.std_logic_1164.all;
use work.coding.all;
use work.types.all;

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
		O_SIGNED:		out std_logic;
		O_SEL_A:		out source_t;
		O_SEL_B:		out source_t;

		-- to EX stage
		O_SEL_B_IMM:		out std_logic;
		O_ALUOP:		out std_logic_vector(FUNC_SZ - 1 downto 0);

		-- to MEM stage
		O_LD:			out std_logic_vector(1 downto 0);
		O_STR:			out std_logic_vector(1 downto 0);

		-- to WB stage
		O_SEL_DST:		out dest_t
	);
end control_unit;

architecture MIXED of control_unit is
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
			O_SIGNED:	out std_logic;

			-- to EX stage
			O_ALUOP:	out std_logic_vector(FUNC_SZ - 1 downto 0);
			O_SEL_B_IMM:	out std_logic;

			-- to MEM stage
			O_LD:		out std_logic_vector(1 downto 0);
			O_STR:		out std_logic_vector(1 downto 0);

			-- to WB stage
			O_SEL_DST:	out dest_t;

			-- to CU
			O_A_NEEDED_ID:	out std_logic;
			O_A_NEEDED_EX:	out std_logic;
			O_B_NEEDED_EX:	out std_logic
		);
	end component inst_decoder;
	
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
	signal DATA_STALL:	std_logic;
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
			O_SIGNED	=> O_SIGNED,
			O_ALUOP		=> O_ALUOP,
			O_SEL_B_IMM	=> O_SEL_B_IMM,
			O_LD		=> O_LD,
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

	-- Data forwarding:
	--	* to ID stage:
	--		1. from ALUOUT of instruction in MEM stage
	--	* to EX stage:
	--		1. from ALUOUT of instruction in MEM stage
	--		2. from ALUOUT of instruction in EX stage
	--		3. from LOADED of instruction in MEM stage
	--	* to MEM stage:
	--		1. from ALUOUT of instruction in MEM stage
	--		2. from ALUOUT of instruction in EX stage
	--		3. from LOADED of instruction in MEM stage
	--		4. from LOADED of instruction in EX stage

	-- Insert a data stall in ID stage when data is not in rf and cannot
	--	be forwarded
	DATA_STALL <= '1' when (
			((A_NEEDED_ID = '1') AND ((SEL_A /= SRC_RF) AND (SEL_A /= SRC_ALU_MEM))) OR
			((A_NEEDED_EX = '1') AND (SEL_A = SRC_LD_EX)) OR
		    	((B_NEEDED_EX = '1') AND (SEL_B = SRC_LD_EX)))
		    else '0';

	stall_gen: process (I_TAKEN_PREV, DATA_STALL, STR, SEL_DST, TAKEN)
	begin
		if (I_TAKEN_PREV = '1') then
			-- stall: disable branches and writes (to memory and rf)
			--	so that current instruction will not have any
			--	effect
			-- 	IF can proceed, since PC has been updated with
			--	the right instruction
			O_STR		<= "00";
			O_SEL_DST	<= DST_NO;
			O_TAKEN		<= '0';
			O_IF_EN		<= '1';
		elsif (DATA_STALL = '1') then
			-- stall: disable branches and writes (to memory and rf)
			--	so that current instruction will not have any
			--	effect
			--	IF cannot proceed, since current instruction
			--	must wait for its operands and then executed
			O_STR		<= "00";
			O_SEL_DST	<= DST_NO;
			O_TAKEN		<= '0';
			O_IF_EN		<= '0';
		else
			-- no stall: output decoded data
			O_STR		<= STR;
			O_SEL_DST	<= SEL_DST;
			O_TAKEN		<= TAKEN;
			O_IF_EN		<= '1';
		end if;
	end process stall_gen;
end MIXED;

