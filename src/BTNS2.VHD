-- John Taylor
-- ecevato@yahoo.com

library IEEE;
use IEEE.std_logic_1164.all;

entity buttons2 is
   port (CLK, RST: in STD_LOGIC;
         ADDR: in STD_LOGIC_VECTOR (15 downto 0);
         AS, INT_ACK:  in STD_LOGIC;
         INT_REQ: out STD_LOGIC;
         BC: in STD_LOGIC_VECTOR (5 downto 0);
         D_OUT: out STD_LOGIC_VECTOR (15 downto 0)
   );
end entity;

architecture inside of buttons2 is
constant ZERO12   : std_logic_vector (11 downto 0) := "000000000000";
constant BUTTON12 : std_logic_vector (11 downto 0) := "100000000000";
begin
   process (BC)
   begin
      case BC is
         when "001010" =>
            D_OUT <= BUTTON12 & "0000";
            INT_REQ <= '1';
         when "000011" =>
            D_OUT <= BUTTON12 & "0001";
            INT_REQ <= '1';
         when "000110" =>
            D_OUT <= BUTTON12 & "0010";
            INT_REQ <= '1';
         when "001100" =>
            D_OUT <= BUTTON12 & "0011";
            INT_REQ <= '1';
         when "011000" =>
            D_OUT <= BUTTON12 & "0100";
            INT_REQ <= '1';
         when "110000" =>
            D_OUT <= BUTTON12 & "0101";
            INT_REQ <= '1';
         when "100001" =>
            D_OUT <= BUTTON12 & "0110";
            INT_REQ <= '1';
         when "000101" =>
            D_OUT <= BUTTON12 & "0111";
            INT_REQ <= '1';
         when "001001" =>
            D_OUT <= BUTTON12 & "1000";
            INT_REQ <= '1';
         when "010001" =>
            D_OUT <= BUTTON12 & "1001";
            INT_REQ <= '1';
         when "010010" =>
            D_OUT <= BUTTON12 & "1010";
            INT_REQ <= '1';
         when "100010" =>
            D_OUT <= BUTTON12 & "1011";
            INT_REQ <= '1';
         when "010100" =>
            D_OUT <= BUTTON12 & "1100";
            INT_REQ <= '1';
         when "100100" =>
            D_OUT <= BUTTON12 & "1101";
            INT_REQ <= '1';
         when "101000" =>
            D_OUT <= BUTTON12 & "1110";
            INT_REQ <= '1';
         when others =>
            D_OUT <= ZERO12 & "0000";
            INT_REQ <= '0';
      end case;
   end process;
end architecture;

