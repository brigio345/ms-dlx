library IEEE;
use IEEE.std_logic_1164.all;
use work.coding.all;
use work.aluops.all;
use work.branch_types.all;

-- combinational circuit generating all ctrl signals for current instruction
entity instr_decoder is
	port (
		-- from ID stage
		I_FUNC:		in std_logic_vector(FUNC_SIZE - 1 downto 0);
		I_OPCODE:	in std_logic_vector(OPCODE_SIZE - 1 downto 0);

		-- to ID stage
		O_BRANCH:	out branch_t;

		-- to EX stage
		O_ALUOP:	out aluop_t;
		O_OP1:		out std_logic; -- alu op1
		O_OP2:		out std_logic; -- alu op2

		-- to MEM stage
		O_LD:		out std_logic;
		O_STR:		out std_logic;

		-- to WB stage
		O_WB_DST:	out std_logic_vector(R_DST_SIZE - 1 downto 0)
	);
end instr_decoder;

architecture BEHAVIORAL of instr_decoder is
begin
	process (I_FUNC, I_OPCODE)
	begin
		-- typical I-TYPE instruction as default values
		-- (since they are the most common instructions this
		-- just reduces code size)
		O_OP1	<= '1';	-- A
		O_OP2	<= '1';	-- IMM
		O_BRANCH<= BRANCH_NO;
		O_LD	<= '0'; -- no load
		O_STR	<= '0'; -- no store
		O_WB_DST<= I_INST(I_DST_RANGE);
		case (I_OPCODE) is
			when OPCODE_RTYPE	=>
				O_OP1	<= '1';	-- A
				O_OP2	<= '0';	-- B
				O_WB_DST<= I_INST(R_DST_RANGE);
				case (I_FUNC) is
					FUNC_SLL	=>
						O_ALUOP	<= ALUOP_SLL;
					FUNC_SRL	=>
						O_ALUOP	<= ALUOP_SRL;
					FUNC_SRA	=>
						O_ALUOP	<= ALUOP_SRA;
					FUNC_ADD | FUNC_ADDU	=>
						O_ALUOP	<= ALUOP_ADD;
					FUNC_SUB | FUNC_SUBU	=>
						O_ALUOP	<= ALUOP_SUB;
					FUNC_AND	=>
						O_ALUOP	<= ALUOP_AND;
					FUNC_OR		=>
						O_ALUOP	<= ALUOP_OR;
					FUNC_XOR	=>
						O_ALUOP	<= ALUOP_XOR;
					FUNC_SEQ	=>
						O_ALUOP	<= ALUOP_SEQ;
					FUNC_SNE	=>
						O_ALUOP	<= ALUOP_SNE;
					FUNC_SLT	=>
						O_ALUOP	<= ALUOP_SLT;
					FUNC_SGT	=>
						O_ALUOP	<= ALUOP_SGT;
					FUNC_SLE	=>
						O_ALUOP	<= ALUOP_SLE;
					FUNC_SGE	=>
						O_ALUOP	<= ALUOP_SGE;
					FUNC_SLTU	=>
						O_ALUOP	<= ALUOP_SLTU;
					FUNC_SGTU	=>
						O_ALUOP	<= ALUOP_SLGTU;
					FUNC_SLEU	=>
						O_ALUOP	<= ALUOP_SLEU;
					FUNC_SGEU	=>
						O_ALUOP	<= ALUOP_SGEU;
					when others	=>
				end case;
			when OPCODE_ADDI | OPCODE_ADDUI	=>
				O_ALUOP	<= ALUOP_ADD;
			when OPCODE_SUBI | OPCODE_SUBI	=>
				O_ALUOP	<= ALUOP_SUB;
			when OPCODE_ANDI	=>
				O_ALUOP	<= ALUOP_AND;
			when OPCODE_ORI		=>
				O_ALUOP	<= ALUOP_OR;
			when OPCODE_XORI	=>
				O_ALUOP	<= ALUOP_XOR;
			when OPCODE_SLLI	=>
				O_ALUOP	<= ALUOP_SLL;
			when OPCODE_SRLI	=>
				O_ALUOP	<= ALUOP_SRL;
			when OPCODE_SRAI	=>
				O_ALUOP	<= ALUOP_SRA;
			when OPCODE_SEQI	=>
				O_WB_DST<= I_INST(I_DST_RANGE);
				O_ALUOP	<= ALUOP_SEQ;
			when OPCODE_SNEI	=>
				O_ALUOP	<= ALUOP_SNE;
			when OPCODE_SLTI	=>
				O_ALUOP	<= ALUOP_SLT;
			when OPCODE_SGTI	=>
				O_ALUOP	<= ALUOP_SGT;
			when OPCODE_SLEI	=>
				O_ALUOP	<= ALUOP_SLE;
			when OPCODE_SGEI	=>
				O_ALUOP	<= ALUOP_SGE;
			when OPCODE_SLTUI	=>
				O_ALUOP	<= ALUOP_SLTU;
			when OPCODE_SGTUI	=>
				O_ALUOP	<= ALUOP_SGTU;
			when OPCODE_SLEUI	=>
				O_ALUOP	<= ALUOP_SLEU;
			when OPCODE_SGEUI	=>
				O_ALUOP	<= ALUOP_SGEU;

			-- Load & store instructions (register-immediate instructions subset)
			when OPCODE_LW		=>
				O_LD	<= '1'; -- load
				O_ALUOP	<= ALUOP_ADD;
			when OPCODE_SW		=>
				O_STR	<= '1'; -- store
				O_ALUOP	<= ALUOP_ADD;

			-- Jump instructions
			when OPCODE_J		=>
				O_OP1	<= '0';	-- NPC
				O_OP2	<= '1';	-- IMM
				O_BRANCH<= BRANCH_UNC;
				O_WB_DST<= (others => '0'); -- no writeback
				O_ALUOP	<= ALUOP_ADD;
			when OPCODE_JAL		=>
				O_OP1	<= '0';	-- NPC
				O_OP2	<= '1';	-- IMM
				O_BRANCH<= BRANCH_UNC;
				O_WB_DST<= (others => '0'); -- no writeback
				O_ALUOP	<= ALUOP_ADD;
			when OPCODE_BEQZ	=>
				O_OP1	<= '0';	-- NPC
				O_OP2	<= '1';	-- IMM
				O_BRANCH<= BRANCH_EQ0;
				O_WB_DST<= (others => '0'); -- no writeback
				O_ALUOP	<= ALUOP_ADD;
			when OPCODE_BNEZ	=>
				O_OP1	<= '0';	-- NPC
				O_OP2	<= '1';	-- IMM
				O_BRANCH<= BRANCH_NE0;
				O_WB_DST<= (others => '0'); -- no writeback
				O_ALUOP	<= ALUOP_ADD;
			when OPCODE_JR		=>
				O_OP1	<= '0';	-- NPC
				O_OP2	<= '1';	-- IMM
				O_BRANCH<= BRANCH_UNC;
				O_WB_DST<= (others => '0'); -- no writeback
				O_ALUOP	<= ALUOP_ADD;
			when OPCODE_JALR	=>
				O_OP1	<= '0';	-- NPC
				O_OP2	<= '1';	-- IMM
				O_BRANCH<= BRANCH_UNC;
				O_WB_DST<= (others => '0'); -- no writeback
				O_ALUOP	<= ALUOP_ADD;

			-- General instructions
			when OPCODE_NOP		=>
				O_WB_DST	<= (others => '0');

			-- NOP when an unsupported instruction is detected
			when others		=>
				O_WB_DST	<= (others => '0');
		end case;
	end process;
end BEHAVIORAL;

