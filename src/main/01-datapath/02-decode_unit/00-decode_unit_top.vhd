library ieee;
use ieee.std_logic_1164.all;
use work.coding.all;
use work.types.all;

-- decode_unit:
--	* extract data from encoded instruction
--	* sign extend operands
--	* read from registerfile
--	* compute next PC
entity decode_unit is
	port (
		-- I_IR: from IF stage; encoded instruction
		I_IR:		in std_logic_vector(INST_SZ - 1 downto 0);
		-- I_NPC: from IF stage; next PC value if instruction is
		--	not a taken branch
		I_NPC:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);

		-- I_RDx_DATA: from rf; data read from rf at address O_RDx_ADDR
		I_RD1_DATA:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);
		I_RD2_DATA:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);

		-- from CU
		I_BRANCH:	in branch_t;

		-- O_RDx_ADDR: to rf; address at which rf has to be read
		O_RD1_ADDR:	out std_logic_vector(RF_ADDR_SZ - 1 downto 0);
		O_RD2_ADDR:	out std_logic_vector(RF_ADDR_SZ - 1 downto 0);

		-- O_DST: to WB stage; address at which rf has to be written
		O_DST:		out std_logic_vector(RF_ADDR_SZ - 1 downto 0);

		-- to CU
		O_OPCODE:	out std_logic_vector(OPCODE_SZ - 1 downto 0);
		O_FUNC:		out std_logic_vector(FUNC_SZ - 1 downto 0);

		-- to EX stage; ALU operands
		O_RD1:		out std_logic_vector(RF_DATA_SZ - 1 downto 0);
		O_RD2:		out std_logic_vector(RF_DATA_SZ - 1 downto 0);
		O_IMM:		out std_logic_vector(RF_DATA_SZ - 1 downto 0);

		-- O_TARGET: to IF stage; address of next instruction
		O_TARGET:	out std_logic_vector(RF_DATA_SZ - 1 downto 0);
		
		-- O_TAKEN: to CU and IF stage
		O_TAKEN:	out std_logic;

		O_PC:		out std_logic_vector(RF_DATA_SZ - 1 downto 0)
	);
end decode_unit;

architecture MIXED of decode_unit is
	component target_computer is
		port (
			I_BRANCH:	in branch_t;
			I_NPC:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);
			I_ABS:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);
			I_IMM:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);
			I_OFF:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);

			O_TARGET:	out std_logic_vector(RF_DATA_SZ - 1 downto 0);
			O_TAKEN:	out std_logic
		);
	end component target_computer;

	signal IMM:	std_logic_vector(O_PC'range);
	signal OFF:	std_logic_vector(O_PC'range);
begin
	-- sign extend
	IMM <= (RF_DATA_SZ - 1 downto IMM_SZ => I_IR(I_IMM_START)) &
		I_IR(I_IMM_END downto I_IMM_START);
	OFF <= (RF_DATA_SZ - 1 downto OFF_SZ => I_IR(J_OFF_START)) &
		I_IR(J_OFF_END downto J_OFF_START);

	target_computer_0: target_computer
		port map (
			I_BRANCH=> I_BRANCH,
			I_NPC	=> I_NPC,
			I_ABS	=> I_RD1_DATA,
			I_IMM	=> IMM,
			I_OFF	=> OFF,
			O_TARGET=> O_TARGET,
			O_TAKEN	=> O_TAKEN
		);

	-- rf addresses
	O_RD1_ADDR	<= I_IR(R_SRC1_END downto R_SRC1_START);
	O_RD2_ADDR	<= I_IR(R_SRC2_END downto R_SRC2_START);
	O_DST		<= I_IR(R_DST_END downto R_DST_START);

	O_RD1 <= I_RD1_DATA;
	O_RD2 <= I_RD2_DATA;

	O_IMM	<= IMM;

	O_OPCODE	<= I_IR(OPCODE_END downto OPCODE_START);
	O_FUNC		<= I_IR(FUNC_END downto FUNC_START);
end MIXED;

