library ieee;
use ieee.std_logic_1164.all;
use work.coding.all;
use work.types.all;
use work.utilities.all;

entity datapath is
	port (
		I_CLK:		in std_logic;
		I_RST:		in std_logic;

		-- I_ENDIAN: specify endianness of data and instruction memories
		--	- '0' => BIG endian
		--	- '1' => LITTLE endian
		I_ENDIAN:	in std_logic;

		-- from i-memory
		I_INST:		in std_logic_vector(INST_SZ - 1 downto 0);

		-- from d-memory
		I_D_RD_DATA:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);

		-- from CU, to IF stage
		I_IF_EN:	in std_logic;

		-- from CU, to ID stage
		I_BRANCH:	in branch_t;
		I_SIGNED:	in std_logic;
		I_SEL_A:	in source_t;
		I_SEL_B:	in source_t;

		-- from CU, to EX stage
		I_SEL_B_IMM:	in std_logic;
		I_ALUOP:	in std_logic_vector(FUNC_SZ - 1 downto 0);

		-- from CU, to MEM stage
		I_LD:		in std_logic_vector(1 downto 0);
		I_STR:		in std_logic_vector(1 downto 0);

		-- from CU, to WB stage
		I_DST:		in std_logic_vector(RF_ADDR_SZ - 1 downto 0);

		-- to i-memory
		O_PC:		out std_logic_vector(RF_DATA_SZ - 1 downto 0);

		-- to d-memory
		O_D_ADDR:	out std_logic_vector(RF_DATA_SZ - 1 downto 0);
		O_D_RD:		out std_logic_vector(1 downto 0);
		O_D_WR:		out std_logic_vector(1 downto 0);
		O_D_WR_DATA:	out std_logic_vector(RF_DATA_SZ - 1 downto 0);

		-- to CU, from ID stage
		O_OPCODE:	out std_logic_vector(OPCODE_SZ - 1 downto 0);
		O_FUNC:		out std_logic_vector(FUNC_SZ - 1 downto 0);
		O_SRC_A:	out std_logic_vector(RF_ADDR_SZ - 1 downto 0);
		O_SRC_B:	out std_logic_vector(RF_ADDR_SZ - 1 downto 0);
		O_DST_ID:	out std_logic_vector(RF_ADDR_SZ - 1 downto 0);
		O_TAKEN_PREV:	out std_logic;

		-- to CU, from EX stage
		O_DST_EX:	out std_logic_vector(RF_ADDR_SZ - 1 downto 0);
		O_LD_EX:	out std_logic_vector(1 downto 0);

		-- to CU, from MEM stage
		O_DST_MEM:	out std_logic_vector(RF_ADDR_SZ - 1 downto 0);
		O_LD_MEM:	out std_logic_vector(1 downto 0)
	);
end datapath;

