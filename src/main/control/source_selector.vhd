library IEEE;
use IEEE.std_logic_1164.all;
use work.source_types.all;

entity source_selector is
	port (
		I_SRC1:		in std_logic_vector(R_SRC_DST_SZ - 1 downto 0);
		I_SRC2:		in std_logic_vector(R_SRC_DST_SZ - 1 downto 0);
		I_DST_EX:	in std_logic_vector(R_SRC_DST_SZ - 1 downto 0);
		I_DST_MEM:	in std_logic_vector(R_SRC_DST_SZ - 1 downto 0);

		O_SEL_A:	out source_t;
		O_SEL_B:	out source_t
	);
end source_selector;

architecture BEHAVIORAL of source_selector is
begin
	sel_a: process(I_SRC1, I_DST_EX, I_DST_MEM)
	begin
		if (I_SRC1 = I_DST_EX) then
			O_SEL_A <= SOURCE_ALU;
		elsif (I_SRC1 = I_DST_MEM) then
			O_SEL_A <= SOURCE_LD;
		else
			O_SEL_A <= SOURCE_RF;
		end if;
	end process sel_a;

	sel_b: process(I_SRC2, I_DST_EX, I_DST_MEM)
	begin
		if (I_SRC2 = I_DST_EX) then
			O_SEL_B <= SOURCE_ALU;
		elsif (I_SRC2 = I_DST_MEM) then
			O_SEL_B <= SOURCE_LD;
		else
			O_SEL_B <= SOURCE_RF;
		end if;
	end process sel_b;
end BEHAVIORAL;

