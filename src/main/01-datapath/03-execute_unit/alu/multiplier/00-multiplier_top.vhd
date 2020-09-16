library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- boothmul: perform integer multiplication using Booth algorithm
entity boothmul is
	generic (
		N_BIT:	integer := 32
	);
	port (
		I_A:	in std_logic_vector(N_BIT - 1 downto 0);      
		I_B:	in std_logic_vector(N_BIT - 1 downto 0);      

		O_P:	out std_logic_vector(2 * N_BIT - 1 downto 0)
	);  
end boothmul;

architecture MIXED of boothmul is
	component booth_mux is
		generic (
			N_BIT:	integer := 32
		);
		port (
			I_A:	in std_logic_vector(2 * N_BIT - 1 downto 0);
			I_B:	in std_logic_vector(2 downto 0);

			O_Y:	out std_logic_vector(2 * N_BIT - 1 downto 0)
		);
	end component booth_mux;
	
	type std_logic_matrix is array (0 to (N_BIT - 2) / 2) of
		std_logic_vector(2 * N_BIT - 1 downto 0);
	
	signal A_MUX:	std_logic_matrix;

	signal A_SUM: 	std_logic_matrix;
	signal B_SUM: 	std_logic_matrix;
begin
	-- A_MUX(0): sign-extention of A on 2 * N
	A_MUX(0) <= (N_BIT - 1 downto 0 => I_A(N_BIT - 1)) & I_A;

	mux0: booth_mux
		generic map (
			N_BIT => N_BIT
		)
		port map (
			I_A => A_MUX(0),
			I_B(2 downto 1) => I_B(1 downto 0),
			I_B(0) => '0',
			O_Y => B_SUM(0)
		);

	-- repetitive network instantiation
	net: for i in 1 to (N_BIT - 2) / 2 generate
		-- A_MUX(i) = 4 ^ i * A
		A_MUX(i) <= A_MUX(i - 1)(2 * N_BIT - 3 downto 0) & "00";

		mux: booth_mux
			generic map (
				N_BIT => N_BIT
			)
			port map (
				I_A => A_MUX(i),
				I_B => I_B((i * 2) + 1 downto ((i - 1) * 2) + 1),
				O_Y => A_SUM(i - 1)
			);

		-- sum current level mux output to previous level adder output
		B_SUM(i) <= std_logic_vector(unsigned(A_SUM(i - 1)) + unsigned(B_SUM(i - 1)));
	end generate net;

	O_P <= B_SUM((N_BIT - 2) / 2);		
end MIXED;	

