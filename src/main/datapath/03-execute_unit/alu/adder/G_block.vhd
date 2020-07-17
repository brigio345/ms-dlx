library ieee; 
use ieee.std_logic_1164.all;

entity G_BLOCK is 
	port (
		G_ik: 	in std_logic;
		P_ik: 	in std_logic;
		G_k1j:	in std_logic;
		G_ij:	out std_logic
	);
end G_BLOCK; 

architecture RTL of G_BLOCK is
begin
	G_ij <= G_ik or (P_ik and G_k1j);
end RTL;

