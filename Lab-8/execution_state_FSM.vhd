----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/25/2019 10:22:02 PM
-- Design Name: 
-- Module Name: execution_state_FSM - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity execution_state_FSM is
  Port ( 
  clk,reset,step,instr,go: in std_logic;
  control_state: in std_logic_vector(1 downto 0); --if red then 01 else if halt then 11 else 00
--  in_execution_state: in std_logic_vector(1 downto 0);
  out_execution_state: out std_logic_vector(2 downto 0)
  );
end execution_state_FSM;

architecture Behavioral of execution_state_FSM is
    signal temp_execution_state: std_logic_vector(2 downto 0);
--    initial is 000
--    onestep is 001
--    oneinstr is 010
--    cont is 011
--    done is 100
begin

process(clk,reset)
begin
    if (reset = '1') then
        temp_execution_state <= "000";
    elsif rising_edge(clk) then
        case temp_execution_state is
            when "000" =>
                if step = '1' then
                    temp_execution_state <= "001";
                elsif instr = '1' then
                    temp_execution_state <= "010";
                elsif go = '1' then
                    temp_execution_state <= "011";
                else
                    temp_execution_state <= "000";
                end if;
             when "001" =>
                temp_execution_state <= "100";
             when "010" =>
                if control_state(0) = '1' then 
                    temp_execution_state <= "100";
                end if;
             when "011" =>
                if control_state = "11" then
                    temp_execution_state <= "100";
                end if;
             when "100" =>
                if step = '0' and go = '0' and instr = '0' then
                    temp_execution_state <= "000";
                end if;
             when others =>
        end case;
    end if;
    out_execution_state <= temp_execution_state;
end process;

end Behavioral;