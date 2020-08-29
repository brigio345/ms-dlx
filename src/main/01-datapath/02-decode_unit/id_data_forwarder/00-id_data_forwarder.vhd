library ieee;
use ieee.std_logic_1164.all;
use work.coding.all;
use work.types.all;

-- id_data_forwarder: forward data if possible, otherwise simply return data
--	read from register file
entity id_data_forwarder is
	port (
		-- from CU
		I_SEL_A:		in source_t;
		I_SEL_B:		in source_t;

		-- I_RDx_DATA: read from rf
		I_RD1_DATA:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);
		I_RD2_DATA:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);

		-- from MEM
		I_ALUOUT_MEM:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);

		-- from WB
		I_ALUOUT_WB:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);
		I_LOADED_WB:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);

		-- forwarded data
		O_A:			out std_logic_vector(RF_DATA_SZ - 1 downto 0);
		O_B:			out std_logic_vector(RF_DATA_SZ - 1 downto 0)
	);
end id_data_forwarder;

architecture RTL of id_data_forwarder is
begin
	with I_SEL_A select O_A <=
		I_ALUOUT_MEM	when SRC_ALU_MEM,
		I_ALUOUT_WB	when SRC_ALU_WB,
		I_LOADED_WB	when SRC_LD_WB,
		I_RD1_DATA	when others;

	with I_SEL_B select O_B <=
		I_ALUOUT_MEM	when SRC_ALU_MEM,
		I_ALUOUT_WB	when SRC_ALU_WB,
		I_LOADED_WB	when SRC_LD_WB,
		I_RD2_DATA	when others;
end RTL;

