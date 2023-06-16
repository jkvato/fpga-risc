-- John Taylor
-- ecevato@yahoo.com

library IEEE;
use IEEE.std_logic_1164.all;

entity KBD_RSM is
   port (CLOCK, RESET: in STD_LOGIC;
         DATA_READY_IN: in STD_LOGIC;
         DATA_IN: in STD_LOGIC_VECTOR (7 downto 0);
         DATA_OUT: out STD_LOGIC_VECTOR (7 downto 0);
         READY: out STD_LOGIC
   );
end entity;

architecture inside of KBD_RSM is

--component KBD_SM
--   port (KBD_CLK, KBD_DATA, RESET: in STD_LOGIC;
--         DATA: out STD_LOGIC_VECTOR (7 downto 0);
--         DATA_READY: out STD_LOGIC );
--end component;

type STATE_TYPE is (ZERO, ONE);
signal STATE: STATE_TYPE;

begin
   DATA_OUT <= DATA_IN;
   process (RESET, CLOCK, STATE, DATA_IN)
   begin
      if RESET = '1' then
         READY <= '0';
         STATE <= ZERO;
      elsif CLOCK'event and CLOCK = '1' then
         case STATE is
            when ZERO =>
               if DATA_READY_IN = '1' then
                  STATE <= ONE;
                  READY <= '1';
               else
                  READY <= '0';
               end if;

            when ONE =>
               READY <= '0';
               if DATA_READY_IN = '0' then
                  STATE <= ZERO;
               end if;
         end case;
      end if;
   end process;
end architecture;

