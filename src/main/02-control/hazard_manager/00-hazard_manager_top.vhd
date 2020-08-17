library ieee;
use ieee.std_logic_1164.all;
use work.coding.all;
use work.types.all;

entity hazard_manager is
	port (
		-- from ID stage
		I_INST_TYPE:	in inst_t;
		I_SRC_A:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
		I_SRC_B:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
		I_TAKEN:	in std_logic;
		I_DST:		in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
		I_STR:		in std_logic;
		I_BRANCH:	in branch_t;

		-- from EX stage
		I_DST_EX:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
		I_LD_EX:	in std_logic;

		-- from MEM stage
		I_DST_MEM:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
		I_LD_MEM:	in std_logic;

		-- to ID stage
		O_SEL_A:	out source_t;
		O_SEL_B:	out source_t;
		O_BRANCH:	out branch_t;
		O_DST:		out std_logic_vector(RF_ADDR_SZ - 1 downto 0);
		O_STR:		out std_logic
	);
end hazard_manager;

architecture MIXED of hazard_manager is
	component source_selector is
		port (
			-- from ID stage
			I_SRC_A:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
			I_SRC_B:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);

			-- from EX stage
			I_DST_EX:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
			I_LD_EX:	in std_logic;

			-- from MEM stage
			I_DST_MEM:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
			I_LD_MEM:	in std_logic;

			O_SEL_A:	out source_t;
			O_SEL_B:	out source_t;
		);
	end component source_selector;

	signal SEL_A:		source_t;
	signal SEL_B:		source_t;

	signal A_NEEDED:	std_logic;
	signal B_NEEDED:	std_logic;
	signal DATA_HAZ:	std_logic;
	signal CTRL_HAZ:	std_logic;
begin
	source_selector_0: source_selector
		port map (
			I_SRC_A		=> I_SRC_A,
			I_SRC_B		=> I_SRC_B,
			I_DST_EX	=> I_DST_EX,
			I_LD_EX		=> I_LD_EX,
			I_DST_MEM	=> I_DST_MEM,
			I_LD_MEM	=> I_LD_MEM,
			O_SEL_A		=> SEL_A,
			O_SEL_B		=> SEL_B
		);

	O_SEL_A	<= SEL_A;
	O_SEL_B	<= SEL_B;

	-- note: this should be changed in order to support JR/JALR,
	-- which also need A
	A_NEEDED <= '0' when (I_INST_TYPE = INST_JMP) else '1';
	B_NEEDED <= '1' when (I_INST_TYPE = INST_REG) else '0';

	-- data hazard occurs when a needed source operand has to be loaded
	-- by the instruction which currently is in EX stage
	DATA_HAZ <= '1' when (((SEL_A = SRC_LD_EX) AND (A_NEEDED = '1')) OR
		    ((SEL_B = SRC_LD_EX) AND (B_NEEDED = '1')))
		    else '0';
	CTRL_HAZ <= I_TAKEN;

	stall_gen: process (DATA_HAZ, CTRL_HAZ, I_DST, I_STR, I_BRANCH)
	begin
		if (DATA_HAZ = '1') then
			-- disable writes to rf and data memory
			O_DST	<= (others => '0');
			O_STR	<= '0';
			-- disable branches
			O_BRANCH<= BRANCH_NO;
		elsif (CTRL_HAZ = '1') then
			-- disable writes to rf and data memory
			O_DST	<= (others => '0');
			O_STR	<= '0';
			O_BRANCH<= I_BRANCH;
		else
			O_DST	<= I_DST;
			O_STR	<= I_STR;
			O_BRANCH<= I_BRANCH;
		end if;
	end process stall_gen;
end MIXED;

