library ieee;
use ieee.std_logic_1164.all;
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
	signal LOADED:	std_logic_vector(I_RD_DATA'range);
	signal WR_DATA:	std_logic_vector(O_WR_DATA'range);
begin
	O_RD		<= I_LD;
	O_WR		<= I_STR;
	O_ADDR		<= I_ADDR;

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

