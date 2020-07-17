library ieee;
use ieee.std_logic_1164.all;
use work.specs.all;

entity decode_unit is
	port (
		-- from IF stage
		I_IR:		in std_logic_vector(INST_SIZE - 1 downto 0);
		I_NPC:		in std_logic_vector(REG_SZ - 1 downto 0);

		-- from rf
		I_RD1_DATA:	in std_logic_vector(REG_SZ - 1 downto 0);
		I_RD2_DATA:	in std_logic_vector(REG_SZ - 1 downto 0);

		-- from CU
		I_BRANCH:	in branch_t;

		-- to rf
		O_RD1_ADDR:	out std_logic_vector(log2_ceil(N_REGS) - 1 downto 0);
		O_RD2_ADDR:	out std_logic_vector(log2_ceil(N_REGS) - 1 downto 0);

		-- to CU
		O_OPCODE:	out std_logic_vector(OPCODE_SZ - 1 downto 0);
		O_FUNC:		out std_logic_vector(FUNC_SZ - 1 downto 0);

		-- to EX stage
		O_A:		out std_logic_vector(REG_SZ - 1 downto 0);
		O_B:		out std_logic_vector(REG_SZ - 1 downto 0);
		O_IMM:		out std_logic_vector(REG_SZ - 1 downto 0);

		-- to IF stage
		O_PC:		out std_logic_vector(REG_SZ - 1 downto 0)
	);
end decode_unit;

architecture MIXED of decode_unit is
	component pc_updater is
		port (
			I_BRANCH:	in branch_t;
			I_NPC:		in std_logic_vector(REG_SZ - 1 downto 0);
			I_ZERO:		in std_logic;
			I_ABS:		in std_logic_vector(REG_SZ - 1 downto 0);
			I_IMM:		in std_logic_vector(REG_SZ - 1 downto 0);
			I_OFF:		in std_logic_vector(REG_SZ - 1 downto 0);
			O_PC:		out std_logic_vector(REG_SZ - 1 downto 0)
		);
	end component pc_updater;

	signal IMM:	std_logic_vector(O_PC'range);
	signal OFF:	std_logic_vector(O_PC'range);

	signal ZERO:	std_logic;
begin
	-- sign extended
	IMM <= (REG_SZ - 1 downto IMM_SZ => I_IR(I_IMM_START)) & I_IR(I_IMM_RANGE);
	OFF <= (REG_SZ - 1 downto OFF_SZ => I_IR(J_OFF_START)) & I_IR(J_OFF_RANGE);

	-- rf addresses
	O_RD1_ADDR <= I_IR(R_SRC1_RANGE);
	O_RD2_ADDR <= I_IR(R_SRC2_RANGE);

	O_A	<= I_RD1_DATA;
	O_B 	<= I_RD2_DATA;
	O_IMM	<= IMM;

	O_OPCODE	<= I_INST(OPCODE_RANGE);
	O_FUNC		<= I_INST(FUNC_RANGE);

	ZERO	<= '1' when (I_RD1_DATA = (I_RD1_DATA'range => '0')) else '0';

	pc_upd: pc_updater
		port map (
			I_BRANCH=> I_BRANCH,
			I_NPC	=> I_NPC,
			I_ZERO	=> ZERO,
			I_ABS:	=> I_RD1_DATA,
			I_IMM	=> IMM,
			I_OFF	=> OFF,
			O_PC	=> O_PC
		);
end MIXED;

