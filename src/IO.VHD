-- John Taylor
-- ecevato@yahoo.com

-- Addresses:
-- 0200 : I/O board 7-segment display
-- 0201 : I/O board LEDs
-- 0202 : I/O board LCD display
-- 0203 : On-board LEDs
-- 0204 : On-board switches

library IEEE;
use IEEE.std_logic_1164.all;

entity IO is
   port (ADDR: in STD_LOGIC_VECTOR (15 downto 0);
         D_IN: in STD_LOGIC_VECTOR (15 downto 0);
         ALE:  in STD_LOGIC;
         CLOCK, RESET: in STD_LOGIC;
         DS0, DS1, DS2: out STD_LOGIC;
         LCD_RS, LCD_RD, LCD_E: out STD_LOGIC;
         A1, A2, A3, A4: out STD_LOGIC;
         D0, D1, D2, D3, D4, D5, D6, D7: out STD_LOGIC
   );
end entity;

architecture inside of IO is

--subtype TIMER_TYPE is integer range 0 to 15;
--constant STEP1: TIMER_TYPE :=  0;
--constant STEP2: TIMER_TYPE :=  2;
--constant STEP3: TIMER_TYPE :=  4;
--constant STEP4: TIMER_TYPE :=  8;
--constant STEP5: TIMER_TYPE := 10;
--constant STEP6: TIMER_TYPE := 12;

subtype TIMER_TYPE is integer range 0 to 8191;
constant STEP1: TIMER_TYPE :=    0;
constant STEP2: TIMER_TYPE := 1024;
constant STEP3: TIMER_TYPE := 2048;
constant STEP4: TIMER_TYPE := 4096;
constant STEP5: TIMER_TYPE := 5120;
constant STEP6: TIMER_TYPE := 6144;

constant ADD0200: STD_LOGIC_VECTOR (15 downto 0) := "0000001000000000";
constant ADD0201: STD_LOGIC_VECTOR (15 downto 0) := "0000001000000001";
constant ADD0202: STD_LOGIC_VECTOR (15 downto 0) := "0000001000000010";

signal LEDS: STD_LOGIC_VECTOR (15 downto 0);
signal SEGS: STD_LOGIC_VECTOR (15 downto 0);
signal LCD : STD_LOGIC_VECTOR (15 downto 0);

signal SEG1: STD_LOGIC_VECTOR (7 downto 0);
signal SEG2: STD_LOGIC_VECTOR (7 downto 0);
signal SEG3: STD_LOGIC_VECTOR (7 downto 0);
signal SEG4: STD_LOGIC_VECTOR (7 downto 0);

signal D: STD_LOGIC_VECTOR (7 downto 0);
signal LCD_TOSEND: STD_LOGIC;
signal TIMER: TIMER_TYPE;

