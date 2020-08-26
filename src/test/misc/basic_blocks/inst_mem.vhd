library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use work.utilities.all;

-- Instruction memory for DLX
-- Memory filled by a process which reads from a file
-- file name is "test.asm.mem"
entity inst_mem is
	generic (
		MEM_FILE:	string := "test.asm.mem";
		RAM_DEPTH:	integer := 512;
		I_SIZE:		integer := 32
	);
	port (
		I_RST:	in std_logic;
		I_ADDR:	in std_logic_vector(I_SIZE - 1 downto 0);
		O_DATA:	out std_logic_vector(I_SIZE - 1 downto 0)
	);
end inst_mem;

architecture BEHAVIORAL of inst_mem is
	type mem_t is array (0 to RAM_DEPTH - 1) of std_logic_vector(I_SIZE - 1 downto 0);

	signal MEM:	mem_t;
begin
	-- fill the instruction memory with the firmware
	fill_mem: process (I_RST)
		file mem_fp:		text;
		variable file_line:	line;
		variable tmp_data_u:	std_logic_vector(I_SIZE - 1 downto 0);
	begin
		if (I_RST = '1') then
			file_open(mem_fp, MEM_FILE, READ_MODE);

			for I in 0 to RAM_DEPTH - 1 loop
				if (not endfile(mem_fp)) then
					readline(mem_fp, file_line);
					hread(file_line, tmp_data_u);
					MEM(I) <= swap_bytes(tmp_data_u);       
				else
					MEM(I) <= (others => '0');
				end if;
			end loop;

			file_close(mem_fp);
		end if;
	end process fill_mem;

	O_DATA <= MEM(to_integer(unsigned(I_ADDR(I_ADDR'left downto 2))));
end BEHAVIORAL;

