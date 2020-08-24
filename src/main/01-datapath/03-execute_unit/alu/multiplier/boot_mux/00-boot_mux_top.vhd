library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity BOOTH_MUX is
	generic (
		N:	integer := 32
	);
	port (
		A:	in std_logic_vector(2 * N - 1 downto 0);
		B:	in std_logic_vector(2 downto 0);
		Y:	out std_logic_vector(2 * N - 1 downto 0)
	);
end BOOTH_MUX;

architecture BEHAVIORAL of BOOTH_MUX is
	signal A_neg:	std_logic_vector(2 * N - 1 downto 0);
begin
	A_neg <= std_logic_vector(-signed(A));

	with B select Y <=
		A when "001" | "010",
		A(2 * N - 2 downto 0) & '0' when "011",
		A_neg(2 * N - 2 downto 0) & '0' when "100",
		A_neg when "101" | "110",
		(others => '0') when others;
end BEHAVIORAL;

