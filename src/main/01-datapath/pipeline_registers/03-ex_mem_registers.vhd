library ieee;
use ieee.std_logic_1164.all;
use work.specs.all;

-- ex_mem_registers: pipeline registers between EX and MEM stages
entity ex_mem_registers is
	port (
		I_CLK:		in std_logic;
		I_RST:		in std_logic;
		I_EN:		in std_logic;

		-- from EX stage
		I_IMM:		in std_logic_vector(REG_SZ - 1 downto 0);
		I_ADDR:		in std_logic_vector(REG_SZ - 1 downto 0);

		I_DST:		in std_logic_vector(R_SRC_DST_SZ - 1 downto 0);

		I_LD:		in std_logic;
		I_STR:		in std_logic;

		-- to MEM stage
		O_ADDR:		out std_logic_vector(REG_SZ - 1 downto 0);
		O_IMM:		out std_logic_vector(REG_SZ - 1 downto 0);

		O_DST:		out std_logic_vector(R_SRC_DST_SZ - 1 downto 0);

		O_LD:		out std_logic;
		O_STR:		out std_logic
	);
end ex_mem_registers;

architecture BEHAVIORAL of ex_mem_registers is
begin
	reg: process (I_CLK)
	begin
		if (I_CLK = '1' AND I_CLK'event) then
			if (I_RST = '1') then
				O_ADDR	<= (others => '0');
				O_IMM	<= (others => '0');
				O_DST	<= (others => '0');
				O_LD	<= '0';
				O_STR	<= '0';
			elsif (I_EN = '1') then
				O_ADDR	<= I_ADDR;
				O_IMM	<= I_IMM;
				O_DST	<= I_DST;
				O_LD	<= I_LD;
				O_STR	<= I_STR;
			end if;
		end if;
	end process reg;
end BEHAVIORAL;

