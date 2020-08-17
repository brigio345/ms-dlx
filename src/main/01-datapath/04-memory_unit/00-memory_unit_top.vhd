library ieee;
use ieee.std_logic_1164.all;
use work.coding.all;

-- memory_unit: forward signals to data memory
entity memory_unit is
	port (
		-- from CU
		I_LD:		in std_logic;
		I_STR:		in std_logic;

		-- from EX stage
		I_ADDR:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);

		-- from ID stage
		I_DATA:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);

		-- from d-memory
		I_RD_DATA:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);

		-- to d-memory
		O_ADDR:		out std_logic_vector(RF_DATA_SZ - 1 downto 0);
		O_RD:		out std_logic;
		O_WR:		out std_logic;
		O_WR_DATA:	out std_logic_vector(RF_DATA_SZ - 1 downto 0);

		-- to WB stage
		O_LOADED:	out std_logic_vector(RF_DATA_SZ - 1 downto 0)
	);
end memory_unit;

architecture RTL of memory_unit is
begin
	O_RD		<= I_LD;
	O_WR		<= I_STR;
	O_WR_DATA	<= I_DATA;
	O_ADDR		<= I_ADDR;

	O_LOADED	<= I_RD_DATA;
end RTL;

