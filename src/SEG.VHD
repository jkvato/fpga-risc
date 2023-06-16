-- John Taylor
-- ecevato@yahoo.com

library IEEE;
use IEEE.std_logic_1164.all;

entity SEGS is
   port (ADDR: in STD_LOGIC_VECTOR (15 downto 0);
         D_IN: in STD_LOGIC_VECTOR (15 downto 0);
         ALE:  in STD_LOGIC;
         CLOCK, RESET: in STD_LOGIC;
         A1, A2: out STD_LOGIC;
         D0, D1, D2, D3, D4, D5, D6: out STD_LOGIC
         );
end entity;

architecture inside of SEGS is

signal DATA: STD_LOGIC_VECTOR (15 downto 0);
signal DOUT: STD_LOGIC_VECTOR (3 downto 0);
signal D: STD_LOGIC_VECTOR (6 downto 0);
signal ALT: integer range 0 to 8191;

begin
   process (RESET, CLOCK, ALE, ADDR, D_IN, DATA, ALT)
   begin
      if RESET = '1' then
         DATA <= (others => '0');
         ALT <= 0;
      elsif CLOCK'event and CLOCK = '1' then
         if ALE = '1' and ADDR = "0000001000000010" then
            DATA <= D_IN;
         else
            DATA <= DATA;
         end if;
         ALT <= ALT + 1;
      end if;

      if ALT < 4096 then
         A1 <= '1';
         A2 <= '0';
         DOUT <= DATA (7 downto 4);
      else
         A1 <= '0';
         A2 <= '1';
         DOUT <= DATA (3 downto 0);
      end if;
   end process;

   with DOUT select
      D <= "1111001" when "0001",       --1 --4F --79
           "0100100" when "0010",       --2 --12 --24
           "0110000" when "0011",       --3 --06 --30
           "0011001" when "0100",       --4 --4C --19
           "0010010" when "0101",       --5 --24 --12
           "0000010" when "0110",       --6 --20 --02
           "1111000" when "0111",       --7 --0F --78
           "0000000" when "1000",       --8 --00 --00
           "0010000" when "1001",       --9 --04 --10
           "0001000" when "1010",       --A
           "0000011" when "1011",       --b
           "1000110" when "1100",       --C
           "0100001" when "1101",       --d
           "0000110" when "1110",       --E
           "0001110" when "1111",       --F
           "1000000" when others;  --0 --01 --40

   D0 <= D (0);
   D1 <= D (1);
   D2 <= D (2);
   D3 <= D (3);
   D4 <= D (4);
   D5 <= D (5);
   D6 <= D (6);
end architecture;

--HEX-to-seven-segment decoder
--	HEX:	in 	STD_LOGIC_VECTOR (3 downto 0);
--	LED:	out	STD_LOGIC_VECTOR (6 downto 0);
--
-- segment encoding
--      0
--     ---  
--  5 |   | 1
--     ---   <- 6
--  4 |   | 2
--     ---
--      3

