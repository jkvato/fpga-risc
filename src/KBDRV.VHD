-- John Taylor
-- ecevato@yahoo.com

entity KB_DRV is
   port (CLOCK, RESET: in STD_LOGIC;
         DATA_IN: in STD_LOGIC_VECTOR (7 downto 0);
         READY: in STD_LOGIC;
         DATA_OUT: out STD_LOGIC_VECTOR (15 downto 0);
         INT_REQ: out STD_LOGIC
   );
end entity;

architecture inside of KB_DRV is

type STATE_TYPE is (WAITING, MADE, F0, INTERRUPT, ACK);
signal STATE: STATE_TYPE;
signal MAKE_CODE: STD_LOGIC_VECTOR (7 downto 0);

begin
   process (CLOCK, RESET)
   if RESET = '1' then
      STATE <= WAITING;
      BREAKING <= '0';
   elsif CLOCK'event and CLOCK = '1' then
      case STATE is
         when WAITING =>
            INT_REQ <= '0';

      ---------- BEGIN CASE -----------------------------------------

      case DATA_IN is
         when "00011100" => -- 1C = 'A'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "00110010" => -- 32 = 'B'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "00100001" => -- 21 = 'C'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "00100011" => -- 23 = 'D'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "00100100" => -- 24 = 'E'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "00101011" => -- 2B = 'F'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "00110100" => -- 34 = 'G'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "00110011" => -- 33 = 'H'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "01000011" => -- 43 = 'I'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "00111011" => -- 3B = 'J'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "01000010" => -- 42 = 'K'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "01001011" => -- 4B = 'L'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "00111010" => -- 3A = 'M'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "00110001" => -- 31 = 'N'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "01000100" => -- 44 = 'O'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "01001101" => -- 4D = 'P'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "00010101" => -- 15 = 'Q'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "00101101" => -- 2D = 'R'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "00011011" => -- 1B = 'S'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "00101100" => -- 2C = 'T'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "00111100" => -- 3C = 'U'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "00101010" => -- 2A = 'V'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "00011101" => -- 1D = 'W'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "00100010" => -- 22 = 'X'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "00110101" => -- 35 = 'Y'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "00011010" => -- 1A = 'Z'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "01000101" => -- 45 = '0'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "00010110" => -- 16 = '1'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "00011110" => -- 1E = '2'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "00100110" => -- 26 = '3'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "00100101" => -- 25 = '4'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "00101110" => -- 2E = '5'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "00110110" => -- 36 = '6'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "00111101" => -- 3D = '7'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "00111110" => -- 3E = '8'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "01000110" => -- 46 = '9'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "01001110" => -- 4E = '-'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "01010101" => -- 55 = '='
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "01001010" => -- 4A = '/'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "01100110" => -- 66 = 'BKSP'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "00101001" => -- 29 = 'SPACE'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "01011010" => -- 5A = 'ENTER'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "01110110" => -- 76 = 'ESC'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "00000101" => -- 05 = 'F1'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "00000110" => -- 06 = 'F2'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "00000100" => -- 04 = 'F3'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "00001100" => -- 0C = 'F4'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "00000011" => -- 03 = 'F5'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "00001011" => -- 0B = 'F6'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "10000011" => -- 83 = 'F7'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "00001010" => -- 0A = 'F8'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "00000001" => -- 01 = 'F9'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "00001001" => -- 09 = 'F10'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "01111000" => -- 78 = 'F11'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "00000111" => -- 07 = 'F12'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "01110001" => -- 71 = 'KPD .'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "01110000" => -- 70 = 'KPD 0'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "01101001" => -- 69 = 'KPD 1'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "01110011" => -- 72 = 'KPD 2'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "01111010" => -- 7A = 'KPD 3'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "01101011" => -- 6B = 'KPD 4'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "01110011" => -- 73 = 'KPD 5'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "01110100" => -- 74 = 'KPD 6'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "01101100" => -- 6C = 'KPD 7'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "01110101" => -- 75 = 'KPD 8'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "01111101" => -- 7D = 'KPD 9'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "01111100" => -- 7C = 'KPD *'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "01111101" => -- 7B = 'KPD -'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when "01111001" => -- 79 = 'KPD +'
            STATE <= MADE;
            MAKE_CODE <= DATA_IN;
         when others =>
            STATE <= STATE;
            MAKE_CODE <= "00000000";
      end case;

      ---------- END CASE -------------------------------------------

         when MADE =>
            if DATA_IN = "11110000" then
               STATE <= F0;
            else
               STATE <= MADE;
            end if;
            INT_REQ <= '0';

         when F0 =>
            if DATA_IN = MAKE_CODE then
               STATE <= INTERRUPT;
               INT_REQ <= '1';

      ---------- BEGIN CASE -----------------------------------------

      case DATA_IN is
         when "00011100" => -- 1C = 'A'
            DATA_OUT <= "01000001" -- 41
         when "00110010" => -- 32 = 'B'
            DATA_OUT <= "01000010" -- 42
         when "00100001" => -- 21 = 'C'
            DATA_OUT <= "01000011" -- 43
         when "00100011" => -- 23 = 'D'
            DATA_OUT <= "01000100" -- 44
         when "00100100" => -- 24 = 'E'
            DATA_OUT <= "01000101" -- 45
         when "00101011" => -- 2B = 'F'
            DATA_OUT <= "01000110" -- 46
         when "00110100" => -- 34 = 'G'
            DATA_OUT <= "01000111" -- 47
         when "00110011" => -- 33 = 'H'
            DATA_OUT <= "0100100" -- 48
         when "01000011" => -- 43 = 'I'
            DATA_OUT <= "01001001" -- 49
         when "00111011" => -- 3B = 'J'
            DATA_OUT <= "01001010" -- 4A
         when "01000010" => -- 42 = 'K'
            DATA_OUT <= "01001011" -- 4B
         when "01001011" => -- 4B = 'L'
            DATA_OUT <= "01001100" -- 4C
         when "00111010" => -- 3A = 'M'
            DATA_OUT <= "01001101" -- 4D
         when "00110001" => -- 31 = 'N'
            DATA_OUT <= "01001110" -- 4E
         when "01000100" => -- 44 = 'O'
            DATA_OUT <= "01001111" -- 4F
         when "01001101" => -- 4D = 'P'
            DATA_OUT <= "01010000" -- 50
         when "00010101" => -- 15 = 'Q'
            DATA_OUT <= "01010001" -- 51
         when "00101101" => -- 2D = 'R'
            DATA_OUT <= "01010010" -- 52
         when "00011011" => -- 1B = 'S'
            DATA_OUT <= "01010011" -- 53
         when "00101100" => -- 2C = 'T'
            DATA_OUT <= "01010100" -- 54
         when "00111100" => -- 3C = 'U'
            DATA_OUT <= "01010101" -- 55
         when "00101010" => -- 2A = 'V'
            DATA_OUT <= "01010110" -- 56
         when "00011101" => -- 1D = 'W'
            DATA_OUT <= "01010111" -- 57
         when "00100010" => -- 22 = 'X'
            DATA_OUT <= "01011000" -- 58
         when "00110101" => -- 35 = 'Y'
            DATA_OUT <= "01011001" -- 59
         when "00011010" => -- 1A = 'Z'
            DATA_OUT <= "01011010" -- 5A
         when "01000101" => -- 45 = '0'
            DATA_OUT <= "00110000" -- 30
         when "00010110" => -- 16 = '1'
            DATA_OUT <= "00110001" -- 31
         when "00011110" => -- 1E = '2'
            DATA_OUT <= "00110010" -- 32
         when "00100110" => -- 26 = '3'
            DATA_OUT <= "00110011" -- 33
         when "00100101" => -- 25 = '4'
            DATA_OUT <= "00110100" -- 34
         when "00101110" => -- 2E = '5'
            DATA_OUT <= "00110101" -- 35
         when "00110110" => -- 36 = '6'
            DATA_OUT <= "00110110" -- 36
         when "00111101" => -- 3D = '7'
            DATA_OUT <= "00110111" -- 37
         when "00111110" => -- 3E = '8'
            DATA_OUT <= "0011100" -- 38
         when "01000110" => -- 46 = '9'
            DATA_OUT <= "00111001" -- 39
         when "01001110" => -- 4E = '-'
            DATA_OUT <= "00101101" -- 2D
         when "01010101" => -- 55 = '='
            DATA_OUT <= "00111101" -- 3D
         when "01001010" => -- 4A = '/'
            DATA_OUT <= "00101111" -- 2F
         when "01100110" => -- 66 = 'BKSP'
            DATA_OUT <= "00001000" -- 08
         when "00101001" => -- 29 = 'SPACE'
            DATA_OUT <= "00100000" -- 20
         when "01011010" => -- 5A = 'ENTER'
            DATA_OUT <= "00001101" -- 0D
         when "01110110" => -- 76 = 'ESC'
            DATA_OUT <= "00011011" -- 1B
         when "00000101" => -- 05 = 'F1'
            DATA_OUT <= "10000001" -- 81
         when "00000110" => -- 06 = 'F2'
            DATA_OUT <= "10000010" -- 82
         when "00000100" => -- 04 = 'F3'
            DATA_OUT <= "10000011" -- 83
         when "00001100" => -- 0C = 'F4'
            DATA_OUT <= "10000100" -- 84
         when "00000011" => -- 03 = 'F5'
            DATA_OUT <= "10000101" -- 85
         when "00001011" => -- 0B = 'F6'
            DATA_OUT <= "10000110" -- 86
         when "10000011" => -- 83 = 'F7'
            DATA_OUT <= "10000111" -- 87
         when "00001010" => -- 0A = 'F8'
            DATA_OUT <= "10001000" -- 88
         when "00000001" => -- 01 = 'F9'
            DATA_OUT <= "10001001" -- 89
         when "00001001" => -- 09 = 'F10'
            DATA_OUT <= "10001010" -- 8A
         when "01111000" => -- 78 = 'F11'
            DATA_OUT <= "10001011" -- 8B
         when "00000111" => -- 07 = 'F12'
            DATA_OUT <= "10001100" -- 8C
         when "01110001" => -- 71 = 'KPD .'
            DATA_OUT <= "00101110" -- 2E
         when "01110000" => -- 70 = 'KPD 0'
            DATA_OUT <= "00110000" -- 30
         when "01101001" => -- 69 = 'KPD 1'
            DATA_OUT <= "00110001" -- 31
         when "01110011" => -- 72 = 'KPD 2'
            DATA_OUT <= "00110010" -- 32
         when "01111010" => -- 7A = 'KPD 3'
            DATA_OUT <= "00110011" -- 33
         when "01101011" => -- 6B = 'KPD 4'
            DATA_OUT <= "00110100" -- 34
         when "01110011" => -- 73 = 'KPD 5'
            DATA_OUT <= "00110101" -- 35
         when "01110100" => -- 74 = 'KPD 6'
            DATA_OUT <= "00110110" -- 36
         when "01101100" => -- 6C = 'KPD 7'
            DATA_OUT <= "00110111" -- 37
         when "01110101" => -- 75 = 'KPD 8'
            DATA_OUT <= "00111000" -- 38
         when "01111101" => -- 7D = 'KPD 9'
            DATA_OUT <= "00111001" -- 39
         when "01111100" => -- 7C = 'KPD *'
            DATA_OUT <= "00101010" -- 2A
         when "01111101" => -- 7B = 'KPD -'
            DATA_OUT <= "00101101" -- 2D
         when "01111001" => -- 79 = 'KPD +'
            DATA_OUT <= "00101011" -- 2B
         when others =>
            DATA_OUT <= "00100000" -- 20
      end case;

      ---------- END CASE -------------------------------------------

            else
               INT_REQ <= '0';
               STATE <= F0;
            end if;

