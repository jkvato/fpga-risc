-- John Taylor
-- ecevato@yahoo.com

library IEEE;
use IEEE.std_logic_1164.all;

entity CPU is
   port (DATA_BUS_IN: in STD_LOGIC_VECTOR (15 downto 0);
         DATA_BUS_OUT: out STD_LOGIC_VECTOR (15 downto 0);
         ADDRESS_BUS_OUT: out STD_LOGIC_VECTOR (15 downto 0);
         INT_REQ: in STD_LOGIC;
         AS, INT_ACK: out STD_LOGIC;
         CLOCK, RESET: in STD_LOGIC
   );
end entity;

architecture inside of CPU is

component REG_FILE
   port (CLOCK, LE: in  STD_LOGIC;
         RZ, RX, RY: in  STD_LOGIC_VECTOR (3 downto 0);
         RZ_IN: in  STD_LOGIC_VECTOR (15 downto 0);
         RZ_OUT, RX_OUT, RY_OUT: out STD_LOGIC_VECTOR (15 downto 0)
   );
end component;

component ALU
   port (A, B: in STD_LOGIC_VECTOR (15 downto 0);
         OPERATION: in STD_LOGIC_VECTOR (3 downto 0);
         Z: out STD_LOGIC_VECTOR (15 downto 0);
         ZERO, CARRY, OVERFLOW, NEGATIVE: out STD_LOGIC
   );
end component;

component CONTROL
   port (INSTRUCTION: in STD_LOGIC_VECTOR (20 downto 0);
         INSTR_ADDR: out STD_LOGIC_VECTOR (15 downto 0);
         RF_IN: in STD_LOGIC_VECTOR (15 downto 0);
         RY_IMM: in STD_LOGIC_VECTOR (15 downto 0);
         F_IN: in STD_LOGIC_VECTOR (3 downto 0);
         CLK, RESET, INT_REQ: in STD_LOGIC;
         F_OUT: out STD_LOGIC_VECTOR (15 downto 0);
         OPERATION: out STD_LOGIC_VECTOR (3 downto 0);
         C0, C1, C2, C3, C5, C6: out STD_LOGIC;
         C4: out STD_LOGIC_VECTOR (1 downto 0);
         IMM: out STD_LOGIC_VECTOR (7 downto 0);
         RZ_ADDR, RX_ADDR, RY_ADDR: out STD_LOGIC_VECTOR (3 downto 0)
   );
end component;

component INSTR_MEM
   port (CLOCK, RESET, CS: in STD_LOGIC;
         ADDRESS: in STD_LOGIC_VECTOR (8 downto 0);
         DATA_OUT: out STD_LOGIC_VECTOR (20 downto 0)
   );
end component;

component DATA_MEM
   port (CLOCK, RESET, CS, R_W: in STD_LOGIC;
         ADDRESS: in STD_LOGIC_VECTOR (8 downto 0);
         DATA_IN: in STD_LOGIC_VECTOR (15 downto 0);
         DATA_OUT: out STD_LOGIC_VECTOR (15 downto 0)
   );
end component;

constant CARRY_FLAG:    INTEGER := 0;
constant OVERFLOW_FLAG: INTEGER := 1;
constant NEGATIVE_FLAG: INTEGER := 2;
constant ZERO_FLAG:     INTEGER := 3;
constant REQ_FLAG:      INTEGER := 4;
constant IEN_FLAG:      INTEGER := 5;
constant ACK_FLAG:      INTEGER := 6;

signal ALU_OUTPUT: STD_LOGIC_VECTOR (15 downto 0);
signal ALU_A_IN: STD_LOGIC_VECTOR (15 downto 0);
signal RF_Z_INPUT: STD_LOGIC_VECTOR (15 downto 0);
signal RF_Z_OUTPUT, RF_X_OUTPUT, RF_Y_OUTPUT: STD_LOGIC_VECTOR (15 downto 0);
signal RZ_ADDRESS, RX_ADDRESS, RY_ADDRESS: STD_LOGIC_VECTOR (3 downto 0);
signal CONTROL_0, CONTROL_1, CONTROL_2, CONTROL_3, CONTROL_5, CONTROL_6: STD_LOGIC;
signal CONTROL_4: STD_LOGIC_VECTOR (1 downto 0);
signal ALU_OPERATION: STD_LOGIC_VECTOR (3 downto 0);
signal ALU_FLAGS_OUT: STD_LOGIC_VECTOR (3 downto 0);
signal CU_FLAGS_OUT: STD_LOGIC_VECTOR (15 downto 0);
signal RY_IMM_OUT: STD_LOGIC_VECTOR (15 downto 0);
signal CU_IMM_OUT: STD_LOGIC_VECTOR (7 downto 0);
signal IMM_SE: STD_LOGIC_VECTOR (15 downto 0);
signal DATAMEM_CS: STD_LOGIC;
signal DATAMEM_DOUT: STD_LOGIC_VECTOR (15 downto 0);
signal INSTRMEM_DOUT: STD_LOGIC_VECTOR (20 downto 0);
signal INSTRMEM_ADDR: STD_LOGIC_VECTOR (15 downto 0);

