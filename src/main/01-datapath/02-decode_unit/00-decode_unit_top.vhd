library ieee;
use ieee.std_logic_1164.all;
use work.coding.all;
use work.utilities.all;

-- decode_unit:
--	* extract data from encoded instruction
--	* extend operands
--	* read from registerfile
--	* compute next PC
entity decode_unit is
	port (
		-- I_IR: from IF stage; encoded instruction
		I_IR:		in std_logic_vector(0 to INST_SZ - 1);
		-- I_NPC: from IF stage; next PC value if instruction is
		--	not a taken branch
		I_NPC:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);

		-- I_RDx_DATA: from rf; data read from rf at address O_RDx_ADDR
		I_RD1_DATA:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);
		I_RD2_DATA:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);

		-- from CU
		I_SEL_OP1:	in std_logic;
		I_SEL_OP2:	in std_logic_vector(1 downto 0);
		I_TAKEN:	in std_logic;
		I_SIGNED:	in std_logic;

		-- O_RDx_ADDR: to rf; address at which rf has to be read
		O_RD1_ADDR:	out std_logic_vector(RF_ADDR_SZ - 1 downto 0);
		O_RD2_ADDR:	out std_logic_vector(RF_ADDR_SZ - 1 downto 0);

		-- O_DST: to WB stage; address at which rf has to be written
		O_DST:		out std_logic_vector(RF_ADDR_SZ - 1 downto 0);

		-- to CU
		O_OPCODE:	out std_logic_vector(OPCODE_SZ - 1 downto 0);
		O_FUNC:		out std_logic_vector(FUNC_SZ - 1 downto 0);
		O_ZERO:		out std_logic;

		-- to EX stage; ALU operands
		O_RD1:		out std_logic_vector(RF_DATA_SZ - 1 downto 0);
		O_RD2:		out std_logic_vector(RF_DATA_SZ - 1 downto 0);
		O_IMM:		out std_logic_vector(RF_DATA_SZ - 1 downto 0);

		-- O_TARGET: to IF stage; address of next instruction
		O_TARGET:	out std_logic_vector(RF_DATA_SZ - 1 downto 0)
	);
end decode_unit;

architecture MIXED of decode_unit is
	component pc_computer is
		port (
			I_SEL_OP1:	in std_logic;
			I_SEL_OP2:	in std_logic_vector(1 downto 0);
			I_TAKEN:	in std_logic;
			I_NPC:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);
			-- I_A: value loaded from rf
			I_A:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);
			-- I_IMM: offset extracted by I-type instruction
			I_IMM:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);
			-- I_OFF: offset extracted by J-type instruction
			I_OFF:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);

			O_TARGET:	out std_logic_vector(RF_DATA_SZ - 1 downto 0)
		);
	end component pc_computer;

	signal IMM:	std_logic_vector(IMM_SZ - 1 downto 0);
	signal IMM_EXT:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal OFF:	std_logic_vector(OFF_SZ - 1 downto 0);
	signal OFF_EXT:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
begin
	IMM	<= I_IR(I_IMM_RANGE);
	OFF	<= I_IR(J_OFF_RANGE);

	-- extend
	IMM_EXT	<= zero_extend(IMM, RF_DATA_SZ) when (I_SIGNED = '0')
		else sign_extend(IMM, IMM'left, RF_DATA_SZ);
	OFF_EXT	<= sign_extend(OFF, OFF'left, RF_DATA_SZ);

	pc_computer_0: pc_computer
		port map (
			I_SEL_OP1	=> I_SEL_OP1,
			I_SEL_OP2	=> I_SEL_OP2,
			I_TAKEN		=> I_TAKEN,
			I_NPC		=> I_NPC,
			I_A		=> I_RD1_DATA,
			I_IMM		=> IMM_EXT,
			I_OFF		=> OFF_EXT,
			O_TARGET	=> O_TARGET
		);

	-- rf addresses
	O_RD1_ADDR	<= I_IR(R_SRC1_RANGE);
	O_RD2_ADDR	<= I_IR(R_SRC2_RANGE);
	O_DST		<= I_IR(R_DST_RANGE);

	-- outputs to EX stage
	O_RD1	<= I_RD1_DATA;
	O_RD2 	<= I_RD2_DATA;

	O_IMM	<= IMM_EXT;

	O_ZERO	<= '1' when (I_RD1_DATA = (I_RD1_DATA'range => '0')) else '0';

	O_OPCODE<= I_IR(OPCODE_RANGE);
	O_FUNC	<= I_IR(FUNC_RANGE);
end MIXED;

