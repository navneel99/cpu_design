library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is 
PORT (
	rd1 : in std_logic_vector(31 downto 0);
	rd2 : in std_logic_vector(31 downto 0);
	sel : in std_logic_vector(3 downto 0);
	res : out std_logic_vector(31 downto 0);
	carry : in std_logic;
	flag : out std_logic_vector(3 downto 0)
);

architecture Behavioral of ALU is
begin 
signal rd1_extend,rd2_extend: std_logic_vector(32 downto 0);
signal carry_vector: std_logic_vector(31 downto 0);
signal out_alu: std_logic_vector(32 downto 0);
rd1_extend <= '0' & rd1;
rd2_extend <= '0' & rd2;
carry_vector <= "0000000000000000000000000000000" & carry;

process(rd1_extend,rd2_extend,sel,carry)
begin 
case sel is
when "0000" => 
	out_alu <= rd1_extend and rd2_extend;    --and
when "0001" =>
	out_alu <= rd1_extend eor rd2_extend;   --XOR
when "0010" => 
	out_alu <= rd1_extend + (not rd2_extend) + 1;    --sub
when "0011" =>
	out_alu <= (not rd1_extend) + rd2_extend + 1;   --rsb
when "0100" => 
	out_alu <= rd1_extend + rd2_extend;
when "0101" =>
	out_alu <= rd1_extend + rd2_extend + carry_vector;
when "0110" => 
	out_alu <= rd1_extend + (not rd2_extend) + carry_vector;
when "0111" => 
	out_alu <= (not rd1_extend) + (rd2_extend) + carry_vector;
when "1000" =>
	out_alu <= rd1_extend and rd2_extend;
when "1001" =>
	out_alu <= rd_extend eor rd2_extend;
when "1010" =>
	out_alu <= rd1_extend + (not rd2_extend) + 1;
when "1011" =>
	out_alu <= rd1_extend + rd2_extend;
when "1100" =>
	out_alu <= rd1_extend or rd2_extend;
when "1101" => 
	out_alu <= rd2_extend;
when "1110" =>
	out_alu <= rd1_extend and (not rd2_extend);
when "1111" =>
	out_alu <= (not rd2_extend);
when others => null;

end case;
end process;

process(out_alu,rd1,rd2)
begin 
out_flag(1) <= not( out_alu(31) or out_alu(30) or out_alu(29) or out_alu(28) or out_alu(27) or out_alu(26) or out_alu(25) or out_alu(24) or out_alu(23) or out_alu(22) or out_alu(21) or out_alu(20) or out_alu(19) or out_alu(18) or out_alu(17) or out_alu(16) or out_alu(15) or out_alu(14) or out_alu(13) or out_alu(12) or out_alu(11) or out_alu(10) or out_alu(9) or out_alu(8) or out_alu(7) or out_alu(6) or out_alu(5) or out_alu(4) or out_alu(3) or out_alu(2) or out_alu(1) or out_alu(0) );
end process;

res <= out_alu(31 downto 0);

end Behavioral;
 