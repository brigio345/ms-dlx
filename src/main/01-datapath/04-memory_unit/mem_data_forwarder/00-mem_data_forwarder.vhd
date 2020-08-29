library ieee;
use ieee.std_logic_1164.all;
use work.coding.all;
use work.types.all;

-- mem_data_forwarder: forward data if possible, otherwise simply return data
--	from previous data forwarder
entity mem_data_forwarder is
	port (
		-- from CU
		I_SEL_B:	in source_t;

		-- from EX stage forward unit
		I_B:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);

		-- value loaded from memory by the instruction which was in EX
		--	stage when current instruction was in ID stage
		I_LOADED_EX:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);

		-- forwarded data
		O_B:		out std_logic_vector(RF_DATA_SZ - 1 downto 0)
	);
end mem_data_forwarder;

architecture RTL of mem_data_forwarder is
begin
	O_B <= I_LOADED_EX when (I_SEL_B = SRC_LD_EX) else I_B;
end RTL;

