-- Quartus Prime VHDL Template
-- Binary Counter

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi_adc_reader is

	port
	(
		clk		   : in  std_logic;
		reset	      : in  std_logic;
		enable	   : in  std_logic;
		--channel_sel : in  std_logic_vector(2 downto 0);
		mosi		   : out std_logic;
		data_ready  : out  std_logic;
		miso		   : in  std_logic;
		sclk		   : out  std_logic;
		cs			   : out  std_logic;
		adc_val     : out  std_logic_vector(11 downto 0)
		
	);

end entity;

architecture rtl of spi_adc_reader is
signal temp_val : std_logic_vector(11 downto 0);
begin	
	process (clk)
		variable   cnt		    : integer range 0 to 15;
		variable   data		 : integer range 0 to 11;
	begin
		if enable = '1' then
		sclk <= clk;	
		end if;
		if (rising_edge(clk)) then

			if reset = '0' then
				-- Reset the counter to 0
				cnt := 0;
				cs  <= '1';

			elsif enable = '1' then
				
				 
				case cnt is
						when 3 =>
								mosi <= '0';
								data := 11;
						when 4 =>
								mosi <= '0';
						when 5 =>
								mosi <= '0';
						when others =>
						mosi <= '0';
				end case;
				if cnt >= 5 then
						temp_val(data) <= miso;
						data := data - 1;
				end if;
				if cnt = 15 then
					adc_val <= temp_val;
					data_ready <= '1';
					cs <= '1';
					else
					data_ready <= '0';
					cs <= '0';
				end if;
				
				-- Increment the counter if counting is enabled				
				cnt  := cnt + 1;		

			end if;
		end if;

		-- Output the current count
		
	end process;

end rtl;
