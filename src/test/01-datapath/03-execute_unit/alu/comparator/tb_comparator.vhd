library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_comparator is
end tb_comparator;

architecture TB_ARCH of tb_comparator is
	component comparator is
		generic (
			N_BIT:	integer := 32
		);
		port (
			I_DELTA:in std_logic_vector(N_BIT - 1 downto 0);
			I_CO:	in std_logic;
			I_OF:	in std_logic;

			O_EQ:	out std_logic;
			O_LT_U:	out std_logic;
			O_GT_U:	out std_logic;
			O_LT_S:	out std_logic;
			O_GT_S:	out std_logic
		);
	end component comparator;

	component p4_adder is
		generic (
			N_BIT:			integer := 32;
			N_BIT_PER_BLOCK:	integer := 4
		);
		port (
			I_A:	in std_logic_vector(N_BIT - 1 downto 0);
			I_B:	in std_logic_vector(N_BIT - 1 downto 0);
			I_C:	in std_logic;
			O_S:	out std_logic_vector(N_BIT - 1 downto 0);
			O_C:	out std_logic;
			O_OF:	out std_logic
		);
	end component p4_adder;

	constant N_BIT:			integer := 4;
	constant N_BIT_PER_BLOCK:	integer := 4;

	signal A:	std_logic_vector(N_BIT - 1 downto 0);
	signal B:	std_logic_vector(N_BIT - 1 downto 0);
	signal B_NEG:	std_logic_vector(N_BIT - 1 downto 0);
	signal DELTA:	std_logic_vector(N_BIT - 1 downto 0);
	signal CO:	std_logic;
	signal OVERFLOW:std_logic;

	signal EQ:	std_logic;
	signal LT_U:	std_logic;
	signal GT_U:	std_logic;
	signal LT_S:	std_logic;
	signal GT_S:	std_logic;
begin
	dut: comparator
		generic map (
			N_BIT	=> N_BIT
		)
		port map (
			I_DELTA	=> DELTA,
			I_CO	=> CO,
			I_OF	=> OVERFLOW,
			O_EQ	=> EQ,
			O_LT_U	=> LT_U,
			O_GT_U	=> GT_U,
			O_LT_S	=> LT_S,
			O_GT_S	=> GT_S
		);

	B_NEG	<= NOT B;

	adder: p4_adder
		generic map (
			N_BIT		=> N_BIT,
			N_BIT_PER_BLOCK	=> N_BIT_PER_BLOCK
		)
		port map (
			I_A	=> A,
			I_B	=> B_NEG,
			I_C	=> '1',
			O_S	=> DELTA,
			O_C	=> CO,
			O_OF	=> OVERFLOW
		);

	stimuli: process
	begin
		for i in 0 to 2 ** N_BIT - 1 loop
			A <= std_logic_vector(to_unsigned(i, A'length));
			for j in 0 to 2 ** N_BIT - 1 loop
				B <= std_logic_vector(to_unsigned(j, B'length));

				wait for 5 ns;

				if (A = B) then
					assert (EQ = '1' AND LT_U = '0' AND GT_U = '0')
					report "error with unsigned A = B";

					assert (EQ = '1' AND LT_S = '0' AND GT_S = '0')
					report "error with signed A = B";
				else
					if (unsigned(A) < unsigned(B)) then
						assert (EQ = '0' AND LT_U = '1' AND GT_U = '0')
						report "error with unsigned A < B";
					else
						assert (EQ = '0' AND LT_U = '0' AND GT_U = '1')
						report "error with unsigned A > B";
					end if;

					if (signed(A) < signed(B)) then
						assert (EQ = '0' AND LT_S = '1' AND GT_S = '0')
						report "error with signed A < B";
					else
						assert (EQ = '0' AND LT_S = '0' AND GT_S = '1')
						report "error with signed A > B";
					end if;
				end if;
			end loop;
		end loop;

		report "comparator simulation completed" severity note;

		wait;
	end process stimuli;
end TB_ARCH;

