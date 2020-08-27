library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.coding.all;
use work.utilities.all;

-- fetch_unit: 
--	* select PC (NPC or branch target)
--	* read IR from instruction memory at address PC
--	* compute Next PC (PC + 4)
entity fetch_unit is
	port (
		-- I_ENDIAN: specify endianness of instruction memory
		--	- '0' => BIG endian
		--	- '1' => LITTLE endian
		I_ENDIAN:	in std_logic;
		I_PHYS_ADDR_SZ:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);

		I_NPC:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);

		-- from ID stage
		I_TARGET:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);
		I_TAKEN:	in std_logic;

		-- I_IR: from instruction memory; data read at address PC
		I_IR:		in std_logic_vector(INST_SZ - 1 downto 0);
		-- O_PC: to instruction memory; address to be read
		O_PC:		out std_logic_vector(RF_DATA_SZ - 1 downto 0);
		-- O_NPC: to ID stage; next PC value if instruction is
		--	not a taken branch
		O_NPC:		out std_logic_vector(RF_DATA_SZ - 1 downto 0);
		-- O_IR: to ID stage; encoded instruction
		O_IR:		out std_logic_vector(INST_SZ - 1 downto 0)
	);
end fetch_unit;

architecture BEHAVIORAL of fetch_unit is
	signal PC:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
begin
	PC	<= I_NPC when (I_TAKEN = '0') else I_TARGET;
	O_NPC	<= std_logic_vector(unsigned(PC) + 4);

	-- cut PC to the physical address length, setting highest bits to 0
	-- and perform word alignment
	cut_addr: process (PC, I_PHYS_ADDR_SZ)
	begin
		for I in PC'range loop
			if ((I > (to_integer(unsigned(I_PHYS_ADDR_SZ)) - 1)) OR
					(I < 2)) then
				O_PC(I) <= '0';
			else
				O_PC(I) <= PC(I);
			end if;
		end loop;
	end process cut_addr;

	-- convert IR to big endian if instruction memory is big endian
	O_IR	<= I_IR when (I_ENDIAN = '1') else swap_bytes(I_IR);	-- forward from i_mem
end BEHAVIORAL;

