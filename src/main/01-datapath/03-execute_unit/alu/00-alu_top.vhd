library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.coding.all;

entity alu is
	generic (
		N_BIT:	integer := 32
	);
	port (
		I_OP:		in std_logic_vector(FUNC_SZ - 1 downto 0);
		I_A:		in std_logic_vector(N_BIT - 1 downto 0);
		I_B:		in std_logic_vector(N_BIT - 1 downto 0);
		O_DATA:		out std_logic_vector(N_BIT - 1 downto 0)
	);
end alu;

architecture MIXED of alu is
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

	component boothmul is
		generic (
			N_BIT:	integer := 32
		);
		port (
			I_A:	in std_logic_vector(N_BIT - 1 downto 0);      
			I_B:	in std_logic_vector(N_BIT - 1 downto 0);      
			O_P:	out std_logic_vector(2 * N_BIT - 1 downto 0)
		);  
	end component boothmul;

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

	-- multiplier signals
	signal A_LOW:	std_logic_vector(N_BIT / 2 - 1 downto 0);
	signal B_LOW:	std_logic_vector(N_BIT / 2 - 1 downto 0);
	signal PROD:	std_logic_vector(N_BIT - 1 downto 0);
begin
	B_INT	<= to_integer(unsigned(I_B));

	adder_0: p4_adder
		generic map (
			N_BIT	=> N_BIT,
			N_BIT_PER_BLOCK	=> 4
		)
		port map (
			I_A	=> I_A,
			I_B	=> B_ADDER,
			I_C	=> C_IN,
			O_S	=> SUM,
			O_C	=> C_OUT,
			O_OF	=> OVERFLOW
		);

	comparator_0: comparator
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

	A_LOW <= I_A(N_BIT / 2 - 1 downto 0);
	B_LOW <= I_B(N_BIT / 2 - 1 downto 0);

	boothmul_0: boothmul
		generic map (
			N_BIT	=> N_BIT / 2
		)
		port map (
			I_A	=> A_LOW,
			I_B	=> B_LOW,
			O_P	=> PROD
		);

	-- perform A + B when an ADD is required,
	-- otherwise perform A - B
	-- ((NOT B) + 1 = -B)
	B_ADDER	<= I_B when (I_OP = FUNC_ADD OR I_OP = FUNC_ADDU) else NOT I_B;
	C_IN	<= '0' when (I_OP = FUNC_ADD OR I_OP = FUNC_ADDU) else '1';

	output_sel: process(I_OP, I_A, I_B, B_INT, SUM, PROD, EQ, LT_S, GT_S, LT_U, GT_U)
	begin
		O_DATA <= (others => '0');
		case I_OP is
			when FUNC_SLL	=>
				O_DATA	<= to_stdlogicvector(to_bitvector(I_A) SLL B_INT);
			when FUNC_SRL	=>
				O_DATA	<= to_stdlogicvector(to_bitvector(I_A) SRL B_INT);
			when FUNC_SRA	=>
				O_DATA	<= to_stdlogicvector(to_bitvector(I_A) SRA B_INT);
			when FUNC_ADD | FUNC_ADDU | FUNC_SUB | FUNC_SUBU =>
				O_DATA <= SUM;
			when FUNC_AND	=>
				O_DATA	<= (I_A AND I_B);
			when FUNC_OR	=>
				O_DATA	<= (I_A OR I_B);
			when FUNC_XOR	=>
				O_DATA	<= (I_A XOR I_B);
			when FUNC_SEQ	=>
				O_DATA(0) <= EQ;
			when FUNC_SNE	=>
				O_DATA(0) <= (NOT EQ);
			when FUNC_SLT	=>
				O_DATA(0) <= LT_S;
			when FUNC_SLE	=>
				O_DATA(0) <= (LT_S OR EQ);
			when FUNC_SGE	=>
				O_DATA(0) <= (GT_S OR EQ);
			when FUNC_SGT	=>
				O_DATA(0) <= GT_S;
			when FUNC_SLTU	=>
				O_DATA(0) <= LT_U;
			when FUNC_SLEU	=>
				O_DATA(0) <= (LT_U OR EQ);
			when FUNC_SGEU	=>
				O_DATA(0) <= (GT_U OR EQ);
			when FUNC_SGTU	=>
				O_DATA(0) <= GT_U;
			when FUNC_MULT	=>
				O_DATA <= PROD;
			when others	=>
				null;
		end case;
	end process output_sel;
end MIXED;

