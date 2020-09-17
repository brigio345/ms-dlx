library ieee; 
use ieee.std_logic_1164.all;

entity full_adder is 
	port (
		I_A:	in std_logic;
		I_B:	in std_logic;
		I_C:	in std_logic;

		O_S:	out std_logic;
		O_C:	out std_logic
	);
end full_adder; 

architecture RTL of full_adder is
begin
	O_S <= I_A XOR I_B XOR I_C;
	O_C <= (I_A AND I_B) OR (I_A AND I_C) OR (I_B AND I_C);
end RTL;

