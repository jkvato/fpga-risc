-- John Taylor
-- ecevato@yahoo.com

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity CONTROL is
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
end entity;

architecture inside of CONTROL is

constant CARRY_FLAG:    INTEGER := 0;
constant OVERFLOW_FLAG: INTEGER := 1;
constant NEGATIVE_FLAG: INTEGER := 2;
constant ZERO_FLAG:     INTEGER := 3;
constant REQ_FLAG:      INTEGER := 4;
constant IEN_FLAG:      INTEGER := 5;
constant ACK_FLAG:      INTEGER := 6;

constant FETCH_STATE:   STD_LOGIC_VECTOR (1 downto 0) := "01";
constant EXECUTE_STATE: STD_LOGIC_VECTOR (1 downto 0) := "10";

constant OPCODE_ADD:   STD_LOGIC_VECTOR (4 downto 0) := "00000";
constant OPCODE_SUB:   STD_LOGIC_VECTOR (4 downto 0) := "00001";
constant OPCODE_AND:   STD_LOGIC_VECTOR (4 downto 0) := "00010";
constant OPCODE_OR:    STD_LOGIC_VECTOR (4 downto 0) := "00011";
constant OPCODE_XOR:   STD_LOGIC_VECTOR (4 downto 0) := "00100";
constant OPCODE_NOT:   STD_LOGIC_VECTOR (4 downto 0) := "00101";
constant OPCODE_SHR:   STD_LOGIC_VECTOR (4 downto 0) := "00110";
constant OPCODE_SHL:   STD_LOGIC_VECTOR (4 downto 0) := "00111";
constant OPCODE_ROR:   STD_LOGIC_VECTOR (4 downto 0) := "01000";
constant OPCODE_ROL:   STD_LOGIC_VECTOR (4 downto 0) := "01001";
constant OPCODE_STORE: STD_LOGIC_VECTOR (4 downto 0) := "01010";
constant OPCODE_LOAD:  STD_LOGIC_VECTOR (4 downto 0) := "01011";
constant OPCODE_ADDI:  STD_LOGIC_VECTOR (4 downto 0) := "01100";
constant OPCODE_BTSS:  STD_LOGIC_VECTOR (4 downto 0) := "01101";
constant OPCODE_BTSC:  STD_LOGIC_VECTOR (4 downto 0) := "01110";
constant OPCODE_JR:    STD_LOGIC_VECTOR (4 downto 0) := "01111";
constant OPCODE_JA:    STD_LOGIC_VECTOR (4 downto 0) := "10000";
constant OPCODE_LUI:   STD_LOGIC_VECTOR (4 downto 0) := "10001";
constant OPCODE_CALL:  STD_LOGIC_VECTOR (4 downto 0) := "10010";
constant OPCODE_RET:   STD_LOGIC_VECTOR (4 downto 0) := "10011";

constant ALU_AND: STD_LOGIC_VECTOR (3 downto 0) := "0000";
constant ALU_OR : STD_LOGIC_VECTOR (3 downto 0) := "0001";
constant ALU_XOR: STD_LOGIC_VECTOR (3 downto 0) := "0010";
constant ALU_NOT: STD_LOGIC_VECTOR (3 downto 0) := "0011";
constant ALU_ADD: STD_LOGIC_VECTOR (3 downto 0) := "0100";
constant ALU_SUB: STD_LOGIC_VECTOR (3 downto 0) := "0101";
constant ALU_ROL: STD_LOGIC_VECTOR (3 downto 0) := "0110";
constant ALU_ROR: STD_LOGIC_VECTOR (3 downto 0) := "0111";
constant ALU_SHL: STD_LOGIC_VECTOR (3 downto 0) := "1000";
constant ALU_SHR: STD_LOGIC_VECTOR (3 downto 0) := "1001";

