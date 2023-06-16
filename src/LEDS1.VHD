library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity leds1 is
    Port ( AS: in std_logic;
           D_IN: in std_logic_vector (15 downto 0);
           ADDR: in std_logic_vector (15 downto 0);
           D_OUT: out std_logic_vector (9 downto 0)
    );
end leds1;

architecture behavioral of leds1 is

signal data : std_logic_vector (9 downto 0);

begin
   process (AS, ADDR, D_IN)
   begin
      if AS = '1' and ADDR (9) = '1' then
         data <= D_IN (9 downto 0);
      else
         data <= data;
      end if;
   end process;
   D_OUT <= data;
end behavioral;
