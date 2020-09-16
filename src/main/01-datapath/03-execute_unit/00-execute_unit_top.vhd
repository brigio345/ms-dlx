library ieee;
use ieee.std_logic_1164.all;
use work.coding.all;
use work.types.all;

-- execute_unit:
--	* forward data from following stages
--	* execute the ALU operation specified by I_ALUOP
entity execute_unit is
	port (
		-- from CU
		I_ALUOP:	in std_logic_vector(FUNC_SZ - 1 downto 0);
		I_SEL_A:	in source_t;
		I_SEL_B:	in source_t;
		I_SEL_B_IMM:	in std_logic;

		-- from ID stage
		I_A:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);
		I_B:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);
		I_IMM:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);
		I_NPC:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);

		-- data forwarded from EX/MEM stages
		I_ALUOUT_EX:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);
		I_LOADED_MEM:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);

		-- to MEM/WB stages
		O_ALUOUT:	out std_logic_vector(RF_DATA_SZ - 1 downto 0);
		O_B:		out std_logic_vector(RF_DATA_SZ - 1 downto 0)
	);
end execute_unit;

architecture MIXED of execute_unit is
	component ex_data_forwarder is
		port (
			-- from CU
			I_SEL_A:	in source_t;
			I_SEL_B:	in source_t;

			-- from ID stage forward unit
			I_A:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);
			I_B:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);

			-- from EX
			I_ALUOUT_EX:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);

			-- from MEM
			I_LOADED_MEM:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);

			-- forwarded data
			O_A:		out std_logic_vector(RF_DATA_SZ - 1 downto 0);
			O_B:		out std_logic_vector(RF_DATA_SZ - 1 downto 0)
		);
	end component ex_data_forwarder;

	component alu is
		generic (
			N_BIT:	integer := 32
		);
		port (
			I_OP:	in std_logic_vector(FUNC_SZ - 1 downto 0);
			I_A:	in std_logic_vector(N_BIT - 1 downto 0);
			I_B:	in std_logic_vector(N_BIT - 1 downto 0);
			O_DATA:	out std_logic_vector(N_BIT - 1 downto 0)
		);
	end component alu;

	signal A:	std_logic_vector(I_A'range);
	signal B:	std_logic_vector(I_B'range);
	signal OP2:	std_logic_vector(I_B'range);
	signal ALUOUT:	std_logic_vector(O_ALUOUT'range);
begin
	ex_data_forwarder_0: ex_data_forwarder
		port map (
			I_SEL_A		=> I_SEL_A,
			I_SEL_B		=> I_SEL_B,
			I_A		=> I_A,
			I_B		=> I_B,
			I_ALUOUT_EX	=> I_ALUOUT_EX,
			I_LOADED_MEM	=> I_LOADED_MEM,
			O_A		=> A,
			O_B		=> B
		);

	OP2 <= B when (I_SEL_B_IMM = '0') else I_IMM;

	alu_0: alu
		generic map (
			N_BIT	=> RF_DATA_SZ
		)
		port map (
			I_OP	=> I_ALUOP,
			I_A	=> A,
			I_B	=> OP2,
			O_DATA	=> ALUOUT
		);
	
	O_ALUOUT	<= ALUOUT when (I_ALUOP /= FUNC_LINK) else I_NPC;
	O_B		<= B;
end MIXED;

