-- John Taylor
-- ecevato@yahoo.com

library IEEE;
use IEEE.std_logic_1164.all;

entity LEDTOP2 is
   port (CLOCK_IN, RESET_IN : in STD_LOGIC;
         DS0, DS1, LCD_RS, LCD_RW, LCD_E: out STD_LOGIC;
         BC: in STD_LOGIC_VECTOR (5 downto 0);
         KBD_CLK, KBD_DATA: in STD_LOGIC;
         D: out STD_LOGIC_VECTOR (7 downto 0);
         SW: in STD_LOGIC_VECTOR (7 downto 0)
   );
end entity;

architecture inside of LEDTOP2 is

signal CLK, RST: std_logic;
component DLL_DIV_R
    port (CLKIN : in  std_logic;
          RESET : in  std_logic;
          CLK0  : out std_logic;
          CLKDV : out std_logic;
          LOCKED: out std_logic;
          RST:    out std_logic);
end component;

signal DATA_IN, DATA_OUT, ADDR_OUT: STD_LOGIC_VECTOR (15 downto 0);
signal AS, INT_REQ, INT_ACK : STD_LOGIC;
signal INT_REQUEST1, INT_REQUEST2 : STD_LOGIC;
signal LOW, HIGH: STD_LOGIC;

component CPU
   port (DATA_BUS_IN: in STD_LOGIC_VECTOR (15 downto 0);
         DATA_BUS_OUT: out STD_LOGIC_VECTOR (15 downto 0);
         ADDRESS_BUS_OUT: out STD_LOGIC_VECTOR (15 downto 0);
         INT_REQ: in STD_LOGIC;
         AS, INT_ACK: out STD_LOGIC;
         CLOCK, RESET: in STD_LOGIC
   );
end component;

component SWITCHES
   port (CLK, RST: in STD_LOGIC;
         ADDR: in STD_LOGIC_VECTOR (15 downto 0);
         AS, INT_ACK:  in STD_LOGIC;
         INT_REQ: out STD_LOGIC;
         SW: in STD_LOGIC_VECTOR (7 downto 0);
         D_OUT: out STD_LOGIC_VECTOR (15 downto 0)
   );
end component;

component buttons2
   port (CLK, RST: in STD_LOGIC;
         ADDR: in STD_LOGIC_VECTOR (15 downto 0);
         AS, INT_ACK:  in STD_LOGIC;
         INT_REQ: out STD_LOGIC;
         BC: in STD_LOGIC_VECTOR (5 downto 0);
         D_OUT: out STD_LOGIC_VECTOR (15 downto 0)
   );
end component;

component outputs
    Port ( CLK, RST: in std_logic;
           AS: in std_logic;
           D_IN: in std_logic_vector (15 downto 0);
           ADDR: in std_logic_vector (15 downto 0);
           D_OUT: out std_logic_vector (15 downto 0)
    );
end component;

component KEYBOARD
   port (KBD_CLK, KBD_DATA: in STD_LOGIC;
         CLOCK, RESET: in STD_LOGIC;
         DATA_OUT: out STD_LOGIC_VECTOR (15 downto 0);
         READY: out STD_LOGIC
   );
end component;

begin
   LOW <= '0';
   HIGH <= '1';

   DLL1 : DLL_DIV_R port map (CLKIN=>CLOCK_IN, RESET=>RESET_IN, CLK0=>open,
                              CLKDV=>CLK, LOCKED=>open, RST=>RST);

   CPU1 : CPU port map (DATA_BUS_IN=>DATA_IN, DATA_BUS_OUT=>DATA_OUT, ADDRESS_BUS_OUT=>ADDR_OUT,
                        INT_REQ=>INT_REQ, AS=>AS, INT_ACK=>INT_ACK, CLOCK=>CLK, RESET=>RST
                        );

--   SW1  : SWITCHES port map (CLK=>CLK, RST=>RST, ADDR=>ADDR_OUT, AS=>AS,
--                             INT_ACK=>INT_ACK, INT_REQ=>INT_REQ,
--                             SW=>SW, D_OUT=>DATA_IN
--                             );

   BTNS2: buttons2 port map (CLK=>CLK, RST=>RST, ADDR=>ADDR_OUT, AS=>AS, INT_ACK=>INT_ACK,
                             INT_REQ=>INT_REQUEST1, BC=>BC, D_OUT=>DATA_IN
                            );

   OUT1 : outputs port map (CLK=>CLK, RST=>RST, AS=>AS, D_IN=>DATA_OUT, ADDR=>ADDR_OUT,
                            D_OUT(7 downto 0)=>D, D_OUT(8)=>LCD_RW, D_OUT(9)=>LCD_RS,
                            D_OUT(10)=>LCD_E, D_OUT(11)=>DS0, D_OUT(12)=>DS1,
                            D_OUT(15 downto 13)=>open
                           );

   KBD1 : KEYBOARD port map (KBD_CLK=>KBD_CLK, KBD_DATA=>KBD_DATA,
                             CLOCK=>CLK, RESET=>RST, DATA_OUT=>DATA_IN,
                             READY=>INT_REQUEST2
                            );

   INT_REQ <= INT_REQUEST1 or INT_REQUEST2;

end architecture;

