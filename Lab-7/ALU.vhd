library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is 
PORT (
	rd1 : in std_logic_vector(31 downto 0); 
	rd2 : in std_logic_vector(31 downto 0);
--	operand inputs
	sel : in std_logic_vector(1 downto 0); --add or subtract only
	res : out std_logic_vector(31 downto 0); --result
	carry : in std_logic;
	flag : out std_logic --flag output
	--flag write enabled input is left.
);
end ALU;

architecture Arch_ALU of ALU is

signal rd1_extend,rd2_extend: std_logic_vector(32 downto 0);
signal carry_vector: std_logic_vector(31 downto 0);
signal out_alu: std_logic_vector(32 downto 0);

begin 

rd1_extend <= '0' & rd1;
rd2_extend <= '0' & rd2;
carry_vector <= "0000000000000000000000000000000" & carry;

out_alu <= 
std_logic_vector(unsigned(rd1_extend) + unsigned(rd2_extend)) when sel="00" else --add
std_logic_vector(unsigned(rd1_extend) - unsigned(rd2_extend)) when sel="01" else --sub
std_logic_vector(unsigned(rd1_extend) + unsigned(rd2_extend) + unsigned(carry_vector)) when sel="10" else  --addc
std_logic_vector(unsigned(rd1_extend) - unsigned(rd2_extend) + unsigned(carry_vector)) when sel="11";  --subc 


flag <= not( out_alu(31) or out_alu(30) or out_alu(29) or out_alu(28) or out_alu(27) or out_alu(26) or out_alu(25) or out_alu(24) or out_alu(23) or out_alu(22) or out_alu(21) or out_alu(20) or out_alu(19) or out_alu(18) or out_alu(17) or out_alu(16) or out_alu(15) or out_alu(14) or out_alu(13) or out_alu(12) or out_alu(11) or out_alu(10) or out_alu(9) or out_alu(8) or out_alu(7) or out_alu(6) or out_alu(5) or out_alu(4) or out_alu(3) or out_alu(2) or out_alu(1) or out_alu(0) );

res <= out_alu(31 downto 0);

end Arch_ALU;
