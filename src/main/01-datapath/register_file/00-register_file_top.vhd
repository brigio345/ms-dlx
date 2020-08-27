library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.utilities.all;

-- register_file is a 2R1W implementation of a register file

-- IMPLEMENTATION DETAILS:
--	* all control signals are active high
--	* writes are performed at the rising edge of the clock
--	* reads are performed asynchronously
entity register_file is
	generic (
		NBIT:	integer := 64;	-- number of bits in each register
		NLINE:	integer := 32	-- number of registers
	);
	port (
		I_CLK:		in std_logic;
		I_RST: 		in std_logic;
		I_RD1: 		in std_logic;
		I_RD2: 		in std_logic;
		I_WR: 		in std_logic;
		I_WR_ADDR: 	in std_logic_vector(log2_ceil(NLINE) - 1 downto 0);
		I_RD1_ADDR: 	in std_logic_vector(log2_ceil(NLINE) - 1 downto 0);
		I_RD2_ADDR: 	in std_logic_vector(log2_ceil(NLINE) - 1 downto 0);
		I_WR_DATA: 	in std_logic_vector(NBIT - 1 downto 0);
		O_RD1_DATA: 	out std_logic_vector(NBIT - 1 downto 0);
		O_RD2_DATA: 	out std_logic_vector(NBIT - 1 downto 0)
	);
end register_file;

architecture BEHAVIORAL of register_file is
	subtype REG_ADDR is natural range 0 to NLINE - 1;
	type REG_ARRAY is array(REG_ADDR) of std_logic_vector(NBIT - 1 downto 0); 

	signal REGISTERS:	REG_ARRAY; 
begin
	write: process(I_CLK)
	begin
		if (I_CLK = '1' AND I_CLK'event) then
			if (I_RST = '1') then
				REGISTERS <= (others => (others => '0'));
			elsif (I_WR = '1') then
				REGISTERS(to_integer(unsigned(I_WR_ADDR))) <= I_WR_DATA;
			end if;
		end if;
	end process write;

	-- asynchronous read
	O_RD1_DATA <= REGISTERS(to_integer(unsigned(I_RD1_ADDR))) when (I_RD1 = '1')
		else (others => '0');
	O_RD2_DATA <= REGISTERS(to_integer(unsigned(I_RD2_ADDR))) when (I_RD2 = '1')
		else (others => '0');
end BEHAVIORAL;

