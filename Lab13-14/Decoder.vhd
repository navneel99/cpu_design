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
type i_decoded_type is (andd, eor, orr, bic, add, sub, adc, sbc, rsb, rsc,      
cmp, cmn, tst, teq, mov, mvn,ldr,str,strsh,ldrsh,beq,bne,b,halt,unknown);

-- in type,andd is used instead of and because and is a keyword in VHDL.

signal instr_class : instr_class_type;
signal i_decoded : i_decoded_type;

signal cond : std_logic_vector (3 downto 0);
signal F_field : std_logic_vector (1 downto 0);
signal I_bit : std_logic;
signal P_bit : std_logic;
signal W_bit : std_logic;
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
P_bit <= pmem(24);
W_bit <= pmem(21);
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
    andd WHEN instr_class = DP and Opcode="0000" else
    eor WHEN instr_class = DP and Opcode="0001" else
    sub WHEN instr_class = DP and Opcode="0010" else
    rsb WHEN instr_class = DP and Opcode="0011" else
    add WHEN instr_class = DP and Opcode="0100" else
    adc WHEN instr_class = DP and Opcode="0101" else
    sbc WHEN instr_class = DP and Opcode="0110" else
    rsc WHEN instr_class = DP and Opcode="0111" else
    tst WHEN instr_class = DP and Opcode="1000" else
    teq WHEN instr_class = DP and Opcode="1001" else
    cmp WHEN instr_class = DP and Opcode="1010" else
    cmn WHEN instr_class = DP and Opcode="1011" else
    orr WHEN instr_class = DP and Opcode="1100" else
    mov WHEN instr_class = DP and Opcode="1101" else
    bic WHEN instr_class = DP and Opcode="1110" else
    mvn WHEN instr_class = DP and Opcode="1111" else
    andd WHEN instr_class = DP and Opcode="0000" else
    eor WHEN instr_class = DP and Opcode="0001" else
    sub WHEN instr_class = DP and Opcode="0010" else
    rsb WHEN instr_class = DP and Opcode="0011" else
    add WHEN instr_class = DP and Opcode="0100" else
    adc WHEN instr_class = DP and Opcode="0101" else
    sbc WHEN instr_class = DP and Opcode="0110" else
    rsc WHEN instr_class = DP and Opcode="0111" else
    tst WHEN instr_class = DP and Opcode="1000" else
    teq WHEN instr_class = DP and Opcode="1001" else
    cmp WHEN instr_class = DP and Opcode="1010" else
    cmn WHEN instr_class = DP and Opcode="1011" else
    orr WHEN instr_class = DP and Opcode="1100" else
    mov WHEN instr_class = DP and Opcode="1101" else
    bic WHEN instr_class = DP and Opcode="1110" else
    mvn WHEN instr_class = DP and Opcode="1111" else
    
--for DT instructions
    str WHEN instr_class = DT  and I_bit='0' and L_bit='0' else
    str WHEN instr_class = DT  and I_bit='1' and L_bit='0' else
    ldr WHEN instr_class = DT  and I_bit='0' and L_bit='1' else
    ldr WHEN instr_class = DT  and I_bit='1' and L_bit='1' else
    strsh WHEN instr_class = DT and F_field = "00" and pmem(22) = '0' and L_bit = '0' else
    strsh WHEN instr_class = DT and F_field = "00" and pmem(22) = '1' and L_bit = '0' else
    ldrsh WHEN instr_class = DT and F_field = "00" and pmem(22) = '0' and L_bit = '1' else
    ldrsh WHEN instr_class = DT and F_field = "00" and pmem(22) = '1' and L_bit = '1' else
    
    b   WHEN cond="1110" else
    beq WHEN cond="0000" else
    bne WHEN cond="0001";
--    null when others;
    
    instr_class <= DT when F_field = "01" or (I_bit = '0' and pmem(7) = '1' and pmem(4) ='1' and F_field = "00") else
                   DP when F_field = "00" else
                   branch when F_field = "10" else
                   unknown;

    out_code <= --DP instructions
                "000000" WHEN i_decoded = andd else
     			"000001" WHEN i_decoded = eor else
     			"000010" WHEN i_decoded = sub else
     			"000011" WHEN i_decoded = rsb else
     			"000100" WHEN i_decoded = add else
     			"000101" WHEN i_decoded = adc else
     			"000110" WHEN i_decoded = sbc else
     			"000111" WHEN i_decoded = rsc else
     			"001000" WHEN i_decoded = tst else
     			"001001" WHEN i_decoded = teq else
     			"001010" WHEN i_decoded = cmp else
     			"001011" WHEN i_decoded = cmn else
     			"001100" WHEN i_decoded = orr else
     			"001101" WHEN i_decoded = mov else
     			"001110" WHEN i_decoded = bic else
     			"001111" WHEN i_decoded = mvn else
     			--DT instructions
     			"010100" WHEN i_decoded = str else
     			"010101" WHEN i_decoded = ldr else
     			"010110" WHEN i_decoded = strsh else
     			"010111" WHEN i_decoded = ldrsh else
     			--Branch Instructions
     			"100110" WHEN i_decoded = b else
     			"100111" WHEN i_decoded = beq else
     			"101000" WHEN i_decoded = bne else
     			--Halt Instructions
     			"111001" WHEN i_decoded = halt;

end Arch_Decoder;
