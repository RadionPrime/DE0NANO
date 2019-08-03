-- Quartus Prime VHDL Template
-- Binary Counter

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm_simple_counter is	

	generic
	(
      bits_resolution : INTEGER := 8          --rodzielczosc bitowa pwm-u    
	);

	port
	(
		clk		  : in std_logic;
		reset	  	  : in std_logic;
		enable	  : in std_logic;
		duty_bit   : in  STD_LOGIC_VECTOR(bits_resolution-1 DOWNTO 0);
		pwm_out    : out STD_LOGIC;          								   
      pwm_n_out  : out STD_LOGIC  
	);

end entity;

architecture rtl of pwm_simple_counter is
begin

	process (clk)
		variable   cnt		   : integer range 0 to (2**bits_resolution-1);
		variable   duty		: integer range 0 to (2**bits_resolution-1); -- wartosci wypelnienia
	begin
		if (rising_edge(clk)) then

			if reset = '0' then
				-- Reset the counter to 0
				cnt := 0;

			elsif enable = '1' then
				-- Increment the counter if counting is enabled	
				duty := to_integer(unsigned(duty_bit));
				cnt := cnt + 1;
				if(cnt >= duty) then                                 
					pwm_out <= '0';                                                 
					pwm_n_out <= '1';                                               
				elsif(cnt < duty) then                         
					pwm_out <= '1';                                                 
					pwm_n_out <= '0'; 
				end if;
			end if;
		end if;
	end process;

end rtl;
