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
			I_IR:		in std_logic_vector(INST_SZ - 1 downto 0);
			-- I_NPC: from IF stage; next PC value if instruction is
			--	not a taken branch
			I_NPC:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);

			-- I_RDx_DATA: from rf; data read from rf at address O_RDx_ADDR
			I_RD1_DATA:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);
			I_RD2_DATA:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);

			-- from CU
			I_BRANCH:	in branch_t;
			I_SIGNED:	in std_logic;

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
			O_TAKEN:	out std_logic
		);
	end component decode_unit;

	constant WAIT_TIME:	time := 2 ns;

	signal IR:	std_logic_vector(INST_SZ - 1 downto 0);
	signal NPC:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal RD1_DATA:std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal RD2_DATA:std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal BRANCH:	branch_t;
	signal S_SIGNED:std_logic;
	signal RD1_ADDR:std_logic_vector(RF_ADDR_SZ - 1 downto 0);
	signal RD2_ADDR:std_logic_vector(RF_ADDR_SZ - 1 downto 0);
	signal DST:	std_logic_vector(RF_ADDR_SZ - 1 downto 0);
	signal OPCODE:	std_logic_vector(OPCODE_SZ - 1 downto 0);
	signal FUNC:	std_logic_vector(FUNC_SZ - 1 downto 0);
	signal RD1:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal RD2:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal IMM_EXT:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal TARGET:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal TAKEN:	std_logic;

begin
	dut: decode_unit
		port map (
			I_IR		=> IR,
			I_NPC		=> NPC,
			I_RD1_DATA	=> RD1_DATA,
			I_RD2_DATA	=> RD2_DATA,
			I_BRANCH	=> BRANCH,
			I_SIGNED	=> S_SIGNED,
			O_RD1_ADDR	=> RD1_ADDR,
			O_RD2_ADDR	=> RD2_ADDR,
			O_DST		=> DST,
			O_OPCODE	=> OPCODE,
			O_FUNC		=> FUNC,
			O_RD1		=> RD1,
			O_RD2		=> RD2,
			O_IMM		=> IMM_EXT,
			O_TARGET	=> TARGET,
			O_TAKEN		=> TAKEN
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
		
		IR	<= OPCODE_BNEZ & RS1 & RS2 & IMM;
		NPC	<= x"01234567";
		RD1_DATA<= (others => '0');
		RD2_DATA<= (others => '0');
		BRANCH	<= BR_NO;
		S_SIGNED<= '0';

		wait for WAIT_TIME;

		wait for WAIT_TIME;

		wait for WAIT_TIME;

		wait for WAIT_TIME;

		wait;
	end process stimuli;
end TB_ARCH;

