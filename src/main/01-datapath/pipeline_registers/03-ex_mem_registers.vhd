library ieee;
use ieee.std_logic_1164.all;
use work.coding.all;
use work.types.all;

-- ex_mem_registers: pipeline registers between EX and MEM stages
entity ex_mem_registers is
	port (
		I_CLK:		in std_logic;
		I_RST:		in std_logic;

		-- from EX stage
		I_ADDR:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);
		I_DATA:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);

		I_DST:		in std_logic_vector(RF_ADDR_SZ - 1 downto 0);

		I_SIGNED:	in std_logic;
		I_LD:		in std_logic_vector(1 downto 0);
		I_STR:		in std_logic_vector(1 downto 0);
		I_SEL_DATA:	in source_t;

		-- to MEM stage
		O_ADDR:		out std_logic_vector(RF_DATA_SZ - 1 downto 0);
		O_DATA:		out std_logic_vector(RF_DATA_SZ - 1 downto 0);

		O_DST:		out std_logic_vector(RF_ADDR_SZ - 1 downto 0);

		O_SIGNED:	out std_logic;
		O_LD:		out std_logic_vector(1 downto 0);
		O_STR:		out std_logic_vector(1 downto 0);
		O_SEL_DATA:	out source_t
	);
end ex_mem_registers;

architecture BEHAVIORAL of ex_mem_registers is
begin
	reg: process (I_CLK)
	begin
		if (I_CLK = '1' AND I_CLK'event) then
			if (I_RST = '1') then
				O_ADDR		<= (others => '0');
				O_DATA		<= (others => '0');
				O_DST		<= (others => '0');
				O_SIGNED	<= '0';
				O_LD		<= (others => '0');
				O_STR		<= (others => '0');
				O_SEL_DATA	<= SRC_RF;
			else
				O_ADDR		<= I_ADDR;
				O_DATA		<= I_DATA;
				O_DST		<= I_DST;
				O_SIGNED	<= I_SIGNED;
				O_LD		<= I_LD;
				O_STR		<= I_STR;
				O_SEL_DATA	<= I_SEL_DATA;
			end if;
		end if;
	end process reg;
end BEHAVIORAL;

