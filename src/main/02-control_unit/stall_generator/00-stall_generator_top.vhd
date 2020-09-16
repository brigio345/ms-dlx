library ieee;
use ieee.std_logic_1164.all;
use work.types.all;

-- stall_generator: force stalls when necessary
entity stall_generator is
	port (
		I_TAKEN:	in std_logic;
		I_SEL_DST:	in dest_t;
		I_STR:		in std_logic_vector(1 downto 0);
		I_SEL_A:	in source_t;
		I_SEL_B:	in source_t;
		I_A_NEEDED_ID:	in std_logic;
		I_A_NEEDED_EX:	in std_logic;
		I_B_NEEDED_EX:	in std_logic;
		I_TAKEN_PREV:	in std_logic;

		O_IF_EN:	out std_logic;
		O_TAKEN:	out std_logic;
		O_STR:		out std_logic_vector(1 downto 0);
		O_SEL_DST:	out dest_t
	);
end stall_generator;

architecture BEHAVIORAL of stall_generator is
	signal DATA_STALL:	std_logic;
begin
	-- Data forwarding:
	--	* to ID stage:
	--		1. from ALUOUT of instruction in MEM stage
	--	* to EX stage:
	--		1. from ALUOUT of instruction in MEM stage
	--		2. from ALUOUT of instruction in EX stage
	--		3. from LOADED of instruction in MEM stage
	--	* to MEM stage:
	--		1. from ALUOUT of instruction in MEM stage
	--		2. from ALUOUT of instruction in EX stage
	--		3. from LOADED of instruction in MEM stage
	--		4. from LOADED of instruction in EX stage

	-- Insert a data stall in ID stage when data is not in rf and cannot
	--	be forwarded
	DATA_STALL <= '1' when (
			((I_A_NEEDED_ID = '1') AND ((I_SEL_A = SRC_ALU_EX) OR
			(I_SEL_A = SRC_LD_EX) OR (I_SEL_A = SRC_LD_MEM))) OR
			((I_A_NEEDED_EX = '1') AND (I_SEL_A = SRC_LD_EX)) OR
		    	((I_B_NEEDED_EX = '1') AND (I_SEL_B = SRC_LD_EX)))
		    else '0';

	stall_gen: process (I_TAKEN_PREV, DATA_STALL, I_STR, I_SEL_DST, I_TAKEN)
	begin
		if (I_TAKEN_PREV = '1') then
			-- stall: disable branches and writes (to memory and rf)
			--	so that current instruction will not have any
			--	effect
			-- 	IF can proceed, since PC has been updated with
			--	the right instruction
			O_STR		<= "00";
			O_SEL_DST	<= DST_NO;
			O_TAKEN		<= '0';
			O_IF_EN		<= '1';
		elsif (DATA_STALL = '1') then
			-- stall: disable branches and writes (to memory and rf)
			--	so that current instruction will not have any
			--	effect
			--	IF cannot proceed, since current instruction
			--	must wait for its operands and then executed
			O_STR		<= "00";
			O_SEL_DST	<= DST_NO;
			O_TAKEN		<= '0';
			O_IF_EN		<= '0';
		else
			-- no stall: output decoded data
			O_STR		<= I_STR;
			O_SEL_DST	<= I_SEL_DST;
			O_TAKEN		<= I_TAKEN;
			O_IF_EN		<= '1';
		end if;
	end process stall_gen;
end BEHAVIORAL;

