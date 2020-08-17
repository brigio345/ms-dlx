library ieee;
use ieee.std_logic_1164.all;
use work.coding.all;

-- if_id_registers: pipeline registers between IF and ID stages
entity if_id_registers is
	port (
		I_CLK:		in std_logic;
		I_RST:		in std_logic;

		-- from IF stage
		I_NPC:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);
		I_IR:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);

		-- to ID stage
		O_NPC:		out std_logic_vector(RF_DATA_SZ - 1 downto 0);
		O_IR:		out std_logic_vector(RF_DATA_SZ - 1 downto 0);
	);
end if_id_registers;

architecture BEHAVIORAL of if_id_registers is
begin
	reg: process (I_CLK)
	begin
		if (I_CLK = '1' AND I_CLK'event) then
			if (I_RST = '1') then
				O_NPC	<= (others => '0');
				O_IR	<= (others => '0');
			else
				O_NPC	<= I_NPC;
				O_IR	<= I_IR;
			end if;
		end if;
	end process reg;
end BEHAVIORAL;

