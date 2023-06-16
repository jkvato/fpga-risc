library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity outputs is
    Port ( CLK, RST: in std_logic;
           AS: in std_logic;
           D_IN: in std_logic_vector (15 downto 0);
           ADDR: in std_logic_vector (15 downto 0);
           D_OUT: out std_logic_vector (15 downto 0)
    );
end entity;

architecture inside of outputs is

signal DATA : std_logic_vector (15 downto 0);
constant ADD0200: STD_LOGIC_VECTOR (15 downto 0) := "0000001000000000";

begin
   process (AS, ADDR, D_IN, DATA, RST, CLK)
   begin
      if RST = '1' then
         DATA <= (others => '0');
      elsif CLK'event and CLK = '1' then
         if AS = '1' and ADDR = ADD0200 then
            DATA <= D_IN (15 downto 0);
         else
            DATA <= DATA;
         end if;
      end if;
   end process;
   D_OUT <= DATA;
end architecture;
