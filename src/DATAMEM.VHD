-- John Taylor, Preeti Chitre, Joel Montes de Oca, Fabian Rosadi
-- Cal Poly Pomona, Spring 2001

-- DATA_MEM entity
-- 512 x 16 data memory module
-- Instantiates two block RAMs of 256 x 16 each
-- within the Xilinx Spartan II chip.
-- Due to problems simulating with tri-state buffers,
-- multiplexers were used instead.

library IEEE;
use IEEE.std_logic_1164.all;

entity DATA_MEM is
   port (CLOCK, RESET, CS, R_W: in STD_LOGIC;
         ADDRESS: in STD_LOGIC_VECTOR (8 downto 0);
         DATA_IN: in STD_LOGIC_VECTOR (15 downto 0);
         DATA_OUT: out STD_LOGIC_VECTOR (15 downto 0)
   );
end entity;

architecture inside of DATA_MEM is

-- 256 x 16 Spartan II memory block primitive
component RAMB4_S16
   port (WE, EN, RST, CLK: in STD_LOGIC;
         ADDR: in STD_LOGIC_VECTOR (7 downto 0);
         DI: in STD_LOGIC_VECTOR (15 downto 0);
         DO: out STD_LOGIC_VECTOR (15 downto 0)
   );
end component;

signal RAM0_OUT: STD_LOGIC_VECTOR (15 downto 0);
signal RAM1_OUT: STD_LOGIC_VECTOR (15 downto 0);
signal RAM0_EN, RAM1_EN: STD_LOGIC;
signal WRITE_EN: STD_LOGIC;
--signal RAM0_TRI, RAM1_TRI: STD_LOGIC_VECTOR (15 downto 0);

begin
   WRITE_EN <= not R_W;

   RAM0_EN <= CS and (not ADDRESS (8)); -- enable RAM block 0 for lower 256 locations
   RAM1_EN <= CS and (ADDRESS (8));     -- enable RAM block 1 for upper 256 locations

   --For tri-state MUX
   --DATA_OUT <= RAM0_TRI;
   --DATA_OUT <= RAM1_TRI;

   -- Instantiate block 0 for lower 256 locations
   U_D_RAM0: RAMB4_S16 port map (
      WE => WRITE_EN, EN => RAM0_EN, RST => RESET, CLK => CLOCK,
      ADDR => ADDRESS (7 downto 0), DI => DATA_IN, DO => RAM0_OUT
   );

   -- Instantiate block 1 for upper 256 locations
   U_D_RAM1: RAMB4_S16 port map (
      WE => WRITE_EN, EN => RAM1_EN, RST => RESET, CLK => CLOCK,
      ADDR => ADDRESS (7 downto 0), DI => DATA_IN, DO => RAM1_OUT
   );

   --Look-Up Table (LUT) MUX
   process (ADDRESS, RAM0_OUT, RAM1_OUT)
   begin
      if ADDRESS (8) = '0' then
         DATA_OUT <= RAM0_OUT;
      else
         DATA_OUT <= RAM1_OUT;
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

