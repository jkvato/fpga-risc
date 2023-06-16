-- John Taylor
-- ecevato@yahoo.com

-- The Digilab II I/O Board multiplexes a data bus (D0-D7) for use with
-- three devices: the 7-segment displays, the LEDs and the LCD display.
-- The IO entity takes care of the details of mutiplexing the data bus.
-- Address 0200 writes to the I/O board 7-segment display register
-- Address 0201 writes to the I/O board LEDs register
-- Address 0202 writes to the LCD display register
-- Address 0203 reads the I/O buttons
-- Address 0204 reads the I/O switches
-- One of the four 7-segment display digits is lit up at a time, each for
-- a fraction of a second.  If they are alternated fast enough, the four
-- digits will appear to be on simultaneously to the human eye.
-- A free-running counter runs from 0 to 32767 (15 digits), creating a
-- cycle of roughly 1.3 milliseconds.
-- Every time the counter is reset to 0, the next digit for the 7-segment
-- display is latched.  Every time the counter hits 1, the first 8 bits
-- of the LED register is latched to the lower 8 LEDs.  Every time the counter
-- hits 2, the last 8 bits of the LED register is latched to the upper 8 LEDs.
-- for the next 32764 clock pulses, the IO entity checks to see if there is
-- data in the LCD register waiting to be sent to the LCD.
-- Hence, each 7-segment display digit is refreshed every 1.3 ms, as are the
-- LEDs.
-- Data can be sent to the IO entity at any time.  If data is being multiplexed
-- to the 7-segment displays or to the LEDs while data is being sent to the LCD
-- register, then it will take at most 3 clock pulses for the data to be sent
-- to the LCD, which is insignificant compared to the relatively low operating
-- speed of LCD displays.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity IO is
   port (CLOCK, RESET: in STD_LOGIC;
         ADDR: in STD_LOGIC_VECTOR (15 downto 0);
         D_IN: in STD_LOGIC_VECTOR (15 downto 0);
         AS:  in STD_LOGIC;
         SEG_OE, LED_OE: in STD_LOGIC;
         DS0, DS1, DS2: out STD_LOGIC;
         LCD_RS, LCD_RD, LCD_E: out STD_LOGIC;
         A: out STD_LOGIC_VECTOR (3 downto 0);
         D: out STD_LOGIC_VECTOR (7 downto 0)
   );
end entity;

architecture inside of IO is

-- hex-to-7segment display component (active low outputs)
component SEGS_AL
   port (DATA : in STD_LOGIC_VECTOR (3 downto 0);
         SEGS : out STD_LOGIC_VECTOR (6 downto 0)
   );
end component;

signal COUNT : INTEGER range 0 to 15;              -- free-running counter (for simulation)
--signal COUNT : INTEGER range 0 to 32767;             -- free-running counter
signal CUR_DIGIT : STD_LOGIC_VECTOR (1 downto 0);    -- current digit being displayed

signal SEG_DATA : STD_LOGIC_VECTOR (15 downto 0);    -- 7-segment data register
signal LED_DATA : STD_LOGIC_VECTOR (15 downto 0);    -- LEDs data register
signal LCD_DATA : STD_LOGIC_VECTOR (15 downto 0);    -- LCD data register
signal DIGIT_DATA : STD_LOGIC_VECTOR (3 downto 0);   -- data representing 7-seg digit to be displayed
signal SEGS_OUT : STD_LOGIC_VECTOR (6 downto 0);     -- 7-segment data representing digit to be displayed
signal A_EN : STD_LOGIC_VECTOR (3 downto 0);         -- array of 4 common annode signals for the 7-segs
signal LCD_TOSEND : STD_LOGIC;                       -- is there data to be sent to the LCD?

constant ADD0200: STD_LOGIC_VECTOR (15 downto 0) := "0000001000000000";
constant ADD0201: STD_LOGIC_VECTOR (15 downto 0) := "0000001000000001";
constant ADD0202: STD_LOGIC_VECTOR (15 downto 0) := "0000001000000010";

