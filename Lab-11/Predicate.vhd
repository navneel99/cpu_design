library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--Vflag 0
--Cflag 1
--Zflag 2
--Nflag 3


entity predicate is 
port(
    instr : in std_logic_vector(3 downto 0);
    flag : in std_logic_vector(3 downto 0);
    p_bit : out std_logic
    );
end entity;

architecture Arch_predicate of predicate is 

begin 
p_bit <=   flag(2) when instr="0000" else
           (not flag(2)) when instr="0001" else
           flag(1) when instr="0010" else
           (not flag(1)) when instr="0011" else
           flag(3) when instr="0100" else
           (not flag(3)) when instr="0101" else
           (flag(0)) when instr="0110" else
           (not flag(0)) when instr="0111" else
           (flag(1) and not(flag(2))) when instr="1000" else
           (flag(2) and not(flag(1))) when instr="1001" else
           (not (flag(0) xor  flag(3))) when instr="1010" else
           ( flag(0) xor flag(3)) when instr="1011" else
           ((not flag(2)) and (not (flag(0) xor flag(3)))) when instr="1100" else
           (flag(2) or ( flag(0) xor flag(3))) when instr="1101" else
           '1' when instr="1110" else 
           '0' when instr="1111";
                                    
end Arch_predicate;