architecture STRUCTURAL of datapath is
	component fetch_unit is
		port (
			-- I_ENDIAN: specify endianness of instruction memory
			--	- '0' => BIG endian
			--	- '1' => LITTLE endian
			I_ENDIAN:	in std_logic;

			I_NPC:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);

			-- from ID stage
			I_TARGET:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);
			I_TAKEN:	in std_logic;

			-- I_IR: from instruction memory; data read at address PC
			I_IR:		in std_logic_vector(INST_SZ - 1 downto 0);
			-- O_PC: to instruction memory; address to be read
			O_PC:		out std_logic_vector(RF_DATA_SZ - 1 downto 0);
			-- O_NPC: to ID stage; next PC value if instruction is
			--	not a taken branch
			O_NPC:		out std_logic_vector(RF_DATA_SZ - 1 downto 0);
			-- O_IR: to ID stage; encoded instruction
			O_IR:		out std_logic_vector(INST_SZ - 1 downto 0)
		);
	end component fetch_unit;

	component decode_unit is
		port (
			-- I_IR: from IF stage; encoded instruction
			I_IR:		in std_logic_vector(INST_SZ - 1 downto 0);
			-- I_NPC: from IF stage; next PC value if instruction is
			--	not a taken branch
			I_NPC:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);

			-- I_RDx_DATA: from rf; data read from rf at address O_RDx_ADDR
			I_RD1_DATA:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);
			I_RD2_DATA:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);

			-- from CU
			I_BRANCH:	in branch_t;
			I_SIGNED:	in std_logic;

			-- O_RDx_ADDR: to rf; address at which rf has to be read
			O_RD1_ADDR:	out std_logic_vector(RF_ADDR_SZ - 1 downto 0);
			O_RD2_ADDR:	out std_logic_vector(RF_ADDR_SZ - 1 downto 0);

			-- O_DST: to WB stage; address at which rf has to be written
			O_DST:		out std_logic_vector(RF_ADDR_SZ - 1 downto 0);

			-- to CU
			O_OPCODE:	out std_logic_vector(OPCODE_SZ - 1 downto 0);
			O_FUNC:		out std_logic_vector(FUNC_SZ - 1 downto 0);

			-- to EX stage; ALU operands
			O_RD1:		out std_logic_vector(RF_DATA_SZ - 1 downto 0);
			O_RD2:		out std_logic_vector(RF_DATA_SZ - 1 downto 0);
			O_IMM:		out std_logic_vector(RF_DATA_SZ - 1 downto 0);

			-- O_TARGET: to IF stage; address of next instruction
			O_TARGET:	out std_logic_vector(RF_DATA_SZ - 1 downto 0);
			
			-- O_TAKEN: to CU and IF stage
			O_TAKEN:	out std_logic
		);
	end component decode_unit;

	component execute_unit is
		port (
			-- from CU
			I_ALUOP:	in std_logic_vector(FUNC_SZ - 1 downto 0);
			I_SEL_A:	in source_t;
			I_SEL_B:	in source_t;
			I_SEL_R_IMM:	in std_logic;

			-- from ID stage
			I_RD1:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);
			I_RD2:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);
			I_IMM:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);
			I_NPC:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);

			-- data forwarded from EX/MEM stages
			I_ALUOUT_EX:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);
			I_ALUOUT_MEM:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);
			I_LOADED:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);

			-- to MEM/WB stages
			O_ALUOUT:	out std_logic_vector(RF_DATA_SZ - 1 downto 0)
		);
	end component execute_unit;

	component memory_unit is
		port (
			-- I_ENDIAN: specify endianness of data memory
			--	- '0' => BIG endian
			--	- '1' => LITTLE endian
			I_ENDIAN:	in std_logic;

			-- from CU
			I_LD:		in std_logic_vector(1 downto 0);
			I_STR:		in std_logic_vector(1 downto 0);
			I_SIGNED:	in std_logic;
			I_SEL_DATA:	in source_t;

			-- from EX stage
			I_ADDR:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);

			-- from ID stage
			I_DATA:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);

			-- data forwarded from EX/MEM stages
			I_ALUOUT_EX:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);
			I_LOADED_EX:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);
			I_ALUOUT_MEM:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);
			I_LOADED_MEM:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);

			-- from d-memory
			I_RD_DATA:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);

			-- to d-memory
			O_ADDR:		out std_logic_vector(RF_DATA_SZ - 1 downto 0);
			O_RD:		out std_logic_vector(1 downto 0);
			O_WR:		out std_logic_vector(1 downto 0);
			O_WR_DATA:	out std_logic_vector(RF_DATA_SZ - 1 downto 0);

			-- to WB stage
			O_LOADED:	out std_logic_vector(RF_DATA_SZ - 1 downto 0)
		);
	end component memory_unit;

	component write_unit is
		port (
			-- from CU
			I_LD:		in std_logic_vector(1 downto 0);

			-- from ID stage
			I_DST:		in std_logic_vector(RF_ADDR_SZ - 1 downto 0);

			-- from EX stage
			I_ALUOUT:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);

			-- from MEM stage
			I_LOADED:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);

			-- to rf
			O_WR:		out std_logic;
			O_WR_ADDR:	out std_logic_vector(RF_ADDR_SZ - 1 downto 0);
			O_WR_DATA:	out std_logic_vector(RF_DATA_SZ - 1 downto 0)
		);
	end component write_unit;

	component id_if_registers is
		port (
			I_CLK:		in std_logic;
			I_RST:		in std_logic;
			I_EN:		in std_logic;

			-- from IF stage
			I_TARGET:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);
			I_TAKEN:	in std_logic;

			-- to ID stage
			O_TARGET:	out std_logic_vector(RF_DATA_SZ - 1 downto 0);
			O_TAKEN:	out std_logic
		);
	end component id_if_registers;

	component if_id_registers is
		port (
			I_CLK:		in std_logic;
			I_RST:		in std_logic;
			I_EN:		in std_logic;

			-- from IF stage
			I_NPC:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);
			I_IR:		in std_logic_vector(INST_SZ - 1 downto 0);

			-- to ID stage
			O_NPC:		out std_logic_vector(RF_DATA_SZ - 1 downto 0);
			O_IR:		out std_logic_vector(INST_SZ - 1 downto 0)
		);
	end component if_id_registers;

	component id_ex_registers is
		port (
			I_CLK:		in std_logic;
			I_RST:		in std_logic;

			-- from ID stage
			I_A:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);
			I_B:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);
			I_IMM:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);
			I_NPC:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);
			I_DST:		in std_logic_vector(RF_ADDR_SZ - 1 downto 0);
			I_SIGNED:	in std_logic;

			I_ALUOP:	in std_logic_vector(FUNC_SZ - 1 downto 0);
			I_SEL_A:	in source_t;
			I_SEL_B:	in source_t;
			I_SEL_B_IMM:	in std_logic;
			I_LD:		in std_logic_vector(1 downto 0);
			I_STR:		in std_logic_vector(1 downto 0);

			-- to EX stage
			O_A:		out std_logic_vector(RF_DATA_SZ - 1 downto 0);
			O_B:		out std_logic_vector(RF_DATA_SZ - 1 downto 0);
			O_IMM:		out std_logic_vector(RF_DATA_SZ - 1 downto 0);
			O_NPC:		out std_logic_vector(RF_DATA_SZ - 1 downto 0);
			O_DST:		out std_logic_vector(RF_ADDR_SZ - 1 downto 0);
			O_SIGNED:	out std_logic;

			O_ALUOP:	out std_logic_vector(FUNC_SZ - 1 downto 0);
			O_SEL_A:	out source_t;
			O_SEL_B:	out source_t;
			O_SEL_B_IMM:	out std_logic;
			O_LD:		out std_logic_vector(1 downto 0);
			O_STR:		out std_logic_vector(1 downto 0)
		);
	end component id_ex_registers;

	component ex_mem_registers is
		port (
			I_CLK:		in std_logic;
			I_RST:		in std_logic;

			-- from EX stage
			I_ADDR:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);
			I_DATA:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);

			I_DST:		in std_logic_vector(RF_ADDR_SZ - 1 downto 0);

			I_SIGNED:	in std_logic;
			I_LD:		in std_logic_vector(1 downto 0);
			I_STR:		in std_logic_vector(1 downto 0);
			I_SEL_DATA:	in source_t;

			-- to MEM stage
			O_ADDR:		out std_logic_vector(RF_DATA_SZ - 1 downto 0);
			O_DATA:		out std_logic_vector(RF_DATA_SZ - 1 downto 0);

			O_DST:		out std_logic_vector(RF_ADDR_SZ - 1 downto 0);

			O_SIGNED:	out std_logic;
			O_LD:		out std_logic_vector(1 downto 0);
			O_STR:		out std_logic_vector(1 downto 0);
			O_SEL_DATA:	out source_t
		);
	end component ex_mem_registers;

	component mem_wb_registers is
		port (
			I_CLK:		in std_logic;
			I_RST:		in std_logic;

			-- from MEM stage
			I_LOADED:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);

			I_ALUOUT:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);
			I_DST:		in std_logic_vector(RF_ADDR_SZ - 1 downto 0);

			I_LD:		in std_logic_vector(1 downto 0);

			-- to WB stage
			O_LOADED:	out std_logic_vector(RF_DATA_SZ - 1 downto 0);

			O_ALUOUT:	out std_logic_vector(RF_DATA_SZ - 1 downto 0);
			O_DST:		out std_logic_vector(RF_ADDR_SZ - 1 downto 0);

			O_LD:		out std_logic_vector(1 downto 0)
		);
	end component mem_wb_registers;

	component wb_mem_registers is
		port (
			I_CLK:		in std_logic;
			I_RST:		in std_logic;

			-- from WB stage
			I_LOADED:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);
			I_ALUOUT:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);

			-- to MEM stage
			O_LOADED:	out std_logic_vector(RF_DATA_SZ - 1 downto 0);
			O_ALUOUT:	out std_logic_vector(RF_DATA_SZ - 1 downto 0)
		);
	end component wb_mem_registers;

	component register_file is
		generic (
			NBIT:	integer := 64;	-- number of bits in each register
			NLINE:	integer := 32	-- number of registers
		);
		port (
			CLK: 		IN std_logic;
			RESET: 		IN std_logic;
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

	signal TARGET_ID:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal TARGET_ID_REG:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal TAKEN_ID:	std_logic;
	signal TAKEN_ID_REG:	std_logic;
	signal RD1_ADDR_ID:	std_logic_vector(RF_ADDR_SZ - 1 downto 0);
	signal RD2_ADDR_ID:	std_logic_vector(RF_ADDR_SZ - 1 downto 0);
	signal FUNC_ID:		std_logic_vector(FUNC_SZ - 1 downto 0);
	signal RD1_ID:		std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal RD1_ID_REG:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal RD2_ID:		std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal RD2_ID_REG:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal IMM_ID:		std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal IMM_ID_REG:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal NPC_ID_REG:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal DST_ID:		std_logic_vector(RF_ADDR_SZ - 1 downto 0);
	signal DST_ID_REG:	std_logic_vector(RF_ADDR_SZ - 1 downto 0);

	signal NPC_IF:		std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal NPC_IF_REG:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal IR_IF:		std_logic_vector(INST_SZ - 1 downto 0);
	signal IR_IF_REG:	std_logic_vector(INST_SZ - 1 downto 0);

	signal ALUOUT_EX:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal ALUOUT_EX_REG:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal LD_EX_REG:	std_logic_vector(1 downto 0);
	signal STR_EX_REG:	std_logic_vector(1 downto 0);
	signal DST_EX_REG:	std_logic_vector(RF_ADDR_SZ - 1 downto 0);
	signal SIGNED_EX_REG:	std_logic;
	signal DATA_EX_REG:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal SEL_B_EX_REG:	source_t;

	signal ALUOUT_MEM_REG:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal LOADED_MEM_REG:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal LOADED_MEM:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal LD_MEM_REG:	std_logic_vector(1 downto 0);
	signal DST_MEM_REG:	std_logic_vector(RF_ADDR_SZ - 1 downto 0);
	signal WR_MEM:		std_logic;
	signal WR_ADDR_MEM:	std_logic_vector(RF_ADDR_SZ - 1 downto 0);
	signal WR_DATA_MEM:	std_logic_vector(RF_DATA_SZ - 1 downto 0);

	signal ALUOUT_WB_REG:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal LOADED_WB_REG:	std_logic_vector(RF_DATA_SZ - 1 downto 0);

	signal RD1_DATA_RF:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal RD2_DATA_RF:	std_logic_vector(RF_DATA_SZ - 1 downto 0);

	signal ALUOP_CU_REG:	std_logic_vector(FUNC_SZ - 1 downto 0);
	signal SEL_A_CU_REG:	source_t;
	signal SEL_B_CU_REG:	source_t;
	signal SEL_B_IMM_CU_REG:std_logic;
	signal LD_CU_REG:	std_logic_vector(1 downto 0);
	signal STR_CU_REG:	std_logic_vector(1 downto 0);
	signal SIGNED_CU_REG:	std_logic;
begin
	fetch_unit_0: fetch_unit
		port map (
			I_ENDIAN	=> I_ENDIAN,
			I_NPC		=> NPC_IF_REG,
			I_TARGET	=> TARGET_ID_REG,
			I_TAKEN		=> TAKEN_ID_REG,
			I_IR		=> I_INST,
			O_PC		=> O_PC,
			O_NPC		=> NPC_IF,
			O_IR		=> IR_IF
		);

	decode_unit_0: decode_unit
		port map (
			I_IR		=> IR_IF_REG,
			I_NPC		=> NPC_IF_REG,
			I_RD1_DATA	=> RD1_DATA_RF,
			I_RD2_DATA	=> RD2_DATA_RF,
			I_BRANCH	=> I_BRANCH,
			I_SIGNED	=> I_SIGNED,
			O_RD1_ADDR	=> RD1_ADDR_ID,
			O_RD2_ADDR	=> RD2_ADDR_ID,
			O_DST		=> DST_ID,
			O_OPCODE	=> O_OPCODE,
			O_FUNC		=> FUNC_ID,
			O_RD1		=> RD1_ID,
			O_RD2		=> RD2_ID,
			O_IMM		=> IMM_ID,
			O_TARGET	=> TARGET_ID,
			O_TAKEN		=> TAKEN_ID
		);

	O_SRC_A	<= RD1_ADDR_ID;
	O_SRC_B	<= RD2_ADDR_ID;
	O_DST_ID<= DST_ID;
	O_FUNC	<= FUNC_ID;

	execute_unit_0: execute_unit
		port map (
			I_ALUOP		=> ALUOP_CU_REG,
			I_SEL_A		=> SEL_A_CU_REG,
			I_SEL_B		=> SEL_B_CU_REG,
			I_SEL_R_IMM	=> SEL_B_IMM_CU_REG,
			I_RD1		=> RD1_ID_REG,
			I_RD2		=> RD2_ID_REG,
			I_IMM		=> IMM_ID_REG,
			I_NPC		=> NPC_ID_REG,
			I_ALUOUT_EX	=> ALUOUT_EX_REG,
			I_ALUOUT_MEM	=> ALUOUT_MEM_REG,
			I_LOADED	=> LOADED_MEM_REG,
			O_ALUOUT	=> ALUOUT_EX
		);

	memory_unit_0: memory_unit
		port map (
			I_ENDIAN	=> I_ENDIAN,
			I_LD		=> LD_EX_REG,
			I_STR		=> STR_EX_REG,
			I_SIGNED	=> SIGNED_EX_REG,
			I_SEL_DATA	=> SEL_B_EX_REG,
			I_ADDR		=> ALUOUT_EX_REG,
			I_DATA		=> DATA_EX_REG,
			I_ALUOUT_EX	=> ALUOUT_MEM_REG,
			I_LOADED_EX	=> LOADED_MEM_REG,
			I_ALUOUT_MEM	=> ALUOUT_WB_REG,
			I_LOADED_MEM	=> LOADED_WB_REG,
			I_RD_DATA	=> I_D_RD_DATA,
			O_ADDR		=> O_D_ADDR,
			O_RD		=> O_D_RD,
			O_WR		=> O_D_WR,
			O_WR_DATA	=> O_D_WR_DATA,
			O_LOADED	=> LOADED_MEM
		);

	write_unit_0: write_unit
		port map (
			I_LD		=> LD_MEM_REG,
			I_DST		=> DST_MEM_REG,
			I_ALUOUT	=> ALUOUT_MEM_REG,
			I_LOADED	=> LOADED_MEM_REG,
			O_WR		=> WR_MEM,
			O_WR_ADDR	=> WR_ADDR_MEM,
			O_WR_DATA	=> WR_DATA_MEM
		);

	id_if_registers_0: id_if_registers
		port map (
			I_CLK		=> I_CLK,
			I_RST		=> I_RST,
			I_EN		=> I_IF_EN,
			I_TARGET	=> TARGET_ID,
			I_TAKEN		=> TAKEN_ID,
			O_TARGET	=> TARGET_ID_REG,
			O_TAKEN		=> TAKEN_ID_REG
		);

	O_TAKEN_PREV <= TAKEN_ID_REG;

	if_id_registers_0: if_id_registers
		port map (
			I_CLK	=> I_CLK,
			I_RST	=> I_RST,
			I_EN	=> I_IF_EN,
			I_NPC	=> NPC_IF,
			I_IR	=> IR_IF,
			O_NPC	=> NPC_IF_REG,
			O_IR	=> IR_IF_REG
		);

	id_ex_registers_0: id_ex_registers
		port map (
			I_CLK		=> I_CLK,
			I_RST		=> I_RST,
			I_A		=> RD1_ID,
			I_B		=> RD2_ID,
			I_IMM		=> IMM_ID,
			I_NPC		=> NPC_IF_REG,
			I_DST		=> I_DST,
			I_SIGNED	=> I_SIGNED,
			I_ALUOP		=> I_ALUOP,
			I_SEL_A		=> I_SEL_A,
			I_SEL_B		=> I_SEL_B,
			I_SEL_B_IMM	=> I_SEL_B_IMM,
			I_LD		=> I_LD,
			I_STR		=> I_STR,
			O_A		=> RD1_ID_REG,
			O_B		=> RD2_ID_REG,
			O_IMM		=> IMM_ID_REG,
			O_NPC		=> NPC_ID_REG,
			O_DST		=> DST_ID_REG,
			O_SIGNED	=> SIGNED_CU_REG,
			O_ALUOP		=> ALUOP_CU_REG,
			O_SEL_A		=> SEL_A_CU_REG,
			O_SEL_B		=> SEL_B_CU_REG,
			O_SEL_B_IMM	=> SEL_B_IMM_CU_REG,
			O_LD		=> LD_CU_REG,
			O_STR		=> STR_CU_REG
		);

	O_DST_EX	<= DST_ID_REG;
	O_LD_EX		<= LD_CU_REG;

	ex_mem_registers_0: ex_mem_registers
		port map (
			I_CLK		=> I_CLK,
			I_RST		=> I_RST,
			I_ADDR		=> ALUOUT_EX,
			I_DATA		=> RD1_ID_REG,
			I_DST		=> DST_ID_REG,
			I_SIGNED	=> SIGNED_CU_REG,
			I_LD		=> LD_CU_REG,
			I_STR		=> STR_CU_REG,
			I_SEL_DATA	=> SEL_B_CU_REG,
			O_ADDR		=> ALUOUT_EX_REG,
			O_DATA		=> DATA_EX_REG,
			O_DST		=> DST_EX_REG,
			O_SIGNED	=> SIGNED_EX_REG,
			O_LD		=> LD_EX_REG,
			O_STR		=> STR_EX_REG,
			O_SEL_DATA	=> SEL_B_EX_REG
		);

	O_DST_MEM	<= DST_EX_REG;
	O_LD_MEM	<= LD_EX_REG;

	mem_wb_registers_0: mem_wb_registers
		port map (
			I_CLK		=> I_CLK,
			I_RST		=> I_RST,
			I_LOADED	=> LOADED_MEM,
			I_ALUOUT	=> ALUOUT_EX_REG,
			I_DST		=> DST_EX_REG,
			I_LD		=> LD_EX_REG,
			O_LOADED	=> LOADED_MEM_REG,
			O_ALUOUT	=> ALUOUT_MEM_REG,
			O_DST		=> DST_MEM_REG,
			O_LD		=> LD_MEM_REG
		);

	wb_mem_registers_0: wb_mem_registers
		port map (
			I_CLK	=> I_CLK,
			I_RST	=> I_RST,
			I_LOADED=> LOADED_MEM_REG,
			I_ALUOUT=> ALUOUT_EX_REG,
			O_LOADED=> LOADED_WB_REG,
			O_ALUOUT=> ALUOUT_WB_REG
		);

	register_file_0: register_file
		generic map (
			NBIT	=> RF_DATA_SZ,
			NLINE	=> 2 ** RF_ADDR_SZ
		)
		port map (
			CLK	=> I_CLK,
			RESET	=> I_RST,
			RD1	=> '1',
			RD2	=> '1',
			WR	=> WR_MEM,
			ADD_WR	=> WR_ADDR_MEM,
			ADD_RD1	=> RD1_ADDR_ID,
			ADD_RD2	=> RD2_ADDR_ID,
			DATAIN	=> WR_DATA_MEM,
			OUT1	=> RD1_DATA_RF,
			OUT2	=> RD2_DATA_RF
		);
end STRUCTURAL;

