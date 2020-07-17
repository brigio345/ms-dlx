library ieee; 
use ieee.std_logic_1164.all;

entity SMALL_PG_BLOCK is 
	port (
		a: 	in std_logic;
		b: 	in std_logic;
		g:	out std_logic;
		p:	out std_logic
	);
end SMALL_PG_BLOCK; 

architecture RTL of SMALL_PG_BLOCK is
begin
	g <= a and b;
	p <= a xor b;
end RTL;

