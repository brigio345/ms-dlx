library IEEE;
use IEEE.std_logic_1164.all;

entity dlx_top is
	port (
		I_CLK:		in std_logic;
		I_RST:		in std_logic;

		I_I_RD_DATA:	in std_logic_vector(INST_SZ - 1 downto 0);
		I_D_RD_DATA:	in std_logic_vector(INST_SZ - 1 downto 0);

		O_I_RD_ADDR:	out std_logic_vector(REG_SZ - 1 downto 0);

		O_D_ADDR:	out std_logic_vector(REG_SZ - 1 downto 0);
		O_D_RD:		out std_logic;
		O_D_WR:		out std_logic;
		O_D_WR_DATA:	out std_logic_vector(REG_SZ - 1 downto 0)
	);
end dlx_top;

architecture STRUCTURAL of dlx_top is
	component datapath_top is
		port (
			I_CLK:		in std_logic;
			I_RST:		in std_logic;

			I_EN_IF:	in std_logic;
			I_EN_ID:	in std_logic;
			I_EN_EX:	in std_logic;
			I_EN_MEM:	in std_logic;
			I_EN_WB:	in std_logic;

			-- from i-memory
			I_INST:		in std_logic_vector(INST_SZ - 1 downto 0);
			-- from d-memory
			I_D_RD_DATA:	out std_logic_vector(REG_SZ - 1 downto 0);

			-- to i-memory
			O_PC:		out std_logic_vector(REG_SZ - 1 downto 0);

			-- to d-memory
			O_D_ADDR:	out std_logic_vector(REG_SZ - 1 downto 0);
			O_D_RD:		out std_logic;
			O_D_WR:		out std_logic;
			O_D_WR_DATA:	out std_logic_vector(REG_SZ - 1 downto 0)
		);
	end component datapath_top;

	component control_top is
	end component control_top;
begin
end STRUCTURAL;

