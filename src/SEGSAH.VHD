-- John Taylor
-- ecevato@yahoo.com

library IEEE;
use IEEE.std_logic_1164.all;

entity SEGS_AH is
   port (DATA : in STD_LOGIC_VECTOR (3 downto 0);
         SEGS : out STD_LOGIC_VECTOR (6 downto 0)
   );
end entity;

architecture inside of SEGS_AH is
begin
   with DATA select
      SEGS <= "0000110" when "0001",   --1
              "1011011" when "0010",   --2
              "1001111" when "0011",   --3
              "1100110" when "0100",   --4
              "1101101" when "0101",   --5
              "1111101" when "0110",   --6
              "0000111" when "0111",   --7
              "1111111" when "1000",   --8
              "1101111" when "1001",   --9
              "1110111" when "1010",   --A
              "1111100" when "1011",   --b
              "0111001" when "1100",   --C
              "1011110" when "1101",   --d
              "1111001" when "1110",   --E
              "1110001" when "1111",   --F
              "0111111" when others;   --0
end architecture;

-- segment encoding
--      0
--     ---  
--  5 |   | 1
--     ---   <- 6
--  4 |   | 2
--     ---
--      3

