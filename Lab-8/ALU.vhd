library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity ALU is 
PORT (
    clk : in std_logic;
	rd1 : in std_logic_vector(31 downto 0); 
	rd2 : in std_logic_vector(31 downto 0);
--	operand inputs
	sel : in std_logic_vector(5 downto 0); --add or subtract only
	res : out std_logic_vector(31 downto 0); --result
	carry : in std_logic;
	flag : out std_logic_vector(3 downto 0); --flag output
	flag_we: in std_logic
	
);
end ALU;

architecture Arch_ALU of ALU is

signal rd1_extend,rd2_extend: std_logic_vector(32 downto 0);
signal carry_vector: std_logic_vector(31 downto 0);
signal out_alu: std_logic_vector(32 downto 0);
signal temp_flag: std_logic_vector(3 downto 0);
begin 

rd1_extend <=  '0'&rd1;
rd2_extend <=  '0'&rd2;
carry_vector <= "0000000000000000000000000000000"& carry;

out_alu <= 

(rd1_extend and rd2_extend) when sel="000000" else    --and
(rd1_extend xor rd2_extend) when sel="000001" else   --eor
std_logic_vector(unsigned(rd1_extend) - unsigned(rd2_extend)) when sel="000010" else --sub
--std_logic_vector((rd1_extend) + (not rd2_extend)) when sel="000010" else
std_logic_vector(unsigned(rd2_extend) - unsigned(rd1_extend)) when sel="000011" else --rsb
std_logic_vector(unsigned(rd1_extend) + unsigned(rd2_extend)) when sel="000100" else --add
std_logic_vector(unsigned(rd1_extend) + unsigned(rd2_extend) + unsigned(carry_vector)) when sel="000101" else  --adc
std_logic_vector(unsigned(rd1_extend) - unsigned(rd2_extend) + unsigned(carry_vector)) when sel="000110" else  --sbc
std_logic_vector(unsigned(rd2_extend) - unsigned(rd1_extend) + unsigned(carry_vector)) when sel="000111" else  --rsc
((rd1_extend) and (rd2_extend)) when sel="001000" else  --tst
((rd1_extend) xor (rd2_extend)) when sel="001001" else  --teq
std_logic_vector(signed(rd1_extend) - signed(rd2_extend)) when sel="001010" else --cmp
std_logic_vector(unsigned(rd1_extend) + unsigned(rd2_extend)) when sel="001011" else --cmn
(rd1_extend or rd2_extend) when sel="001100" else  --orr
rd2_extend when sel="001101" else  --mov
(rd1_extend) and (not rd2_extend) when sel="001110" else  --bic
(not rd2_extend) when sel="001111";

temp_flag(0) <= (out_alu(32) xor(rd1_extend(31)) xor rd2_extend(32));                                              --V flag
temp_flag(1) <= out_alu(32);                                                            --C flag
temp_flag(2) <= '1' when out_alu = "000000000000000000000000000000000" else   --Z flag
        '0';
temp_flag(3) <= out_alu(31);                                                                             --N flag

flag <= temp_flag when flag_we = '1';
res <= out_alu(31 downto 0);

end Arch_ALU;
