-- John Taylor
-- ecevato@yahoo.com

library IEEE;
use IEEE.std_logic_1164.all;

entity buttons is
   port (CLK, RST: in STD_LOGIC;
         ADDR: in STD_LOGIC_VECTOR (15 downto 0);
         AS, INT_ACK:  in STD_LOGIC;
         INT_REQ: out STD_LOGIC;
         BC: in STD_LOGIC_VECTOR (5 downto 0);
         D_OUT: out STD_LOGIC_VECTOR (15 downto 0)
   );
end entity;

architecture inside of buttons is
constant COUNT_MAX : integer := 3125;
signal count : integer range 0 to COUNT_MAX;
signal last_data : std_logic_vector (5 downto 0);

begin
   process (RST, CLK, count)
   begin
      if RST = '1' then
         count <= 0;
         last_data <= "000000";
      else
         if count = COUNT_MAX then
            if BC = "000000" and last_data /= "000000" then
               case last_data is
                  when "000011" =>
                     data_out <= "0001";
                  when "000110" =>
                     data_out <= "0010";
                  when "001100" =>
                     data_out <= "0011";
                  when "011000" =>
                     data_out <= "0100";
                  when "110000" =>
                     data_out <= "0101";
                  when "100001" =>
                     data_out <= "0110";
                  when "000101" =>
                     data_out <= "0111";
                  when "001001" =>
                     data_out <= "1000";
                  when "010001" =>
                     data_out <= "1001";
                  when "010010" =>
                     data_out <= "1010";
                  when "100010" =>
                     data_out <= "1011";
                  when "010100" =>
                     data_out <= "1100";
                  when "100100" =>
                     data_out <= "1101";
                  when "101000" =>
                     data_out <= "1110";
                  when "001010" =>
                     data_out <= "0000";
                  when others =>
                     data_out <= "1111";
               end case;
            else
               data_out <= "1111";
            end if;
         end if;
         count <= count + 1;
      end if;
   end process;
end architecture;

