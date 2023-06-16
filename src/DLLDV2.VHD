-- John Taylor
-- ecevato@yahoo.com
-- XAPP174 

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

--library unisim;
--use unisim.vcomponents.all;

entity DLL_DIV2 is
    port (CLKIN : in  std_logic;
          RESET : in  std_logic;
          CLK0  : out std_logic;
          CLKDV : out std_logic;
          LOCKED: out std_logic;
          RST:    out std_logic);
end entity;

architecture structural of DLL_DIV2 is

component CLKDLL
      port (CLKIN, CLKFB, RST : in STD_LOGIC;
      CLK0, CLK90, CLK180, CLK270, CLK2X, CLKDV, LOCKED : out std_logic);
end component;

component IBUFG
      port (I : in STD_LOGIC; O : out std_logic);
end component;

component IBUF
      port (I : in STD_LOGIC; O : out std_logic);
end component;

component BUFG
      port (I : in STD_LOGIC; O : out std_logic);
end component;

signal CLKIN_w, RESET_w, CLK0_dll, CLK0_g, CLKDV_dll : std_logic;
signal COUNT : std_logic_vector (20 downto 0);
signal CLKDV_BUF : std_logic;
signal CLOCK_OUT : std_logic;

begin 

clkpad : IBUFG  port map (I=>CLKIN, O=>CLKIN_w);
rstpad : IBUF   port map (I=>RESET, O=>RESET_w);

dll    : CLKDLL port map (CLKIN=>CLKIN_w,   CLKFB=>CLK0_g, RST=>RESET_w,
                          CLK0=>CLK0_dll,   CLK90=>open, CLK180=>open, CLK270=>open,
                          CLK2X=>open, CLKDV=>CLKDV_dll, LOCKED=>LOCKED);

clkg   : BUFG   port map (I=>CLK0_dll,   O=>CLK0_g);
clkdvg : BUFG   port map (I=>CLKDV_dll,  O=>CLKDV_BUF);

CLK0 <= CLK0_g;
RST <= RESET_w;
CLKDV <= CLOCK_OUT;

process (RESET_w, CLKDV_BUF, COUNT)
begin
   if RESET_w = '1' then
      COUNT <= "000000000000000000000";
      CLOCK_OUT <= '0';
   elsif CLKDV_BUF'event and CLKDV_BUF = '1' then
      if COUNT = "101111101011110000100" then
         COUNT <= "000000000000000000000";
         CLOCK_OUT <= not CLOCK_OUT;
      else
         COUNT <= COUNT + 1;
      end if;
   end if;
end process;

end architecture;

