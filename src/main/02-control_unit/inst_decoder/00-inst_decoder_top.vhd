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
		I_DST_R:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
		I_DST_I:	in std_logic_vector(RF_ADDR_SZ - 1 downto 0);

		-- to ID stage
		O_BRANCH:	out branch_t;
		O_SIGNED:	out std_logic;

		-- to EX stage
		O_ALUOP:	out std_logic_vector(FUNC_SZ - 1 downto 0);
		O_SEL_B_IMM:	out std_logic;

		-- to MEM stage
		O_LD:		out std_logic_vector(1 downto 0);
		O_STR:		out std_logic_vector(1 downto 0);

		-- to WB stage
		O_DST:		out std_logic_vector(RF_ADDR_SZ - 1 downto 0);

		-- to CU
		O_INST_TYPE:	out inst_t
	);
end inst_decoder;

architecture BEHAVIORAL of inst_decoder is
begin
	process (I_FUNC, I_OPCODE, I_DST_R, I_DST_I)
	begin
		-- typical I-TYPE instruction as default values
		-- (since they are the most common instructions this
		-- just reduces inst_decoder code size)
		O_INST_TYPE	<= INST_IMM;
		O_SEL_B_IMM	<= '1';	-- IMM
		O_BRANCH	<= BR_NO;
		O_SIGNED	<= '1';	-- signed
		O_LD		<= "00"; -- no load
		O_STR		<= "00"; -- no store
		O_DST		<= I_DST_I;
		O_ALUOP		<= FUNC_ADD;
		case (I_OPCODE) is
			when OPCODE_RTYPE	=>
				O_INST_TYPE	<= INST_REG;
				O_SEL_B_IMM	<= '0';	-- B
				O_DST		<= I_DST_R;
				O_ALUOP		<= I_FUNC;
				-- O_SIGNED is used for data extension only:
				--	there is no need to specify it with
				--	R-type instructions
			when OPCODE_ADDI	=>
				O_ALUOP	<= FUNC_ADD;
			when OPCODE_ADDUI	=>
				O_SIGNED <= '0';
				O_ALUOP	<= FUNC_ADD;
			when OPCODE_SUBI	=>
				O_ALUOP	<= FUNC_SUB;
			when OPCODE_SUBUI	=>
				O_SIGNED <= '0';
				O_ALUOP	<= FUNC_SUB;
			when OPCODE_ANDI	=>
				O_SIGNED <= '0';
				O_ALUOP	<= FUNC_AND;
			when OPCODE_ORI		=>
				O_SIGNED <= '0';
				O_ALUOP	<= FUNC_OR;
			when OPCODE_XORI	=>
				O_SIGNED <= '0';
				O_ALUOP	<= FUNC_XOR;
			when OPCODE_SLLI	=>
				O_SIGNED <= '0';
				O_ALUOP	<= FUNC_SLL;
			when OPCODE_SRLI	=>
				O_SIGNED <= '0';
				O_ALUOP	<= FUNC_SRL;
			when OPCODE_SRAI	=>
				O_SIGNED <= '0';
				O_ALUOP	<= FUNC_SRA;
			when OPCODE_SEQI	=>
				O_ALUOP	<= FUNC_SEQ;
			when OPCODE_SNEI	=>
				O_ALUOP	<= FUNC_SNE;
			when OPCODE_SLTI	=>
				O_ALUOP	<= FUNC_SLT;
			when OPCODE_SGTI	=>
				O_ALUOP	<= FUNC_SGT;
			when OPCODE_SLEI	=>
				O_ALUOP	<= FUNC_SLE;
			when OPCODE_SGEI	=>
				O_ALUOP	<= FUNC_SGE;
			when OPCODE_SLTUI	=>
				O_ALUOP	<= FUNC_SLTU;
			when OPCODE_SGTUI	=>
				O_ALUOP	<= FUNC_SGTU;
			when OPCODE_SLEUI	=>
				O_ALUOP	<= FUNC_SLEU;
			when OPCODE_SGEUI	=>
				O_ALUOP	<= FUNC_SGEU;

			-- Load & store instructions (register-immediate instructions subset)
			when OPCODE_LB		=>
				O_LD		<= "01";	-- load byte
				O_SIGNED	<= '1';
				O_ALUOP		<= FUNC_ADD;
			when OPCODE_LBU		=>
				O_LD		<= "01";	-- load byte
				O_SIGNED	<= '0';
				O_ALUOP		<= FUNC_ADD;
			when OPCODE_LH		=>
				O_LD		<= "10";	-- load half word
				O_SIGNED	<= '1';
				O_ALUOP		<= FUNC_ADD;
			when OPCODE_LHU		=>
				O_LD		<= "10";	-- load half word
				O_SIGNED	<= '0';
				O_ALUOP		<= FUNC_ADD;
			when OPCODE_LW		=>
				O_LD		<= "11";	-- load word
				O_ALUOP		<= FUNC_ADD;
			when OPCODE_SB		=>
				O_DST		<= (others => '0');
				O_STR		<= "01";	-- store word
				O_ALUOP		<= FUNC_ADD;
			when OPCODE_SH		=>
				O_DST		<= (others => '0');
				O_STR		<= "10";	-- store word
				O_ALUOP		<= FUNC_ADD;
			when OPCODE_SW		=>
				O_DST		<= (others => '0');
				O_STR		<= "11";	-- store word
				O_ALUOP		<= FUNC_ADD;

			-- Jump/branch instructions
			when OPCODE_J		=>
				O_INST_TYPE	<= INST_JMP_REL;
				O_SEL_B_IMM	<= '1';	-- IMM
				O_BRANCH	<= BR_UNC_REL;
				O_DST		<= (others => '0'); -- no writeback
				O_ALUOP		<= FUNC_ADD;
			when OPCODE_JAL		=>
				O_INST_TYPE	<= INST_JMP_REL;
				O_SEL_B_IMM	<= '1';	-- IMM
				O_BRANCH	<= BR_UNC_REL;
				O_ALUOP		<= FUNC_ADD;
			when OPCODE_BEQZ	=>
				O_SEL_B_IMM	<= '1';	-- IMM
				O_BRANCH	<= BR_EQ0_REL;
				O_DST		<= (others => '0'); -- no writeback
				O_ALUOP		<= FUNC_ADD;
			when OPCODE_BNEZ	=>
				O_SEL_B_IMM	<= '1';	-- IMM
				O_BRANCH	<= BR_NE0_REL;
				O_DST		<= (others => '0'); -- no writeback
				O_ALUOP		<= FUNC_ADD;
			when OPCODE_JR		=>
				O_INST_TYPE	<= INST_JMP_ABS;
				O_SEL_B_IMM	<= '1';	-- IMM
				O_BRANCH	<= BR_UNC_ABS;
				O_DST		<= (others => '0'); -- no writeback
				O_ALUOP		<= FUNC_ADD;
			when OPCODE_JALR	=>
				O_INST_TYPE	<= INST_JMP_ABS;
				O_SEL_B_IMM	<= '1';	-- IMM
				O_BRANCH	<= BR_UNC_ABS;
				O_ALUOP		<= FUNC_ADD;

			-- General instructions
			when OPCODE_NOP		=>
				O_INST_TYPE	<= INST_NOP;
				O_DST		<= (others => '0');

			-- NOP when an unsupported instruction is detected
			when others		=>
				O_INST_TYPE	<= INST_NOP;
				O_DST		<= (others => '0');
		end case;
	end process;
end BEHAVIORAL;

