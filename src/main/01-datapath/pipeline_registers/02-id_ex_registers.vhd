library ieee;
use ieee.std_logic_1164.all;
use work.coding.all;
use work.types.all;

-- id_ex_registers: pipeline registers between ID and EX stages
entity id_ex_registers is
	port (
		I_CLK:		in std_logic;
		I_RST:		in std_logic;

		-- from ID stage
		I_A:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);
		I_B:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);
		I_IMM:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);
		I_DST:		in std_logic_vector(RF_ADDR_SZ - 1 downto 0);

		I_ALUOP:	in std_logic_vector(FUNC_SZ - 1 downto 0);
		I_SEL_A:	in source_t;
		I_SEL_B:	in source_t;
		I_SEL_B_IMM:	in std_logic;
		I_LD:		in std_logic;
		I_STR:		in std_logic;

		-- to EX stage
		O_A:		out std_logic_vector(RF_DATA_SZ - 1 downto 0);
		O_B:		out std_logic_vector(RF_DATA_SZ - 1 downto 0);
		O_IMM:		out std_logic_vector(RF_DATA_SZ - 1 downto 0);
		O_DST:		out std_logic_vector(RF_ADDR_SZ - 1 downto 0);

		O_ALUOP:	out std_logic_vector(FUNC_SZ - 1 downto 0);
		O_SEL_A:	out source_t;
		O_SEL_B:	out source_t;
		O_SEL_B_IMM:	out std_logic;
		O_LD:		out std_logic;
		O_STR:		out std_logic
	);
end id_ex_registers;

architecture BEHAVIORAL of id_ex_registers is
begin
	reg: process (I_CLK)
	begin
		if (I_CLK = '1' AND I_CLK'event) then
			if (I_RST = '1') then
				O_A		<= (others => '0');
				O_B		<= (others => '0');
				O_IMM		<= (others => '0');
				O_DST		<= (others => '0');
				O_ALUOP		<= FUNC_ADD;
				O_SEL_A		<= SRC_RF;
				O_SEL_B		<= SRC_RF;
				O_SEL_B_IMM	<= '0';
				O_LD		<= '0';
				O_STR		<= '0';
			else
				O_A		<= I_A;
				O_B		<= I_B;
				O_IMM		<= I_IMM;
				O_DST		<= I_DST;
				O_ALUOP		<= I_ALUOP;
				O_SEL_A		<= I_SEL_A;
				O_SEL_B		<= I_SEL_B;
				O_SEL_B_IMM	<= I_SEL_B_IMM;
				O_LD		<= I_LD;
				O_STR		<= I_STR;
			end if;
		end if;
	end process reg;
end BEHAVIORAL;

