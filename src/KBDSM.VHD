-- John Taylor
-- ecevato@yahoo.com

library IEEE;
use IEEE.std_logic_1164.all;

entity KBD_SM is
   port (KBD_CLK, KBD_DATA, RESET: in STD_LOGIC;
         DATA: out STD_LOGIC_VECTOR (7 downto 0);
         DATA_READY: out STD_LOGIC );
end entity;

architecture inside of KBD_SM is

type STATE_TYPE is (START, DATA0, DATA1, DATA2, DATA3, DATA4, 
                    DATA5, DATA6, DATA7, PARITY, STOP_BIT);
signal STATE: STATE_TYPE;

--constant START   : STD_LOGIC_VECTOR (10 downto 0) := "00000000001"; -- 001
--constant DATA0   : STD_LOGIC_VECTOR (10 downto 0) := "00000000010"; -- 002
--constant DATA1   : STD_LOGIC_VECTOR (10 downto 0) := "00000000100"; -- 004
--constant DATA2   : STD_LOGIC_VECTOR (10 downto 0) := "00000001000"; -- 008
--constant DATA3   : STD_LOGIC_VECTOR (10 downto 0) := "00000010000"; -- 010
--constant DATA4   : STD_LOGIC_VECTOR (10 downto 0) := "00000100000"; -- 020
--constant DATA5   : STD_LOGIC_VECTOR (10 downto 0) := "00001000000"; -- 040
--constant DATA6   : STD_LOGIC_VECTOR (10 downto 0) := "00010000000"; -- 080
--constant DATA7   : STD_LOGIC_VECTOR (10 downto 0) := "00100000000"; -- 100
--constant PARITY  : STD_LOGIC_VECTOR (10 downto 0) := "01000000000"; -- 200
--constant STOP_BIT: STD_LOGIC_VECTOR (10 downto 0) := "10000000000"; -- 400
--signal STATE: STD_LOGIC_VECTOR (10 downto 0);

signal PARITY_BIT: STD_LOGIC;

begin
   process (KBD_CLK, RESET)
   begin
      if (RESET='1') then
         STATE <= START;
         DATA <= "00000000";
         DATA_READY <= '0';
         PARITY_BIT <= '1';
      elsif (KBD_CLK'event and KBD_CLK = '0') then
         case STATE is

            when START =>
               PARITY_BIT <= '1';
               DATA_READY <= '0';
               DATA <= "00000000";
               if KBD_DATA = '0' then
                  STATE <= DATA0;
               end if;

            -- DATA0 state: we have just received data bit 0
            when DATA0 =>
               DATA(0) <= KBD_DATA;
               if KBD_DATA = '1' then
                  PARITY_BIT <= not PARITY_BIT;
               end if;
               STATE <= DATA1;

            -- DATA1 state: we have just received data bit 1
            when DATA1 =>
               DATA(1) <= KBD_DATA;
               if KBD_DATA = '1' then
                  PARITY_BIT <= not PARITY_BIT;
               end if;
               STATE <= DATA2;

            -- DATA2 state: we have just received data bit 2
            when DATA2 =>
               DATA(2) <= KBD_DATA;
               if KBD_DATA = '1' then
                  PARITY_BIT <= not PARITY_BIT;
               end if;
               STATE <= DATA3;

            -- DATA3 state: we have just received data bit 3
            when DATA3 =>
               DATA(3) <= KBD_DATA;
               if KBD_DATA = '1' then
                  PARITY_BIT <= not PARITY_BIT;
               end if;
               STATE <= DATA4;

            -- DATA4 state: we have just received data bit 4
            when DATA4 =>
               DATA(4) <= KBD_DATA;
               if KBD_DATA = '1' then
                  PARITY_BIT <= not PARITY_BIT;
               end if;
               STATE <= DATA5;

            -- DATA5 state: we have just received data bit 5
            when DATA5 =>
               DATA(5) <= KBD_DATA;
               if KBD_DATA = '1' then
                  PARITY_BIT <= not PARITY_BIT;
               end if;
               STATE <= DATA6;

            -- DATA6 state: we have just received data bit 6
            when DATA6 =>
               DATA(6) <= KBD_DATA;
               if KBD_DATA = '1' then
                  PARITY_BIT <= not PARITY_BIT;
               end if;
               STATE <= DATA7;

            -- DATA7 state: we have just received data bit 7
            when DATA7 =>
               DATA(7) <= KBD_DATA;
               if KBD_DATA = '1' then
                  PARITY_BIT <= not PARITY_BIT;
               end if;
               STATE <= PARITY;

            when PARITY =>
               if KBD_DATA = PARITY_BIT then
                  DATA_READY <= '1';
                  STATE <= STOP_BIT;
               else
                  STATE <= START;
               end if;

            when STOP_BIT =>
               DATA_READY <= '0';
               STATE <= START;

            when others =>
               STATE <= START;
         end case;
      end if;
   end process;

end architecture;

