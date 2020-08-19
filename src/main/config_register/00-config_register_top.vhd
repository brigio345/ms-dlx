library ieee;
use ieee.std_logic_1164.all;

-- config_register: store processor configuration
entity config_register is
	port (
		I_CLK:		in std_logic;
		I_RST:		in std_logic;
		I_LD:		in std_logic;

		I_ENDIAN:	in std_logic;

		O_ENDIAN:	out std_logic
	);
end config_register;

architecture BEHAVIORAL of config_register is
begin
	reg: process (I_CLK)
	begin
		if (I_CLK = '1' AND I_CLK'event) then
			if (I_RST = '1') then
				O_ENDIAN <= '0';
			elsif (I_LD = '1') then
				O_ENDIAN <= I_ENDIAN;
			end if;
		end if;
	end process reg;
end BEHAVIORAL;

