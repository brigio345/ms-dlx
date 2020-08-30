library ieee;
use ieee.std_logic_1164.all;
use work.coding.all;
use work.types.all;

entity tb_inst_decoder is
end tb_inst_decoder;

architecture TB_ARCH of tb_inst_decoder is
	component inst_decoder is
		port (
			-- from ID stage
			I_FUNC:		in std_logic_vector(FUNC_SZ - 1 downto 0);
			I_OPCODE:	in std_logic_vector(OPCODE_SZ - 1 downto 0);
			I_ZERO:		in std_logic;

			-- to ID stage
			O_TAKEN:	out std_logic;
			O_SEL_JMP:	out jump_t;
			O_IMM_SIGN:	out std_logic;

			-- to EX stage
			O_ALUOP:	out std_logic_vector(FUNC_SZ - 1 downto 0);
			O_SEL_B_IMM:	out std_logic;

			-- to MEM stage
			O_LD:		out std_logic_vector(1 downto 0);
			O_LD_SIGN:	out std_logic;
			O_STR:		out std_logic_vector(1 downto 0);

			-- to WB stage
			O_SEL_DST:	out dest_t;

			-- to CU
			O_A_NEEDED_ID:	out std_logic;
			O_A_NEEDED_EX:	out std_logic;
			O_B_NEEDED_EX:	out std_logic
		);
	end component inst_decoder;

	constant WAIT_TIME:	time := 2 ns;

	signal FUNC:		std_logic_vector(FUNC_SZ - 1 downto 0);
	signal OPCODE:		std_logic_vector(OPCODE_SZ - 1 downto 0);
	signal ZERO:		std_logic;
	signal TAKEN:		std_logic;
	signal SEL_JMP:		jump_t;
	signal IMM_SIGN:	std_logic;
	signal ALUOP:		std_logic_vector(FUNC_SZ - 1 downto 0);
	signal SEL_B_IMM:	std_logic;
	signal LD:		std_logic_vector(1 downto 0);
	signal LD_SIGN:		std_logic;
	signal STR:		std_logic_vector(1 downto 0);
	signal SEL_DST:		dest_t;
	signal A_NEEDED_ID:	std_logic;
	signal A_NEEDED_EX:	std_logic;
	signal B_NEEDED_EX:	std_logic;