begin
   -- instantiate the hex-to-7segment display entity
   UHEX2SEG : SEGS_AL port map (DATA=>DIGIT_DATA, SEGS=>SEGS_OUT);

   -- map bit 8 of the LCD data to LCD_RD, and bit 9 to LCD_RS
   LCD_RS <= LCD_DATA (9);
   LCD_RD <= LCD_DATA (8);

   process (RESET, CLOCK, CUR_DIGIT, SEG_DATA, LED_DATA, ADDR, AS, D_IN, SEGS_OUT, A_EN, LED_OE, SEG_OE)
   begin
      -- 7-segment output enable:
      -- if 1, then turn on current 7-segment digit
      -- if 0, turn off all 7-segment digits
      -- digits are turned off by sending '0' to all common annodes
      if SEG_OE = '1' then
         A <= A_EN;
      else
         A <= "0000";
      end if;

      if RESET = '1' then
         SEG_DATA <= "0000000000000000";
         LED_DATA <= "0000000000000000";
         LCD_DATA <= "0000000000000000";
         COUNT <= 0;
         CUR_DIGIT <= "00";
         LCD_TOSEND <= '0';

      elsif CLOCK'event and CLOCK = '1' then

         -- Check address strobe
         -- Check for valid data only when AS is high
         if AS = '1' then
            case ADDR is
               when ADD0200 =>         -- ADDR 0200 : update SEGs register
                  SEG_DATA <= D_IN;
               when ADD0201 =>         -- ADDR 0201 : update LEDs register
                  LED_DATA <= D_IN;
               when ADD0202 =>         -- ADDR 0202 : update LCD register
                  LCD_DATA <= D_IN;
                  LCD_TOSEND <= '1';
               when others =>
            end case;
         end if;

         case COUNT is
            -- When the free-running counter = 0, update the next 7-segment digit
            when 0 to 2 =>
               case CUR_DIGIT is
                  when "00" =>
                     DIGIT_DATA <= SEG_DATA (15 downto 12);   -- send most sig. digit to display
                     A_EN <= "0001";                          -- enable the first 7-seg digit
                  when "01" =>
                     DIGIT_DATA <= SEG_DATA (11 downto 8);    -- etc.
                     A_EN <= "0010";
                  when "10" =>
                     DIGIT_DATA <= SEG_DATA (7 downto 4);
                     A_EN <= "0100";
                  when others =>
                     DIGIT_DATA <= SEG_DATA (3 downto 0);
                     A_EN <= "1000";
               end case;

               D <= '1' & SEGS_OUT;
               DS0 <= '0';
               DS1 <= '0';
               if COUNT = 1 then
                  DS2 <= '1';
               else
                  DS2 <= '0';
               end if;

               -- Skip to the next digit
               if COUNT = 2 then
                  CUR_DIGIT <= CUR_DIGIT + 1;
               end if;

            -- Update the first 8 LEDs when the counter reaches 1
            when 3 to 5 =>
               DIGIT_DATA <= "----";
               if LED_OE = '1' then
                  D <= LED_DATA (7 downto 0);
               else
                  D <= "00000000";
               end if;
               A_EN <= A_EN;
               if COUNT = 4 then
                  DS0 <= '1';
               else
                  DS0 <= '0';
               end if;
               DS1 <= '0';
               DS2 <= '0';

            -- Update the second 8 LEDs when the counter reaches 2
            when 6 to 8 =>
               DIGIT_DATA <= "----";
               if LED_OE = '1' then
                  D <= LED_DATA (15 downto 8);
               else
                  D <= "00000000";
               end if;
               A_EN <= A_EN;
               DS0 <= '0';
               if COUNT = 7 then
                  DS1 <= '1';
               else
                  DS1 <= '0';
               end if;
               DS2 <= '0';

            -- Check to see if there's data to send to the LCD
            when others =>
               DIGIT_DATA <= "----";
               A_EN <= A_EN;
               DS0 <= '0';
               DS1 <= '0';
               DS2 <= '0';
               D <= LCD_DATA (7 downto 0);
               if LCD_TOSEND = '1' then
                  LCD_E <= '1';
                  LCD_TOSEND <= '0';
               else
                  LCD_E <= '0';
               end if;
         end case;

         -- Increment the free-running counter
         COUNT <= COUNT + 1;

      end if;
   end process;
end architecture;

-- For the 7-segment display data,
-- the following table correlates
-- D bus values to the digit being displayed:
-- F9 = 1
-- A4 = 2
-- B0 = 3
-- 99 = 4
-- 92 = 5
-- 82 = 6
-- F8 = 7
-- 80 = 8
-- 90 = 9
-- 88 = A
-- 83 = b
-- C6 = C
-- A1 = d
-- 86 = E
-- 8E = F
-- C0 = 0

