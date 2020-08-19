library IEEE;
use IEEE.std_logic_1164.all;
use work.utilities.all;

entity tb_utilities is
end tb_utilities;

architecture TB_ARCH of tb_utilities is
	constant N_BIT:		integer := 32;
	
	constant WAIT_TIME:	time := 2 ns;

	signal LITTLE:		std_logic_vector(N_BIT - 1 downto 0);
	signal BIG:		std_logic_vector(N_BIT - 1 downto 0);
begin
	BIG <= swap_bytes(LITTLE);

	stimuli: process
	begin
		LITTLE <= x"0A0B0C0D";
		wait for WAIT_TIME;
		assert BIG = x"0D0C0B0A"
		report "little to big endian conversion failed";

		wait;
	end process stimuli;
end TB_ARCH;

