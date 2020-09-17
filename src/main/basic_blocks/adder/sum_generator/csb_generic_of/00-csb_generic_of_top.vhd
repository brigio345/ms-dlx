library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

-- Carry Select Block + overflow detector:
--	* compute A + B + '0' and A + B + '1' in parallel
--	* select the right sum according to the effective Ci
--	* O_OF = '1' when overflow is detected
entity CSB_GENERIC_OF is
	generic (
		N:	integer := 8
	);
	port (	
		I_A:	in std_logic_vector(N - 1 downto 0);
		I_B:	in std_logic_vector(N - 1 downto 0);
		I_CIN:	in std_logic;

		O_S:	out std_logic_vector(N - 1 downto 0);
		O_OF:	out std_logic
	);
end CSB_GENERIC_OF;

architecture MIXED of CSB_GENERIC_OF is
	component full_adder is 
		port (
			I_A:	in std_logic;
			I_B:	in std_logic;
			I_C:	in std_logic;

			O_S:	out std_logic;
			O_C:	out std_logic
		);
	end component full_adder; 

	signal S0:	std_logic_vector(O_S'range);
	signal S1:	std_logic_vector(O_S'range);
	signal C0:	std_logic_vector(O_S'range);
	signal C1:	std_logic_vector(O_S'range);
	signal OF0:	std_logic;
	signal OF1:	std_logic;
begin
	FA_0_0: full_adder
		port map (
			I_A => I_A(0),
			I_B => I_B(0),
			I_C => '0',
			O_S => S0(0),
			O_C => C0(0)
		);

	GEN_LOOP_FA_0: for i in 1 to N - 1 generate
		FA_0_X: full_adder
			port map (
				I_A => I_A(i),
				I_B => I_B(i),
				I_C => C0(i - 1),
				O_S => S0(i),
				O_C => C0(i)
			);
	end generate GEN_LOOP_FA_0;

	FA_1_0: full_adder
		port map (
			I_A => I_A(0),
			I_B => I_B(0),
			I_C => '1',
			O_S => S1(0),
			O_C => C1(0)
		);

	GEN_LOOP_FA_1: for i in 1 to N - 1 generate
		FA_1_X: full_adder
			port map (
				I_A => I_A(i),
				I_B => I_B(i),
				I_C => C1(i - 1),
				O_S => S1(i),
				O_C => C1(i)
			);
	end generate GEN_LOOP_FA_1;

	-- there is overflow if latest carry out differs from the latest but one
	OF0	<= C0(C0'left) XOR C0(C0'left - 1);
	OF1	<= C1(C1'left) XOR C1(C1'left - 1);

	O_S	<= S0 when (I_CIN = '0') else S1;
	O_OF	<= OF0 when (I_CIN = '0') else OF1;
end MIXED;

