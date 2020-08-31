library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity booth_mux is
	generic (
		N_BIT:	integer := 32
	);
	port (
		I_A:	in std_logic_vector(2 * N_BIT - 1 downto 0);
		I_B:	in std_logic_vector(2 downto 0);

		O_Y:	out std_logic_vector(2 * N_BIT - 1 downto 0)
	);
end booth_mux;

architecture BEHAVIORAL of booth_mux is
	signal A_NEG:	std_logic_vector(2 * N_BIT - 1 downto 0);
begin
	A_NEG <= std_logic_vector(-signed(I_A));

	with I_B select O_Y <=
		I_A					when "001" | "010",
		I_A(2 * N_BIT - 2 downto 0) & '0'	when "011",
		A_NEG(2 * N_BIT - 2 downto 0) & '0'	when "100",
		A_NEG					when "101" | "110",
		(others => '0')				when others;
end BEHAVIORAL;

