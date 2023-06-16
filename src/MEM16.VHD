-- John Taylor
-- ecevato@yahoo.com

-- RAM16X16D
-- Create a block of 16x16 dual-port memory using RAM16X1D primitives
-- Each RAM16X1D is a 16-deep, 1-bit wide RAM module instantiated in
-- select-memory using LUTs (look-up tables)
-- Sixteen RAM16X1D's are instantiated in parallel forming a 16x16
-- block of RAM

library IEEE;
use IEEE.std_logic_1164.all;

entity RAM16X16D is
   port (WE, CLK: in STD_LOGIC;
         ADDR_W, ADDR_R: in STD_LOGIC_VECTOR (3 downto 0);
         DIN: in STD_LOGIC_VECTOR (15 downto 0);
         SPO, DPO: out STD_LOGIC_VECTOR (15 downto 0)
   );
end entity;

architecture inside of RAM16X16D is

component RAM16X1D
   port (WE, D, WCLK: in STD_LOGIC;
         A0, A1, A2, A3: in STD_LOGIC;
         DPRA0, DPRA1, DPRA2, DPRA3: in STD_LOGIC;
         SPO, DPO: out STD_LOGIC
   );
end component;

begin
   G1: for i in 0 to 15 generate
      U_RAM16D: RAM16X1D port map (
         WE => WE, D => DIN(i), WCLK => CLK,
         A0 => ADDR_W(0), A1 => ADDR_W(1), A2 => ADDR_W(2), A3 => ADDR_W(3),
         DPRA0 => ADDR_R(0), DPRA1 => ADDR_R(1), DPRA2 => ADDR_R(2), DPRA3 => ADDR_R(3),
         SPO => SPO(i), DPO => DPO(i)
      );
   end generate;
end architecture;

