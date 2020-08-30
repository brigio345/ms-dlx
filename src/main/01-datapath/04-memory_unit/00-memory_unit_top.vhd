library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.coding.all;
use work.types.all;
use work.utilities.all;

-- memory_unit: forward signals to data memory
entity memory_unit is
	port (
		-- I_ENDIAN: specify endianness of data memory
		--	- '0' => BIG endian
		--	- '1' => LITTLE endian
		I_ENDIAN:	in std_logic;
		I_MEM_SZ:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);

		-- from CU
		I_LD:		in std_logic_vector(1 downto 0);
		I_LD_SIGN:	in std_logic;
		I_STR:		in std_logic_vector(1 downto 0);
		I_SEL_DATA:	in source_t;

		-- from EX stage
		I_ADDR:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);

		-- from ID stage
		I_DATA:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);

		-- data forwarded from EX/MEM stages
		I_LOADED_EX:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);

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
end memory_unit;

architecture BEHAVIORAL of memory_unit is
	component mem_data_forwarder is
		port (
			-- from CU
			I_SEL_B:	in source_t;

			-- from EX stage forward unit
			I_B:		in std_logic_vector(RF_DATA_SZ - 1 downto 0);

			-- value loaded from memory by the instruction which was in EX
			--	stage when current instruction was in ID stage
			I_LOADED_EX:	in std_logic_vector(RF_DATA_SZ - 1 downto 0);

			-- forwarded data
			O_B:		out std_logic_vector(RF_DATA_SZ - 1 downto 0)
		);
	end component mem_data_forwarder;

	signal LOADED:	std_logic_vector(I_RD_DATA'range);
	signal WR_DATA:	std_logic_vector(O_WR_DATA'range);
	signal ADDR:	std_logic_vector(O_ADDR'range);
begin
	mem_data_forwarder_0: mem_data_forwarder
		port map (
			I_SEL_B		=> I_SEL_DATA,
			I_B		=> I_DATA,
			I_LOADED_EX	=> I_LOADED_EX,
			O_B		=> WR_DATA
		);

	align_addr: process (I_LD, I_STR, I_ADDR)
	begin
		if ((I_LD = "11") OR (I_STR = "11")) then
			-- word align
			ADDR	<= I_ADDR(I_ADDR'left downto 2) & "00";
		elsif ((I_LD = "10") OR (I_STR = "10")) then
			-- half-word align
			ADDR	<= I_ADDR(I_ADDR'left downto 1) & "0";
		else
			-- no align
			ADDR	<= I_ADDR;
		end if;
	end process align_addr;

	O_ADDR	<= ADDR;

	bound_check: process (ADDR, I_MEM_SZ, I_LD, I_STR)
	begin
		if (unsigned(ADDR) < unsigned(I_MEM_SZ)) then
			O_RD	<= I_LD;
			O_WR	<= I_STR;
		else
			-- disable memory access since address is out of
			--	allowed range
			O_RD	<= "00";
			O_WR	<= "00";
		end if;
	end process bound_check;

	-- convert output data to big endian, if data memory is big endian
	O_WR_DATA	<= WR_DATA when (I_ENDIAN = '1') else swap_bytes(WR_DATA);
	-- convert input data to little endian, if data memory is big endian
	LOADED	<= I_RD_DATA when (I_ENDIAN = '1') else swap_bytes(I_RD_DATA);

	extend: process (LOADED, I_LD_SIGN, I_LD)
	begin
		if (I_LD_SIGN = '1') then
			case I_LD is
				when "10"	=>
					O_LOADED <= sign_extend(LOADED, 15, RF_DATA_SZ);
				when "01"	=>
					O_LOADED <= sign_extend(LOADED, 7, RF_DATA_SZ);
				when others	=>
					O_LOADED <= LOADED;
			end case;
		else
			O_LOADED <= LOADED;
		end if;
	end process extend;
end BEHAVIORAL;

