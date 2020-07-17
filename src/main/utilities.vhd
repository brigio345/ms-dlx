library IEEE;
use IEEE.std_logic_1164.all;

package utilities is
	function std_logic_vector_image (a: std_logic_vector) return string;
	function log2(i : natural) return integer;
	function log2_ceil(i : natural) return integer;
end package utilities;

package body utilities is
	function std_logic_vector_image (
		a:	 std_logic_vector
	) return string is
		variable str:	string(1 to a'length);
	begin
		for i in a'range loop
			str(a'length - i) := std_logic'image(a(i))(2);
		end loop;

		return str;
	end function;

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

