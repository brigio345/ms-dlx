library ieee;
use ieee.std_logic_1164.all;
use work.coding.all;

-- config_register: store processor configuration
entity config_register is
	port (
		I_RST:		in std_logic;
		I_LD:		in std_logic;

		I_ENDIAN:	in std_logic;
		I_I_MEM_SZ:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);
		I_D_MEM_SZ:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);

		O_ENDIAN:	out std_logic;
		O_I_MEM_SZ:	out std_logic_vector(RF_DATA_SZ - 1 downto 0);
		O_D_MEM_SZ:	out std_logic_vector(RF_DATA_SZ - 1 downto 0)
	);
end config_register;

architecture BEHAVIORAL of config_register is
begin
	reg: process (I_RST, I_LD, I_ENDIAN, I_I_MEM_SZ, I_D_MEM_SZ)
	begin
		if (I_RST = '1') then
			O_ENDIAN	<= '0';
			O_I_MEM_SZ	<= (others => '0');
			O_D_MEM_SZ	<= (others => '0');
		elsif (I_LD = '1') then
			O_ENDIAN	<= I_ENDIAN;
			O_I_MEM_SZ	<= I_I_MEM_SZ;
			O_D_MEM_SZ	<= I_D_MEM_SZ;
		end if;
	end process reg;
end BEHAVIORAL;

