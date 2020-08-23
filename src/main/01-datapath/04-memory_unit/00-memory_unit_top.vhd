library ieee;
use ieee.std_logic_1164.all;
use work.coding.all;
use work.utilities.all;

-- memory_unit: forward signals to data memory
entity memory_unit is
	port (
		-- I_ENDIAN: specify endianness of data memory
		--	- '0' => BIG endian
		--	- '1' => LITTLE endian
		I_ENDIAN:	in std_logic;

		-- from CU
		I_LD:		in std_logic_vector(1 downto 0);
		I_STR:		in std_logic_vector(1 downto 0);
		I_SIGNED:	in std_logic;

		-- from EX stage
		I_ADDR:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);

		-- from ID stage
		I_DATA:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);

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

architecture RTL of memory_unit is
	signal LOADED:	std_logic_vector(I_RD_DATA'range);
begin
	O_RD		<= I_LD;
	O_WR		<= I_STR;
	O_ADDR		<= I_ADDR;

	-- convert output data to big endian, if data memory is big endian
	O_WR_DATA	<= I_DATA when (I_ENDIAN = '1') else swap_bytes(I_DATA);
	-- convert input data to little endian, if data memory is big endian
	LOADED	<= I_RD_DATA when (I_ENDIAN = '1') else swap_bytes(I_RD_DATA);

	extend: process (LOADED, I_SIGNED, I_LD)
	begin
		case I_LD is
			when "10"	=>
				if (I_SIGNED = '1') then
					O_LOADED <= sign_extend(LOADED, 15, RF_DATA_SZ);
				else
					O_LOADED <= LOADED;
				end if;
			when "01"	=>
				if (I_SIGNED = '1') then
					O_LOADED <= sign_extend(LOADED, 7, RF_DATA_SZ);
				else
					O_LOADED <= LOADED;
				end if;
			when others	=>
				O_LOADED <= LOADED;
		end case;
	end process extend;
end RTL;

