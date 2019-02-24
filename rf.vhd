library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rf is 
port(
	wd : in std_logic_vector(31 downto 0);
	rad1 : in std_logic_vector(3 downto 0);
	rad2 : in std_logic_vector(3 downto 0);
	wad : in std_logic_vector(3 downto 0);
	enable : in std_logic;
	clk: in std_logic;
	reset : in std_logic;
	rd1 : out std_logic_vector(32 downto 0);
	rd2 : out std_logic_vector(32 downto 0)	
);
end rf;

architecture Behavioral of rf is 
type mult_array is array(15 downto 0) of std_logic_vector(31 downto 0);
signal rfile : mult_array;

begin

rfile(0) <= "00000000000000000000000000000000";
rfile(1) <= "00000000000000000000000000000000";
rfile(2) <= "00000000000000000000000000000000";
rfile(3) <= "00000000000000000000000000000000";
rfile(4) <= "00000000000000000000000000000000";
rfile(5) <= "00000000000000000000000000000000";
rfile(6) <= "00000000000000000000000000000000";
rfile(7) <= "00000000000000000000000000000000";
rfile(8) <= "00000000000000000000000000000000";
rfile(9) <= "00000000000000000000000000000000";
rfile(10) <= "00000000000000000000000000000000";
rfile(11) <= "00000000000000000000000000000000";
rfile(12) <= "00000000000000000000000000000000";
rfile(13) <= "00000000000000000000000000000000";
rfile(14) <= "00000000000000000000000000000000";
rfile(15) <= "00000000000000000000000000000000";

rd1 <= rfile(0) when rad1="0000" else
 rfile(1) when rad1="0001" else
 rfile(2) when rad1="0010" else
 rfile(3) when rad1="0011" else
 rfile(4) when rad1="0100" else
 rfile(5) when rad1="0101" else
 rfile(6) when rad1="0110" else
 rfile(7) when rad1="0111" else
 rfile(8) when rad1="1000" else
 rfile(9) when rad1="1001" else
 rfile(10) when rad1="1010" else
 rfile(11) when rad1="1011" else
 rfile(12) when rad1="1100" else
 rfile(13) when rad1="1101" else
 rfile(14) when rad1="1110" else
 rfile(15)  when rad1="1111";

rd2 <= rfile(0) when rad2="0000" else
rfile(1) when rad2="0001" else
rfile(2) when rad2="0010" else
rfile(3) when rad2="0011" else
rfile(4) when rad2="0100" else
rfile(5) when rad2="0101" else
rfile(6) when rad2="0110" else
rfile(7) when rad2="0111" else
rfile(8) when rad2="1000" else
rfile(9) when rad2="1001" else
rfile(10) when rad2="1010" else
rfile(11) when rad2="1011" else
rfile(12) when rad2="1100" else
rfile(13) when rad2="1101" else
rfile(14) when rad2="1110" else
rfile(15)  when rad2="1111";



write_port:	process(clk,reset,wad)
begin

if reset='0' then
	if rising_edge(clk) then
		if(enable='1') then 
			case wad is
				when "0000" =>
					rfile(0) <= wd;
				when "0001" =>
					rfile(1) <= wd;
				when "0010" =>
					rfile(2) <= wd;
				when "0011" =>
					rfile(3) <= wd;
				when "0100" =>
					rfile(4) <= wd;
				when "0101" =>
					rfile(5) <= wd;
				when "0110" =>
					rfile(6) <= wd;
				when "0111" =>
					rfile(7) <= wd;					
				when "1000" =>
					rfile(8) <= wd;
				when "1001" =>
					rfile(9) <= wd;
				when "1010" =>
					rfile(10) <= wd;
				when "1011" =>
					rfile(11) <= wd;
				when "1100" =>
					rfile(12) <= wd;
				when "1101" =>
					rfile(13) <= wd;
				when "1110" =>
					rfile(14) <= wd;
				when "1111" =>
					rfile(15) <= wd;					
				when others => null;
			end case;
		end if;
	end if;


else
	rfile(0) <= "00000000000000000000000000000000";
	rfile(1) <= "00000000000000000000000000000000";
	rfile(2) <= "00000000000000000000000000000000";
	rfile(3) <= "00000000000000000000000000000000";
	rfile(4) <= "00000000000000000000000000000000";
	rfile(5) <= "00000000000000000000000000000000";
	rfile(6) <= "00000000000000000000000000000000";
	rfile(7) <= "00000000000000000000000000000000";
	rfile(8) <= "00000000000000000000000000000000";
	rfile(9) <= "00000000000000000000000000000000";
	rfile(10) <= "00000000000000000000000000000000";
	rfile(11) <= "00000000000000000000000000000000";
	rfile(12) <= "00000000000000000000000000000000";
	rfile(13) <= "00000000000000000000000000000000";
	rfile(14) <= "00000000000000000000000000000000";
	rfile(15) <= "00000000000000000000000000000000";

end if;

end process;

end Behavioral;


