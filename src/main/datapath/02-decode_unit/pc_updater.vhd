library ieee;
use ieee.std_logic_1164.all;
use work.specs.all;

entity pc_updater is
	port (
		I_BRANCH:	in branch_t;
		I_NPC:		in std_logic_vector(REG_SZ - 1 downto 0);
		I_ZERO:		in std_logic;
		I_ABS:		in std_logic_vector(REG_SZ - 1 downto 0);
		I_IMM:		in std_logic_vector(REG_SZ - 1 downto 0);
		I_OFF:		in std_logic_vector(REG_SZ - 1 downto 0);
		O_PC:		out std_logic_vector(REG_SZ - 1 downto 0)
	);
end pc_updater;

architecture MIXED of pc_updater is
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

	signal OFF:	std_logic_vector(O_PC'range);
	signal SUM:	std_logic_vector(O_PC'range);
begin
	adder: p4_adder
		generic map (
			NBIT		=> REG_SZ,
			NBIT_PER_BLOCK	=> 4
		)
		port map (
			A	=> I_NPC,
			B	=> OFF,
			Cin	=> '0',
			S	=> SUM,
			Cout	=> open,
			O_OF	=> open
		);

	OFF <= I_OFF when (I_BRANCH = BRANCH_U_R) else I_IMM;

	out_sel: process(I_BRANCH, I_ZERO, I_NPC, I_ABS, SUM)
	begin
		case (I_BRANCH) is
			when BRANCH_U_R	=>
				O_PC <= SUM;
			when BRANCH_U_A =>
				O_PC <= I_ABS;
			when BRANCH_EQ0	=>
				if (I_ZERO = '1') then
					O_PC <= SUM;
				else
					O_PC <= I_NPC;
				end if;
			when BRANCH_NE0 =>
				if (I_ZERO = '0') then
					O_PC <= SUM;
				else
					O_PC <= I_NPC;
				end if;
			when others =>
				O_PC <= I_NPC;
		end case;
	end process out_sel;
end MIXED;

