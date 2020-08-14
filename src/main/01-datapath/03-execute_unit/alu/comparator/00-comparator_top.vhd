library ieee;
use ieee.std_logic_1164.all;

entity comparator is
	generic (
		N_BIT:	integer := 32
	);
	port (
		I_DELTA:in std_logic_vector(N_BIT - 1 downto 0);
		I_CO:	in std_logic;
		I_OF:	in std_logic;

		O_EQ:	out std_logic;
		O_LT_U:	out std_logic;
		O_GT_U:	out std_logic;
		O_LT_S:	out std_logic;
		O_GT_S:	out std_logic
	);
end comparator;

architecture BEHAVIORAL of comparator is
begin
	cmp: process(I_DELTA, I_CO, I_OF)
	begin
		if (I_DELTA = (I_DELTA'range => '0')) then
			O_EQ	<= '1';

			O_LT_U	<= '0';
			O_GT_U	<= '0';

			O_LT_S	<= '0';
			O_GT_S	<= '0';
		else
			O_EQ	<= '0';

			O_LT_U	<= NOT I_CO;
			O_GT_U	<= I_CO;

			if (I_OF = '0') then
				O_LT_S	<= I_DELTA(I_DELTA'left);
				O_GT_S	<= NOT I_DELTA(I_DELTA'left);
			else
				O_LT_S <= I_CO;
				O_GT_S <= NOT I_CO;
			end if;
		end if;
	end process cmp;
end BEHAVIORAL;

