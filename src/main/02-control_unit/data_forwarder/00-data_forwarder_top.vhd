library IEEE;
use IEEE.std_logic_1164.all;
use work.types.all;

-- data_forwarder: generate selection signals for A and B (this implements
-- 	a data forwarding mechanism)
entity data_forwarder is
	port (
		-- from ID stage
		I_ZERO_SRC_A:		in std_logic;
		I_ZERO_SRC_B:		in std_logic;
		I_SRC_A_EQ_DST_EX:	in std_logic;
		I_SRC_B_EQ_DST_EX:	in std_logic;
		I_SRC_A_EQ_DST_MEM:	in std_logic;
		I_SRC_B_EQ_DST_MEM:	in std_logic;

		-- from EX stage
		I_LD_EX:		in std_logic_vector(1 downto 0);

		-- from MEM stage
		I_LD_MEM:		in std_logic_vector(1 downto 0);

		O_SEL_A:		out source_t;
		O_SEL_B:		out source_t
	);
end data_forwarder;

architecture BEHAVIORAL of data_forwarder is
	function source_sel_f (
		I_ZERO_SRC:		in std_logic;
		I_SRC_EQ_DST_EX:	in std_logic;
		I_LD_EX:		in std_logic_vector(1 downto 0);
		I_SRC_EQ_DST_MEM:	in std_logic;
		I_LD_MEM:		in std_logic_vector(1 downto 0)
	)
	return source_t is
		variable ret:	source_t;
	begin
		if (I_ZERO_SRC = '1') then
			-- R0 is always 0 => it can't cause an hazard
			ret := SRC_RF;
		elsif (I_SRC_EQ_DST_EX = '1') then
			if (I_LD_EX /= "00") then
				ret := SRC_LD_EX;
			else
				ret := SRC_ALU_EX;
			end if;
		elsif (I_SRC_EQ_DST_MEM = '1') then
			if (I_LD_MEM /= "00") then
				ret := SRC_LD_MEM;
			else
				ret := SRC_ALU_MEM;
			end if;
		end if;

		return ret;
	end function source_sel_f;
begin
	O_SEL_A <= source_sel_f(I_ZERO_SRC_A, I_SRC_A_EQ_DST_EX, I_LD_EX,
		I_SRC_A_EQ_DST_MEM, I_LD_MEM);
	O_SEL_B <= source_sel_f(I_ZERO_SRC_B, I_SRC_B_EQ_DST_EX, I_LD_EX,
		I_SRC_B_EQ_DST_MEM, I_LD_MEM);
end BEHAVIORAL;

