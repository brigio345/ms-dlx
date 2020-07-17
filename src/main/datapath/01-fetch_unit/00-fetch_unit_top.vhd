library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.specs.all;
use work.utilities.all;

entity fetch_unit is
	port (
		I_PC:	in std_logic_vector(REG_SZ - 1 downto 0);
		I_INST:	in std_logic_vector(INST_SZ - 1 downto 0);	-- from i_mem
		O_ADDR:	out std_logic_vector(REG_SZ - 1 downto 0);	-- to i_mem
		O_NPC:	out std_logic_vector(REG_SZ - 1 downto 0);
		O_IR:	out std_logic_vector(INST_SZ - 1 downto 0)
	);
end fetch_unit;

architecture RTL of fetch_unit is
begin
	O_ADDR	<= I_PC;	-- forward PC to i_mem
	O_NPC	<= std_logic_vector(unsigned(I_PC) + 4);
	O_IR	<= I_INST;	-- forward instruction from i_mem
end RTL;

