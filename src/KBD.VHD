-- John Taylor
-- ecevato@yahoo.com

library IEEE;
use IEEE.std_logic_1164.all;

entity KEYBOARD is
   port (KBD_CLK, KBD_DATA: in STD_LOGIC;
         CLOCK, RESET: in STD_LOGIC;
         DATA_OUT: out STD_LOGIC_VECTOR (15 downto 0);
         READY: out STD_LOGIC
   );
end entity;

architecture inside of KEYBOARD is

signal DATA: STD_LOGIC_VECTOR (7 downto 0);
signal DATA_READY: STD_LOGIC;

component KBD_SM
   port (KBD_CLK, KBD_DATA, RESET: in STD_LOGIC;
         DATA: out STD_LOGIC_VECTOR (7 downto 0);
         DATA_READY: out STD_LOGIC );
end component;

component KBD_RSM
   port (CLOCK, RESET: in STD_LOGIC;
         DATA_READY_IN: in STD_LOGIC;
         DATA_IN: in STD_LOGIC_VECTOR (7 downto 0);
         DATA_OUT: out STD_LOGIC_VECTOR (7 downto 0);
         READY: out STD_LOGIC
   );
end component;

component IBUF
      port (I : in STD_LOGIC; O : out std_logic);
end component;

signal KBD_CLK_w : STD_LOGIC;

begin
   KBD_C : IBUF port map (I=>KBD_CLK, O=>KBD_CLK_w);

   KBDSM : KBD_SM port map (KBD_CLK=>KBD_CLK_W, KBD_DATA=>KBD_DATA,
                            RESET=>RESET, DATA=>DATA, DATA_READY=>DATA_READY);

   KBDRSM : KBD_RSM port map (CLOCK=>CLOCK, RESET=>RESET, DATA_READY_IN=>DATA_READY,
                              DATA_IN=>DATA, DATA_OUT=>DATA_OUT (7 downto 0), READY=>READY);

   DATA_OUT (15 downto 8) <= "00000001";
end architecture;