begin
	dut: inst_decoder
		port map (
			I_FUNC		=> FUNC,
			I_OPCODE	=> OPCODE,
			I_ZERO		=> ZERO,
			O_TAKEN		=> TAKEN,
			O_SEL_JMP	=> SEL_JMP,
			O_IMM_SIGN	=> IMM_SIGN,
			O_ALUOP		=> ALUOP,
			O_SEL_B_IMM	=> SEL_B_IMM,
			O_LD		=> LD,
			O_LD_SIGN	=> LD_SIGN,
			O_STR		=> STR,
			O_SEL_DST	=> SEL_DST,
			O_A_NEEDED_ID	=> A_NEEDED_ID,
			O_A_NEEDED_EX	=> A_NEEDED_EX,
			O_B_NEEDED_EX	=> B_NEEDED_EX
		);

	stimuli: process
	begin
		-- test R-type instructions decoding
		OPCODE	<= OPCODE_RTYPE;
		ZERO	<= '0';

		FUNC	<= FUNC_SLL;

		wait for WAIT_TIME;
		assert ((TAKEN = '0') AND (ALUOP = FUNC) AND (SEL_B_IMM = '0') AND
				(STR = "00") AND (SEL_DST = DST_REG) AND
				(A_NEEDED_ID = '0') AND (A_NEEDED_EX = '1') AND 
				(B_NEEDED_EX = '1'))
			report "unexpected decoding for R-type SLL";

		FUNC	<= FUNC_SRL;

		wait for WAIT_TIME;

		assert ((TAKEN = '0') AND (ALUOP = FUNC) AND (SEL_B_IMM = '0') AND
				(STR = "00") AND (SEL_DST = DST_REG) AND
				(A_NEEDED_ID = '0') AND (A_NEEDED_EX = '1') AND 
				(B_NEEDED_EX = '1'))
			report "unexpected decoding for R-type SRL";

		FUNC	<= FUNC_SRA;

		wait for WAIT_TIME;
		assert ((TAKEN = '0') AND (ALUOP = FUNC) AND (SEL_B_IMM = '0') AND
				(STR = "00") AND (SEL_DST = DST_REG) AND
				(A_NEEDED_ID = '0') AND (A_NEEDED_EX = '1') AND 
				(B_NEEDED_EX = '1'))
			report "unexpected decoding for R-type SRA";

		FUNC	<= FUNC_ADD;

		wait for WAIT_TIME;
		assert ((TAKEN = '0') AND (ALUOP = FUNC) AND (SEL_B_IMM = '0') AND
				(STR = "00") AND (SEL_DST = DST_REG) AND
				(A_NEEDED_ID = '0') AND (A_NEEDED_EX = '1') AND 
				(B_NEEDED_EX = '1'))
			report "unexpected decoding for R-type ADD";


		FUNC	<= FUNC_ADDU;

		wait for WAIT_TIME;
		assert ((TAKEN = '0') AND (ALUOP = FUNC) AND (SEL_B_IMM = '0') AND
				(STR = "00") AND (SEL_DST = DST_REG) AND
				(A_NEEDED_ID = '0') AND (A_NEEDED_EX = '1') AND 
				(B_NEEDED_EX = '1'))
			report "unexpected decoding for R-type ADDU";

		FUNC	<= FUNC_SUB;

		wait for WAIT_TIME;

		assert ((TAKEN = '0') AND (ALUOP = FUNC) AND (SEL_B_IMM = '0') AND
				(STR = "00") AND (SEL_DST = DST_REG) AND
				(A_NEEDED_ID = '0') AND (A_NEEDED_EX = '1') AND 
				(B_NEEDED_EX = '1'))
			report "unexpected decoding for R-type SUB";

		FUNC	<= FUNC_SUBU;

		wait for WAIT_TIME;
		assert ((TAKEN = '0') AND (ALUOP = FUNC) AND (SEL_B_IMM = '0') AND
				(STR = "00") AND (SEL_DST = DST_REG) AND
				(A_NEEDED_ID = '0') AND (A_NEEDED_EX = '1') AND 
				(B_NEEDED_EX = '1'))
			report "unexpected decoding for R-type SUBU";

		FUNC	<= FUNC_AND;

		wait for WAIT_TIME;
		assert ((TAKEN = '0') AND (ALUOP = FUNC) AND (SEL_B_IMM = '0') AND
				(STR = "00") AND (SEL_DST = DST_REG) AND
				(A_NEEDED_ID = '0') AND (A_NEEDED_EX = '1') AND 
				(B_NEEDED_EX = '1'))
			report "unexpected decoding for R-type AND";


		FUNC	<= FUNC_OR;

		wait for WAIT_TIME;
		assert ((TAKEN = '0') AND (ALUOP = FUNC) AND (SEL_B_IMM = '0') AND
				(STR = "00") AND (SEL_DST = DST_REG) AND
				(A_NEEDED_ID = '0') AND (A_NEEDED_EX = '1') AND 
				(B_NEEDED_EX = '1'))
			report "unexpected decoding for R-type OR";

		FUNC	<= FUNC_XOR;

		wait for WAIT_TIME;

		assert ((TAKEN = '0') AND (ALUOP = FUNC) AND (SEL_B_IMM = '0') AND
				(STR = "00") AND (SEL_DST = DST_REG) AND
				(A_NEEDED_ID = '0') AND (A_NEEDED_EX = '1') AND 
				(B_NEEDED_EX = '1'))
			report "unexpected decoding for R-type XOR";

		FUNC	<= FUNC_SEQ;

		wait for WAIT_TIME;
		assert ((TAKEN = '0') AND (ALUOP = FUNC) AND (SEL_B_IMM = '0') AND
				(STR = "00") AND (SEL_DST = DST_REG) AND
				(A_NEEDED_ID = '0') AND (A_NEEDED_EX = '1') AND 
				(B_NEEDED_EX = '1'))
			report "unexpected decoding for R-type SEQ";

		FUNC	<= FUNC_SNE;

		wait for WAIT_TIME;
		assert ((TAKEN = '0') AND (ALUOP = FUNC) AND (SEL_B_IMM = '0') AND
				(STR = "00") AND (SEL_DST = DST_REG) AND
				(A_NEEDED_ID = '0') AND (A_NEEDED_EX = '1') AND 
				(B_NEEDED_EX = '1'))
			report "unexpected decoding for R-type SNE";


		FUNC	<= FUNC_SLT;

		wait for WAIT_TIME;
		assert ((TAKEN = '0') AND (ALUOP = FUNC) AND (SEL_B_IMM = '0') AND
				(STR = "00") AND (SEL_DST = DST_REG) AND
				(A_NEEDED_ID = '0') AND (A_NEEDED_EX = '1') AND 
				(B_NEEDED_EX = '1'))
			report "unexpected decoding for R-type SLT";

		FUNC	<= FUNC_SGT;

		wait for WAIT_TIME;

		assert ((TAKEN = '0') AND (ALUOP = FUNC) AND (SEL_B_IMM = '0') AND
				(STR = "00") AND (SEL_DST = DST_REG) AND
				(A_NEEDED_ID = '0') AND (A_NEEDED_EX = '1') AND 
				(B_NEEDED_EX = '1'))
			report "unexpected decoding for R-type SGT";

		FUNC	<= FUNC_SLE;

		wait for WAIT_TIME;
		assert ((TAKEN = '0') AND (ALUOP = FUNC) AND (SEL_B_IMM = '0') AND
				(STR = "00") AND (SEL_DST = DST_REG) AND
				(A_NEEDED_ID = '0') AND (A_NEEDED_EX = '1') AND 
				(B_NEEDED_EX = '1'))
			report "unexpected decoding for R-type SLE";

		FUNC	<= FUNC_SGE;

		wait for WAIT_TIME;
		assert ((TAKEN = '0') AND (ALUOP = FUNC) AND (SEL_B_IMM = '0') AND
				(STR = "00") AND (SEL_DST = DST_REG) AND
				(A_NEEDED_ID = '0') AND (A_NEEDED_EX = '1') AND 
				(B_NEEDED_EX = '1'))
			report "unexpected decoding for R-type SGE";


		FUNC	<= FUNC_SLTU;

		wait for WAIT_TIME;

		assert ((TAKEN = '0') AND (ALUOP = FUNC) AND (SEL_B_IMM = '0') AND
				(STR = "00") AND (SEL_DST = DST_REG) AND
				(A_NEEDED_ID = '0') AND (A_NEEDED_EX = '1') AND 
				(B_NEEDED_EX = '1'))
			report "unexpected decoding for R-type SLTU";

		FUNC	<= FUNC_SGTU;

		wait for WAIT_TIME;
		assert ((TAKEN = '0') AND (ALUOP = FUNC) AND (SEL_B_IMM = '0') AND
				(STR = "00") AND (SEL_DST = DST_REG) AND
				(A_NEEDED_ID = '0') AND (A_NEEDED_EX = '1') AND 
				(B_NEEDED_EX = '1'))
			report "unexpected decoding for R-type SGTU";

		FUNC	<= FUNC_SLEU;

		wait for WAIT_TIME;
		assert ((TAKEN = '0') AND (ALUOP = FUNC) AND (SEL_B_IMM = '0') AND
				(STR = "00") AND (SEL_DST = DST_REG) AND
				(A_NEEDED_ID = '0') AND (A_NEEDED_EX = '1') AND 
				(B_NEEDED_EX = '1'))
			report "unexpected decoding for R-type SLEU";


		FUNC	<= FUNC_SGEU;

		wait for WAIT_TIME;
		assert ((TAKEN = '0') AND (ALUOP = FUNC) AND (SEL_B_IMM = '0') AND
				(STR = "00") AND (SEL_DST = DST_REG) AND
				(A_NEEDED_ID = '0') AND (A_NEEDED_EX = '1') AND 
				(B_NEEDED_EX = '1'))
			report "unexpected decoding for R-type SGEU";

		OPCODE	<= OPCODE_FRTYPE;
		FUNC	<= FUNC_MULT;

		wait for WAIT_TIME;
		assert ((TAKEN = '0') AND (ALUOP = FUNC) AND (SEL_B_IMM = '0') AND
				(STR = "00") AND (SEL_DST = DST_REG) AND
				(A_NEEDED_ID = '0') AND (A_NEEDED_EX = '1') AND 
				(B_NEEDED_EX = '1'))
			report "unexpected decoding for FR-type MULT";


		-- test I-type instructions decoding
		FUNC	<= (others => '0');

		OPCODE	<= OPCODE_BEQZ;
		ZERO	<= '0';

		wait for WAIT_TIME;

		assert ((TAKEN = '0') AND (STR = "00") AND (SEL_DST = DST_NO) AND
				(A_NEEDED_ID = '1') AND (A_NEEDED_EX = '0') AND 
				(B_NEEDED_EX = '0'))
			report "unexpected decoding for I-type BEQZ with ZERO = '0'";

		OPCODE	<= OPCODE_BEQZ;
		ZERO	<= '1';

		wait for WAIT_TIME;

		assert ((TAKEN = '1') AND (SEL_JMP = JMP_REL_IMM) AND 
				(STR = "00") AND (SEL_DST = DST_NO) AND
				(A_NEEDED_ID = '1') AND (A_NEEDED_EX = '0') AND 
				(B_NEEDED_EX = '0'))
			report "unexpected decoding for I-type BEQZ with ZERO = '1'";


		OPCODE	<= OPCODE_BNEZ;
		ZERO	<= '1';

		wait for WAIT_TIME;

		assert ((TAKEN = '0') AND (STR = "00") AND (SEL_DST = DST_NO) AND
				(A_NEEDED_ID = '1') AND (A_NEEDED_EX = '0') AND 
				(B_NEEDED_EX = '0'))
			report "unexpected decoding for I-type BNEZ with ZERO = '1'";

		OPCODE	<= OPCODE_BNEZ;
		ZERO	<= '0';

		wait for WAIT_TIME;

		assert ((TAKEN = '1') AND (SEL_JMP = JMP_REL_IMM) AND 
				(STR = "00") AND (SEL_DST = DST_NO) AND
				(A_NEEDED_ID = '1') AND (A_NEEDED_EX = '0') AND 
				(B_NEEDED_EX = '0'))
			report "unexpected decoding for I-type BNEZ with ZERO = '0'";

		ZERO	<= '0';

		OPCODE	<= OPCODE_ADDI;

		wait for WAIT_TIME;

		assert ((TAKEN = '0') AND (IMM_SIGN = '1') AND
				((ALUOP = FUNC_ADD) OR (ALUOP = FUNC_ADDU)) AND
				(SEL_B_IMM = '1') AND (STR = "00") AND
				(SEL_DST = DST_IMM) AND (A_NEEDED_ID = '0') AND
				(A_NEEDED_EX = '1') AND (B_NEEDED_EX = '0'))
			report "unexpected decoding for I-type ADDI";

		OPCODE	<= OPCODE_ADDUI;

		wait for WAIT_TIME;

		assert ((TAKEN = '0') AND (IMM_SIGN = '0') AND
				((ALUOP = FUNC_ADD) OR (ALUOP = FUNC_ADDU)) AND
				(SEL_B_IMM = '1') AND (STR = "00") AND
				(SEL_DST = DST_IMM) AND (A_NEEDED_ID = '0') AND
				(A_NEEDED_EX = '1') AND (B_NEEDED_EX = '0'))
			report "unexpected decoding for I-type ADDUI";

		OPCODE	<= OPCODE_SUBI;

		wait for WAIT_TIME;

		assert ((TAKEN = '0') AND (IMM_SIGN = '1') AND
				((ALUOP = FUNC_SUB) OR (ALUOP = FUNC_SUBU)) AND
				(SEL_B_IMM = '1') AND (STR = "00") AND
				(SEL_DST = DST_IMM) AND (A_NEEDED_ID = '0') AND
				(A_NEEDED_EX = '1') AND (B_NEEDED_EX = '0'))
			report "unexpected decoding for I-type SUBI";

		OPCODE	<= OPCODE_SUBUI;

		wait for WAIT_TIME;

		assert ((TAKEN = '0') AND (IMM_SIGN = '0') AND
				((ALUOP = FUNC_SUB) OR (ALUOP = FUNC_SUBU)) AND
				(SEL_B_IMM = '1') AND (STR = "00") AND
				(SEL_DST = DST_IMM) AND (A_NEEDED_ID = '0') AND
				(A_NEEDED_EX = '1') AND (B_NEEDED_EX = '0'))
			report "unexpected decoding for I-type SUBUI";

		OPCODE	<= OPCODE_ANDI;

		wait for WAIT_TIME;

		assert ((TAKEN = '0') AND (IMM_SIGN = '0') AND
				(ALUOP = FUNC_AND) AND
				(SEL_B_IMM = '1') AND (STR = "00") AND
				(SEL_DST = DST_IMM) AND (A_NEEDED_ID = '0') AND
				(A_NEEDED_EX = '1') AND (B_NEEDED_EX = '0'))
			report "unexpected decoding for I-type ADDI";

		OPCODE	<= OPCODE_ORI;

		wait for WAIT_TIME;

		assert ((TAKEN = '0') AND (IMM_SIGN = '0') AND
				(ALUOP = FUNC_OR) AND
				(SEL_B_IMM = '1') AND (STR = "00") AND
				(SEL_DST = DST_IMM) AND (A_NEEDED_ID = '0') AND
				(A_NEEDED_EX = '1') AND (B_NEEDED_EX = '0'))
			report "unexpected decoding for I-type ORI";


		OPCODE	<= OPCODE_XORI;

		wait for WAIT_TIME;

		assert ((TAKEN = '0') AND (IMM_SIGN = '0') AND
				(ALUOP = FUNC_XOR) AND
				(SEL_B_IMM = '1') AND (STR = "00") AND
				(SEL_DST = DST_IMM) AND (A_NEEDED_ID = '0') AND
				(A_NEEDED_EX = '1') AND (B_NEEDED_EX = '0'))
			report "unexpected decoding for I-type XORI";

		OPCODE	<= OPCODE_SLLI;

		wait for WAIT_TIME;

		assert ((TAKEN = '0') AND (IMM_SIGN = '0') AND
				(ALUOP = FUNC_SLL) AND
				(SEL_B_IMM = '1') AND (STR = "00") AND
				(SEL_DST = DST_IMM) AND (A_NEEDED_ID = '0') AND
				(A_NEEDED_EX = '1') AND (B_NEEDED_EX = '0'))
			report "unexpected decoding for I-type SLLI";

		OPCODE	<= OPCODE_SRLI;

		wait for WAIT_TIME;

		assert ((TAKEN = '0') AND (IMM_SIGN = '0') AND
				(ALUOP = FUNC_SRL) AND
				(SEL_B_IMM = '1') AND (STR = "00") AND
				(SEL_DST = DST_IMM) AND (A_NEEDED_ID = '0') AND
				(A_NEEDED_EX = '1') AND (B_NEEDED_EX = '0'))
			report "unexpected decoding for I-type SRLI";

		OPCODE	<= OPCODE_SRAI;

		wait for WAIT_TIME;

		assert ((TAKEN = '0') AND (IMM_SIGN = '0') AND
				(ALUOP = FUNC_SRA) AND
				(SEL_B_IMM = '1') AND (STR = "00") AND
				(SEL_DST = DST_IMM) AND (A_NEEDED_ID = '0') AND
				(A_NEEDED_EX = '1') AND (B_NEEDED_EX = '0'))
			report "unexpected decoding for I-type SRAI";

		OPCODE	<= OPCODE_SEQI;

		wait for WAIT_TIME;

		assert ((TAKEN = '0') AND (IMM_SIGN = '1') AND
				(ALUOP = FUNC_SEQ) AND
				(SEL_B_IMM = '1') AND (STR = "00") AND
				(SEL_DST = DST_IMM) AND (A_NEEDED_ID = '0') AND
				(A_NEEDED_EX = '1') AND (B_NEEDED_EX = '0'))
			report "unexpected decoding for I-type SEQI";

		OPCODE	<= OPCODE_SNEI;

		wait for WAIT_TIME;

		assert ((TAKEN = '0') AND (IMM_SIGN = '1') AND
				(ALUOP = FUNC_SNE) AND
				(SEL_B_IMM = '1') AND (STR = "00") AND
				(SEL_DST = DST_IMM) AND (A_NEEDED_ID = '0') AND
				(A_NEEDED_EX = '1') AND (B_NEEDED_EX = '0'))
			report "unexpected decoding for I-type SNEI";

		OPCODE	<= OPCODE_SLTI;

		wait for WAIT_TIME;

		assert ((TAKEN = '0') AND (IMM_SIGN = '1') AND
				(ALUOP = FUNC_SLT) AND
				(SEL_B_IMM = '1') AND (STR = "00") AND
				(SEL_DST = DST_IMM) AND (A_NEEDED_ID = '0') AND
				(A_NEEDED_EX = '1') AND (B_NEEDED_EX = '0'))
			report "unexpected decoding for I-type SLTI";

		OPCODE	<= OPCODE_SGTI;

		wait for WAIT_TIME;

		assert ((TAKEN = '0') AND (IMM_SIGN = '1') AND
				(ALUOP = FUNC_SGT) AND
				(SEL_B_IMM = '1') AND (STR = "00") AND
				(SEL_DST = DST_IMM) AND (A_NEEDED_ID = '0') AND
				(A_NEEDED_EX = '1') AND (B_NEEDED_EX = '0'))
			report "unexpected decoding for I-type SGTI";

		OPCODE	<= OPCODE_SLEI;

		wait for WAIT_TIME;

		assert ((TAKEN = '0') AND (IMM_SIGN = '1') AND
				(ALUOP = FUNC_SLE) AND
				(SEL_B_IMM = '1') AND (STR = "00") AND
				(SEL_DST = DST_IMM) AND (A_NEEDED_ID = '0') AND
				(A_NEEDED_EX = '1') AND (B_NEEDED_EX = '0'))
			report "unexpected decoding for I-type SLE";

		OPCODE	<= OPCODE_SGEI;

		wait for WAIT_TIME;

		assert ((TAKEN = '0') AND (IMM_SIGN = '1') AND
				(ALUOP = FUNC_SGE) AND
				(SEL_B_IMM = '1') AND (STR = "00") AND
				(SEL_DST = DST_IMM) AND (A_NEEDED_ID = '0') AND
				(A_NEEDED_EX = '1') AND (B_NEEDED_EX = '0'))
			report "unexpected decoding for I-type SGEI";

		OPCODE	<= OPCODE_SLTUI;

		wait for WAIT_TIME;

		assert ((TAKEN = '0') AND (IMM_SIGN = '0') AND
				(ALUOP = FUNC_SLTU) AND
				(SEL_B_IMM = '1') AND (STR = "00") AND
				(SEL_DST = DST_IMM) AND (A_NEEDED_ID = '0') AND
				(A_NEEDED_EX = '1') AND (B_NEEDED_EX = '0'))
			report "unexpected decoding for I-type SLTUI";

		OPCODE	<= OPCODE_SGTUI;

		wait for WAIT_TIME;

		assert ((TAKEN = '0') AND (IMM_SIGN = '0') AND
				(ALUOP = FUNC_SGTU) AND
				(SEL_B_IMM = '1') AND (STR = "00") AND
				(SEL_DST = DST_IMM) AND (A_NEEDED_ID = '0') AND
				(A_NEEDED_EX = '1') AND (B_NEEDED_EX = '0'))
			report "unexpected decoding for I-type SGTUI";

		OPCODE	<= OPCODE_SLEUI;

		wait for WAIT_TIME;

		assert ((TAKEN = '0') AND (IMM_SIGN = '0') AND
				(ALUOP = FUNC_SLEU) AND
				(SEL_B_IMM = '1') AND (STR = "00") AND
				(SEL_DST = DST_IMM) AND (A_NEEDED_ID = '0') AND
				(A_NEEDED_EX = '1') AND (B_NEEDED_EX = '0'))
			report "unexpected decoding for I-type SLEU";

		OPCODE	<= OPCODE_SGEUI;

		wait for WAIT_TIME;

		assert ((TAKEN = '0') AND (IMM_SIGN = '0') AND
				(ALUOP = FUNC_SGEU) AND
				(SEL_B_IMM = '1') AND (STR = "00") AND
				(SEL_DST = DST_IMM) AND (A_NEEDED_ID = '0') AND
				(A_NEEDED_EX = '1') AND (B_NEEDED_EX = '0'))
			report "unexpected decoding for I-type SGEUI";

		OPCODE	<= OPCODE_LB;

		wait for WAIT_TIME;

		assert ((TAKEN = '0') AND (IMM_SIGN = '1') AND
				((ALUOP = FUNC_ADD) OR (ALUOP = FUNC_ADDU)) AND
				(SEL_B_IMM = '1') AND
				(LD = "01") AND (LD_SIGN = '1') AND
				(STR = "00") AND
				(SEL_DST = DST_IMM) AND (A_NEEDED_ID = '0') AND
				(A_NEEDED_EX = '1') AND (B_NEEDED_EX = '0'))
			report "unexpected decoding for I-type LB";

		OPCODE	<= OPCODE_LH;

		wait for WAIT_TIME;

		assert ((TAKEN = '0') AND (IMM_SIGN = '1') AND
				((ALUOP = FUNC_ADD) OR (ALUOP = FUNC_ADDU)) AND
				(SEL_B_IMM = '1') AND
				(LD = "10") AND (LD_SIGN = '1') AND
				(STR = "00") AND
				(SEL_DST = DST_IMM) AND (A_NEEDED_ID = '0') AND
				(A_NEEDED_EX = '1') AND (B_NEEDED_EX = '0'))
			report "unexpected decoding for I-type LH";

		OPCODE	<= OPCODE_LW;

		wait for WAIT_TIME;

		assert ((TAKEN = '0') AND (IMM_SIGN = '1') AND
				((ALUOP = FUNC_ADD) OR (ALUOP = FUNC_ADDU)) AND
				(SEL_B_IMM = '1') AND
				(LD = "11") AND (STR = "00") AND
				(SEL_DST = DST_IMM) AND (A_NEEDED_ID = '0') AND
				(A_NEEDED_EX = '1') AND (B_NEEDED_EX = '0'))
			report "unexpected decoding for I-type LW";

		OPCODE	<= OPCODE_LBU;

		wait for WAIT_TIME;

		assert ((TAKEN = '0') AND (IMM_SIGN = '1') AND
				((ALUOP = FUNC_ADD) OR (ALUOP = FUNC_ADDU)) AND
				(SEL_B_IMM = '1') AND
				(LD = "01") AND (LD_SIGN = '0') AND
				(STR = "00") AND
				(SEL_DST = DST_IMM) AND (A_NEEDED_ID = '0') AND
				(A_NEEDED_EX = '1') AND (B_NEEDED_EX = '0'))
			report "unexpected decoding for I-type LBU";

		OPCODE	<= OPCODE_LHU;

		wait for WAIT_TIME;

		assert ((TAKEN = '0') AND (IMM_SIGN = '1') AND
				((ALUOP = FUNC_ADD) OR (ALUOP = FUNC_ADDU)) AND
				(SEL_B_IMM = '1') AND
				(LD = "10") AND (LD_SIGN = '0') AND
				(STR = "00") AND
				(SEL_DST = DST_IMM) AND (A_NEEDED_ID = '0') AND
				(A_NEEDED_EX = '1') AND (B_NEEDED_EX = '0'))
			report "unexpected decoding for I-type LHU";

		OPCODE	<= OPCODE_SB;

		wait for WAIT_TIME;

		assert ((TAKEN = '0') AND (IMM_SIGN = '1') AND
				((ALUOP = FUNC_ADD) OR (ALUOP = FUNC_ADDU)) AND
				(SEL_B_IMM = '1') AND
				(LD = "00") AND (STR = "01") AND
				(SEL_DST = DST_NO) AND (A_NEEDED_ID = '0') AND
				(A_NEEDED_EX = '1') AND (B_NEEDED_EX = '0'))
			report "unexpected decoding for I-type SB";

		OPCODE	<= OPCODE_SH;

		wait for WAIT_TIME;

		assert ((TAKEN = '0') AND (IMM_SIGN = '1') AND
				((ALUOP = FUNC_ADD) OR (ALUOP = FUNC_ADDU)) AND
				(SEL_B_IMM = '1') AND
				(LD = "00") AND (STR = "10") AND
				(SEL_DST = DST_NO) AND (A_NEEDED_ID = '0') AND
				(A_NEEDED_EX = '1') AND (B_NEEDED_EX = '0'))
			report "unexpected decoding for I-type SH";

		OPCODE	<= OPCODE_SW;

		wait for WAIT_TIME;

		assert ((TAKEN = '0') AND (IMM_SIGN = '1') AND
				((ALUOP = FUNC_ADD) OR (ALUOP = FUNC_ADDU)) AND
				(SEL_B_IMM = '1') AND
				(LD = "00") AND (STR = "11") AND
				(SEL_DST = DST_NO) AND (A_NEEDED_ID = '0') AND
				(A_NEEDED_EX = '1') AND (B_NEEDED_EX = '0'))
			report "unexpected decoding for I-type SW";

		OPCODE	<= OPCODE_NOP;

		wait for WAIT_TIME;

		assert ((TAKEN = '0') AND (STR = "00") AND (SEL_DST = DST_NO) AND
				(A_NEEDED_ID = '0') AND (A_NEEDED_EX = '0') AND
				(B_NEEDED_EX = '0'))
			report "unexpected decoding for I-type NOP";

		-- test J-type instructions decoding

		FUNC	<= (others => '0');
		ZERO	<= '0';

		OPCODE	<= OPCODE_J;

		wait for WAIT_TIME;

		assert ((TAKEN = '1') AND (SEL_JMP = JMP_REL_OFF) AND
				(STR = "00") AND (SEL_DST = DST_NO) AND
				(A_NEEDED_ID = '0') AND (A_NEEDED_EX = '0') AND
				(B_NEEDED_EX = '0'))
			report "unexpected decoding for J-type J";

		OPCODE	<= OPCODE_JAL;

		wait for WAIT_TIME;

		assert ((TAKEN = '1') AND (SEL_JMP = JMP_REL_OFF) AND
				(ALUOP = FUNC_LINK) AND
				(STR = "00") AND (SEL_DST = DST_LINK) AND
				(A_NEEDED_ID = '0') AND (A_NEEDED_EX = '0') AND
				(B_NEEDED_EX = '0'))
			report "unexpected decoding for J-type JAL";

		OPCODE	<= OPCODE_JR;

		wait for WAIT_TIME;

		assert ((TAKEN = '1') AND (SEL_JMP = JMP_ABS) AND
				(STR = "00") AND (SEL_DST = DST_NO) AND
				(A_NEEDED_ID = '1') AND (A_NEEDED_EX = '0') AND
				(B_NEEDED_EX = '0'))
			report "unexpected decoding for J-type JR";

		OPCODE	<= OPCODE_JALR;

		wait for WAIT_TIME;

		assert ((TAKEN = '1') AND (SEL_JMP = JMP_ABS) AND
				(ALUOP = FUNC_LINK) AND
				(STR = "00") AND (SEL_DST = DST_LINK) AND
				(A_NEEDED_ID = '1') AND (A_NEEDED_EX = '0') AND
				(B_NEEDED_EX = '0'))
			report "unexpected decoding for J-type JALR";

		wait;
	end process stimuli;
end TB_ARCH;

