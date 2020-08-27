library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.coding.all;
use work.types.all;
use work.utilities.all;

-- memory_unit: forward signals to data memory
entity memory_unit is
	port (
		-- I_ENDIAN: specify endianness of data memory
		--	- '0' => BIG endian
		--	- '1' => LITTLE endian
		I_ENDIAN:	in std_logic;
		I_PHYS_ADDR_SZ:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);

		-- from CU
		I_LD:		in std_logic_vector(1 downto 0);
		I_STR:		in std_logic_vector(1 downto 0);
		I_SIGNED:	in std_logic;
		I_SEL_DATA:	in source_t;

		-- from EX stage
		I_ADDR:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);

		-- from ID stage
		I_DATA:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);

		-- data forwarded from EX/MEM stages
		I_LOADED_EX:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);

		-- from d-memory
		I_RD_DATA:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);

		-- to d-memory
		O_ADDR:		out std_logic_vector(RF_DATA_SZ - 1 downto 0);
		O_RD:		out std_logic_vector(1 downto 0);
		O_WR:		out std_logic_vector(1 downto 0);
		O_WR_DATA:	out std_logic_vector(RF_DATA_SZ - 1 downto 0);

		-- to WB stage
		O_LOADED:	out std_logic_vector(RF_DATA_SZ - 1 downto 0)
	);
end memory_unit;

architecture BEHAVIORAL of memory_unit is
	signal LOADED:		std_logic_vector(I_RD_DATA'range);
	signal WR_DATA:		std_logic_vector(O_WR_DATA'range);
	signal PHYS_ADDR:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
begin
	O_RD	<= I_LD;
	O_WR	<= I_STR;

	-- cut I_ADDR to the physical address length, setting highest bits to 0
	cut_addr: process (I_ADDR, I_PHYS_ADDR_SZ)
	begin
		for I in I_ADDR'range loop
			if (I > (to_integer(unsigned(I_PHYS_ADDR_SZ)) - 1)) then
				PHYS_ADDR(I) <= '0';
			else
				PHYS_ADDR(I) <= I_ADDR(I);
			end if;
		end loop;
	end process cut_addr;

	align_addr: process (I_LD, I_STR, PHYS_ADDR)
	begin
		if ((I_LD = "11") OR (I_STR = "11")) then
			-- word align
			O_ADDR	<= PHYS_ADDR(PHYS_ADDR'left downto 2) & "00";
		elsif ((I_LD = "10") OR (I_STR = "10")) then
			-- half-word align
			O_ADDR	<= PHYS_ADDR(PHYS_ADDR'left downto 1) & "0";
		else
			-- no align
			O_ADDR	<= PHYS_ADDR;
		end if;
	end process align_addr;

	-- data forwarding
	WR_DATA <= I_LOADED_EX when (I_SEL_DATA = SRC_LD_EX) else I_DATA;

	-- convert output data to big endian, if data memory is big endian
	O_WR_DATA	<= WR_DATA when (I_ENDIAN = '1') else swap_bytes(WR_DATA);
	-- convert input data to little endian, if data memory is big endian
	LOADED	<= I_RD_DATA when (I_ENDIAN = '1') else swap_bytes(I_RD_DATA);

	extend: process (LOADED, I_SIGNED, I_LD)
	begin
		if (I_SIGNED = '1') then
			case I_LD is
				when "10"	=>
					O_LOADED <= sign_extend(LOADED, 15, RF_DATA_SZ);
				when "01"	=>
					O_LOADED <= sign_extend(LOADED, 7, RF_DATA_SZ);
				when others	=>
					O_LOADED <= LOADED;
			end case;
		else
			O_LOADED <= LOADED;
		end if;
	end process extend;
end BEHAVIORAL;

