-- John Taylor
-- ecevato@yahoo.com

library IEEE;
use IEEE.std_logic_1164.all;

entity test is
   port (CLOCK_IN, RESET_IN: in STD_LOGIC;
         SW_1, SW_2, SW_3, SW_4, SW_5, SW_6, SW_7, SW_8: in STD_LOGIC;
         DS0, DS1, DS2: out STD_LOGIC;
         A1, A2, A3, A4: out STD_LOGIC;
         D0, D1, D2, D3, D4, D5, D6, D7: out STD_LOGIC
   );
end entity;

architecture inside of test is

signal CLK, RST: std_logic;
component DLL_DIV
    port (CLKIN : in  std_logic;
          RESET : in  std_logic;
          CLK0  : out std_logic;
          CLKDV : out std_logic;
          LOCKED: out std_logic;
          RST:    out std_logic);
end component;

component SWITCHES
   port (ADDR: in STD_LOGIC_VECTOR (15 downto 0);
         ALE:  in STD_LOGIC;
         SW1, SW2, SW3, SW4, SW5, SW6, SW7, SW8: in STD_LOGIC;
         D_OUT: out STD_LOGIC_VECTOR (15 downto 0)
   );
end component;

component IO2
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
end component;

signal A200: STD_LOGIC_VECTOR (15 downto 0);
signal ZEROS: STD_LOGIC_VECTOR (15 downto 0);
signal ONE: STD_LOGIC;
signal DATA: STD_LOGIC_VECTOR (15 downto 0);

signal A: STD_LOGIC_VECTOR (3 downto 0);
signal D: STD_LOGIC_VECTOR (7 downto 0);

begin
   A1 <= A (0);
   A2 <= A (1);
   A3 <= A (2);
   A4 <= A (3);
   D0 <= D (0);
   D1 <= D (1);
   D2 <= D (2);
   D3 <= D (3);
   D4 <= D (4);
   D5 <= D (5);
   D6 <= D (6);
   D7 <= D (7);

   ONE <= '1';
   A200 <= "0000001000000000";
   ZEROS <= "0000000000000000";

   U_DLL: DLL_DIV port map (CLKIN=>CLOCK_IN, RESET=>RESET_IN, CLK0=>open,
                            CLKDV=>CLK, LOCKED=>open, RST=>RST);

   U_SW : SWITCHES port map (ADDR=>ZEROS, ALE=>ONE, D_OUT=>DATA,
                             SW1=>SW_1, SW2=>SW_2, SW3=>SW_3, SW4=>SW_4,
                             SW5=>SW_5, SW6=>SW_6, SW7=>SW_7, SW8=>SW_8);

   U_IO : IO2 port map (CLOCK=>CLK, RESET=>RST, ADDR=>A200, D_IN=>DATA, AS=>ONE,
                       SEG_OE=>ONE, LED_OE=>ONE, DS0=>DS0, DS1=>DS1, DS2=>DS2,
                       LCD_RS=>open, LCD_RD=>open, LCD_E=>open,
                       A=>A, D=>D);
end architecture;

