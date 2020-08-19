library ieee;
use ieee.std_logic_1164.all;
use work.coding.all;
use work.types.all;

-- pc_computer: compute next PC
entity pc_computer is
	port (
		I_BRANCH:	in branch_t;
		I_NPC:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);
		-- I_A: value loaded from rf
		I_A:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);
		-- I_IMM: offset extracted by I-type instruction
		I_IMM:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);
		-- I_OFF: offset extracted by J-type instruction
		I_OFF:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);

		O_TARGET:	out std_logic_vector(RF_DATA_SZ - 1 downto 0);
		O_TAKEN:	out std_logic
	);
end pc_computer;

architecture MIXED of pc_computer is
	component P4_ADDER is
		generic (
			NBIT:		integer := 32;
			NBIT_PER_BLOCK:	integer := 4
		);
		port (
			A:	in	std_logic_vector(NBIT-1 downto 0);
			B:	in	std_logic_vector(NBIT-1 downto 0);
			Cin:	in	std_logic;
			S:	out	std_logic_vector(NBIT-1 downto 0);
			Cout:	out	std_logic;
			O_OF:	out	std_logic
		);
	end component P4_ADDER;

	signal OP1:	std_logic_vector(O_TARGET'range);
	signal OP2:	std_logic_vector(O_TARGET'range);
begin
	adder: p4_adder
		generic map (
			NBIT		=> RF_DATA_SZ,
			NBIT_PER_BLOCK	=> 4
		)
		port map (
			A	=> OP1,
			B	=> OP2,
			Cin	=> '0',
			S	=> O_TARGET,
			Cout	=> open,
			O_OF	=> open
		);

	op_sel: process(I_BRANCH, I_NPC, I_A, I_IMM, I_OFF)
	begin
		-- default values: branch not taken (O_TARGET = I_NPC + 0)
		OP1	<= I_NPC;
		OP2	<= (OP2'range => '0');
		O_TAKEN	<= '0';

		case (I_BRANCH) is
			when BRANCH_U_R	=>
				-- unconditional relative branch (O_TARGET = I_NPC + I_OFF)
				-- (J, JAL)
				OP1	<= I_NPC;
				OP2	<= I_OFF;
				O_TAKEN	<= '1';
			when BRANCH_U_A =>
				-- unconditional absolute branch (O_TARGET = I_A + 0)
				-- (JALR, JR)
				OP1	<= I_A;
				OP2	<= (OP2'range => '0');
				O_TAKEN	<= '1';
			when BRANCH_EQ0	=>
				-- conditional (if 0) relative branch (O_TARGET = I_NPC + I_IMM)
				-- (BEQZ)
				if (I_A = (I_A'range => '0')) then
					OP1	<= I_NPC;
					OP2	<= I_IMM;
					O_TAKEN	<= '1';
				end if;
			when BRANCH_NE0 =>
				-- conditional (if not 0) relative branch (O_TARGET = I_NPC + I_IMM)
				-- (BNEZ)
				if (I_A /= (I_A'range => '0')) then
					OP1	<= I_NPC;
					OP2	<= I_IMM;
					O_TAKEN	<= '1';
				end if;
			when others =>
				-- default values: branch not taken (O_TARGET = I_NPC + 0)
				OP1	<= I_NPC;
				OP2	<= (OP2'range => '0');
				O_TAKEN	<= '0';
		end case;
	end process op_sel;
end MIXED;

