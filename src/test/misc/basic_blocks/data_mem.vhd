library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utilities.all;

-- Data memory for DLX
entity data_mem is
	generic (
		DATA_SZ:	integer := 32;
		N_LINES:	integer := 1024
	);
	port (
		I_CLK:	in std_logic;
		I_RST:	in std_logic;

		I_ADDR:	in std_logic_vector(31 downto 0);
		I_DATA:	in std_logic_vector(DATA_SZ - 1 downto 0);
		I_RD:	in std_logic_vector(1 downto 0);
		I_WR:	in std_logic_vector(1 downto 0);

		O_DATA:	out std_logic_vector(DATA_SZ - 1 downto 0)
	);
end data_mem;

architecture BEHAVIORAL of data_mem is
	type mem_t is array (0 to N_LINES - 1) of
		std_logic_vector(7 downto 0);

	subtype PHYS_ADDR_RANGE is natural range log2_ceil(N_LINES) - 1 downto 0;

	subtype BYTE0 is natural range 7 downto 0;
	subtype BYTE1 is natural range 15 downto 8;
	subtype BYTE2 is natural range 23 downto 16;
	subtype BYTE3 is natural range 31 downto 24;

	constant ZERO_BYTE:	std_logic_vector(7 downto 0) := "00000000";

	signal MEM:		mem_t;
	signal ADDR_INT:	integer;
begin
	ADDR_INT <= to_integer(unsigned(I_ADDR(PHYS_ADDR_RANGE)));

	write: process (I_CLK)
	begin
		if (I_CLK = '0' AND I_CLK'event) then
			if (I_RST = '1') then
				MEM <= (others => (others => '0'));
			else
				case I_WR is
					when "11"	=>
						-- store word
						MEM(ADDR_INT)		<= I_DATA(BYTE3);
						MEM(ADDR_INT + 1)	<= I_DATA(BYTE2);
						MEM(ADDR_INT + 2)	<= I_DATA(BYTE1);
						MEM(ADDR_INT + 3)	<= I_DATA(BYTE0);
					when "10"	=>
						-- store half word
						MEM(ADDR_INT)		<= I_DATA(BYTE3);
						MEM(ADDR_INT + 1)	<= I_DATA(BYTE2);
					when "01"	=>
						-- store byte
						MEM(ADDR_INT)		<= I_DATA(BYTE3);
					when others	=>
						null;
				end case;
			end if;
		end if;
	end process write;

	read: process (ADDR_INT, I_RD)
	begin
		case I_RD is
			when "11"	=>
				O_DATA <=  MEM(ADDR_INT) & MEM(ADDR_INT + 1) &
					MEM(ADDR_INT + 2) & MEM(ADDR_INT + 3);
			when "10"	=>
				O_DATA <= MEM(ADDR_INT) & MEM(ADDR_INT + 1) & 
					ZERO_BYTE & ZERO_BYTE;
			when "01"	=>
				O_DATA <= MEM(ADDR_INT) & ZERO_BYTE &
					ZERO_BYTE & ZERO_BYTE;
			when others	=>
				O_DATA <= (others => '0');
		end case;
	end process read;
end BEHAVIORAL;

