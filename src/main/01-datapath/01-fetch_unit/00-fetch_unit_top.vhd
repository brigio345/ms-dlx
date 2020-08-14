library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.specs.all;
use work.utilities.all;

-- fetch_unit: 
--	* read IR from instruction memory at address PC
--	* compute Next PC (PC + 4)
entity fetch_unit is
	port (
		-- I_PC: from ID stage; can be NPC or target of a branch
		I_PC:	in std_logic_vector(REG_SZ - 1 downto 0);
		-- I_IR: from instruction memory; data read at address PC
		I_IR:	in std_logic_vector(INST_SZ - 1 downto 0);
		-- O_PC: to instruction memory; address to be read
		O_PC:	out std_logic_vector(REG_SZ - 1 downto 0);
		-- O_NPC: to ID stage; next PC value if instruction is
		--	not a taken branch
		O_NPC:	out std_logic_vector(REG_SZ - 1 downto 0);
		-- O_IR: to ID stage; encoded instruction
		O_IR:	out std_logic_vector(INST_SZ - 1 downto 0)
	);
end fetch_unit;

architecture BEHAVIORAL of fetch_unit is
begin
	O_PC	<= I_PC;	-- forward PC to i_mem (can be NPC or a target)
	O_NPC	<= std_logic_vector(unsigned(I_PC) + 4);
	O_IR	<= I_IR;	-- forward instruction from i_mem
end BEHAVIORAL;

