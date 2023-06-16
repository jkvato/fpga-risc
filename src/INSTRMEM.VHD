-- John Taylor, Preeti Chitre, Joel Montes de Oca, Fabian Rosadi
-- Cal Poly Pomona, Spring 2001

-- INSTR_MEM entity
-- 512 x 21 instruction memory module configured as read-only
-- Instantiates two block RAMs of 256 x 16 each,
-- and one of 512 x 8 (upper 3 bits are ignored,
-- giving 16 + 5 = 21-bit memory).
-- Due to problems simulating with tri-state buffers,
-- multiplexers were used instead.

library IEEE;
use IEEE.std_logic_1164.all;

entity INSTR_MEM is
   port (CLOCK, RESET, CS: in STD_LOGIC;
         ADDRESS: in STD_LOGIC_VECTOR (8 downto 0);
         DATA_OUT: out STD_LOGIC_VECTOR (20 downto 0)
   );
end entity;

architecture inside of INSTR_MEM is

-- 256 x 16 Spartan II memory block primitive
component RAMB4_S16
   port (WE, EN, RST, CLK: in STD_LOGIC;
         ADDR: in STD_LOGIC_VECTOR (7 downto 0);
         DI: in STD_LOGIC_VECTOR (15 downto 0);
         DO: out STD_LOGIC_VECTOR (15 downto 0)
   );
end component;

-- 512 x 8 Spartan II memory block primitive
component RAMB4_S8
   port (WE, EN, RST, CLK: in STD_LOGIC;
         ADDR: in STD_LOGIC_VECTOR (8 downto 0);
         DI: in STD_LOGIC_VECTOR (7 downto 0);
         DO: out STD_LOGIC_VECTOR (7 downto 0)
   );
end component;

signal ZERO: STD_LOGIC;
signal ZERO16: STD_LOGIC_VECTOR (15 downto 0);
signal RAM0_OUT: STD_LOGIC_VECTOR (15 downto 0);
signal RAM1_OUT: STD_LOGIC_VECTOR (15 downto 0);
signal RAM0_EN, RAM1_EN: STD_LOGIC;
--signal RAM0_TRI, RAM1_TRI: STD_LOGIC_VECTOR (15 downto 0);

begin
   ZERO <= '0';
   ZERO16 <= "0000000000000000";

   RAM0_EN <= CS and (not ADDRESS (8));  -- Enable lower block RAM
   RAM1_EN <= CS and (ADDRESS (8));      -- Enable upper block RAM

   --For tri-state MUX
   --DATA_OUT (15 downto 0) <= RAM0_TRI;
   --DATA_OUT (15 downto 0) <= RAM1_TRI;

   -- Lower 256 locations of 16-bit memory
   U_I_RAM0: RAMB4_S16 port map (
      WE => ZERO, EN => RAM0_EN, RST => RESET, CLK => CLOCK,
      ADDR => ADDRESS (7 downto 0), DI => ZERO16, DO => RAM0_OUT
   );

   -- Upper 256 locations of 16-bit memory
   U_I_RAM1: RAMB4_S16 port map (
      WE => ZERO, EN => RAM1_EN, RST => RESET, CLK => CLOCK,
      ADDR => ADDRESS (7 downto 0), DI => ZERO16, DO => RAM1_OUT
   );

   -- Instantiate the 512 x 8-bit memory
   U_I_RAM2: RAMB4_S8 port map (
      WE => ZERO, EN => CS, RST => RESET, CLK => CLOCK,
      ADDR => ADDRESS, DI => ZERO16 (7 downto 0), DO (4 downto 0) => DATA_OUT (20 downto 16),
      DO (7 downto 5) => open
   );

   --LUT (Look-Up Table) MUX
   process (ADDRESS, RAM0_OUT, RAM1_OUT)
   begin
      if ADDRESS (8) = '0' then
         DATA_OUT (15 downto 0) <= RAM0_OUT;
      else
         DATA_OUT (15 downto 0) <= RAM1_OUT;
      end if;
   end process;

   --Tri-state MUX
   --process (ADDRESS, RAM0_OUT, RAM1_OUT)
   --begin
   --   if ADDRESS (8) = '0' then
   --      RAM0_TRI <= RAM0_OUT;
   --      RAM1_TRI <= (others => 'Z');
   --   else
   --      RAM0_TRI <= (others => 'Z');
   --      RAM1_TRI <= RAM1_OUT;
   --   end if;
   --end process;
end architecture;

