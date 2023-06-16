-- John Taylor
-- ecevato@yahoo.com

library IEEE;
use IEEE.std_logic_1164.all;

entity TOP is
   port (CLOCK_IN, RESET_IN : in STD_LOGIC;
         BTN1: in STD_LOGIC;
         LED1: out STD_LOGIC
   );
end entity;

architecture inside of TOP is

signal CLK, RST: std_logic;
component DLL_DIV
    port (CLKIN : in  std_logic;
          RESET : in  std_logic;
          CLK0  : out std_logic;
          CLKDV : out std_logic;
          LOCKED: out std_logic;
          RST:    out std_logic);
end component;

component IBUFG
      port (I : in STD_LOGIC; O : out std_logic);
end component;

signal DATA_IN, DATA_OUT, ADDR_OUT: STD_LOGIC_VECTOR (15 downto 0);
signal ALE: STD_LOGIC;
signal BTN1_G : STD_LOGIC;
signal LOW, HIGH: STD_LOGIC;

component CPU
   port (DATA_BUS_IN: in STD_LOGIC_VECTOR (15 downto 0);
         DATA_BUS_OUT: out STD_LOGIC_VECTOR (15 downto 0);
         ADDRESS_BUS_OUT: out STD_LOGIC_VECTOR (15 downto 0);
         INT_REQ: in STD_LOGIC;
         ALE: out STD_LOGIC;
         CLOCK, RESET: in STD_LOGIC
   );
end component;

component mainio
   port (CLOCK, RESET: in STD_LOGIC;
         ADDR: in STD_LOGIC_VECTOR (15 downto 0);
         D_IN: in STD_LOGIC_VECTOR (15 downto 0);
         D_OUT: out STD_LOGIC_VECTOR (15 downto 0);
         AS:  in STD_LOGIC;
         BTN1: in std_logic;
         LED1: out std_logic
   );
end component;

begin
   LOW <= '0';
   HIGH <= '1';
   --DATA_IN <= "0000000000000000";

   IBUFG1 : IBUFG  port map (I=>BTN1, O=>BTN1_G);

   DLL1 : DLL_DIV port map (CLKIN=>CLOCK_IN, RESET=>RESET_IN, CLK0=>open,
                            CLKDV=>CLK, LOCKED=>open, RST=>RST);

   CPU1 : CPU port map (DATA_BUS_IN=>DATA_IN, DATA_BUS_OUT=>DATA_OUT, ADDRESS_BUS_OUT=>ADDR_OUT,
                        INT_REQ=>LOW, ALE=>ALE, CLOCK=>CLK, RESET=>RST
                        );

   MAINIO1: mainio port map (CLOCK=>CLK, RESET=>RST,
                             ADDR=>ADDR_OUT, D_IN=>DATA_OUT, D_OUT=>DATA_IN,
                             AS=>ALE, BTN1=>BTN1_G, LED1=>LED1);
end architecture;

