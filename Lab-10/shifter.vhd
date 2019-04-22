library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity shifter is 
PORT (
    op1 : in std_logic_vector(31 downto 0);
    res : out std_logic_vector(31 downto 0);
    sel : in std_logic_vector(1 downto 0);
    shift : in std_logic_vector(31 downto 0);
    carry : out std_logic);
end;

architecture Arch_Shift of shifter is 
signal temp_out : std_logic_vector(33 downto 0);
begin 

temp_out <= '0'&op1&'0';

res <= std_logic_vector(shift_left(unsigned(op1),to_integer(signed(shift)))) when sel="00" else  --LSL
       std_logic_vector(shift_right(unsigned(op1),to_integer(signed(shift)))) when sel="01" else   --LSR
       std_logic_vector(shift_right(signed(op1),to_integer(signed(shift)))) when sel="10" else   --ASR
       std_logic_vector(rotate_right(unsigned(op1),to_integer(signed(shift)))) when sel="11";  --ROR
       
carry <= temp_out(33-to_integer(signed(shift))) when sel="00" else
         temp_out(to_integer(signed(shift))) when sel="01" else
         temp_out(to_integer(signed(shift))) when sel="10" else
         '0' when sel="11";
                
end architecture Arch_Shift;