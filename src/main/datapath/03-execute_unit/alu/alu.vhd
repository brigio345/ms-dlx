library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.aluops.all;

entity alu is
	generic (
		N_BIT:	integer := 32
	);
	port (
		I_OP:		in aluop_t;
		I_A:		in std_logic_vector(N_BIT - 1 downto 0);
		I_B:		in std_logic_vector(N_BIT - 1 downto 0);
		O_DATA:		out std_logic_vector(N_BIT - 1 downto 0)
	);
end alu;

architecture MIXED of alu is
	component P4_ADDER is
		generic (
			NBIT:		integer := 32;
			NBIT_PER_BLOCK:	integer := 4
		);
		port (
			A:	in	std_logic_vector(NBIT-1 downto 0);
			B:	in	std_logic_vector(NBIT-1 downto 0);
			Cin:	in	std_logic;
			S:	out	std_logic_vector(NBIT-1 downto 0);
			Cout:	out	std_logic;
			O_OF:	out	std_logic
		);
	end component P4_ADDER;

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

	-- adder signals
	signal C_IN:	std_logic;
	signal B_ADDER:	std_logic_vector(N_BIT - 1 downto 0);
	signal SUM:	std_logic_vector(N_BIT - 1 downto 0);
	signal C_OUT:	std_logic;
	signal OVERFLOW:std_logic;

	-- shifter signals
	signal B_INT:	integer;

	-- comparator signals
	signal EQ:	std_logic;
	signal LT_U:	std_logic;
	signal GT_U:	std_logic;
	signal LT_S:	std_logic;
	signal GT_S:	std_logic;
begin
	B_INT	<= to_integer(unsigned(I_B));

	adder: p4_adder
		generic map (
			NBIT	=> N_BIT,
			NBIT_PER_BLOCK	=> 4
		)
		port map (
			A	=> I_A,
			B	=> B_ADDER,
			Cin	=> C_IN,
			S	=> SUM,
			Cout	=> C_OUT,
			O_OF	=> OVERFLOW
		);

	cmp0: comparator
		generic map (
			N_BIT => N_BIT
		)
		port map (
			I_DELTA	=> SUM,
			I_CO	=> C_OUT,
			I_OF	=> OVERFLOW,
			O_EQ	=> EQ,
			O_LT_U	=> LT_U,
			O_GT_U	=> GT_U,
			O_LT_S	=> LT_S,
			O_GT_S	=> GT_S
		);

	-- perform A + B when an ADD is required,
	-- otherwise perform A - B
	-- ((NOT B) + 1 = -B)
	B_ADDER	<= I_B when (I_OP = ALUOP_ADD) else NOT I_B;
	C_IN	<= '0' when (I_OP = ALUOP_ADD) else '1';

	output_sel: process(I_OP, I_A, I_B, SUM, EQ, LT_S, GT_S, LT_U, GT_U)
	begin
		O_DATA <= (others => '0');
		case I_OP is
			when ALUOP_SLL	=>
				O_DATA	<= to_stdlogicvector(to_bitvector(I_A) SLL B_INT);
			when ALUOP_SRL	=>
				O_DATA	<= to_stdlogicvector(to_bitvector(I_A) SRL B_INT);
			when ALUOP_SRA	=>
				O_DATA	<= to_stdlogicvector(to_bitvector(I_A) SRA B_INT);
			when ALUOP_ADD | ALUOP_SUB	=>
				O_DATA <= SUM;
			when ALUOP_AND	=>
				O_DATA	<= I_A AND I_B;
			when ALUOP_OR	=>
				O_DATA	<= I_A OR I_B;
			when ALUOP_XOR	=>
				O_DATA	<= I_A XOR I_B;
			when ALUOP_SEQ	=>
				O_DATA(0) <= EQ;
			when ALUOP_SNE	=>
				O_DATA(0) <= NOT EQ;
			when ALUOP_SLT	=>
				O_DATA(0) <= LT_S;
			when ALUOP_SLE	=>
				O_DATA(0) <= LT_S OR EQ;
			when ALUOP_SGE	=>
				O_DATA(0) <= GT_S OR EQ;
			when ALUOP_SGT	=>
				O_DATA(0) <= GT_S;
			when ALUOP_SLTU	=>
				O_DATA(0) <= LT_U;
			when ALUOP_SLEU =>
				O_DATA(0) <= LT_U OR EQ;
			when ALUOP_SGEU =>
				O_DATA(0) <= GT_U OR EQ;
			when ALUOP_SGTU=>
				O_DATA(0) <= GT_U;
			when others	=>
				null;
		end case;
	end process output_sel;
end MIXED;

