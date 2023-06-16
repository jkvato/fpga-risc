-- John Taylor
-- ecevato@yahoo.com

library IEEE;
use IEEE.std_logic_1164.all;

entity SWITCHES is
   port (CLK, RST: in STD_LOGIC;
         ADDR: in STD_LOGIC_VECTOR (15 downto 0);
         AS, INT_ACK:  in STD_LOGIC;
         INT_REQ: out STD_LOGIC;
         SW: in STD_LOGIC_VECTOR (7 downto 0);
         D_OUT: out STD_LOGIC_VECTOR (15 downto 0)
   );
end entity;

architecture inside of SWITCHES is

constant WAITING_STATE   : STD_LOGIC_VECTOR (3 downto 0) := "0001";
constant REQUEST_STATE   : STD_LOGIC_VECTOR (3 downto 0) := "0010";
constant INTERRUPT1_STATE: STD_LOGIC_VECTOR (3 downto 0) := "0100";
constant INTERRUPT2_STATE: STD_LOGIC_VECTOR (3 downto 0) := "1000";

signal PREVIOUS, PREVIOUS_NEXT : STD_LOGIC_VECTOR (7 downto 0);

signal STATE, STATE_NEXT : STD_LOGIC_VECTOR (3 downto 0);
signal DATA, DATA_NEXT : STD_LOGIC_VECTOR (15 downto 0);

constant ADD0204: STD_LOGIC_VECTOR (15 downto 0) := "0000001000000100";
constant UPPER_BYTE: STD_LOGIC_VECTOR (7 downto 0) := "00000100";

begin
   process(STATE, SW, PREVIOUS, DATA, AS, ADDR, INT_ACK)
   begin
      case STATE is

         when WAITING_STATE =>
            DATA_NEXT <= UPPER_BYTE & SW;
            INT_REQ <= '0';
            --D_OUT <= "ZZZZZZZZZZZZZZZZ";
            D_OUT <= "0000000000000000";
            if PREVIOUS /= SW then
               STATE_NEXT <= REQUEST_STATE;
            else
               STATE_NEXT <= WAITING_STATE;
            end if;
            PREVIOUS_NEXT <= SW;

         when REQUEST_STATE =>
            DATA_NEXT <= DATA;
            INT_REQ <= '1';
            D_OUT <= DATA;
            if INT_ACK = '1' then
               STATE_NEXT <= INTERRUPT1_STATE;
            else
               STATE_NEXT <= REQUEST_STATE;
            end if;
            PREVIOUS_NEXT <= DATA (7 downto 0);

         when INTERRUPT1_STATE =>
            DATA_NEXT <= DATA;
            INT_REQ <= '1';
            D_OUT <= DATA;
            if AS = '1' and ADDR = ADD0204 then
               STATE_NEXT <= INTERRUPT2_STATE;
            else
               STATE_NEXT <= INTERRUPT1_STATE;
            end if;
            PREVIOUS_NEXT <= DATA (7 downto 0);

         when others =>
            DATA_NEXT <= DATA;
            INT_REQ <= '0';
            D_OUT <= DATA;
            STATE_NEXT <= WAITING_STATE;
            PREVIOUS_NEXT <= DATA (7 downto 0);

      end case;
   end process;

   process(CLK, RST, PREVIOUS_NEXT, STATE_NEXT, DATA_NEXT, SW)
   begin
      if RST = '1' then
         STATE <= WAITING_STATE;
         PREVIOUS <= SW;
         DATA <= "0000000000000000";
      elsif CLK'event and CLK = '1' then
         STATE <= STATE_NEXT;
         PREVIOUS <= PREVIOUS_NEXT;
         DATA <= DATA_NEXT;
      end if;
   end process;
end architecture;