begin
   DATA_BUS_OUT <= RF_Z_OUTPUT;
   ADDRESS_BUS_OUT <= ALU_OUTPUT;
   AS <= CONTROL_2;
	INT_ACK <= CU_FLAGS_OUT (ACK_FLAG);

   IMM_SE (7 downto 0) <= CU_IMM_OUT;
   IMM_SE (8) <= CU_IMM_OUT (7);
   IMM_SE (9) <= CU_IMM_OUT (7);
   IMM_SE (10) <= CU_IMM_OUT (7);
   IMM_SE (11) <= CU_IMM_OUT (7);
   IMM_SE (12) <= CU_IMM_OUT (7);
   IMM_SE (13) <= CU_IMM_OUT (7);
   IMM_SE (14) <= CU_IMM_OUT (7);
   IMM_SE (15) <= CU_IMM_OUT (7);

   --SEL_C4 (0) <= CONTROL_4 (0) and ALU_OUTPUT (9);
   --SEL_C4 (1) <= CONTROL_4 (1);

   DATAMEM_CS <= CONTROL_2 and (not ALU_OUTPUT(9));

   --CONTROL_6 <= RX_ADDRESS (0) or RX_ADDRESS (1) or RX_ADDRESS (2) or RX_ADDRESS (3);

   process (CONTROL_0, CONTROL_6, CU_FLAGS_OUT, RF_X_OUTPUT, RF_Y_OUTPUT, RF_Z_OUTPUT, IMM_SE, DATAMEM_DOUT, DATA_BUS_IN,
            CU_IMM_OUT, ALU_OUTPUT, CONTROL_4)
   begin
      if CONTROL_6 = '0' then
         ALU_A_IN <= CU_FLAGS_OUT;
      else
         ALU_A_IN <= RF_X_OUTPUT;
      end if;

      if CONTROL_0 = '0' then
         RY_IMM_OUT <= RF_Y_OUTPUT;
      else
         RY_IMM_OUT <= IMM_SE;
      end if;

      case CONTROL_4 is
         when "00" =>      -- RF <- ALU
            RF_Z_INPUT <= ALU_OUTPUT;
         when "01" =>      -- RF <- DATA MEM or I/O DATA IN
            if ALU_OUTPUT(9) = '1' then
               RF_Z_INPUT <= DATA_BUS_IN;
            else
               RF_Z_INPUT <= DATAMEM_DOUT;
            end if;
         when others =>      -- RF <- LUI
            RF_Z_INPUT (7 downto 0) <= RF_Z_OUTPUT (7 downto 0);
            RF_Z_INPUT (15 downto 8) <= CU_IMM_OUT;
      end case;

      --case SEL_C4 is
      --   when "00" =>      -- RF <- ALU
      --      RF_Z_INPUT <= ALU_OUTPUT;
      --   when "01" =>      -- RF <- DATA MEM
      --      RF_Z_INPUT <= DATAMEM_DOUT;
      --   when "10" =>      -- RF <- LUI
      --      RF_Z_INPUT (7 downto 0) <= RF_Z_OUTPUT (7 downto 0);
      --      RF_Z_INPUT (15 downto 8) <= CU_IMM_OUT;
      --   when others =>    -- RF <- I/O DATA IN
      --      RF_Z_INPUT <= DATA_BUS_IN;
      --end case;
   end process;

   U_REGFILE: REG_FILE port map(
      CLOCK => CLOCK, LE => CONTROL_1,
      RZ => RZ_ADDRESS, RY => RY_ADDRESS, RX => RX_ADDRESS,
      RZ_IN => RF_Z_INPUT, RZ_OUT => RF_Z_OUTPUT, RX_OUT => RF_X_OUTPUT, RY_OUT => RF_Y_OUTPUT
   );

   U_ALU: ALU port map(
      A => ALU_A_IN, B => RY_IMM_OUT,
      OPERATION => ALU_OPERATION,
      Z => ALU_OUTPUT,
      ZERO => ALU_FLAGS_OUT (ZERO_FLAG),
      CARRY => ALU_FLAGS_OUT (CARRY_FLAG),
      OVERFLOW => ALU_FLAGS_OUT (OVERFLOW_FLAG),
      NEGATIVE => ALU_FLAGS_OUT (NEGATIVE_FLAG)
   );

   U_CONTROL: CONTROL port map(
      INSTRUCTION => INSTRMEM_DOUT, INSTR_ADDR => INSTRMEM_ADDR,
      RF_IN => RF_Z_INPUT, RY_IMM => RY_IMM_OUT,
      F_IN => ALU_FLAGS_OUT, F_OUT => CU_FLAGS_OUT,
      OPERATION => ALU_OPERATION,
      C0 => CONTROL_0, C1 => CONTROL_1, C2 => CONTROL_2,
      C3 => CONTROL_3, C4 => CONTROL_4, C5 => CONTROL_5,
      C6 => CONTROL_6,
      IMM => CU_IMM_OUT,
      RZ_ADDR => RZ_ADDRESS, RX_ADDR => RX_ADDRESS, RY_ADDR => RY_ADDRESS,
      CLK => CLOCK, RESET => RESET, INT_REQ => INT_REQ
   );

   U_DATA_MEM: DATA_MEM port map(
      CLOCK => CLOCK, RESET => RESET,
      CS => DATAMEM_CS, R_W => CONTROL_3,
      ADDRESS => ALU_OUTPUT (8 downto 0),
      DATA_IN => RF_Z_OUTPUT,
      DATA_OUT => DATAMEM_DOUT
   );

   U_INSTR_MEM: INSTR_MEM port map(
      CLOCK => CLOCK, RESET => RESET, CS => CONTROL_5,
      ADDRESS => INSTRMEM_ADDR (8 downto 0),
      DATA_OUT => INSTRMEM_DOUT
   );

end architecture;

