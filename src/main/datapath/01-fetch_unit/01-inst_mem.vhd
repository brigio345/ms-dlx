library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.specs.all;

entity inst_mem is
	generic (
		WORD_SZ:	integer := 32,
		ADDR_SZ:	integer := 32,
		N_LINES: 	integer := 512
	);
	port (
		I_ADDR:	in std_logic_vector(ADDR_SZ - 1 downto 0);
		I_EN:	in std_logic;
		O_DATA:	out std_logic_vector(WORD_SZ - 1 downto 0)
	);
end inst_mem;

architecture BEHAVIORAL of inst_mem is
begin
	O_DATA <= MEM(to_integer(unsigned(I_ADDR))) when ((I_EN = '1') AND (unsigned(I_ADDR) < N_LINES))
		else (others => '0');
end BEHAVIORAL;

