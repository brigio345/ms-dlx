library ieee;
use ieee.std_logic_1164.all;

-- utilities: collection of common general purpose functions
package utilities is
	function swap_bytes (
		i_data:	std_logic_vector
	)
	return std_logic_vector;

	function sign_extend (
		I_DATA:		std_logic_vector;
		I_MSB:		integer;
		I_LENGTH:	integer
	)
	return std_logic_vector;

	function zero_extend (
		I_DATA:		std_logic_vector;
		I_LENGTH:	integer
	)
	return std_logic_vector;

	function log2 (
		i:	natural
	)
	return integer;

	function log2_ceil (
		i:	natural
	)
	return integer;
end package utilities;

package body utilities is
	function swap_bytes (
		i_data:	std_logic_vector
	)
	return std_logic_vector is
		variable o_data:std_logic_vector(i_data'range);
		variable l_in:	integer;
		variable r_in:	integer;
		variable l_out:	integer;
		variable r_out:	integer;
	begin
		for i in 0 to i_data'length / 8 - 1 loop
			r_in := i * 8;
			l_in := r_in + 7;
			
			l_out := i_data'length - r_in - 1;
			r_out := l_out - 7;

			o_data(l_out downto r_out) := i_data(l_in downto r_in);
		end loop;

		return o_data;
	end function swap_bytes;

	function sign_extend (
		I_DATA:		std_logic_vector;
		I_MSB:		integer;
		I_LENGTH:	integer
	)
	return std_logic_vector is
	begin
		return (I_LENGTH - 1 downto I_MSB + 1 => I_DATA(I_MSB)) &
			I_DATA(I_MSB downto 0);
	end function sign_extend;

	function zero_extend (
		I_DATA:		std_logic_vector;
		I_LENGTH:	integer
	)
	return std_logic_vector is
	begin
		return (I_LENGTH - 1 downto I_DATA'length => '0') &
			I_DATA(I_DATA'left downto 0);
	end function zero_extend;

	function log2(i : natural) return integer is
		variable temp    : integer := i;
		variable ret_val : integer := 0; 
	begin					
		while temp > 1 loop
			ret_val := ret_val + 1;
			temp    := temp / 2;     
		end loop;
					
		return ret_val;
	end function;

	function log2_ceil(i : natural) return integer is
		variable temp    : integer := i;
		variable ret_val : integer := 0; 
	begin					
		while temp > 1 loop
			ret_val := ret_val + 1;
			temp    := temp / 2;     
		end loop;

		if (2**ret_val < i) then
			ret_val := ret_val + 1;
		end if;
					
		return ret_val;
	end function;
end package body utilities;

