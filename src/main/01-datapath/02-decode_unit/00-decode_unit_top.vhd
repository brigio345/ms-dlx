library ieee;
use ieee.std_logic_1164.all;
use work.coding.all;
use work.types.all;
use work.utilities.all;

-- decode_unit:
--	* extract data from encoded instruction
--	* extend operands
--	* read from registerfile
--	* compute next PC
entity decode_unit is
	port (
		-- I_IR: from IF stage; encoded instruction
		I_IR:			in std_logic_vector(0 to INST_SZ - 1);
		-- I_NPC: from IF stage; next PC value if instruction is
		--	not a taken branch
		I_NPC:			in std_logic_vector(RF_DATA_SZ - 1 downto 0);

		-- I_RDx_DATA: from rf; data read from rf at address O_RDx_ADDR
		I_RD1_DATA:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);
		I_RD2_DATA:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);

		-- from CU
		I_SEL_OP1:		in std_logic;
		I_SEL_OP2:		in std_logic_vector(1 downto 0);
		I_TAKEN:		in std_logic;
		I_SIGNED:		in std_logic;
		I_SEL_A:		in source_t;
		I_SEL_B:		in source_t;
		I_SEL_DST:		in dest_t;

		-- from MEM
		I_ALUOUT_MEM:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);

		I_DST_EX:		in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
		I_DST_MEM:		in std_logic_vector(RF_ADDR_SZ - 1 downto 0);

		-- O_RDx_ADDR: to rf; address at which rf has to be read
		O_RD1_ADDR:		out std_logic_vector(RF_ADDR_SZ - 1 downto 0);
		O_RD2_ADDR:		out std_logic_vector(RF_ADDR_SZ - 1 downto 0);

		-- O_DST: to WB stage; address at which rf has to be written
		O_DST:			out std_logic_vector(RF_ADDR_SZ - 1 downto 0);

		-- to CU
		O_OPCODE:		out std_logic_vector(OPCODE_SZ - 1 downto 0);
		O_FUNC:			out std_logic_vector(FUNC_SZ - 1 downto 0);
		O_ZERO:			out std_logic;
		O_ZERO_SRC_A:		out std_logic;
		O_ZERO_SRC_B:		out std_logic;
		O_SRC_A_EQ_DST_EX:	out std_logic;
		O_SRC_B_EQ_DST_EX:	out std_logic;
		O_SRC_A_EQ_DST_MEM:	out std_logic;
		O_SRC_B_EQ_DST_MEM:	out std_logic;

		-- to EX stage; ALU operands
		O_A:			out std_logic_vector(RF_DATA_SZ - 1 downto 0);
		O_B:			out std_logic_vector(RF_DATA_SZ - 1 downto 0);
		O_IMM:			out std_logic_vector(RF_DATA_SZ - 1 downto 0);

		-- O_TARGET: to IF stage; address of next instruction
		O_TARGET:		out std_logic_vector(RF_DATA_SZ - 1 downto 0)
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

	signal SRC_A:	std_logic_vector(RF_ADDR_SZ - 1 downto 0);
	signal SRC_B:	std_logic_vector(RF_ADDR_SZ - 1 downto 0);
	signal DST:	std_logic_vector(RF_ADDR_SZ - 1 downto 0);
	signal A:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal B:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal IMM:	std_logic_vector(IMM_SZ - 1 downto 0);
	signal IMM_EXT:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal OFF:	std_logic_vector(OFF_SZ - 1 downto 0);
	signal OFF_EXT:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
begin
	SRC_A	<= I_IR(R_SRC1_RANGE);
	SRC_B	<= I_IR(R_SRC2_RANGE);
	IMM	<= I_IR(I_IMM_RANGE);
	OFF	<= I_IR(J_OFF_RANGE);

	-- data forwarding
	A	<= I_ALUOUT_MEM when (I_SEL_A = SRC_ALU_MEM) else I_RD1_DATA;
	O_B 	<= I_ALUOUT_MEM when (I_SEL_B = SRC_ALU_MEM) else I_RD2_DATA;

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
			I_A		=> A,
			I_IMM		=> IMM_EXT,
			I_OFF		=> OFF_EXT,
			O_TARGET	=> O_TARGET
		);

	-- rf addresses
	O_RD1_ADDR	<= SRC_A;
	O_RD2_ADDR	<= SRC_B;

	with I_SEL_DST select DST <=
		(others => '0')		when DST_NO,
		(others => '1')		when DST_LINK,
		I_IR(I_DST_RANGE)	when DST_IMM,
		I_IR(R_DST_RANGE)	when others;

	-- outputs to CU
	O_ZERO_SRC_A		<= '1' when (SRC_A = (SRC_A'range => '0')) else '0';
	O_ZERO_SRC_B		<= '1' when (SRC_B = (SRC_B'range => '0')) else '0';
	O_SRC_A_EQ_DST_EX	<= '1' when (SRC_A = I_DST_EX) else '0';
	O_SRC_B_EQ_DST_EX	<= '1' when (SRC_B = I_DST_EX) else '0';
	O_SRC_A_EQ_DST_MEM	<= '1' when (SRC_A = I_DST_MEM) else '0';
	O_SRC_B_EQ_DST_MEM	<= '1' when (SRC_B = I_DST_MEM) else '0';

	-- outputs to EX stage
	O_A	<= A;
	O_IMM	<= IMM_EXT;

	-- outputs to ID stage
	O_ZERO	<= '1' when (A = (A'range => '0')) else '0';
	O_OPCODE<= I_IR(OPCODE_RANGE);
	O_FUNC	<= I_IR(FUNC_RANGE);

	-- outputs to WB stage
	O_DST	<= DST;
end MIXED;

