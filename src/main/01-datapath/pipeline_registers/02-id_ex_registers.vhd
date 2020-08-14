library ieee;
use ieee.std_logic_1164.all;
use work.specs.all;
use work.aluop.all;

-- id_ex_registers: pipeline registers between ID and EX stages
entity id_ex_registers is
	port (
		I_CLK:		in std_logic;
		I_RST:		in std_logic;
		I_LD:		in std_logic;

		-- from ID stage
		I_A:		in std_logic_vector(REG_SZ - 1 downto 0);
		I_B:		in std_logic_vector(REG_SZ - 1 downto 0);
		I_IMM:		in std_logic_vector(REG_SZ - 1 downto 0);
		I_DST:		in std_logic_vector(R_SRC_DST_SZ - 1 downto 0);

		I_ALUOP:	in aluop_t;
		I_SEL_B_IMM:	in std_logic;
		I_LD:		in std_logic;
		I_STR:		in std_logic;

		-- to EX stage
		O_A:		out std_logic_vector(REG_SZ - 1 downto 0);
		O_B:		out std_logic_vector(REG_SZ - 1 downto 0);
		O_IMM:		out std_logic_vector(REG_SZ - 1 downto 0);
		O_DST:		out std_logic_vector(R_SRC_DST_SZ - 1 downto 0);

		O_ALUOP:	out aluop_t;
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
				O_ALUOP		<= ALUOP_NOP;
				O_SEL_B_IMM	<= '0';
				O_LD		<= '0';
				O_STR		<= '0';
			elsif (I_LD = '1') then
				O_A		<= I_A;
				O_B		<= I_B;
				O_IMM		<= I_IMM;
				O_DST		<= I_DST;
				O_ALUOP		<= I_ALUOP;
				O_SEL_B_IMM	<= I_SEL_B_IMM;
				O_LD		<= I_LD;
				O_STR		<= I_STR;
			end if;
		end if;
	end process reg;
end BEHAVIORAL;

