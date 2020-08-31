library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.coding.all;
use work.types.all;

entity tb_fetch_unit is
end tb_fetch_unit;

architecture TB_ARCH of tb_fetch_unit is
	component fetch_unit is
		port (
			-- I_ENDIAN: specify endianness of instruction memory
			--	- '0' => BIG endian
			--	- '1' => LITTLE endian
			I_ENDIAN:	in std_logic;
			I_MEM_SZ:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);

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

	constant WAIT_TIME:	time := 2 ns;

	signal ENDIAN:	std_logic;
	signal MEM_SZ:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal NPC_IN:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal TARGET:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal TAKEN:	std_logic;
	signal IR_IN:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal PC:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal NPC_OUT:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
	signal IR_OUT:	std_logic_vector(RF_DATA_SZ - 1 downto 0);
begin
	dut: fetch_unit
		port map (
			I_ENDIAN	=> ENDIAN,
			I_MEM_SZ	=> MEM_SZ,
			I_NPC		=> NPC_IN,
			I_TARGET	=> TARGET,
			I_TAKEN		=> TAKEN,
			I_IR		=> IR_IN,
			O_PC		=> PC,
			O_NPC		=> NPC_OUT,
			O_IR		=> IR_OUT
		);

	stimuli: process
	begin
		ENDIAN		<= '1';
		MEM_SZ		<= x"00000020";
		NPC_IN		<= x"01234567";
		TARGET		<= x"76543210";
		TAKEN		<= '0';
		IR_IN		<= x"AABBCCDD";

		wait for WAIT_TIME;
		assert ((PC = (NPC_IN(NPC_IN'left downto 2) & "00")) AND
				(NPC_OUT = std_logic_vector(unsigned(NPC_IN(NPC_IN'left downto 2) & "00") + 4)) AND
				(IR_OUT = (OPCODE_NOP & (IR_OUT'length - OPCODE_SZ - 1 downto 0 => '0'))))
			report "unexpected output detected when testing out of bound address";

		ENDIAN		<= '1';
		MEM_SZ		<= x"F0000020";
		NPC_IN		<= x"01234567";
		TARGET		<= x"76543210";
		TAKEN		<= '0';
		IR_IN		<= x"AABBCCDD";

		wait for WAIT_TIME;
		assert ((PC = (NPC_IN(NPC_IN'left downto 2) & "00")) AND
				(NPC_OUT = std_logic_vector(unsigned(NPC_IN(NPC_IN'left downto 2) & "00") + 4)) AND
				(IR_OUT = IR_IN))
			report "unexpected output detected when testing little endian";

		ENDIAN		<= '0';
		MEM_SZ		<= x"F0000020";
		NPC_IN		<= x"01234567";
		TARGET		<= x"76543210";
		TAKEN		<= '0';
		IR_IN		<= x"AABBCCDD";

		wait for WAIT_TIME;
		assert ((PC = (NPC_IN(NPC_IN'left downto 2) & "00")) AND
				(NPC_OUT = std_logic_vector(unsigned(NPC_IN(NPC_IN'left downto 2) & "00") + 4)) AND
				(IR_OUT = x"DDCCBBAA"))
			report "unexpected output detected when testing big endian";

		ENDIAN		<= '0';
		MEM_SZ		<= x"F0000020";
		NPC_IN		<= x"01234567";
		TARGET		<= x"76543210";
		TAKEN		<= '1';
		IR_IN		<= x"AABBCCDD";

		wait for WAIT_TIME;
		assert ((PC = (TARGET(TARGET'left downto 2) & "00")) AND
				(NPC_OUT = std_logic_vector(unsigned(TARGET(TARGET'left downto 2) & "00") + 4)) AND
				(IR_OUT = x"DDCCBBAA"))
			report "unexpected output detected when testing taken branch";

		wait;
	end process stimuli;
end TB_ARCH;

