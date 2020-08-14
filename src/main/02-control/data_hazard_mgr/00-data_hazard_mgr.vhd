library IEEE;
use IEEE.std_logic_1164.all;
use work.types.all;

-- data_hazard_mgr
entity data_hazard_mgr is
	port (
		I_CLK:		in std_logic;
		I_RST:		in std_logic;

		I_INST_TYPE:	in aluop_t;

		I_ADDR_DST:	in std_logic_vector(R_SRC_DST_SZ - 1 downto 0);
		I_ADDR_SRC1:	in std_logic_vector(R_SRC_DST_SZ - 1 downto 0);
		I_ADDR_SRC2:	in std_logic_vector(R_SRC_DST_SZ - 1 downto 0);

		O_SEL_A:	out source_t;
		O_SEL_B:	out source_t;
		O_STALL:	out std_logic
	);
end data_hazard_mgr;

architecture BEHAVIORAL of data_hazard_mgr is
	component rf_status_keeper is
		generic (
			NLINE:	integer := 32	-- number of registers
		);
		port (
			I_CLK: 		in std_logic;
			I_RST: 		in std_logic;

			I_SHIFT:	in std_logic;
			I_SET: 		in std_logic;
			I_STATUS_SET:	in reg_status_t;
			I_ADDR_SET: 	in std_logic_vector(log2_ceil(NLINE) - 1 downto 0);
			I_ADDR_CHK1: 	in std_logic_vector(log2_ceil(NLINE) - 1 downto 0);
			I_ADDR_CHK2: 	in std_logic_vector(log2_ceil(NLINE) - 1 downto 0);

			O_STATUS1: 	out std_logic_vector(NBIT - 1 downto 0);
			O_STATUS2: 	out std_logic_vector(NBIT - 1 downto 0)
		);
	end component rf_status_keeper;
begin
end BEHAVIORAL;

