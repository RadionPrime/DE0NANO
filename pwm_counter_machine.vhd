library ieee;
use ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity pwm_counter_machine is

	generic
	(
      sys_clk         : INTEGER := 300_000_000; --czestotliwosc zegara takujacego blok pwm
      pwm_freq_res    : INTEGER := 8;          --szerokosc bitow rodzielczosci czestotliwosci(tzn zakres)
      bits_resolution : INTEGER := 12           --rodzielczosc bitowa pwm-u    
	);

	port
	(
	   clk           : IN  STD_LOGIC;                                    --wejscie zegara
      reset_n       : IN  STD_LOGIC;                                    --reset aktywny niskim
      ena           : IN  STD_LOGIC;                                    --wejscie enable
      duty_bit      : IN  STD_LOGIC_VECTOR(bits_resolution-1 DOWNTO 0); --wartosci wypelnienia
		freq_input    : IN  STD_LOGIC_VECTOR(7 DOWNTO 0); 					   --wartosc czestoliwosci
      pwm_out       : OUT STD_LOGIC;          								   --wyjscie pwm
      pwm_n_out     : OUT STD_LOGIC;         									   --odwrocone wyjscie pwm
		pwm_new_cycle : OUT STD_LOGIC
	);

end entity;

architecture rtl of pwm_counter_machine is

signal   period    : integer range sys_clk/((2**bits_resolution)*1000) to sys_clk/1000  := sys_clk/(((to_integer(unsigned(freq_input)))+1)*1000); 
-- period to ilosc cykli zegara na okres bloku  
-- wartosc PWM sys_clk/((2**bits_resolution)*1000) to minimalana przy czestoliwosci 256kHz
-- wartosc sys_clk/1000 to wartosc maksymalna 1kHz
-- := sys_clk/(((to_integer(unsigned(freq_input)))+1)*1000); Przeliczenie czestotliwosci na okres wyglada następujaco
--1 Konwersja wartosci w formacie STD_LOGIC_VECTOR na całkowitą bez znaku
--2 Dodanie jedynki w celu unikniecia operacji dzielenia i mnożenia przez zero, mnożenie przez 1000 
--3 Dzielenie czestoliwoci zegara systemowego przez uzyskana wartosc z poprzednich krokow
signal   duty		 : integer range 0 to sys_clk/1000; -- wartosci wypelnienia
signal   count     : integer range 0 to sys_clk/1000; -- wartosc ktora jest inkrementowana
	
begin
	process (clk)
	   begin
		if (rising_edge(clk)) then

			if reset_n = '0' then -- stan niski powoduje reset wartosci sygnalow duty i count
				duty  <= 0;
				count <= 0;
			elsif ena = '1' then -- blok dziala tylko przy stanie wysokim na wejsciu ena i reset_N
				period <= sys_clk/(((to_integer(unsigned(freq_input)))+1)*1000); --przypisanie nowego okresu(ilosc cykli zegarowych)
				duty <= to_integer(unsigned(duty_bit))*period/(2**bits_resolution); -- obliczanie wartosci wypelenienia
				--wartosc na wejsciu jest przeliczana na liczbe w rejestrze(sygnale) duty wedlug wzoru duty = (duty_wejscie * okres) / 2^liczba_bitow_rozdzielczosci
				if(count = period) then -- zerowanie licznika gdy osiągnie wartosc równa okresowi.                  
				count <= 0;                                                     
				else -- w przeciwnym wypdaku inkrementacja                                                               
				count <= count + 1;                                        
				end if;
				if(count < 100) then
				pwm_new_cycle <= '1';
				else
				pwm_new_cycle <= '0';
				end if;		
				if(count >= duty) then  -- jesli wartosc licznika jest wieksza lub rowna wystaw stan wysoki na wyjsciu zanegowany a niski na normalnym                               
					pwm_out <= '0';                                                 
					pwm_n_out <= '1';                                               
				elsif(count < duty) then -- w przeciwnym wypadku wystaw stan wysoki na normalnym wyjsciu a niski na negujacym                         
					pwm_out <= '1';                                                 
					pwm_n_out <= '0';                                               
				end if;
			end if;
		end if;
	end process;

end rtl;
