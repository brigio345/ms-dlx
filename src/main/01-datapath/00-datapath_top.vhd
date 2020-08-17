library ieee;
use ieee.std_logic_1164.all;
use work.specs.all;
use work.utilities.all;

entity datapath is
	port (
		I_CLK:		in std_logic;
		I_RST:		in std_logic;

		I_EN_IF:	in std_logic;
		I_EN_ID:	in std_logic;
		I_EN_EX:	in std_logic;
		I_EN_MEM:	in std_logic;
		I_EN_WB:	in std_logic;

		-- from i-memory
		I_INST:		in std_logic_vector(INST_SZ - 1 downto 0);
		-- from d-memory
		I_D_RD_DATA:	out std_logic_vector(REG_SZ - 1 downto 0);

		-- to i-memory
		O_PC:		out std_logic_vector(REG_SZ - 1 downto 0);

		-- to d-memory
		O_D_ADDR:	out std_logic_vector(REG_SZ - 1 downto 0);
		O_D_RD:		out std_logic;
		O_D_WR:		out std_logic;
		O_D_WR_DATA:	out std_logic_vector(REG_SZ - 1 downto 0)
	);
end datapath;

architecture STRUCTURAL of datapath is
	component fetch_unit is
		port (
			-- I_PC: from ID stage; can be NPC or target of a branch
			I_PC:	in std_logic_vector(REG_SZ - 1 downto 0);
			-- I_IR: from instruction memory; data read at address PC
			I_IR:	in std_logic_vector(INST_SZ - 1 downto 0);
			-- O_PC: to instruction memory; address to be read
			O_PC:	out std_logic_vector(REG_SZ - 1 downto 0);
			-- O_NPC: to ID stage; next PC value if instruction is
			--	not a taken branch
			O_NPC:	out std_logic_vector(REG_SZ - 1 downto 0);
			-- O_IR: to ID stage; encoded instruction
			O_IR:	out std_logic_vector(INST_SZ - 1 downto 0)
		);
	end component fetch_unit;

	component decode_unit is
		port (
			-- I_IR: from IF stage; encoded instruction
			I_IR:		in std_logic_vector(INST_SIZE - 1 downto 0);
			-- I_NPC: from IF stage; next PC value if instruction is
			--	not a taken branch
			I_NPC:		in std_logic_vector(REG_SZ - 1 downto 0);

			-- I_RDx_DATA: from rf; data read from rf at address O_RDx_ADDR
			I_RD1_DATA:	in std_logic_vector(REG_SZ - 1 downto 0);
			I_RD2_DATA:	in std_logic_vector(REG_SZ - 1 downto 0);

			-- from CU
			I_BRANCH:	in branch_t;

			-- O_RDx_ADDR: to rf; address at which rf has to be read
			O_RD1_ADDR:	out std_logic_vector(log2_ceil(N_REGS) - 1 downto 0);
			O_RD2_ADDR:	out std_logic_vector(log2_ceil(N_REGS) - 1 downto 0);

			-- O_DST: to WB stage; address at which rf has to be written
			O_DST:		out std_logic_vector(log2_ceil(N_REGS) - 1 downto 0);

			-- to CU
			O_OPCODE:	out std_logic_vector(OPCODE_SZ - 1 downto 0);
			O_FUNC:		out std_logic_vector(FUNC_SZ - 1 downto 0);

			-- to EX stage; ALU operands
			O_A:		out std_logic_vector(REG_SZ - 1 downto 0);
			O_B:		out std_logic_vector(REG_SZ - 1 downto 0);
			O_IMM:		out std_logic_vector(REG_SZ - 1 downto 0);

			-- O_PC: to IF stage; address of next instruction
			O_PC:		out std_logic_vector(REG_SZ - 1 downto 0)
		);
	end component decode_unit;

	component execute_unit is
		port (
			-- from CU
			I_ALUOP:	in aluop_t;
			I_SEL_B_IMM:	in std_logic;

			-- from ID stage
			I_A:	in std_logic_vector(REG_SZ - 1 downto 0);
			I_B:	in std_logic_vector(REG_SZ - 1 downto 0);
			I_IMM:	in std_logic_vector(REG_SZ - 1 downto 0);

			-- to MEM/WB stages
			O_DATA:	out std_logic_vector(REG_SZ - 1 downto 0)
		);
	end component execute_unit;

	component memory_unit is
		port (
			-- from CU
			I_LD:		in std_logic;
			I_STR:		in std_logic;

			-- from EX stage
			I_ADDR:		in std_logic_vector(REG_SZ - 1 downto 0);

			-- from ID stage
			I_DATA:		in std_logic_vector(REG_SZ - 1 downto 0);

			-- from d-memory
			I_RD_DATA:	out std_logic_vector(REG_SZ - 1 downto 0);

			-- to d-memory
			O_ADDR:		out std_logic_vector(REG_SZ - 1 downto 0);
			O_RD:		out std_logic;
			O_WR:		out std_logic;
			O_WR_DATA:	out std_logic_vector(REG_SZ - 1 downto 0);

			-- to WB stage
			O_LOADED:	out std_logic_vector(REG_SZ - 1 downto 0)
		);
	end component memory_unit;

	component write_unit is
		port (
			-- from CU
			I_LD:		in std_logic;

			-- from ID stage
			I_DST:		in std_logic_vector(R_SRC_DST_SZ - 1 downto 0);

			-- from EX stage
			I_ALUOUT:	in std_logic_vector(DATA_SZ - 1 downto 0);

			-- from MEM stage
			I_LOADED:	in std_logic_vector(DATA_SZ - 1 downto 0);

			-- to rf
			O_WR:		out std_logic;
			O_WR_ADDR:	out std_logic_vector(R_SRC_DST_SZ - 1 downto 0);
			O_WR_DATA:	out std_logic_vector(DATA_SZ - 1 downto 0)
		);
	end component write_unit;

	component if_id_registers is
		port (
			I_CLK:		in std_logic;
			I_RST:		in std_logic;
			I_LD:		in std_logic;

			-- from IF stage
			I_NPC:		in std_logic_vector(REG_SZ - 1 downto 0);
			I_IR:		in std_logic_vector(REG_SZ - 1 downto 0);

			-- to ID stage
			O_NPC:		out std_logic_vector(REG_SZ - 1 downto 0);
			O_IR:		out std_logic_vector(REG_SZ - 1 downto 0);
		);
	end component if_id_registers;

	component id_ex_registers is
		port (
			I_CLK:		in std_logic;
			I_RST:		in std_logic;
			I_LD:		in std_logic;

			-- from ID stage
			I_A:		in std_logic_vector(REG_SZ - 1 downto 0);
			I_B:		in std_logic_vector(REG_SZ - 1 downto 0);
			I_IMM:		in std_logic_vector(REG_SZ - 1 downto 0);
			I_DST:		in std_logic_vector(R_SRC_DST_SZ - 1 downto 0);

			I_ALUOP:	in aluop_t;
			I_SEL_B_IMM:	in std_logic;
			I_LD:		in std_logic;
			I_STR:		in std_logic;

			-- to EX stage
			O_A:		out std_logic_vector(REG_SZ - 1 downto 0);
			O_B:		out std_logic_vector(REG_SZ - 1 downto 0);
			O_IMM:		out std_logic_vector(REG_SZ - 1 downto 0);
			O_DST:		out std_logic_vector(R_SRC_DST_SZ - 1 downto 0);

			O_ALUOP:	out aluop_t;
			O_SEL_B_IMM:	out std_logic;
			O_LD:		out std_logic;
			O_STR:		out std_logic
		);
	end component id_ex_registers;

	component ex_mem_registers is
		port (
			I_CLK:		in std_logic;
			I_RST:		in std_logic;
			I_EN:		in std_logic;

			-- from EX stage
			I_IMM:		in std_logic_vector(REG_SZ - 1 downto 0);
			I_ADDR:		in std_logic_vector(REG_SZ - 1 downto 0);

			I_DST:		in std_logic_vector(R_SRC_DST_SZ - 1 downto 0);

			I_LD:		in std_logic;
			I_STR:		in std_logic;

			-- to MEM stage
			O_ADDR:		out std_logic_vector(REG_SZ - 1 downto 0);
			O_IMM:		out std_logic_vector(REG_SZ - 1 downto 0);

			O_DST:		out std_logic_vector(R_SRC_DST_SZ - 1 downto 0);

			O_LD:		out std_logic;
			O_STR:		out std_logic
		);
	end component ex_mem_registers;

	component mem_wb_registers is
		port (
			I_CLK:		in std_logic;
			I_RST:		in std_logic;
			I_EN:		in std_logic;

			-- from MEM stage
			I_LOADED:	in std_logic_vector(REG_SZ - 1 downto 0);

			I_ALUOUT:	in std_logic_vector(REG_SZ - 1 downto 0);
			I_DST:		in std_logic_vector(R_SRC_DST_SZ - 1 downto 0);

			I_LD:		in std_logic;

			-- to WB stage
			O_LOADED:	out std_logic_vector(REG_SZ - 1 downto 0);

			O_ALUOUT:	out std_logic_vector(REG_SZ - 1 downto 0);
			O_DST:		out std_logic_vector(R_SRC_DST_SZ - 1 downto 0);

			O_LD:		out std_logic;
		);
	end component mem_wb_registers;

	component register_file is
		generic (
			NBIT:	integer := 64;	-- number of bits in each register
			NLINE:	integer := 32	-- number of registers
		);
		port (
			CLK: 		IN std_logic;
			RESET: 		IN std_logic;
			ENABLE: 	IN std_logic;
			RD1: 		IN std_logic;
			RD2: 		IN std_logic;
			WR: 		IN std_logic;
			ADD_WR: 	IN std_logic_vector(log2_ceil(NLINE) - 1 downto 0);
			ADD_RD1: 	IN std_logic_vector(log2_ceil(NLINE) - 1 downto 0);
			ADD_RD2: 	IN std_logic_vector(log2_ceil(NLINE) - 1 downto 0);
			DATAIN: 	IN std_logic_vector(NBIT - 1 downto 0);
			OUT1: 		OUT std_logic_vector(NBIT - 1 downto 0);
			OUT2: 		OUT std_logic_vector(NBIT - 1 downto 0)
		);
	end component register_file;

	signal PC:	std_logic_vector(REG_SZ - 1 downto 0);
	signal INST:	std_logic_vector(INST_SZ - 1 downto 0);
	signal ADDR:	std_logic_vector(REG_SZ - 1 downto 0);
	signal NPC:	std_logic_vector(REG_SZ - 1 downto 0);
	signal IR:	std_logic_vector(INST_SZ - 1 downto 0);
	signal RD_ADDR1:std_logic_vector(log2_ceil(N_REGS) - 1 downto 0);
	signal RD_ADDR2:std_logic_vector(log2_ceil(N_REGS) - 1 downto 0);
	signal ALUOP:	aluop_t;
	signal OP1:	std_logic;
	signal OP2:	std_logic;
	signal A:	std_logic_vector(REG_SZ - 1 downto 0);
	signal B:	std_logic_vector(REG_SZ - 1 downto 0);
	signal IMM:	std_logic_vector(REG_SZ - 1 downto 0);
	signal BRANCH:	std_logic;
	signal LD:	std_logic;
	signal STR:	std_logic;
	signal WB_DST:	std_logic_vector(SRC_DST_R_SZ - 1 downto 0);
	signal ALUOUT:	std_logic_vector(REG_SZ - 1 downto 0);
	signal ZERO:	std_logic;

begin
end STRUCTURAL;

