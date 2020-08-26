library ieee;
use ieee.std_logic_1164.all;
use work.coding.all;
use work.types.all;

entity tb_decode_unit is
end tb_decode_unit;

architecture TB_ARCH of tb_decode_unit is
	component decode_unit is
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
			I_SEL_JMP_OP1:		in std_logic;
			I_SEL_JMP_OP2:		in std_logic_vector(1 downto 0);
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
	end component decode_unit;

	constant WAIT_TIME:	time := 2 ns;

	signal IR:			std_logic_vector(INST_SZ - 1 downto 0);
	signal NPC:			std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal RD1_DATA:		std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal RD2_DATA:		std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal SEL_JMP_OP1:		std_logic;
	signal SEL_JMP_OP2:		std_logic_vector(1 downto 0);
	signal S_SIGNED:		std_logic;
	signal SEL_A:			source_t;
	signal SEL_B:			source_t;
	signal SEL_DST:			dest_t;
	signal ALUOUT_MEM:		std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal DST_EX:			std_logic_vector(RF_ADDR_SZ - 1 downto 0);
	signal DST_MEM:			std_logic_vector(RF_ADDR_SZ - 1 downto 0);
	signal RD1_ADDR:		std_logic_vector(RF_ADDR_SZ - 1 downto 0);
	signal RD2_ADDR:		std_logic_vector(RF_ADDR_SZ - 1 downto 0);
	signal DST:			std_logic_vector(RF_ADDR_SZ - 1 downto 0);
	signal OPCODE:			std_logic_vector(OPCODE_SZ - 1 downto 0);
	signal FUNC:			std_logic_vector(FUNC_SZ - 1 downto 0);
	signal ZERO:			std_logic;
	signal ZERO_SRC_A:		std_logic;
	signal ZERO_SRC_B:		std_logic;
	signal SRC_A_EQ_DST_EX:		std_logic;
	signal SRC_B_EQ_DST_EX:		std_logic;
	signal SRC_A_EQ_DST_MEM:	std_logic;
	signal SRC_B_EQ_DST_MEM:	std_logic;
	signal A:			std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal B:			std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal IMM:			std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal TARGET:			std_logic_vector(RF_DATA_SZ - 1 downto 0);
begin
	dut: decode_unit
		port map (
			I_IR			=> IR,
			I_NPC			=> NPC,
			I_RD1_DATA		=> RD1_DATA,
			I_RD2_DATA		=> RD2_DATA,
			I_SEL_JMP_OP1		=> SEL_JMP_OP1,
			I_SEL_JMP_OP2		=> SEL_JMP_OP2,
			I_SIGNED		=> S_SIGNED,
			I_SEL_A			=> SEL_A,
			I_SEL_B			=> SEL_B,
			I_SEL_DST		=> SEL_DST,
			I_ALUOUT_MEM		=> ALUOUT_MEM,
			I_DST_EX		=> DST_EX,
			I_DST_MEM		=> DST_MEM,
			O_RD1_ADDR		=> RD1_ADDR,
			O_RD2_ADDR		=> RD2_ADDR,
			O_DST			=> DST,
			O_OPCODE		=> OPCODE,
			O_FUNC			=> FUNC,
			O_ZERO			=> ZERO,
			O_ZERO_SRC_A		=> ZERO_SRC_A,
			O_ZERO_SRC_B		=> ZERO_SRC_B,
			O_SRC_A_EQ_DST_EX	=> SRC_A_EQ_DST_EX,
			O_SRC_B_EQ_DST_EX	=> SRC_B_EQ_DST_EX,
			O_SRC_A_EQ_DST_MEM	=> SRC_A_EQ_DST_MEM,
			O_SRC_B_EQ_DST_MEM	=> SRC_B_EQ_DST_MEM,
			O_A			=> A,
			O_B			=> B,
			O_IMM			=> IMM,
			O_TARGET		=> TARGET
		);

	stimuli: process
		variable RS1:	std_logic_vector(RF_ADDR_SZ - 1 downto 0);
		variable RS2:	std_logic_vector(RF_ADDR_SZ - 1 downto 0);
		variable RD:	std_logic_vector(RF_ADDR_SZ - 1 downto 0);
		variable IMM:	std_logic_vector(IMM_SZ - 1 downto 0);
	begin
		RS1	:= "00100";
		RS2	:= "00010";
		RD	:= "00000";
		IMM	:= "0011000011101001";
		
		IR		<= OPCODE_BNEZ & RS1 & RS2 & IMM;
		NPC		<= x"01234567";
		RD1_DATA	<= (others => '0');
		RD2_DATA	<= (others => '0');
		SEL_JMP_OP1	<= '0';
		SEL_JMP_OP2	<= "00";
		S_SIGNED	<= '0';
		SEL_A		<= SRC_RF;
		SEL_B		<= SRC_RF;
		SEL_DST		<= DST_NO;
		ALUOUT_MEM	<= (others => '0');
		DST_EX		<= (others => '0');
		DST_MEM		<= (others => '0');

		wait for WAIT_TIME;
		wait;
	end process stimuli;
end TB_ARCH;

