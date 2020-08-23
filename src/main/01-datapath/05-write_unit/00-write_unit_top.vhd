library ieee;
use ieee.std_logic_1164.all;
use work.coding.all;

-- write_unit: manage writeback to register file
entity write_unit is
	port (
		-- from CU
		I_LD:		in std_logic_vector(1 downto 0);

		-- from ID stage
		I_DST:		in std_logic_vector(RF_ADDR_SZ - 1 downto 0);

		-- from EX stage
		I_ALUOUT:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);

		-- from MEM stage
		I_LOADED:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);

		-- to rf
		O_WR:		out std_logic;
		O_WR_ADDR:	out std_logic_vector(RF_ADDR_SZ - 1 downto 0);
		O_WR_DATA:	out std_logic_vector(RF_DATA_SZ - 1 downto 0)
	);
end write_unit;

architecture RTL of write_unit is
begin
	-- disable write when DST is R0
	O_WR <= '1' when (I_DST /= (I_DST'range => '0')) else '0';

	O_WR_ADDR <= I_DST;
	O_WR_DATA <= I_ALUOUT when (I_LD = "00") else I_LOADED;
end RTL;

