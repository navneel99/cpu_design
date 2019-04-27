library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Decoder is
Port(
clk: in std_logic;
pmem: in std_logic_vector(31 downto 0);
out_code: out std_logic_vector(5 downto 0)
);
end Decoder;

architecture Arch_Decoder of Decoder is 

type instr_class_type is (DP, DT, branch, unknown);
type i_decoded_type is (add,sub,cmp,mov,ldr,str,beq,bne,b,halt,unknown);

signal instr_class : instr_class_type;
signal i_decoded : i_decoded_type;

signal cond : std_logic_vector (3 downto 0);
signal F_field : std_logic_vector (1 downto 0);
signal I_bit : std_logic;
signal Opcode : std_logic_vector (3 downto 0);
signal U_bit,L_bit: std_logic;
signal Rn: std_logic_vector(3 downto 0 );
signal Rd: std_logic_vector(3 downto 0 );
signal Imm8: std_logic_vector(7 downto 0);
signal Rm: std_logic_vector(3 downto 0 );
signal Imm24: std_logic_vector(23 downto 0); 
signal Imm12: std_logic_vector(11 downto 0);
signal shift_spec: std_logic_vector(7 downto 0);

begin 

cond <= pmem (31 downto 28);
F_field <= pmem (27 downto 26);
I_bit <= pmem (25);
shift_spec <= pmem (11 downto 4);
Opcode <= pmem (24 downto 21);
U_bit <= pmem(23);
L_bit <= pmem(20); 
Rn <= pmem(19 downto 16);
Rd <= pmem(15 downto 12);
Rm <= pmem(3 downto 0);
Imm8 <= pmem(7 downto 0);
Imm24 <= pmem(23 downto 0);
Imm12 <= pmem(11 downto 0);

--for DP instructions
 i_decoded <= 
    halt when pmem = "00000000000000000000000000000000" else
    add  WHEN cond="1110" and F_field="00" and I_bit='1' and Opcode="0100" else
    sub WHEN cond="1110" and F_field="00" and I_bit='1' and Opcode="0010" else
    mov WHEN cond="1110" and F_field="00" and I_bit='1' and Opcode="1101" else
    cmp WHEN cond="1110" and F_field="00" and I_bit='1' and Opcode="1010" else
    add WHEN cond="1110" and F_field="00" and I_bit='0' and Opcode="0100" else
    sub WHEN cond="1110" and F_field="00" and I_bit='0' and Opcode="0010" else
    mov WHEN cond="1110" and F_field="00" and I_bit='0' and Opcode="1101" else
    cmp WHEN cond="1110" and F_field="00" and I_bit='0' and Opcode="1010" else
    
--for DT instructions
    str WHEN cond="1110" and F_field="01" and I_bit='0' and U_bit='0' and L_bit='0' else
    str WHEN cond="1110" and F_field="01" and I_bit='0' and U_bit='1' and L_bit='0' else
    ldr WHEN cond="1110" and F_field="01" and I_bit='0' and U_bit='0' and L_bit='1' else
    ldr WHEN cond="1110" and F_field="01" and I_bit='0' and U_bit='1' and L_bit='1' else
    
    b   WHEN cond="1110" else
    beq WHEN cond="0000" else
    bne WHEN cond="0001" else
    unknown;
--    null when others;
    
    instr_class <= DP when F_field = "00" else
                   DT when F_field = "01" else
                   branch when F_field = "10" else
                   unknown;

    out_code <= "000000" WHEN i_decoded = add else
     			"000001" WHEN i_decoded = sub else
     			"000010" WHEN i_decoded = mov else
     			"000011" WHEN i_decoded = cmp else
     			"010100" WHEN i_decoded = str else
     			"010101" WHEN i_decoded = ldr else
     			"100110" WHEN i_decoded = b else
     			"100111" WHEN i_decoded = beq else
     			"101000" WHEN i_decoded = bne else
     			"111001" WHEN i_decoded = halt;

end Arch_Decoder;
