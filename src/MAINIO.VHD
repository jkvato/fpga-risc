library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity mainio is
   port (CLOCK, RESET: in STD_LOGIC;
         ADDR: in STD_LOGIC_VECTOR (15 downto 0);
         D_IN: in STD_LOGIC_VECTOR (15 downto 0);
         D_OUT: out STD_LOGIC_VECTOR (15 downto 0);
         AS:  in STD_LOGIC;
         BTN1: in std_logic;
         LED1: out std_logic
   );
end mainio;

architecture inside of mainio is

constant ADD0205: STD_LOGIC_VECTOR (15 downto 0) := "0000001000000101";
constant ADD0206: STD_LOGIC_VECTOR (15 downto 0) := "0000001000000110";

signal LED_STATE : std_logic;

begin
   process (RESET, CLOCK, AS, ADDR, BTN1, D_IN)
   begin
      if RESET = '1' then
         LED_STATE <= '0';
      elsif CLOCK'event and CLOCK = '1' then
         if AS = '1' then
            case ADDR is
               when ADD0205 =>
                  D_OUT (15 downto 1) <= (others => '0');
                  D_OUT (0) <= BTN1;
               when ADD0206 =>
                  LED_STATE <= D_IN (0);
               when others =>
            end case;
         end if;
      end if;
   end process;
end inside;
