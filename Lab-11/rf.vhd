library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rf is 
port(
    disp_rad: in std_logic_vector(3 downto 0);
    disp_rd: out std_logic_vector(31 downto 0);
	wd : in std_logic_vector(31 downto 0);
	rad1 : in std_logic_vector(3 downto 0);
	rad2 : in std_logic_vector(3 downto 0);
	pc_in : in std_logic_vector(31 downto 0);  
	wad : in std_logic_vector(3 downto 0);
	enable : in std_logic;
	clk: in std_logic;
	rd1 : out std_logic_vector(31 downto 0);
	rd2 : out std_logic_vector(31 downto 0);	
	pc_out : out std_logic_vector(31 downto 0);
	pc_enable:in std_logic
);
end rf;

architecture Behavioral of rf is 
type mult_array is array(15 downto 0) of std_logic_vector(31 downto 0);
signal rfile : mult_array;
signal pc : std_logic_vector(31 downto 0); 

begin
 
rd1 <= rfile(to_integer(unsigned(rad1)));
rd2 <= rfile(to_integer(unsigned(rad2)));

pc <= pc_in when pc_enable = '1';
pc_out <= pc;
disp_rd <= rfile(to_integer(unsigned(disp_rad)));
--rfile(to_integer(unsigned(wad))) <= wd when enable = '1';



process(clk)
begin
----    rfile <=(others=>"00000000000000000000000000000000");
if rising_edge(clk) then
	if(enable='1') then 
       rfile(to_integer(unsigned(wad))) <= wd;
	end if;
end if;
end process;

end Behavioral;
