-- John Taylor
-- ecevato@yahoo.com

library IEEE;
use IEEE.std_logic_1164.all;

entity LEDS is
   port (ADDR: in STD_LOGIC_VECTOR (15 downto 0);
         D_IN: in STD_LOGIC_VECTOR (15 downto 0);
         ALE:  in STD_LOGIC;
         CLOCK, RESET: in STD_LOGIC;
         LED1: out STD_LOGIC;
         LED3: out STD_LOGIC;
         LED4: out STD_LOGIC
         );
end entity;

architecture inside of LEDS is

signal DATA: STD_LOGIC_VECTOR (15 downto 0);

begin
   process (RESET, CLOCK, ALE, ADDR, D_IN, DATA)
   begin
      if RESET = '1' then
         DATA <= (others => '0');
      elsif CLOCK'event and CLOCK = '1' then
         if ALE = '1' and ADDR = "0000001000000000" then
            DATA <= D_IN;
         else
            DATA <= DATA;
         end if;
      end if;
   end process;
   
   LED1 <= DATA (0);
   LED3 <= DATA (1);
   LED4 <= DATA (2);
end architecture;

