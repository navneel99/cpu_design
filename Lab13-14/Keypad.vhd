library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Keypad is
port(
    clk : in std_logic;
    row_out : out std_logic_vector(3 downto 0);
    current_input : in std_logic_vector(3 downto 0);
    previous_input : in std_logic_vector(3 downto 0);
    column_in : in std_logic_vector(3 downto 0);
    reset : in std_logic;
    write_keypad : out stdf_logic 
    );
end entity;
 
 architecture Arch_Keypad of Keypad is 

 signal counter : integer;

 begin
 
 counter <= 0;
 
 process(clk,reset)
 begin 
 
 if reset='1' then
     current_input <= "0000";
     previous_input <= "0000";
elsif clk'event and clk = '1' then
    previous_input <= current_input;
if columns = "0111" then
            if row_out = "0111" then
                current_Input <= "0001";
            elsif row_out = "1011" then
                current_Input <= "0100";
            elsif row_out = "1101" then
                current_Input <= "0111";
            elsif row_out = "1110" then
                current_Input <= "0000";
            end if;
    elsif columns = "1011" then
            if row_out = "0111" then
                current_Input <= "0010";
            elsif row_out = "1011" then
                current_Input <= "0101";
            elsif row_out = "1101" then
                current_Input <= "1000";
            elsif row_out = "1110" then
                current_Input <= "1111";
            end if;		
    elsif columns = "1101" then
            if row_out = "0111" then
                current_Input <= "0011";
            elsif row_out = "1011" then
                current_Input <= "0110";
            elsif row_out = "1101" then
                current_Input <= "1001";
            elsif row_out = "1110" then
                current_Input <= "1110";
    elsif columns = "1110" then
            if row_out = "0111" then
                current_Input <= "1010";
            elsif row_out = "1011" then
                current_Input <= "1011";
            elsif row_out = "1101" then
                current_Input <= "1100";
            elsif row_out = "1110" then
                current_Input <= "1101";
    else
        current_Input <= "0000";
    end if;
    
    counter=counter+1;
    
    end process;
    
    row_out <= "0111" when counter=0 else
               "1011" when counter=1 else
               "1101" when counter=2 else
               "1110" when counter=3 ;
               
   end Arch_Keypad; 







     