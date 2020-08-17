library ieee;
use ieee.std_logic_1164.all;
use work.coding.all;
use work.types.all;

-- execute_unit: execute the ALU operation specified by I_ALUOP
entity execute_unit is
	port (
		-- from CU
		I_ALUOP:	in std_logic_vector(FUNC_SZ - 1 downto 0);
		I_SEL_A:	in source_t;
		I_SEL_B:	in source_t;
		I_SEL_R_IMM:	in std_logic;

		-- from ID stage
		I_RD1:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);
		I_RD2:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);
		I_IMM:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);

		-- data forwarded from EX/MEM stages
		I_ALUOUT_EX:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);
		I_ALUOUT_MEM:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);
		I_LOADED:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);

		-- to MEM/WB stages
		O_ALUOUT:	out std_logic_vector(RF_DATA_SZ - 1 downto 0)
	);
end execute_unit;

architecture MIXED of execute_unit is
	component alu is
		generic (
			N_BIT:	integer := 32;
		);
		port (
			I_OP:	in std_logic_vector(FUNC_SZ - 1 downto 0);
			I_A:	in std_logic_vector(N_BIT - 1 downto 0);
			I_B:	in std_logic_vector(N_BIT - 1 downto 0);
			O_DATA:	out std_logic_vector(N_BIT - 1 downto 0)
		);
	end component alu;

	signal A:	std_logic_vector(I_RD1'range);
	signal B:	std_logic_vector(I_RD2'range);
	signal R:	std_logic_vector(I_RD2'range);
begin
	mux_a: process (I_SEL_A, I_RD1, I_ALUOUT_EX, I_ALUOUT_MEM, I_LOADED)
	begin
		case I_SEL_A is
			when SRC_RF	=>
				A <= I_RD1;
			when SRC_ALU_EX	=>
				A <= I_ALUOUT_EX;
			when SRC_ALU_MEM=>
				A <= I_ALUOUT_MEM;
			when SRC_LD_MEM	=>
				A <= I_LOADED;
			when others	=>
				A <= I_RD1;
		end case;
	end process mux_a;

	mux_b: process (I_SEL_B, I_RD2, I_ALUOUT_EX, I_ALUOUT_MEM, I_LOADED)
	begin
		case I_SEL_B is
			when SRC_RF	=>
				R <= I_RD2;
			when SRC_ALU_EX	=>
				R <= I_ALUOUT_EX;
			when SRC_ALU_MEM=>
				R <= I_ALUOUT_MEM;
			when SRC_LD_MEM	=>
				R <= I_LOADED;
			when others	=>
				R <= I_RD2;
		end case;
	end process mux_b;

	B <= R when (I_SEL_R_IMM = '0') else I_IMM;

	alu_0: alu
		generic map (
			N_BIT	=> RF_DATA_SZ
		)
		port map (
			I_OP	=> I_ALUOP,
			I_A	=> A,
			I_B	=> B,
			O_DATA	=> O_ALUOUT
		);
end MIXED;

