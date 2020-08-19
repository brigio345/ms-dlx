library ieee;
use ieee.std_logic_1164.all;
use work.coding.all;

-- mem_wb_registers: pipeline registers between MEM and WB stages
entity mem_wb_registers is
	port (
		I_CLK:		in std_logic;
		I_RST:		in std_logic;

		-- from MEM stage
		I_LOADED:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);

		I_ALUOUT:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);
		I_DST:		in std_logic_vector(RF_ADDR_SZ - 1 downto 0);

		I_LD:		in std_logic;

		-- to WB stage
		O_LOADED:	out std_logic_vector(RF_DATA_SZ - 1 downto 0);

		O_ALUOUT:	out std_logic_vector(RF_DATA_SZ - 1 downto 0);
		O_DST:		out std_logic_vector(RF_ADDR_SZ - 1 downto 0);

		O_LD:		out std_logic
	);
end mem_wb_registers;

architecture BEHAVIORAL of mem_wb_registers is
begin
	reg: process (I_CLK)
	begin
		if (I_CLK = '1' AND I_CLK'event) then
			if (I_RST = '1') then
				O_LOADED<= (others => '0');
				O_ALUOUT<= (others => '0');
				O_DST	<= (others => '0');
				O_LD	<= '0';
			else
				O_LOADED<= I_LOADED;
				O_ALUOUT<= I_ALUOUT;
				O_DST	<= I_DST;
				O_LD	<= I_LD;
			end if;
		end if;
	end process reg;
end BEHAVIORAL;

