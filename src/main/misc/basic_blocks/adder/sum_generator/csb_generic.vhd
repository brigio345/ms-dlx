library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

-- Carry Select Block:
--	* compute A + B + '0' and A + B + '1' in parallel
--	* select the right sum according to the effective Ci
entity CSB_GENERIC is
	generic (
		N:	integer := 8
	);
	port (	
		I_A:	in std_logic_vector(N - 1 downto 0);
		I_B:	in std_logic_vector(N - 1 downto 0);
		I_CIN:	in std_logic;

		O_S:	out std_logic_vector(N - 1 downto 0)
	);
end CSB_GENERIC;

architecture BEHAVIORAL of CSB_GENERIC is
	signal S0:	std_logic_vector(O_S'range);
	signal S1:	std_logic_vector(O_S'range);
begin
	S0 <= std_logic_vector(unsigned(I_A) + unsigned(I_B));
	S1 <= std_logic_vector(unsigned(I_A) + unsigned(I_B) + 1);

	O_S <= S0 when I_CIN = '0' else S1;
end BEHAVIORAL;

