-- John Taylor, Preeti Chitre, Joel Montes de Oca, Fabian Rosadi
-- Cal Poly Pomona, Spring 2001

-- REG_FILE entity
-- 16-deep, 16-bit register file
-- Register 0 is read-only
-- Utilizes RAM16X16D entity (16 x 16 dual-port memory)
-- Allows single port data input (port Z) and
-- triple port data output (ports Z, X and Y)
-- One dual-port memory module is linked to ports Z and X
-- the other is linked to ports Z and Y

library IEEE;
use IEEE.std_logic_1164.all;

entity REG_FILE is
   port (CLOCK, LE: in STD_LOGIC;
         RZ, RX, RY: in STD_LOGIC_VECTOR (3 downto 0);
         RZ_IN: in STD_LOGIC_VECTOR (15 downto 0);
         RZ_OUT, RX_OUT, RY_OUT: out STD_LOGIC_VECTOR (15 downto 0)
   );
end entity;

architecture inside of REG_FILE is

-- 16 x 16 dual-port memory component
component RAM16X16D
   port (WE, CLK: in STD_LOGIC;
         ADDR_W, ADDR_R: in STD_LOGIC_VECTOR (3 downto 0);
         DIN: in STD_LOGIC_VECTOR (15 downto 0);
         SPO, DPO: out STD_LOGIC_VECTOR (15 downto 0)
   );
end component;

signal WRITE_EN: STD_LOGIC;

begin
   process (LE, RZ)
   begin
      -- Make register zero read-only by sending '0'
      -- to the write enable signal when RZ=0
      if RZ = "0000" then
         WRITE_EN <= '0';
      else
         WRITE_EN <= not LE;
      end if;
   end process;

   -- Instantiate first dual-port memory
   U_RAM1: RAM16X16D port map (
      WE => WRITE_EN, CLK => CLOCK,
      ADDR_W => RZ, ADDR_R => RX,
      DIN => RZ_IN,
      SPO => RZ_OUT, DPO => RX_OUT
   );

   -- Instantiate second dual-port memory
   U_RAM2: RAM16X16D port map (
      WE => WRITE_EN, CLK => CLOCK,
      ADDR_W => RZ, ADDR_R => RY,
      DIN => RZ_IN,
      DPO => RY_OUT
   );
end architecture;

