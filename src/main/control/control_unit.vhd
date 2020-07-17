library ieee;
use ieee.std_logic_1164.all;
use work.coding.all;

entity control_unit is
	port (
		I_CLK:		in std_logic;
		I_RST:		in std_logic;

		-- to CU
		I_OPCODE:	in std_logic_vector(OPCODE_SZ - 1 downto 0);
		I_FUNC:		in std_logic_vector(FUNC_SZ - 1 downto 0);

		-- to IF stage
		O_IF_EN:	out std_logic;

		-- to ID stage
		O_ID_EN:	out std_logic;

		-- to EX stage
		O_EX_EN:	out std_logic;
		O_OP1:		out std_logic;
		O_OP2:		out std_logic;
		O_ALUOP:	out aluop_t;

		-- to MEM stage
		O_MEM_EN:	out std_logic;
		O_LD:		out std_logic;
		O_STR:		out std_logic;

		-- to WB stage
		O_WB_EN:	out std_logic
	);
end control_unit;

architecture FSM of control_unit is
	component instr_decoder is
		port (
			-- from ID stage
			I_FUNC:		in std_logic_vector(FUNC_SZ - 1 downto 0);
			I_OPCODE:	in std_logic_vector(OPCODE_SZ - 1 downto 0);

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
			O_WB_DST:	out std_logic_vector(R_DST_SZ - 1 downto 0)
		);
	end component instr_decoder;

	type state_t is (
		STATE_INIT,
		STATE_RUNNING
	);

	signal ST_CURR:	state_t;
	signal ST_NEXT:	state_t;
begin
	id: inst_decoder
		port map (
			I_FUNC	=> I_FUNC,
			I_OPCODE=> I_OPCODE,
			O_BRANCH=> O_BRANCH,
			O_ALUOP	=> O_ALUOP,
			O_OP1	=> O_OP1,
			O_OP2	=> O_OP2,
			O_LD	=> O_LD,
			O_STR	=> O_STR,
			O_WB_DST=> O_WB_DST
		);

	state_reg: process (I_CLK)
	begin
		if (I_CLK = '1' AND I_CLK'event) then
			if (I_RST = '1') then
				ST_CURR	<= STATE_INIT;
			else
				ST_CURR	<= ST_NEXT;
			end if;
		end if;
	end process state_reg;

	comb_logic: process (ST_CURR)
	begin
		case (ST_CURR) is
			when STATE_INIT		=>
			when STATE_RUNNING	=>
			when others		=>
		end case;
	end process comb_logic;
end FSM;

