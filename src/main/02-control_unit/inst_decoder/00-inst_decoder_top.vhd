library IEEE;
use IEEE.std_logic_1164.all;
use work.coding.all;
use work.types.all;

-- inst_decoder: generate all ctrl signals for current instruction
entity inst_decoder is
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
end inst_decoder;

architecture BEHAVIORAL of inst_decoder is
begin
	process (I_FUNC, I_OPCODE, I_ZERO)
	begin
		case I_OPCODE is
			when OPCODE_RTYPE | OPCODE_FRTYPE	=>
				O_TAKEN		<= '0';
				O_SEL_JMP	<= JMP_REL_IMM;	-- not meaningful
				O_IMM_SIGN	<= '0';		-- not meaningful
				O_ALUOP		<= I_FUNC;
				O_SEL_B_IMM	<= '0';		-- B
				O_LD		<= "00";	-- no load
				O_LD_SIGN	<= '0';		-- not meaningful
				O_STR		<= "00";	-- no store
				O_SEL_DST	<= DST_REG;
				O_A_NEEDED_ID	<= '0';
				O_A_NEEDED_EX	<= '1';
				O_B_NEEDED_EX	<= '1';
			when OPCODE_ADDI	=>
				O_TAKEN		<= '0';
				O_SEL_JMP	<= JMP_REL_IMM;	-- not meaningful
				O_IMM_SIGN	<= '1';		-- signed
				O_ALUOP		<= FUNC_ADD;
				O_SEL_B_IMM	<= '1';		-- IMM
				O_LD		<= "00";	-- no load
				O_LD_SIGN	<= '0';		-- not meaningful
				O_STR		<= "00";	-- no store
				O_SEL_DST	<= DST_IMM;
				O_A_NEEDED_ID	<= '0';
				O_A_NEEDED_EX	<= '1';
				O_B_NEEDED_EX	<= '0';
			when OPCODE_ADDUI	=>
				O_TAKEN		<= '0';
				O_SEL_JMP	<= JMP_REL_IMM;	-- not meaningful
				O_IMM_SIGN	<= '0';		-- unsigned
				O_ALUOP		<= FUNC_ADD;
				O_SEL_B_IMM	<= '1';		-- IMM
				O_LD		<= "00";	-- no load
				O_LD_SIGN	<= '0';		-- not meaningful
				O_STR		<= "00";	-- no store
				O_SEL_DST	<= DST_IMM;
				O_A_NEEDED_ID	<= '0';
				O_A_NEEDED_EX	<= '1';
				O_B_NEEDED_EX	<= '0';
			when OPCODE_SUBI	=>
				O_TAKEN		<= '0';
				O_SEL_JMP	<= JMP_REL_IMM;	-- not meaningful
				O_IMM_SIGN	<= '1';		-- signed
				O_ALUOP		<= FUNC_SUB;
				O_SEL_B_IMM	<= '1';		-- IMM
				O_LD		<= "00";	-- no load
				O_LD_SIGN	<= '0';		-- not meaningful
				O_STR		<= "00";	-- no store
				O_SEL_DST	<= DST_IMM;
				O_A_NEEDED_ID	<= '0';
				O_A_NEEDED_EX	<= '1';
				O_B_NEEDED_EX	<= '0';
			when OPCODE_SUBUI	=>
				O_TAKEN		<= '0';
				O_SEL_JMP	<= JMP_REL_IMM;	-- not meaningful
				O_IMM_SIGN	<= '0';		-- unsigned
				O_ALUOP		<= FUNC_SUB;
				O_SEL_B_IMM	<= '1';		-- IMM
				O_LD		<= "00";	-- no load
				O_LD_SIGN	<= '0';		-- not meaningful
				O_STR		<= "00";	-- no store
				O_SEL_DST	<= DST_IMM;
				O_A_NEEDED_ID	<= '0';
				O_A_NEEDED_EX	<= '1';
				O_B_NEEDED_EX	<= '0';
			when OPCODE_ANDI	=>
				O_TAKEN		<= '0';
				O_SEL_JMP	<= JMP_REL_IMM;	-- not meaningful
				O_IMM_SIGN	<= '0';		-- unsigned
				O_ALUOP		<= FUNC_AND;
				O_SEL_B_IMM	<= '1';		-- IMM
				O_LD		<= "00";	-- no load
				O_LD_SIGN	<= '0';		-- not meaningful
				O_STR		<= "00";	-- no store
				O_SEL_DST	<= DST_IMM;
				O_A_NEEDED_ID	<= '0';
				O_A_NEEDED_EX	<= '1';
				O_B_NEEDED_EX	<= '0';
			when OPCODE_ORI		=>
				O_TAKEN		<= '0';
				O_SEL_JMP	<= JMP_REL_IMM;	-- not meaningful
				O_IMM_SIGN	<= '0';		-- unsigned
				O_ALUOP		<= FUNC_OR;
				O_SEL_B_IMM	<= '1';		-- IMM
				O_LD		<= "00";	-- no load
				O_LD_SIGN	<= '0';		-- not meaningful
				O_STR		<= "00";	-- no store
				O_SEL_DST	<= DST_IMM;
				O_A_NEEDED_ID	<= '0';
				O_A_NEEDED_EX	<= '1';
				O_B_NEEDED_EX	<= '0';
			when OPCODE_XORI	=>
				O_TAKEN		<= '0';
				O_SEL_JMP	<= JMP_REL_IMM;	-- not meaningful
				O_IMM_SIGN	<= '0';		-- unsigned
				O_ALUOP		<= FUNC_XOR;
				O_SEL_B_IMM	<= '1';		-- IMM
				O_LD		<= "00";	-- no load
				O_LD_SIGN	<= '0';		-- not meaningful
				O_STR		<= "00";	-- no store
				O_SEL_DST	<= DST_IMM;
				O_A_NEEDED_ID	<= '0';
				O_A_NEEDED_EX	<= '1';
				O_B_NEEDED_EX	<= '0';
			when OPCODE_SLLI	=>
				O_TAKEN		<= '0';
				O_SEL_JMP	<= JMP_REL_IMM;	-- not meaningful
				O_IMM_SIGN	<= '0';		-- unsigned
				O_ALUOP		<= FUNC_SLL;
				O_SEL_B_IMM	<= '1';		-- IMM
				O_LD		<= "00";	-- no load
				O_LD_SIGN	<= '0';		-- not meaningful
				O_STR		<= "00";	-- no store
				O_SEL_DST	<= DST_IMM;
				O_A_NEEDED_ID	<= '0';
				O_A_NEEDED_EX	<= '1';
				O_B_NEEDED_EX	<= '0';
			when OPCODE_SRLI	=>
				O_TAKEN		<= '0';
				O_SEL_JMP	<= JMP_REL_IMM;	-- not meaningful
				O_IMM_SIGN	<= '0';		-- unsigned
				O_ALUOP		<= FUNC_SRL;
				O_SEL_B_IMM	<= '1';		-- IMM
				O_LD		<= "00";	-- no load
				O_LD_SIGN	<= '0';		-- not meaningful
				O_STR		<= "00";	-- no store
				O_SEL_DST	<= DST_IMM;
				O_A_NEEDED_ID	<= '0';
				O_A_NEEDED_EX	<= '1';
				O_B_NEEDED_EX	<= '0';
			when OPCODE_SRAI	=>
				O_TAKEN		<= '0';
				O_SEL_JMP	<= JMP_REL_IMM;	-- not meaningful
				O_IMM_SIGN	<= '0';		-- unsigned
				O_ALUOP		<= FUNC_SRA;
				O_SEL_B_IMM	<= '1';		-- IMM
				O_LD		<= "00";	-- no load
				O_LD_SIGN	<= '0';		-- not meaningful
				O_STR		<= "00";	-- no store
				O_SEL_DST	<= DST_IMM;
				O_A_NEEDED_ID	<= '0';
				O_A_NEEDED_EX	<= '1';
				O_B_NEEDED_EX	<= '0';
			when OPCODE_SEQI	=>
				O_TAKEN		<= '0';
				O_SEL_JMP	<= JMP_REL_IMM;	-- not meaningful
				O_IMM_SIGN	<= '1';		-- signed
				O_ALUOP		<= FUNC_SEQ;
				O_SEL_B_IMM	<= '1';		-- IMM
				O_LD		<= "00";	-- no load
				O_LD_SIGN	<= '0';		-- not meaningful
				O_STR		<= "00";	-- no store
				O_SEL_DST	<= DST_IMM;
				O_A_NEEDED_ID	<= '0';
				O_A_NEEDED_EX	<= '1';
				O_B_NEEDED_EX	<= '0';
			when OPCODE_SNEI	=>
				O_TAKEN		<= '0';
				O_SEL_JMP	<= JMP_REL_IMM;	-- not meaningful
				O_IMM_SIGN	<= '1';		-- signed
				O_ALUOP		<= FUNC_SNE;
				O_SEL_B_IMM	<= '1';		-- IMM
				O_LD		<= "00";	-- no load
				O_LD_SIGN	<= '0';		-- not meaningful
				O_STR		<= "00";	-- no store
				O_SEL_DST	<= DST_IMM;
				O_A_NEEDED_ID	<= '0';
				O_A_NEEDED_EX	<= '1';
				O_B_NEEDED_EX	<= '0';
			when OPCODE_SLTI	=>
				O_TAKEN		<= '0';
				O_SEL_JMP	<= JMP_REL_IMM;	-- not meaningful
				O_IMM_SIGN	<= '1';		-- signed
				O_ALUOP		<= FUNC_SLT;
				O_SEL_B_IMM	<= '1';		-- IMM
				O_LD		<= "00";	-- no load
				O_LD_SIGN	<= '0';		-- not meaningful
				O_STR		<= "00";	-- no store
				O_SEL_DST	<= DST_IMM;
				O_A_NEEDED_ID	<= '0';
				O_A_NEEDED_EX	<= '1';
				O_B_NEEDED_EX	<= '0';
			when OPCODE_SGTI	=>
				O_TAKEN		<= '0';
				O_SEL_JMP	<= JMP_REL_IMM;	-- not meaningful
				O_IMM_SIGN	<= '1';		-- signed
				O_ALUOP		<= FUNC_SGT;
				O_SEL_B_IMM	<= '1';		-- IMM
				O_LD		<= "00";	-- no load
				O_LD_SIGN	<= '0';		-- not meaningful
				O_STR		<= "00";	-- no store
				O_SEL_DST	<= DST_IMM;
				O_A_NEEDED_ID	<= '0';
				O_A_NEEDED_EX	<= '1';
				O_B_NEEDED_EX	<= '0';
			when OPCODE_SLEI	=>
				O_TAKEN		<= '0';
				O_SEL_JMP	<= JMP_REL_IMM;	-- not meaningful
				O_IMM_SIGN	<= '1';		-- signed
				O_ALUOP		<= FUNC_SLE;
				O_SEL_B_IMM	<= '1';		-- IMM
				O_LD		<= "00";	-- no load
				O_LD_SIGN	<= '0';		-- not meaningful
				O_STR		<= "00";	-- no store
				O_SEL_DST	<= DST_IMM;
				O_A_NEEDED_ID	<= '0';
				O_A_NEEDED_EX	<= '1';
				O_B_NEEDED_EX	<= '0';
			when OPCODE_SGEI	=>
				O_TAKEN		<= '0';
				O_SEL_JMP	<= JMP_REL_IMM;	-- not meaningful
				O_IMM_SIGN	<= '1';		-- signed
				O_ALUOP		<= FUNC_SGE;
				O_SEL_B_IMM	<= '1';		-- IMM
				O_LD		<= "00";	-- no load
				O_LD_SIGN	<= '0';		-- not meaningful
				O_STR		<= "00";	-- no store
				O_SEL_DST	<= DST_IMM;
				O_A_NEEDED_ID	<= '0';
				O_A_NEEDED_EX	<= '1';
				O_B_NEEDED_EX	<= '0';
			when OPCODE_SLTUI	=>
				O_TAKEN		<= '0';
				O_SEL_JMP	<= JMP_REL_IMM;	-- not meaningful
				O_IMM_SIGN	<= '0';		-- unsigned
				O_ALUOP		<= FUNC_SLTU;
				O_SEL_B_IMM	<= '1';		-- IMM
				O_LD		<= "00";	-- no load
				O_LD_SIGN	<= '0';		-- not meaningful
				O_STR		<= "00";	-- no store
				O_SEL_DST	<= DST_IMM;
				O_A_NEEDED_ID	<= '0';
				O_A_NEEDED_EX	<= '1';
				O_B_NEEDED_EX	<= '0';
			when OPCODE_SGTUI	=>
				O_TAKEN		<= '0';
				O_SEL_JMP	<= JMP_REL_IMM;	-- not meaningful
				O_IMM_SIGN	<= '0';		-- unsigned
				O_ALUOP		<= FUNC_SGTU;
				O_SEL_B_IMM	<= '1';		-- IMM
				O_LD		<= "00";	-- no load
				O_LD_SIGN	<= '0';		-- not meaningful
				O_STR		<= "00";	-- no store
				O_SEL_DST	<= DST_IMM;
				O_A_NEEDED_ID	<= '0';
				O_A_NEEDED_EX	<= '1';
				O_B_NEEDED_EX	<= '0';
			when OPCODE_SLEUI	=>
				O_TAKEN		<= '0';
				O_SEL_JMP	<= JMP_REL_IMM;	-- not meaningful
				O_IMM_SIGN	<= '0';		-- unsigned
				O_ALUOP		<= FUNC_SLEU;
				O_SEL_B_IMM	<= '1';		-- IMM
				O_LD		<= "00";	-- no load
				O_LD_SIGN	<= '0';		-- not meaningful
				O_STR		<= "00";	-- no store
				O_SEL_DST	<= DST_IMM;
				O_A_NEEDED_ID	<= '0';
				O_A_NEEDED_EX	<= '1';
				O_B_NEEDED_EX	<= '0';
			when OPCODE_SGEUI	=>
				O_TAKEN		<= '0';
				O_SEL_JMP	<= JMP_REL_IMM;	-- not meaningful
				O_IMM_SIGN	<= '0';		-- unsigned
				O_ALUOP		<= FUNC_SGEU;
				O_SEL_B_IMM	<= '1';		-- IMM
				O_LD		<= "00";	-- no load
				O_LD_SIGN	<= '0';		-- not meaningful
				O_STR		<= "00";	-- no store
				O_SEL_DST	<= DST_IMM;
				O_A_NEEDED_ID	<= '0';
				O_A_NEEDED_EX	<= '1';
				O_B_NEEDED_EX	<= '0';

			-- Load & store instructions (register-immediate instructions subset)
			when OPCODE_LB		=>
				O_TAKEN		<= '0';
				O_SEL_JMP	<= JMP_REL_IMM;	-- not meaningful
				O_IMM_SIGN	<= '1';		-- signed
				O_ALUOP		<= FUNC_ADD;
				O_SEL_B_IMM	<= '1';		-- IMM
				O_LD		<= "01";	-- load byte
				O_LD_SIGN	<= '1';		-- signed
				O_STR		<= "00";	-- no store
				O_SEL_DST	<= DST_IMM;
				O_A_NEEDED_ID	<= '0';
				O_A_NEEDED_EX	<= '1';
				O_B_NEEDED_EX	<= '0';
			when OPCODE_LBU		=>
				O_TAKEN		<= '0';
				O_SEL_JMP	<= JMP_REL_IMM;	-- not meaningful
				O_IMM_SIGN	<= '1';		-- signed
				O_ALUOP		<= FUNC_ADD;
				O_SEL_B_IMM	<= '1';		-- IMM
				O_LD		<= "01";	-- load byte
				O_LD_SIGN	<= '0';		-- unsigned
				O_STR		<= "00";	-- no store
				O_SEL_DST	<= DST_IMM;
				O_A_NEEDED_ID	<= '0';
				O_A_NEEDED_EX	<= '1';
				O_B_NEEDED_EX	<= '0';
			when OPCODE_LH		=>
				O_TAKEN		<= '0';
				O_SEL_JMP	<= JMP_REL_IMM;	-- not meaningful
				O_IMM_SIGN	<= '1';		-- signed
				O_ALUOP		<= FUNC_ADD;
				O_SEL_B_IMM	<= '1';		-- IMM
				O_LD		<= "10";	-- load half word
				O_LD_SIGN	<= '1';		-- signed
				O_STR		<= "00";	-- no store
				O_SEL_DST	<= DST_IMM;
				O_A_NEEDED_ID	<= '0';
				O_A_NEEDED_EX	<= '1';
				O_B_NEEDED_EX	<= '0';
			when OPCODE_LHU		=>
				O_TAKEN		<= '0';
				O_SEL_JMP	<= JMP_REL_IMM;	-- not meaningful
				O_IMM_SIGN	<= '1';		-- signed
				O_ALUOP		<= FUNC_ADD;
				O_SEL_B_IMM	<= '1';		-- IMM
				O_LD		<= "10";	-- load half word
				O_LD_SIGN	<= '0';		-- unsigned
				O_STR		<= "00";	-- no store
				O_SEL_DST	<= DST_IMM;
				O_A_NEEDED_ID	<= '0';
				O_A_NEEDED_EX	<= '1';
				O_B_NEEDED_EX	<= '0';
			when OPCODE_LW		=>
				O_TAKEN		<= '0';
				O_SEL_JMP	<= JMP_REL_IMM;	-- not meaningful
				O_IMM_SIGN	<= '1';		-- signed
				O_ALUOP		<= FUNC_ADD;
				O_SEL_B_IMM	<= '1';		-- IMM
				O_LD		<= "11";	-- load word
				O_LD_SIGN	<= '0';		-- not meaningful
				O_STR		<= "00";	-- no store
				O_SEL_DST	<= DST_IMM;
				O_A_NEEDED_ID	<= '0';
				O_A_NEEDED_EX	<= '1';
				O_B_NEEDED_EX	<= '0';
			when OPCODE_SB		=>
				O_TAKEN		<= '0';
				O_SEL_JMP	<= JMP_REL_IMM;	-- not meaningful
				O_IMM_SIGN	<= '1';		-- signed
				O_ALUOP		<= FUNC_ADD;
				O_SEL_B_IMM	<= '1';		-- IMM
				O_LD		<= "00";	-- no load
				O_LD_SIGN	<= '0';		-- not meaningful
				O_STR		<= "01";	-- store byte
				O_SEL_DST	<= DST_NO;
				O_A_NEEDED_ID	<= '0';
				O_A_NEEDED_EX	<= '1';
				O_B_NEEDED_EX	<= '0';
			when OPCODE_SH		=>
				O_TAKEN		<= '0';
				O_SEL_JMP	<= JMP_REL_IMM;	-- not meaningful
				O_IMM_SIGN	<= '1';		-- signed
				O_ALUOP		<= FUNC_ADD;
				O_SEL_B_IMM	<= '1';		-- IMM
				O_LD		<= "00";	-- no load
				O_LD_SIGN	<= '0';		-- not meaningful
				O_STR		<= "10";	-- store half word
				O_SEL_DST	<= DST_NO;
				O_A_NEEDED_ID	<= '0';
				O_A_NEEDED_EX	<= '1';
				O_B_NEEDED_EX	<= '0';
			when OPCODE_SW		=>
				O_TAKEN		<= '0';
				O_SEL_JMP	<= JMP_REL_IMM;	-- not meaningful
				O_IMM_SIGN	<= '1';		-- signed
				O_ALUOP		<= FUNC_ADD;
				O_SEL_B_IMM	<= '1';		-- IMM
				O_LD		<= "00";	-- no load
				O_LD_SIGN	<= '0';		-- not meaningful
				O_STR		<= "11";	-- store word
				O_SEL_DST	<= DST_NO;
				O_A_NEEDED_ID	<= '0';
				O_A_NEEDED_EX	<= '1';
				O_B_NEEDED_EX	<= '0';

			-- Jump/branch instructions
			when OPCODE_BEQZ	=>
				O_TAKEN		<= I_ZERO;
				O_SEL_JMP	<= JMP_REL_IMM;
				O_IMM_SIGN	<= '1';		-- signed
				O_ALUOP		<= FUNC_ADD;	-- not meaningful
				O_SEL_B_IMM	<= '1';		-- IMM
				O_LD		<= "00";	-- no load
				O_LD_SIGN	<= '0';		-- not meaningful
				O_STR		<= "00";	-- no store
				O_SEL_DST	<= DST_NO;
				O_A_NEEDED_ID	<= '1';
				O_A_NEEDED_EX	<= '0';
				O_B_NEEDED_EX	<= '0';
			when OPCODE_BNEZ	=>
				O_TAKEN		<= (NOT I_ZERO);
				O_SEL_JMP	<= JMP_REL_IMM;
				O_IMM_SIGN	<= '1';		-- signed
				O_ALUOP		<= FUNC_ADD;	-- not meaningful
				O_SEL_B_IMM	<= '1';		-- not meaningful
				O_LD		<= "00";	-- no load
				O_LD_SIGN	<= '0';		-- not meaningful
				O_STR		<= "00";	-- no store
				O_SEL_DST	<= DST_NO;
				O_A_NEEDED_ID	<= '1';
				O_A_NEEDED_EX	<= '0';
				O_B_NEEDED_EX	<= '0';
			when OPCODE_J		=>
				O_TAKEN		<= '1';
				O_SEL_JMP	<= JMP_REL_OFF;
				O_IMM_SIGN	<= '0';		-- not meaningful
				O_ALUOP		<= FUNC_ADD;	-- not meaningful
				O_SEL_B_IMM	<= '1';		-- not meaningful
				O_LD		<= "00";	-- no load
				O_LD_SIGN	<= '0';		-- not meaningful
				O_STR		<= "00";	-- no store
				O_SEL_DST	<= DST_NO;
				O_A_NEEDED_ID	<= '0';
				O_A_NEEDED_EX	<= '0';
				O_B_NEEDED_EX	<= '0';
			when OPCODE_JAL		=>
				O_TAKEN		<= '1';
				O_SEL_JMP	<= JMP_REL_OFF;
				O_IMM_SIGN	<= '0';		-- not meaningful
				O_ALUOP		<= FUNC_LINK;
				O_SEL_B_IMM	<= '1';		-- not meaningful
				O_LD		<= "00";	-- no load
				O_LD_SIGN	<= '0';		-- not meaningful
				O_STR		<= "00";	-- no store
				O_SEL_DST	<= DST_LINK;	-- write to R31
				O_A_NEEDED_ID	<= '0';
				O_A_NEEDED_EX	<= '0';
				O_B_NEEDED_EX	<= '0';
			when OPCODE_JR		=>
				O_TAKEN		<= '1';
				O_SEL_JMP	<= JMP_ABS;
				O_IMM_SIGN	<= '0';		-- not meaningful
				O_ALUOP		<= FUNC_ADD;	-- not meaningful
				O_SEL_B_IMM	<= '1';		-- not meaningful
				O_LD		<= "00";	-- no load
				O_LD_SIGN	<= '0';		-- not meaningful
				O_STR		<= "00";	-- no store
				O_SEL_DST	<= DST_NO;	-- no writeback
				O_A_NEEDED_ID	<= '1';
				O_A_NEEDED_EX	<= '0';
				O_B_NEEDED_EX	<= '0';
			when OPCODE_JALR	=>
				O_TAKEN		<= '1';
				O_SEL_JMP	<= JMP_ABS;
				O_IMM_SIGN	<= '0';		-- not meaningful
				O_ALUOP		<= FUNC_LINK;
				O_SEL_B_IMM	<= '1';		-- not meaningful
				O_LD		<= "00";	-- no load
				O_LD_SIGN	<= '0';		-- not meaningful
				O_STR		<= "00";	-- no store
				O_SEL_DST	<= DST_LINK;	-- write to R31
				O_A_NEEDED_ID	<= '1';
				O_A_NEEDED_EX	<= '0';
				O_B_NEEDED_EX	<= '0';

			-- General instructions
			when others		=>
				-- NOP and unsupported instructions
				O_TAKEN		<= '0';
				O_SEL_JMP	<= JMP_REL_IMM;	-- not meaningful
				O_IMM_SIGN	<= '0';		-- not meaningful
				O_ALUOP		<= FUNC_ADD;	-- not meaningful
				O_SEL_B_IMM	<= '1';		-- not meaningful
				O_LD		<= "00";	-- no load
				O_LD_SIGN	<= '0';		-- not meaningful
				O_STR		<= "00";	-- no store
				O_SEL_DST	<= DST_NO;	-- no write
				O_A_NEEDED_ID	<= '0';
				O_A_NEEDED_EX	<= '0';
				O_B_NEEDED_EX	<= '0';
		end case;
	end process;
end BEHAVIORAL;

