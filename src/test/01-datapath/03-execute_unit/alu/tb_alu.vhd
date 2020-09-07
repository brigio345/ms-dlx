library ieee;
use ieee.std_logic_1164.all;
use work.coding.all;

entity tb_alu is
end tb_alu;

architecture TB_ARCH of tb_alu is
	component alu is
		generic (
			N_BIT:	integer := 32
		);
		port (
			I_OP:		in std_logic_vector(FUNC_SZ - 1 downto 0);
			I_A:		in std_logic_vector(N_BIT - 1 downto 0);
			I_B:		in std_logic_vector(N_BIT - 1 downto 0);
			O_DATA:		out std_logic_vector(N_BIT - 1 downto 0)
		);
	end component alu;

	constant N_BIT:	integer := RF_DATA_SZ;

	signal OP:	std_logic_vector(FUNC_SZ - 1 downto 0);
	signal A:	std_logic_vector(N_BIT - 1 downto 0);
	signal B:	std_logic_vector(N_BIT - 1 downto 0);
	signal ALU_OUT:	std_logic_vector(N_BIT - 1 downto 0);
begin
	dut: alu
		generic map (
			N_BIT	=> N_BIT
		)
		port map (
			I_OP	=> OP,
			I_A	=> A,
			I_B	=> B,
			O_DATA	=> ALU_OUT
		);

	stimuli: process
	begin
		A <= x"00000014";
		B <= x"00000005";

		OP <= FUNC_SLL;
		wait for 5 ns;

		OP <= FUNC_SRL;
		wait for 5 ns;

		OP <= FUNC_SRA;
		wait for 5 ns;

		OP <= FUNC_SLL;
		wait for 5 ns;

		OP <= FUNC_ADD;
		wait for 5 ns;

		OP <= FUNC_SUB;
		wait for 5 ns;

		OP <= FUNC_AND;
		wait for 5 ns;

		OP <= FUNC_OR;
		wait for 5 ns;

		OP <= FUNC_XOR;
		wait for 5 ns;

		OP <= FUNC_SEQ;
		wait for 5 ns;

		OP <= FUNC_SNE;
		wait for 5 ns;

		OP <= FUNC_SLT;
		wait for 5 ns;

		OP <= FUNC_SGT;
		wait for 5 ns;

		OP <= FUNC_SLE;
		wait for 5 ns;

		OP <= FUNC_SGE;
		wait for 5 ns;

		OP <= FUNC_SLTU;
		wait for 5 ns;

		OP <= FUNC_SGTU;
		wait for 5 ns;

		OP <= FUNC_SLEU;
		wait for 5 ns;

		OP <= FUNC_SGEU;

		wait;
	end process stimuli;
end TB_ARCH;

