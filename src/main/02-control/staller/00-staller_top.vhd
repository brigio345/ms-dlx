library IEEE;
use IEEE.std_logic_1164.all;
use work.inst_types.all;

entity data_staller is
	port (
		I_SRC1:		in std_logic_vector(R_SRC_DST_SZ - 1 downto 0);
		I_SRC2:		in std_logic_vector(R_SRC_DST_SZ - 1 downto 0);
		I_DST_LD_EX:	in std_logic_vector(R_SRC_DST_SZ - 1 downto 0);
		I_INST_TYPE:	in inst_t;

		O_STALL:	out std_logic
	);
end data_staller;

architecture BEHAVIORAL of data_staller is
begin
	O_STALL <= '1' when ((I_SRC1 = I_DST_LD_EX) OR (I_SRC2 = I_DST_LD_EX))
			else '0';
end BEHAVIORAL;

