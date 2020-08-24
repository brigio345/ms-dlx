library ieee;
use ieee.std_logic_1164.all;
use work.coding.all;

-- wb_mem_registers: pipeline registers between WB and MEM stages
entity wb_mem_registers is
	port (
		I_CLK:		in std_logic;
		I_RST:		in std_logic;

		-- from WB stage
		I_LOADED:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);
		I_ALUOUT:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);

		-- to MEM stage
		O_LOADED:	out std_logic_vector(RF_DATA_SZ - 1 downto 0);
		O_ALUOUT:	out std_logic_vector(RF_DATA_SZ - 1 downto 0)
	);
end wb_mem_registers;

architecture BEHAVIORAL of wb_mem_registers is
begin
	reg: process (I_CLK)
	begin
		if (I_CLK = '1' AND I_CLK'event) then
			if (I_RST = '1') then
				O_LOADED<= (others => '0');
				O_ALUOUT<= (others => '0');
			else
				O_LOADED<= I_LOADED;
				O_ALUOUT<= I_ALUOUT;
			end if;
		end if;
	end process reg;
end BEHAVIORAL;

