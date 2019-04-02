library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
use Ieee.std_logic_unsigned.all;

entity CPU is
Port(
clk: in std_logic;
reset: in std_logic;
pmem: in std_logic_vector(31 downto 0);
dfmem: in std_logic_vector(7 downto 0); --not sure about the dimensions of the data
apmem,dtmem: out std_logic_vector(7 downto 0);
we: out std_logic);
end CPU;

architecture arch_CPU of CPU is

type instr_class_type is (DP, DT, branch, unknown);
type i_decoded_type is (add,sub,cmp,mov,ldr,str,beq,bne,b,unknown);

type rf_type is array (0 to 15) of std_logic_vector(7 downto 0);
signal rf : rf_type;

signal instr_class : instr_class_type;
signal i_decoded : i_decoded_type;


signal cond : std_logic_vector (3 downto 0);
signal F_field : std_logic_vector (1 downto 0);
signal I_bit : std_logic;
signal Opcode : std_logic_vector (3 downto 0);
signal U_bit,L_bit: std_logic;
signal Rn: std_logic_vector(3 downto 0 );
signal Rd: std_logic_vector(3 downto 0 );
signal Rotspec: std_logic_vector(3 downto 0);
signal shift_spec : std_logic_vector (7 downto 0);
signal Imm8: std_logic_vector(7 downto 0);
signal Rm: std_logic_vector(3 downto 0 );
signal pc: std_logic_vector(7 downto 0):="00000000" ;
signal flags: std_logic_vector(7 downto 0);
begin 

--process(clk)
--begin
--    if(reset='1')then
--        pc <= "00000000";
--    else if(clk='1' and clk'EVENT)then
    
--    cond <= pmem (31 downto 28);
--    F_field <= pmem (27 downto 26);
----    I_bit <= pmem (25);
--    shift_spec <= pmem (11 downto 4);

--        if(cond="1110" and F_field="00")then
            
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
    
               
--for DP instructions
 
 i_decoded <= add  WHEN cond="1110" and F_field="00" and I_bit='1' and Opcode="0100" else
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
    bne WHEN cond="0001";
    
    instr_class <= DP when F_field = "00" else
                   DT when F_field = "01" else
                   branch when F_field = "10" else
                   unknown;
  
  process (clk,reset)
  begin
  if reset = '1' then
    pc <= "00000000";
  elsif (rising_edge(clk)) then
      case i_decoded is
        when add => 
            case I_bit is
                when '0' =>
                    rf(to_integer(unsigned(Rd)))<= rf(to_integer(unsigned(Rn))) + rf(to_integer(unsigned(Rm)));
                when '1' =>
                    rf(to_integer(unsigned(Rd)))<= rf(to_integer(unsigned(Rn))) + Imm8;                    
             end case;
             pc <= pc + "00000100";
        when sub =>
            case I_bit is
                when '0' =>
                    rf(to_integer(unsigned(Rd)))<= rf(to_integer(unsigned(Rn))) - rf(to_integer(unsigned(Rm)));
                when '1' =>
                    rf(to_integer(unsigned(Rd)))<= rf(to_integer(unsigned(Rn))) - Imm8;                    
             end case;
         pc <= pc + "00000100";        
        when mov =>
            case I_bit is
                when '0' =>
                    rf(to_integer(unsigned(Rd)))<= rf(to_integer(unsigned(Rn)) + to_integer(unsigned(rf(to_integer(unsigned(Rm))))));
                when '1' =>
                    rf(to_integer(unsigned(Rd)))<= rf(to_integer(unsigned(Rn)) + to_integer(unsigned(Imm8)));                    
             end case;
            pc <= pc + "00000100";
        when cmp =>
            case I_bit is
                when '0' =>
                    if ( rf(to_integer(unsigned(Rn))) = rf(to_integer(unsigned(Rm)))) then
                        flags <= "00000001";
                    else
                        flags <= "00000000";
                    end if;
                 when '1' =>
                    if ( rf(to_integer(unsigned(Rn))) = rf(to_integer(unsigned(Rm)))) then
                        flags <= "00000001";
                    else
                        flags <= "00000000";
                    end if;                    
            end case;
            pc <= pc + "00000100";
        when str =>
            case U_bit is
                when '1' =>
                    --store into data memory with +ve offset /to be implemented in assignment 5     
                when '0' =>
                    --store into data memory with -ve offset /to be implemented in assignment 5 
            end case;
            we <= '1';        
            pc <= pc + "00000100";
        when ldr =>
            case U_bit is
                when '1' =>
                    rf(to_integer(unsigned(Rd)))<= dfmem;           --/+ve offset 
                when '0' =>
                    rf(to_integer(unsigned(Rd)))<= dfmem;           -- -ve offset                        
            end case;
            pc <= pc + "00000100";
        when b =>
            pc <= pc + "00000100";
        when beq =>
            case flags is 
                when "00000001" =>
                    --don't jump
                when "00000000" =>
                    -- jump to an address
             end case;
            pc <= pc + "00000100";
        when bne =>
            pc <= pc + "00000100";               
      end case;
  end if;
  end process;
end arch_CPU;
