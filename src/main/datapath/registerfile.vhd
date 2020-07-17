library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.utilities.all;

-- register_file is a 2R1W implementation of a register file

-- IMPLEMENTATION DETAILS:
--	* all control signals are active high
--	* reads and writes only happen at clock rising edge
--	* NLINE can be a non-power-of-2 number (thus addresses are expressed on
--		log2_ceil bits): if an out-of-bound address is provided
--		the corresponding R/W access is aborted
entity register_file is
	generic (
		NBIT:	integer := 64;	-- number of bits in each register
		NLINE:	integer := 32	-- number of registers
	);
	port (
		CLK: 		IN std_logic;
		RESET: 		IN std_logic;
		ENABLE: 	IN std_logic;
		RD1: 		IN std_logic;
		RD2: 		IN std_logic;
		WR: 		IN std_logic;
		ADD_WR: 	IN std_logic_vector(log2_ceil(NLINE) - 1 downto 0);
		ADD_RD1: 	IN std_logic_vector(log2_ceil(NLINE) - 1 downto 0);
		ADD_RD2: 	IN std_logic_vector(log2_ceil(NLINE) - 1 downto 0);
		DATAIN: 	IN std_logic_vector(NBIT - 1 downto 0);
		OUT1: 		OUT std_logic_vector(NBIT - 1 downto 0);
		OUT2: 		OUT std_logic_vector(NBIT - 1 downto 0)
	);
end register_file;

architecture BEHAVIORAL of register_file is
	subtype REG_ADDR is natural range 0 to NLINE - 1;
	type REG_ARRAY is array(REG_ADDR) of std_logic_vector(NBIT - 1 downto 0); 

	signal REGISTERS:	REG_ARRAY; 
begin
	write: process(CLK, RESET, ENABLE, WR, ADD_WR, DATAIN)
	begin
		if (CLK = '1' and CLK'event) then
			if (RESET = '1') then
				REGISTERS <= (others => (others => '0'));
			elsif (ENABLE = '1' and WR = '1' and unsigned(ADD_WR) < NLINE) then
				REGISTERS(to_integer(unsigned(ADD_WR))) <= DATAIN;
			end if;
		end if;
	end process write;

	read1: process(CLK, ENABLE, RD1, ADD_RD1, REGISTERS)
	begin
		if (CLK = '1' and CLK'event) then
			if (ENABLE = '1' and RD1 = '1' and unsigned(ADD_RD1) < NLINE) then
				OUT1 <= REGISTERS(to_integer(unsigned(ADD_RD1)));
			else
				OUT1 <= (others => '0');
			end if;
		end if;
	end process read1;

	read2: process(CLK, ENABLE, RD2, ADD_RD2, REGISTERS)
	begin
		if (CLK = '1' and CLK'event) then
			if (ENABLE = '1' and RD2 = '1' and unsigned(ADD_RD2) < NLINE) then
				OUT2 <= REGISTERS(to_integer(unsigned(ADD_RD2)));
			else
				OUT2 <= (others => '0');
			end if;
		end if;
	end process read2;
end BEHAVIORAL;

