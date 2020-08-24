library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity BOOTHMUL is
	generic (
		N:	integer := 32
	);
	port (
		A: in std_logic_vector(N - 1 downto 0);      
		B: in std_logic_vector(N - 1 downto 0);      
		P: out std_logic_vector(2 * N - 1 downto 0)
	);  
end BOOTHMUL;

architecture MIXED of BOOTHMUL is
	component BOOTH_MUX is
		generic (
			N:	integer := 32
		);
		port (
			A:	in std_logic_vector(2 * N - 1 downto 0);
			B:	in std_logic_vector(2 downto 0);
			Y:	out std_logic_vector(2 * N - 1 downto 0)
		);
	end component BOOTH_MUX;
	
	type std_logic_matrix is array (0 to (N - 2) / 2) of
		std_logic_vector(2 * N - 1 downto 0);
	
	signal A_mux:	std_logic_matrix;

	signal A_sum: 	std_logic_matrix;
	signal B_sum: 	std_logic_matrix;
	
begin
	-- A_mux(0): sign-extention of A on 2 * N
	A_mux(0) <= (N - 1 downto 0 => A(N - 1)) & A;

	mux0: BOOTH_MUX
		generic map (
			N => N
		)
		port map (
			A => A_mux(0),
			B(2 downto 1) => B(1 downto 0),
			B(0) => '0',
			Y => B_sum(0)
		);


	-- repetitive network instantiation
	net: for i in 1 to (N - 2) / 2 generate
		-- A_mux(i) = 4 ^ i * A
		A_mux(i) <= A_mux(i - 1)(2 * N - 3 downto 0) & "00";

		mux: BOOTH_MUX
			generic map (
				N => N
			)
			port map (
				A => A_mux(i),
				B => B((i * 2) + 1 downto ((i - 1) * 2) + 1),
				Y => A_sum(i - 1)
			);

		-- sum current level mux output to previous level adder output
		B_sum(i) <= std_logic_vector(unsigned(A_sum(i - 1)) + unsigned(B_sum(i - 1)));
	end generate net;

	P <= B_sum((N - 2) / 2);		
end MIXED;	

