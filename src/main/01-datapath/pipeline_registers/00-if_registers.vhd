library ieee;
use ieee.std_logic_1164.all;
use work.coding.all;

-- if_registers: pipeline registers between IF and ID stages
entity if_registers is
	port (
		I_CLK:		in std_logic;
		I_RST:		in std_logic;

		-- from IF stage
		I_TARGET:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);
		I_TAKEN:	in std_logic;

		-- to ID stage
		O_TARGET:	out std_logic_vector(RF_DATA_SZ - 1 downto 0);
		O_TAKEN:	out std_logic
	);
end if_registers;

architecture BEHAVIORAL of if_registers is
begin
	reg: process (I_CLK)
	begin
		if (I_CLK = '1' AND I_CLK'event) then
			if (I_RST = '1') then
				O_TARGET<= (others => '0');
				O_TAKEN	<= '0';
			else
				O_TARGET<= I_TARGET;
				O_TAKEN	<= I_TAKEN;
			end if;
		end if;
	end process reg;
end BEHAVIORAL;