begin
   process (RESET, CLOCK, ALE, ADDR, D_IN, TIMER, 
            SEG1, SEG2, SEG3, SEG4, LEDS, LCD, LCD_TOSEND)
   begin
      if RESET = '1' then
         SEGS <= (others => '0');
         LEDS <= (others => '0');
         LCD <= (others => '0');
         TIMER <= 0;
         LCD_TOSEND <= '0';
      elsif CLOCK'event and CLOCK = '1' then
         if ALE = '1' then
            case ADDR is
               when ADD0200 =>
                  SEGS <= D_IN;
                  --LCD_TOSEND <= '0';
               when ADD0201 =>
                  LEDS <= D_IN;
                  --LCD_TOSEND <= '0';
               when ADD0202 =>
                  LCD <= D_IN;
                  LCD_TOSEND <= '1';
               when others =>
                  --LCD_TOSEND <= '0';
            end case;
         else
            --LCD_TOSEND <= '0';
         end if;
         TIMER <= TIMER + 1;

         case TIMER is
            -- Latch 7-seg #1
            when STEP1 =>
               DS0 <= '0';
               DS1 <= '0';
               DS2 <= '1';
               A1 <= '1';
               A2 <= '0';
               A3 <= '0';
               A4 <= '0';
               LCD_E <= '0';
               D <= SEG1;
            -- Latch upper 8 LEDs
            when STEP2 =>
               DS0 <= '1';
               DS1 <= '0';
               DS2 <= '0';
               A1 <= '0';
               A2 <= '0';
               A3 <= '0';
               A4 <= '0';
               LCD_E <= '0';
               D <= LEDS (7 downto 0);
            -- Latch 7-seg #2
            when STEP3 =>
               DS0 <= '0';
               DS1 <= '0';
               DS2 <= '1';
               A1 <= '0';
               A2 <= '1';
               A3 <= '0';
               A4 <= '0';
               LCD_E <= '0';
               D <= SEG2;
            -- Latch 7-seg #3
            when STEP4 =>
               DS0 <= '0';
               DS1 <= '0';
               DS2 <= '1';
               A1 <= '0';
               A2 <= '0';
               A3 <= '1';
               A4 <= '0';
               LCD_E <= '0';
               D <= SEG3;
            -- Latch lower 8 LEDs
            when STEP5 =>
               DS0 <= '0';
               DS1 <= '1';
               DS2 <= '0';
               A1 <= '0';
               A2 <= '0';
               A3 <= '0';
               A4 <= '0';
               LCD_E <= '0';
               D <= LEDS (15 downto 8);
            -- Latch 7-seg #4
            when STEP6 =>
               DS0 <= '0';
               DS1 <= '0';
               DS2 <= '1';
               A1 <= '0';
               A2 <= '0';
               A3 <= '0';
               A4 <= '1';
               LCD_E <= '0';
               D <= SEG4;
            when others =>
               DS0 <= '0';
               DS1 <= '0';
               DS2 <= '0';
               A1 <= '0';
               A2 <= '0';
               A3 <= '0';
               A4 <= '0';
               if LCD_TOSEND = '1' then
                  D <= LCD (7 downto 0);
                  LCD_E <= '1';
                  LCD_TOSEND <= '0';
               else
                  D <= "--------";
                  LCD_E <= '0';
               end if;
         end case;
      end if;
   end process;

   with SEGS (3 downto 0) select
      SEG4 <= "11111001" when "0001",       --1 F9
              "10100100" when "0010",       --2 A4
              "10110000" when "0011",       --3 B0
              "10011001" when "0100",       --4 99
              "10010010" when "0101",       --5 92
              "10000010" when "0110",       --6 82
              "11111000" when "0111",       --7 F8
              "10000000" when "1000",       --8 80
              "10010000" when "1001",       --9 90
              "10001000" when "1010",       --A 88
              "10000011" when "1011",       --b 83
              "11000110" when "1100",       --C C6
              "10100001" when "1101",       --d A1
              "10000110" when "1110",       --E 86
              "10001110" when "1111",       --F 8E
              "11000000" when others;       --0 C0
   with SEGS (7 downto 4) select
      SEG3 <= "11111001" when "0001",       --1
              "10100100" when "0010",       --2
              "10110000" when "0011",       --3
              "10011001" when "0100",       --4
              "10010010" when "0101",       --5
              "10000010" when "0110",       --6
              "11111000" when "0111",       --7
              "10000000" when "1000",       --8
              "10010000" when "1001",       --9
              "10001000" when "1010",       --A
              "10000011" when "1011",       --b
              "11000110" when "1100",       --C
              "10100001" when "1101",       --d
              "10000110" when "1110",       --E
              "10001110" when "1111",       --F
              "11000000" when others;       --0

   with SEGS (11 downto 8) select
      SEG2 <= "11111001" when "0001",       --1
              "10100100" when "0010",       --2
              "10110000" when "0011",       --3
              "10011001" when "0100",       --4
              "10010010" when "0101",       --5
              "10000010" when "0110",       --6
              "11111000" when "0111",       --7
              "10000000" when "1000",       --8
              "10010000" when "1001",       --9
              "10001000" when "1010",       --A
              "10000011" when "1011",       --b
              "11000110" when "1100",       --C
              "10100001" when "1101",       --d
              "10000110" when "1110",       --E
              "10001110" when "1111",       --F
              "11000000" when others;       --0

   with SEGS (15 downto 12) select
      SEG1 <= "11111001" when "0001",       --1
              "10100100" when "0010",       --2
              "10110000" when "0011",       --3
              "10011001" when "0100",       --4
              "10010010" when "0101",       --5
              "10000010" when "0110",       --6
              "11111000" when "0111",       --7
              "10000000" when "1000",       --8
              "10010000" when "1001",       --9
              "10001000" when "1010",       --A
              "10000011" when "1011",       --b
              "11000110" when "1100",       --C
              "10100001" when "1101",       --d
              "10000110" when "1110",       --E
              "10001110" when "1111",       --F
              "11000000" when others;       --0

   D0 <= D (0);
   D1 <= D (1);
   D2 <= D (2);
   D3 <= D (3);
   D4 <= D (4);
   D5 <= D (5);
   D6 <= D (6);
   D7 <= D (7);
   LCD_RS <= LCD (9);
   LCD_RD <= LCD (8);
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

