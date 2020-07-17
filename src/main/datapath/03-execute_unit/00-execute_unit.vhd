library ieee;
use ieee.std_logic_1164.all;
use work.specs.all;

entity execute_unit is
	port (
		I_ALUOP:	in aluop_t;
		I_SEL_B_IMM:	in std_logic;

		I_A:	in std_logic_vector(REG_SZ - 1 downto 0);
		I_B:	in std_logic_vector(REG_SZ - 1 downto 0);
		I_IMM:	in std_logic_vector(REG_SZ - 1 downto 0);

		O_DATA:	out std_logic_vector(REG_SZ - 1 downto 0)
	);
end execute_unit;

architecture MIXED of execute_unit is
	component alu is
		generic (
			N_BIT:	integer := 32;
		)
		port (
			I_OP:	in aluop_t;
			I_A:	in std_logic_vector(N_BIT - 1 downto 0);
			I_B:	in std_logic_vector(N_BIT - 1 downto 0);
			O_DATA:	out std_logic_vector(N_BIT - 1 downto 0)
		);
	end component alu;

	signal B:	std_logic_vector(I_B'range);
begin
	alu0: alu
		generic map (
			N_BIT	=> REG_SZ
		)
		port map (
			I_OP	=> I_ALUOP,
			I_A	=> I_A,
			I_B	=> B,
			O_DATA	=> O_DATA
		);

	B <= I_B when (I_SEL_B_IMM = '0') else I_IMM;
end MIXED;

