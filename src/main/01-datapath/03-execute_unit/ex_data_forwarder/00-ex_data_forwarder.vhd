library ieee;
use ieee.std_logic_1164.all;
use work.coding.all;
use work.types.all;

-- ex_data_forwarder: forward data if possible, otherwise simply return data
--	from previous data forwarder
entity ex_data_forwarder is
	port (
		-- from CU
		I_SEL_A:	in source_t;
		I_SEL_B:	in source_t;

		-- from ID stage forward unit
		I_A:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);
		I_B:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);

		-- ALUOUT of instruction which was in EX stage when current
		--	instruction was in ID stage
		I_ALUOUT_EX:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);

		-- LOADED of instruction which was in MEM stage when current
		--	instruction was in ID stage
		I_LOADED_MEM:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);

		-- forwarded data
		O_A:		out std_logic_vector(RF_DATA_SZ - 1 downto 0);
		O_B:		out std_logic_vector(RF_DATA_SZ - 1 downto 0)
	);
end ex_data_forwarder;

architecture RTL of ex_data_forwarder is
begin
	with I_SEL_A select O_A <=
		I_ALUOUT_EX	when SRC_ALU_EX,
		I_LOADED_MEM	when SRC_LD_MEM,
		I_A		when others;
	
	with I_SEL_B select O_B <=
		I_ALUOUT_EX	when SRC_ALU_EX,
		I_LOADED_MEM	when SRC_LD_MEM,
		I_B		when others;
end RTL;