signal R0_FLAG: STD_LOGIC;
signal STATE, STATE_NEXT:  STD_LOGIC_VECTOR (1 downto 0);
signal PC, PC_NEXT:        STD_LOGIC_VECTOR (15 downto 0);
signal PCRC, PCRC_NEXT:    STD_LOGIC_VECTOR (15 downto 0);
signal FLAGS, FLAGS_NEXT:  STD_LOGIC_VECTOR (15 downto 0);
signal IR, IR_NEXT:        STD_LOGIC_VECTOR (20 downto 0);
signal PCRI, PCRI_NEXT:    STD_LOGIC_VECTOR (15 downto 0);
signal INTV, INTV_NEXT:    STD_LOGIC_VECTOR (15 downto 0);
signal IEN1, IEN1_NEXT:    STD_LOGIC;
signal IEN2, IEN2_NEXT:    STD_LOGIC;
signal IEN3, IEN3_NEXT:    STD_LOGIC;

signal INTERRUPT : STD_LOGIC;

begin
   F_OUT <= FLAGS;
   RZ_ADDR <= IR (15 downto 12);
   RX_ADDR <= IR (11 downto 8);
   RY_ADDR <= IR (7 downto 4);
   IMM <= IR (7 downto 0);

   INSTR_ADDR <= PC_NEXT;
   INTERRUPT <= FLAGS (IEN_FLAG) and FLAGS (REQ_FLAG) and IEN1 and IEN2 and IEN3;

   --C6 <= (IR(11) or IR(10) or IR(9) or IR(8)) and R0_FLAG;

   COMBINATIONAL: process (STATE, PC, INSTRUCTION, F_IN, IR, FLAGS, IEN1, IEN2, IEN3, RF_IN,
                           PCRC, RY_IMM, INTV, PCRI, RESET,
                           INT_REQ, R0_FLAG, PC_NEXT, INTERRUPT)

   begin
      FLAGS_NEXT (REQ_FLAG) <= INT_REQ;

      if IR(11 downto 8) = "0000" and R0_FLAG = '1' then
         C6 <= '0';
      else
         C6 <= '1';
      end if;

      case STATE is

         when FETCH_STATE =>
            OPERATION <= "----";
            C0 <= '-';
            C1 <= '1';
            C2 <= '0';
            C3 <= '-';
            C4 <= "--";
            C5 <= '1';
            R0_FLAG <= '-';

            --INSTR_ADDR <= PC;
            IR_NEXT <= INSTRUCTION;
            FLAGS_NEXT <= FLAGS;
            PC_NEXT <= PC + 1;
            PCRC_NEXT <= PCRC;
            PCRI_NEXT <= PCRI;
            INTV_NEXT <= INTV;
            IEN1_NEXT <= IEN1;
            IEN2_NEXT <= IEN2;
            IEN3_NEXT <= IEN3;
            STATE_NEXT <= EXECUTE_STATE;

         when EXECUTE_STATE =>
            C5 <= '1';
            --INSTR_ADDR <= "----------------";
            IR_NEXT <= IR;
            STATE_NEXT <= FETCH_STATE;
            case IR (20 downto 16) is

               when OPCODE_ADD =>
                  OPERATION <= ALU_ADD;
                  C0 <= '0';
                  C1 <= '0';
                  C2 <= '0';
                  C3 <= '-';
                  C4 <= "00";
                  R0_FLAG <= '0';
                  FLAGS_NEXT (3 downto 0) <= F_IN;
                  FLAGS_NEXT (15 downto 5) <= FLAGS (15 downto 5);
                  PCRC_NEXT <= PCRC;
                  INTV_NEXT <= INTV;
                  if INTERRUPT = '1' then
                     PCRI_NEXT <= PC;
                     PC_NEXT <= INTV;
                     FLAGS_NEXT (IEN_FLAG) <= '0';
                  else
                     PC_NEXT <= PC;
                     PCRI_NEXT <= PCRI;
                  end if;

               when OPCODE_SUB =>
                  OPERATION <= ALU_SUB;
                  C0 <= '0';
                  C1 <= '0';
                  C2 <= '0';
                  C3 <= '-';
                  C4 <= "00";
                  R0_FLAG <= '0';
                  FLAGS_NEXT (3 downto 0) <= F_IN;
                  FLAGS_NEXT (15 downto 5) <= FLAGS (15 downto 5);
                  PCRC_NEXT <= PCRC;
                  INTV_NEXT <= INTV;
                  if INTERRUPT = '1' then
                     PCRI_NEXT <= PC;
                     PC_NEXT <= INTV;
                     FLAGS_NEXT (IEN_FLAG) <= '0';
                  else
                     PC_NEXT <= PC;
                     PCRI_NEXT <= PCRI;
                  end if;

               when OPCODE_AND =>
                  OPERATION <= ALU_AND;
                  C0 <= '0';
                  C1 <= '0';
                  C2 <= '0';
                  C3 <= '-';
                  C4 <= "00";
                  R0_FLAG <= '1';
                  if IR(15 downto 12) = "0000" then
                     FLAGS_NEXT (3 downto 0) <= RF_IN (3 downto 0);
                     FLAGS_NEXT (15 downto 5) <= RF_IN (15 downto 5);
                  else
                     FLAGS_NEXT (3 downto 0) <= F_IN;
                     FLAGS_NEXT (15 downto 5) <= FLAGS (15 downto 5);
                  end if;
                  PCRC_NEXT <= PCRC;
                  INTV_NEXT <= INTV;
                  if INTERRUPT = '1' then
                     PCRI_NEXT <= PC;
                     PC_NEXT <= INTV;
                     FLAGS_NEXT (IEN_FLAG) <= '0';
                  else
                     PC_NEXT <= PC;
                     PCRI_NEXT <= PCRI;
                  end if;

               when OPCODE_OR =>
                  OPERATION <= ALU_OR;
                  C0 <= '0';
                  C1 <= '0';
                  C2 <= '0';
                  C3 <= '-';
                  C4 <= "00";
                  R0_FLAG <= '1';
                  if IR(15 downto 12) = "0000" then
                     FLAGS_NEXT (3 downto 0) <= RF_IN (3 downto 0);
                     FLAGS_NEXT (15 downto 5) <= RF_IN (15 downto 5);
                  else
                     FLAGS_NEXT (3 downto 0) <= F_IN;
                     FLAGS_NEXT (15 downto 5) <= FLAGS (15 downto 5);
                  end if;
                  PCRC_NEXT <= PCRC;
                  INTV_NEXT <= INTV;
                  if INTERRUPT = '1' then
                     PCRI_NEXT <= PC;
                     PC_NEXT <= INTV;
                     FLAGS_NEXT (IEN_FLAG) <= '0';
                  else
                     PC_NEXT <= PC;
                     PCRI_NEXT <= PCRI;
                  end if;

               when OPCODE_XOR =>
                  OPERATION <= ALU_XOR;
                  C0 <= '0';
                  C1 <= '0';
                  C2 <= '0';
                  C3 <= '-';
                  C4 <= "00";
                  R0_FLAG <= '1';
                  if IR(15 downto 12) = "0000" then
                     FLAGS_NEXT (3 downto 0) <= RF_IN (3 downto 0);
                     FLAGS_NEXT (15 downto 5) <= RF_IN (15 downto 5);
                  else
                     FLAGS_NEXT (3 downto 0) <= F_IN;
                     FLAGS_NEXT (15 downto 5) <= FLAGS (15 downto 5);
                  end if;
                  PCRC_NEXT <= PCRC;
                  INTV_NEXT <= INTV;
                  if INTERRUPT = '1' then
                     PCRI_NEXT <= PC;
                     PC_NEXT <= INTV;
                     FLAGS_NEXT (IEN_FLAG) <= '0';
                  else
                     PC_NEXT <= PC;
                     PCRI_NEXT <= PCRI;
                  end if;

               when OPCODE_NOT =>
                  OPERATION <= ALU_NOT;
                  C0 <= '-';
                  C1 <= '0';
                  C2 <= '0';
                  C3 <= '-';
                  C4 <= "00";
                  R0_FLAG <= '1';
                  if IR(15 downto 12) = "0000" then
                     FLAGS_NEXT (3 downto 0) <= RF_IN (3 downto 0);
                     FLAGS_NEXT (15 downto 5) <= RF_IN (15 downto 5);
                  else
                     FLAGS_NEXT (3 downto 0) <= F_IN;
                     FLAGS_NEXT (15 downto 5) <= FLAGS (15 downto 5);
                  end if;
                  PCRC_NEXT <= PCRC;
                  INTV_NEXT <= INTV;
                  if INTERRUPT = '1' then
                     PCRI_NEXT <= PC;
                     PC_NEXT <= INTV;
                     FLAGS_NEXT (IEN_FLAG) <= '0';
                  else
                     PC_NEXT <= PC;
                     PCRI_NEXT <= PCRI;
                  end if;

               when OPCODE_SHL =>
                  OPERATION <= ALU_SHL;
                  C0 <= '1';
                  C1 <= '0';
                  C2 <= '0';
                  C3 <= '-';
                  C4 <= "00";
                  R0_FLAG <= '1';
                  FLAGS_NEXT (3 downto 0) <= F_IN;
                  FLAGS_NEXT (15 downto 5) <= FLAGS (15 downto 5);
                  PCRC_NEXT <= PCRC;
                  INTV_NEXT <= INTV;
                  if INTERRUPT = '1' then
                     PCRI_NEXT <= PC;
                     PC_NEXT <= INTV;
                     FLAGS_NEXT (IEN_FLAG) <= '0';
                  else
                     PC_NEXT <= PC;
                     PCRI_NEXT <= PCRI;
                  end if;

               when OPCODE_SHR =>
                  OPERATION <= ALU_SHR;
                  C0 <= '1';
                  C1 <= '0';
                  C2 <= '0';
                  C3 <= '-';
                  C4 <= "00";
                  R0_FLAG <= '1';
                  FLAGS_NEXT (3 downto 0) <= F_IN;
                  FLAGS_NEXT (15 downto 5) <= FLAGS (15 downto 5);
                  PCRC_NEXT <= PCRC;
                  INTV_NEXT <= INTV;
                  if INTERRUPT = '1' then
                     PCRI_NEXT <= PC;
                     PC_NEXT <= INTV;
                     FLAGS_NEXT (IEN_FLAG) <= '0';
                  else
                     PC_NEXT <= PC;
                     PCRI_NEXT <= PCRI;
                  end if;

               when OPCODE_ROR =>
                  OPERATION <= ALU_ROR;
                  C0 <= '0';
                  C1 <= '0';
                  C2 <= '0';
                  C3 <= '-';
                  C4 <= "00";
                  R0_FLAG <= '1';
                  FLAGS_NEXT (3 downto 0) <= F_IN;
                  FLAGS_NEXT (15 downto 5) <= FLAGS (15 downto 5);
                  PCRC_NEXT <= PCRC;
                  INTV_NEXT <= INTV;
                  if INTERRUPT = '1' then
                     PCRI_NEXT <= PC;
                     PC_NEXT <= INTV;
                     FLAGS_NEXT (IEN_FLAG) <= '0';
                  else
                     PC_NEXT <= PC;
                     PCRI_NEXT <= PCRI;
                  end if;

               when OPCODE_ROL =>
                  OPERATION <= ALU_ROL;
                  C0 <= '0';
                  C1 <= '0';
                  C2 <= '0';
                  C3 <= '-';
                  C4 <= "00";
                  R0_FLAG <= '1';
                  FLAGS_NEXT (3 downto 0) <= F_IN;
                  FLAGS_NEXT (15 downto 5) <= FLAGS (15 downto 5);
                  PCRC_NEXT <= PCRC;
                  INTV_NEXT <= INTV;
                  if INTERRUPT = '1' then
                     PCRI_NEXT <= PC;
                     PC_NEXT <= INTV;
                     FLAGS_NEXT (IEN_FLAG) <= '0';
                  else
                     PC_NEXT <= PC;
                     PCRI_NEXT <= PCRI;
                  end if;

               when OPCODE_STORE =>
                  OPERATION <= ALU_ADD;
                  C0 <= '0';
                  C1 <= '1';
                  C2 <= '1';
                  C3 <= '0';
                  C4 <= "--";
                  R0_FLAG <= '0';
                  FLAGS_NEXT (3 downto 0) <= FLAGS (3 downto 0);
                  FLAGS_NEXT (15 downto 5) <= FLAGS (15 downto 5);
                  PCRC_NEXT <= PCRC;
                  INTV_NEXT <= INTV;
                  if INTERRUPT = '1' then
                     PCRI_NEXT <= PC;
                     PC_NEXT <= INTV;
                     FLAGS_NEXT (IEN_FLAG) <= '0';
                  else
                     PC_NEXT <= PC;
                     PCRI_NEXT <= PCRI;
                  end if;

               when OPCODE_LOAD =>
                  OPERATION <= ALU_ADD;
                  C0 <= '0';
                  C1 <= '0';
                  C2 <= '1';
                  C3 <= '1';
                  C4 <= "01";
                  R0_FLAG <= '0';
                  FLAGS_NEXT (3 downto 0) <= FLAGS (3 downto 0);
                  FLAGS_NEXT (15 downto 5) <= FLAGS (15 downto 5);
                  PCRC_NEXT <= PCRC;
                  INTV_NEXT <= INTV;
                  if INTERRUPT = '1' then
                     PCRI_NEXT <= PC;
                     PC_NEXT <= INTV;
                     FLAGS_NEXT (IEN_FLAG) <= '0';
                  else
                     PC_NEXT <= PC;
                     PCRI_NEXT <= PCRI;
                  end if;

               when OPCODE_LUI =>
                  OPERATION <= "----";
                  C0 <= '-';
                  C1 <= '0';
                  C2 <= '0';
                  C3 <= '-';
                  C4 <= "10";
                  R0_FLAG <= '-';
                  FLAGS_NEXT (3 downto 0) <= FLAGS (3 downto 0);
                  FLAGS_NEXT (15 downto 5) <= FLAGS (15 downto 5);
                  PCRC_NEXT <= PCRC;
                  INTV_NEXT (7 downto 0) <= INTV (7 downto 0);
                  if IR (15 downto 12) = "0000" then
                     INTV_NEXT (15 downto 8) <= RF_IN (15 downto 8);
                  else
                     INTV_NEXT (15 downto 8) <= INTV (15 downto 8);
                  end if;
                  if INTERRUPT = '1' then
                     PCRI_NEXT <= PC;
                     PC_NEXT <= INTV;
                     FLAGS_NEXT (IEN_FLAG) <= '0';
                  else
                     PC_NEXT <= PC;
                     PCRI_NEXT <= PCRI;
                  end if;

               when OPCODE_ADDI =>
                  OPERATION <= ALU_ADD;
                  C0 <= '1';
                  C1 <= '0';
                  C2 <= '0';
                  C3 <= '-';
                  C4 <= "00";
                  R0_FLAG <= '0';
                  FLAGS_NEXT (3 downto 0) <= F_IN;
                  FLAGS_NEXT (15 downto 5) <= FLAGS (15 downto 5);
                  PCRC_NEXT <= PCRC;
                  if IR (15 downto 12) = "0000" then
                     INTV_NEXT <= RF_IN;
                  else
                     INTV_NEXT <= INTV;
                  end if;
                  if INTERRUPT = '1' then
                     PCRI_NEXT <= PC;
                     PC_NEXT <= INTV;
                     FLAGS_NEXT (IEN_FLAG) <= '0';
                  else
                     PC_NEXT <= PC;
                     PCRI_NEXT <= PCRI;
                  end if;

               when OPCODE_CALL =>
                  OPERATION <= "----";
                  C0 <= '0';
                  C1 <= '1';
                  C2 <= '0';
                  C3 <= '-';
                  C4 <= "--";
                  R0_FLAG <= '-';
                  FLAGS_NEXT (3 downto 0) <= FLAGS (3 downto 0);
                  FLAGS_NEXT (15 downto 5) <= FLAGS (15 downto 5);
                  PCRC_NEXT <= PC;
                  INTV_NEXT <= INTV;
                  if INTERRUPT = '1' then
                     PCRI_NEXT <= RY_IMM;
                     PC_NEXT <= INTV;
                     FLAGS_NEXT (IEN_FLAG) <= '0';
                  else
                     PC_NEXT <= RY_IMM;
                     PCRI_NEXT <= PCRI;
                  end if;

               when OPCODE_RET =>
                  OPERATION <= "----";
                  C0 <= '-';
                  C1 <= '1';
                  C2 <= '0';
                  C3 <= '-';
                  C4 <= "--";
                  R0_FLAG <= '-';
                  FLAGS_NEXT (3 downto 0) <= FLAGS (3 downto 0);
                  FLAGS_NEXT (15 downto 5) <= FLAGS (15 downto 5);
                  PCRC_NEXT <= PCRC;
                  INTV_NEXT <= INTV;
                  if INTERRUPT = '1' then
                     PCRI_NEXT <= PCRC;
                     PC_NEXT <= INTV;
                     FLAGS_NEXT (IEN_FLAG) <= '0';
                  else
                     PC_NEXT <= PCRC;
                     PCRI_NEXT <= PCRI;
                  end if;

               when OPCODE_BTSS =>
                  OPERATION <= ALU_AND;
                  C0 <= '1';
                  C1 <= '1';
                  C2 <= '0';
                  C3 <= '-';
                  C4 <= "--";
                  R0_FLAG <= '1';
                  FLAGS_NEXT (3 downto 0) <= FLAGS (3 downto 0);
                  FLAGS_NEXT (15 downto 5) <= FLAGS (15 downto 5);
                  PCRC_NEXT <= PCRC;
                  INTV_NEXT <= INTV;
                  if INTERRUPT = '1' then
                     if F_IN (ZERO_FLAG) = '0' then
                        PCRI_NEXT <= PC + 1;
                     else
                        PCRI_NEXT <= PC;
                     end if;
                     PC_NEXT <= INTV;
                     FLAGS_NEXT (IEN_FLAG) <= '0';
                  else
                     if F_IN (ZERO_FLAG) = '0' then
                        PC_NEXT <= PC + 1;
                     else
                        PC_NEXT <= PC;
                     end if;
                     PCRI_NEXT <= PCRI;
                  end if;

               when OPCODE_BTSC =>
                  OPERATION <= ALU_AND;
                  C0 <= '1';
                  C1 <= '1';
                  C2 <= '0';
                  C3 <= '-';
                  C4 <= "--";
                  R0_FLAG <= '1';
                  FLAGS_NEXT (3 downto 0) <= FLAGS (3 downto 0);
                  FLAGS_NEXT (15 downto 5) <= FLAGS (15 downto 5);
                  PCRC_NEXT <= PCRC;
                  INTV_NEXT <= INTV;
                  if INTERRUPT = '1' then
                     if F_IN (ZERO_FLAG) = '1' then
                        PCRI_NEXT <= PC + 1;
                     else
                        PCRI_NEXT <= PC;
                     end if;
                     PC_NEXT <= INTV;
                     FLAGS_NEXT (IEN_FLAG) <= '0';
                  else
                     if F_IN (ZERO_FLAG) = '1' then
                        PC_NEXT <= PC + 1;
                     else
                        PC_NEXT <= PC;
                     end if;
                     PCRI_NEXT <= PCRI;
                  end if;

               when OPCODE_JR =>
                  OPERATION <= "----";
                  C0 <= '1';
                  C1 <= '1';
                  C2 <= '0';
                  C3 <= '-';
                  C4 <= "--";
                  R0_FLAG <= '-';
                  FLAGS_NEXT (3 downto 0) <= FLAGS (3 downto 0);
                  FLAGS_NEXT (15 downto 5) <= FLAGS (15 downto 5);
                  PCRC_NEXT <= PCRC;
                  INTV_NEXT <= INTV;
                  if INTERRUPT = '1' then
                     PCRI_NEXT <= PC + RY_IMM;
                     PC_NEXT <= INTV;
                     FLAGS_NEXT (IEN_FLAG) <= '0';
                  else
                     PC_NEXT <= PC + RY_IMM;
                     PCRI_NEXT <= PCRI;
                  end if;

               when OPCODE_JA =>
                  OPERATION <= "----";
                  C0 <= '0';
                  C1 <= '1';
                  C2 <= '0';
                  C3 <= '-';
                  C4 <= "--";
                  R0_FLAG <= '-';
                  FLAGS_NEXT (3 downto 0) <= FLAGS (3 downto 0);
                  FLAGS_NEXT (15 downto 5) <= FLAGS (15 downto 5);
                  PCRC_NEXT <= PCRC;
                  INTV_NEXT <= INTV;
                  if INTERRUPT = '1' then
                     if IR (7 downto 4) = "0000" then
                        PCRI_NEXT <= PCRI;
                     else
                        PCRI_NEXT <= RY_IMM;
                     end if;
                     PC_NEXT <= INTV;
                     FLAGS_NEXT (IEN_FLAG) <= '0';
                  else
                     if IR (7 downto 4) = "0000" then
                        PC_NEXT <= PCRI;
                     else
                        PC_NEXT <= RY_IMM;
                     end if;
                     PCRI_NEXT <= PCRI;
                  end if;

               -- other opcodes
               when others =>
                  OPERATION <= "----";
                  C0 <= '-';
                  C1 <= '-';
                  C2 <= '-';
                  C3 <= '-';
                  C4 <= "--";
                  R0_FLAG <= '-';
                  FLAGS_NEXT (3 downto 0) <= FLAGS (3 downto 0);
                  FLAGS_NEXT (15 downto 5) <= FLAGS (15 downto 5);
                  PCRC_NEXT <= PCRC;
                  INTV_NEXT <= INTV;
                  if INTERRUPT = '1' then
                     PCRI_NEXT <= PC;
                     PC_NEXT <= INTV;
                     FLAGS_NEXT (IEN_FLAG) <= '0';
                  else
                     PC_NEXT <= PC;
                     PCRI_NEXT <= PCRI;
                  end if;

            end case;

         --if FLAGS (IEN_FLAG) = '1' and FLAGS (REQ_FLAG) = '1' and IEN1 = '1' and IEN2 = '1' and IEN3 = '1' then
         --if INTERRUPT = '1' then
            ----PCRI_NEXT <= PC_NEXT;
            ----PCRI_NEXT <= PC + 1;
            --PCRI_NEXT <= PC;
            --PC_NEXT <= INTV;
            --FLAGS_NEXT (IEN_FLAG) <= '0';
         --else
            --PCRI_NEXT <= PCRI;
         --end if;

         IEN1_NEXT <= FLAGS (IEN_FLAG);
         IEN2_NEXT <= IEN1;
         IEN3_NEXT <= IEN2;

         -- other state machine states
         when others =>
            OPERATION <= "----";
            C0 <= '-';
            C1 <= '-';
            C2 <= '-';
            C3 <= '-';
            C4 <= "--";
            C5 <= '-';
            R0_FLAG <= '-';
            --INSTR_ADDR <= PC;
            IR_NEXT <= IR;
            FLAGS_NEXT <= FLAGS;
            PC_NEXT <= PC;
            PCRC_NEXT <= PCRC;
            PCRI_NEXT <= PCRI;
            INTV_NEXT <= INTV;
            IEN1_NEXT <= IEN1;
            IEN2_NEXT <= IEN2;
            IEN3_NEXT <= IEN3;
            STATE_NEXT <= FETCH_STATE;

      end case;
   end process;
   
   SEQUENTIAL: process (CLK, RESET)
   begin
      if RESET = '1' then
         PC <= (others => '0');
         PCRC <= (others => '0');
         STATE <= (others => '0');
         IR <= (others => '0');
         FLAGS <= (others => '0');
         PCRI <= (others => '0');
         INTV <= (others => '0');
         IEN1 <= '0';
         IEN2 <= '0';
         IEN3 <= '0';
      elsif CLK'event and CLK='1' then
         PC <= PC_NEXT;
         PCRC <= PCRC_NEXT;
         STATE <= STATE_NEXT;
         IR <= IR_NEXT;
         FLAGS <= FLAGS_NEXT;
         PCRI <= PCRI_NEXT;
         INTV <= INTV_NEXT;
         IEN1 <= IEN1_NEXT;
         IEN2 <= IEN2_NEXT;
         IEN3 <= IEN3_NEXT;
      end if;
   end process;
         
end architecture;

