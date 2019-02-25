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

entity control_state_FSM is
  Port ( 
  clk,reset: in std_logic;
  in_execution_state: in std_logic_vector(2 downto 0);
  LD_bit: in std_logic;
  out_code: in std_logic_vector(5 downto 0);
  control_state: out std_logic_vector(1 downto 0) --if red then 01 else if halt then 11 else 00
  );
end control_state_FSM;

architecture Behavioral of control_state_FSM is
type control_state_fsm_type is (fetch, decode, instr_class_state, arith, res2RF, addr, mem_wr, mem_rd, mem2RF, brn, halt);

signal control_fsm_state: control_state_fsm_type;
signal instr_class_slice: std_logic_vector(1 downto 0);
signal execution_state_slice: std_logic_vector(1 downto 0);
begin

instr_class_slice <= out_code(5 downto 4);
execution_state_slice <= in_execution_state(1 downto 0);

process(clk, control_fsm_state, reset)
    begin
        if reset = '1' then
            control_fsm_state <= fetch;
            control_state <= "00";
        elsif rising_edge(clk) then
            if (execution_state_slice /= "00") then
                case control_fsm_state is
                    when fetch =>
                        control_fsm_state <= decode;
                    when decode =>
                        control_fsm_state <= instr_class_state;
                    when instr_class_state =>
                        if (instr_class_slice = "00") then
                            control_fsm_state <= arith;
                        elsif ( instr_class_slice = "01") then
                            control_fsm_state <= addr;
                        elsif ( instr_class_slice = "10") then
                            control_fsm_state <= brn;
                            control_state <= "01";
                        else
                            control_fsm_state <= halt;
                            control_state <= "11";
                        end if;
                    when arith =>             
                        control_fsm_state <= res2RF;
                        control_state <= "01";
                    when addr =>
                        if LD_bit = '1' then
                            control_fsm_state <= mem_rd;
                        else
                            control_fsm_state <= mem_wr;
                            control_state <= "01";
                        end if;
                   when mem_rd =>
                        control_fsm_state <= mem2RF;
                        control_state <= "01";
                   when others => --These are the read conditions
                        control_fsm_state <= fetch;
                        control_state <= "00";
                end case;
            end if;
        end if;
end process;
end Behavioral;
