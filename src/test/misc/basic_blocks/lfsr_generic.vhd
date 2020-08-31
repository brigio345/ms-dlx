library ieee; 
use ieee.std_logic_1164.all;
use work.utilities.all;

entity lfsr is 
	generic (
		N_BIT:	integer := 16
	);
	port ( 
		I_CLK:		in std_logic;
		I_RST:		in std_logic;
		I_LD:		in std_logic;
		I_EN:		in std_logic;

		I_SEED:		in std_logic_vector (N_BIT - 1 downto 0);

		O_RANDOM:	out std_logic_vector (N_BIT - 1 downto 0)
	);
end lfsr;

architecture BEHAVIORAL of lfsr is
	constant N_XOR:	integer := log2(N_BIT);
	signal T_PRN:	std_logic_vector(N_BIT - 1 downto 0);
begin
	O_RANDOM <= T_PRN;

	process(I_CLK,I_RST) 
		variable tmp: std_logic;
	begin 
		if (I_RST = '1') then 
			T_PRN <= (N_BIT - 1 downto 1 => '0') & '1'; -- load 1 at reset 
		elsif (I_CLK = '1' and I_CLK'event) then 
			if (I_LD = '1') then -- load a new seed when ld is active 
				T_PRN <= I_SEED; 
			elsif (I_EN = '1') then -- shift when enabled 
				tmp := T_PRN(2) xor T_PRN(1);
				for i in 2 to N_XOR - 1 loop
					tmp := tmp xor T_PRN(2**i - 1);
				end loop;
				
				T_PRN(0) <= tmp;
				T_PRN(N_BIT - 1 downto 1) <= T_PRN(N_BIT - 2 downto 0); 
			end if; 
		end if;
	  end process;
end BEHAVIORAL;

