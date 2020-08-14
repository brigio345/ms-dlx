library ieee;
use ieee.std_logic_1164.all;
use work.specs.all;
use work.source_types.all;

-- decode_unit:
--	* extract data from encoded instruction
--	* sign extend operands
--	* read from registerfile
--	* compute next PC
entity decode_unit is
	port (
		-- I_IR: from IF stage; encoded instruction
		I_IR:		in std_logic_vector(INST_SIZE - 1 downto 0);
		-- I_NPC: from IF stage; next PC value if instruction is
		--	not a taken branch
		I_NPC:		in std_logic_vector(REG_SZ - 1 downto 0);

		-- I_RDx_DATA: from rf; data read from rf at address O_RDx_ADDR
		I_RD1_DATA:	in std_logic_vector(REG_SZ - 1 downto 0);
		I_RD2_DATA:	in std_logic_vector(REG_SZ - 1 downto 0);

		-- from CU
		I_BRANCH:	in branch_t;

		-- O_RDx_ADDR: to rf; address at which rf has to be read
		O_RD1_ADDR:	out std_logic_vector(log2_ceil(N_REGS) - 1 downto 0);
		O_RD2_ADDR:	out std_logic_vector(log2_ceil(N_REGS) - 1 downto 0);

		-- O_DST: to WB stage; address at which rf has to be written
		O_DST:		out std_logic_vector(log2_ceil(N_REGS) - 1 downto 0);

		-- to CU
		O_OPCODE:	out std_logic_vector(OPCODE_SZ - 1 downto 0);
		O_FUNC:		out std_logic_vector(FUNC_SZ - 1 downto 0);

		-- to EX stage; ALU operands
		O_RD1:		out std_logic_vector(REG_SZ - 1 downto 0);
		O_RD2:		out std_logic_vector(REG_SZ - 1 downto 0);
		O_IMM:		out std_logic_vector(REG_SZ - 1 downto 0);

		-- O_PC: to IF stage; address of next instruction
		O_PC:		out std_logic_vector(REG_SZ - 1 downto 0);
		
		-- O_TAKEN: to CU
		O_TAKEN:	out std_logic
	);
end decode_unit;

architecture MIXED of decode_unit is
	component pc_updater is
		port (
			I_BRANCH:	in branch_t;
			I_NPC:		in std_logic_vector(REG_SZ - 1 downto 0);
			I_ABS:		in std_logic_vector(REG_SZ - 1 downto 0);
			I_IMM:		in std_logic_vector(REG_SZ - 1 downto 0);
			I_OFF:		in std_logic_vector(REG_SZ - 1 downto 0);
			O_PC:		out std_logic_vector(REG_SZ - 1 downto 0);
			O_TAKEN:	out std_logic
		);
	end component pc_updater;

	signal IMM:	std_logic_vector(O_PC'range);
	signal OFF:	std_logic_vector(O_PC'range);
begin
	-- sign extend
	IMM <= (REG_SZ - 1 downto IMM_SZ => I_IR(I_IMM_START)) & I_IR(I_IMM_RANGE);
	OFF <= (REG_SZ - 1 downto OFF_SZ => I_IR(J_OFF_START)) & I_IR(J_OFF_RANGE);

	pc_updater_0: pc_updater
		port map (
			I_BRANCH=> I_BRANCH,
			I_NPC	=> I_NPC,
			I_ABS	=> I_RD1_DATA,
			I_IMM	=> IMM,
			I_OFF	=> OFF,
			O_PC	=> O_PC,
			O_TAKEN	=> O_TAKEN
		);

	-- rf addresses
	O_RD1_ADDR	<= I_IR(R_SRC1_RANGE);
	O_RD2_ADDR	<= I_IR(R_SRC2_RANGE);
	O_DST		<= I_IR(R_DST_RANGE);

	O_RD1 <= I_RD1_DATA;
	O_RD2 <= I_RD2_DATA;

	O_IMM	<= IMM;

	O_OPCODE	<= I_INST(OPCODE_RANGE);
	O_FUNC		<= I_INST(FUNC_RANGE);
end MIXED;

