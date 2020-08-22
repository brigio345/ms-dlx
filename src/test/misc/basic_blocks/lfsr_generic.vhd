library ieee; 
use ieee.std_logic_1164.all;
use work.utilities.all;

entity LFSR is 
	generic (
		NBIT:	integer := 16
	);
	port ( 
		CLK:	in std_logic;
		RESET:	in std_logic;
		LD:	in std_logic;
		EN:	in std_logic;
		DIN:	in std_logic_vector (NBIT - 1 downto 0);
		PRN:	out std_logic_vector (NBIT - 1 downto 0)
	);
end LFSR;

architecture RTL of LFSR is
	constant NXOR: integer := log2(NBIT);
	signal t_prn : std_logic_vector(NBIT - 1 downto 0);
begin
	PRN <= t_prn;

	process(CLK,RESET) 
		variable tmp: std_logic;
	begin 
		if (RESET = '1') then 
			t_prn <= (NBIT - 1 downto 1 => '0') & '1'; -- load 1 at reset 
		elsif (CLK = '1' and CLK'event) then 
			if (LD = '1') then -- load a new seed when ld is active 
				t_prn <= DIN; 
			elsif (EN = '1') then -- shift when enabled 
				tmp := t_prn(2) xor t_prn(1);
				for i in 2 to NXOR - 1 loop
					tmp := tmp xor t_prn(2**i - 1);
				end loop;
				
				t_prn(0) <= tmp;
				t_prn(NBIT - 1 downto 1) <= t_prn(NBIT - 2 downto 0); 
			end if; 
		end if;
	  end process;
end RTL;

