library ieee;
use ieee.std_logic_1164.all;
use work.specs.all;
use work.aluops.all;

entity tb_alu is
end tb_alu;

architecture TB_ARCH of tb_alu is
	component alu is
		generic (
			N_BIT:	integer := 32
		);
		port (
			I_OP:		in aluop_t;
			I_A:		in std_logic_vector(N_BIT - 1 downto 0);
			I_B:		in std_logic_vector(N_BIT - 1 downto 0);
			O_DATA:		out std_logic_vector(N_BIT - 1 downto 0)
		);
	end component alu;

	constant N_BIT:	integer := REG_SZ;

	signal OP:	aluop_t;
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

		OP <= ALUOP_SLL;
		wait for 5 ns;

		OP <= ALUOP_SRL;
		wait for 5 ns;

		OP <= ALUOP_SRA;
		wait for 5 ns;

		OP <= ALUOP_SLL;
		wait for 5 ns;

		OP <= ALUOP_ADD;
		wait for 5 ns;

		OP <= ALUOP_SUB;
		wait for 5 ns;

		OP <= ALUOP_AND;
		wait for 5 ns;

		OP <= ALUOP_OR;
		wait for 5 ns;

		OP <= ALUOP_XOR;
		wait for 5 ns;

		OP <= ALUOP_SEQ;
		wait for 5 ns;

		OP <= ALUOP_SNE;
		wait for 5 ns;

		OP <= ALUOP_SLT;
		wait for 5 ns;

		OP <= ALUOP_SGT;
		wait for 5 ns;

		OP <= ALUOP_SLE;
		wait for 5 ns;

		OP <= ALUOP_SGE;
		wait for 5 ns;

		OP <= ALUOP_SLTU;
		wait for 5 ns;

		OP <= ALUOP_SGTU;
		wait for 5 ns;

		OP <= ALUOP_SLEU;
		wait for 5 ns;

		OP <= ALUOP_SGEU;

		wait;
	end process stimuli;
end TB_ARCH;

