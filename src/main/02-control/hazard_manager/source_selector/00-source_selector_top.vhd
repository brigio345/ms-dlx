library IEEE;
use IEEE.std_logic_1164.all;
use work.coding.all;
use work.types.all;

-- source_selector: generate selection signals for A and B (this implements
-- 	a data forwarding mechanism)
entity source_selector is
	port (
		-- from ID stage
		I_SRC_A:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
		I_SRC_B:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);

		-- from EX stage
		I_DST_EX:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
		I_LD_EX:	in std_logic;

		-- from MEM stage
		I_DST_MEM:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
		I_LD_MEM:	in std_logic;

		O_SEL_A:	out source_t;
		O_SEL_B:	out source_t;
	);
end source_selector;

architecture BEHAVIORAL of source_selector is
	function source_sel_f (
		I_SRC:		in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
		I_DST_EX:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
		I_LD_EX:	in std_logic;
		I_DST_MEM:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
		I_LD_MEM:	in std_logic
	)
	return source_t is
		variable ret:	source_t;
	begin
		if (I_SRC = (I_SRC'range => '0')) then
			-- R0 is always 0 => it can't cause an hazard
			ret := SRC_RF;
		elsif (I_SRC = I_DST_EX) then
			if (I_LD_EX = '1') then
				ret := SRC_LD_EX;
			else
				ret := SRC_ALU_EX;
			end if;
		elsif (I_SRC = I_DST_MEM) then
			if (I_LD_MEM = '1') then
				ret := SRC_LD_MEM;
			else
				ret := SRC_ALU_MEM;
			end if;
		end if;

		return ret;
	end function source_sel_f;
begin
	O_SEL_A <= source_sel_f(I_SRC_A, I_DST_EX, I_LD_EX, I_DST_MEM, I_LD_MEM);
	O_SEL_B <= source_sel_f(I_SRC_B, I_DST_EX, I_LD_EX, I_DST_MEM, I_LD_MEM);
end BEHAVIORAL;

