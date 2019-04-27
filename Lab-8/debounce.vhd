library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity debounce is
Port (
input,clk: in std_logic;
output: out std_logic
 );
end debounce;

architecture Behavioral of debounce is
signal count: std_logic_vector(3 downto 0):= "0000";

begin
    process(clk)
    begin
        if rising_edge(clk) then
            count<=count+1;
            if(count="1111") then
                output <= input;
            end if;
        end if;
        
    end process;       

end Behavioral;