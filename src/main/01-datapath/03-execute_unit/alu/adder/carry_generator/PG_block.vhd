library ieee; 
use ieee.std_logic_1164.all;

entity PG_BLOCK is 
	port (
		G_ik: 	in std_logic;
		P_ik: 	in std_logic;
		G_k1j:	in std_logic;
		P_k1j:	in std_logic;
		G_ij:	out std_logic;
		P_ij:	out std_logic
	);
end PG_BLOCK; 

architecture RTL of PG_BLOCK is
begin
	G_ij <= G_ik or (P_ik and G_k1j);
	P_ij <= P_ik and P_k1j;
end RTL;

