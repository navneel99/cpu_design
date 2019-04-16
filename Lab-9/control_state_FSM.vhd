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
  control_state: out std_logic_vector(1 downto 0); --if red then 01 else if halt then 11 else 00
  curr_control_state: out std_logic_vector(3 downto 0) --This will give the state of this FSM as a bit vector
  );
end control_state_FSM;

architecture Behavioral of control_state_FSM is
type control_state_fsm_type is (fetch, decode, instr_class_state, shift_dp_read, shift_dp_write, shift_dt, dt_incr, arith, res2RF, addr, mem_wr, mem_rd, mem2RF, brn, halt);

signal control_fsm_state: control_state_fsm_type;
signal instr_class_slice: std_logic_vector(1 downto 0);
signal execution_state_slice: std_logic_vector(1 downto 0);
begin

--Current Control State gives these:
--fetch as 0000
--decode as 0001
--instr_class_state as 0010
--arith as 0011
--addr as 0100
--brn as 0101
--halt as 0110
--res2RF as 0111
--mem_wr as 1000
--mem_rd as 1001
--mem2RF as 1010
--shift_dp_read as 1011
--shift_dp_write as 1111
--shift_dt as 1100
--dt_incr as 1101

instr_class_slice <= out_code(5 downto 4);
execution_state_slice <= in_execution_state(1 downto 0);

process(clk, control_fsm_state, reset)
    begin
        if reset = '1' then
            control_fsm_state <= fetch;
            control_state <= "00";
            curr_control_state <="0000";
        elsif rising_edge(clk) then
            if (execution_state_slice /= "00") then
                case control_fsm_state is
                    when fetch =>
                        control_fsm_state <= decode;
                        curr_control_state <="0001";
                    when decode =>
                        control_fsm_state <= instr_class_state;
                        curr_control_state <="0010";
                    when instr_class_state =>
                        if (instr_class_slice = "00") then --DP
                            control_fsm_state <= shift_dp_read;
                            curr_control_state <="1011";
                        elsif ( instr_class_slice = "01") then --DT
                            control_fsm_state <= shift_dt;
                            curr_control_state <="1100";
                        elsif ( instr_class_slice = "10") then --branch
                            control_fsm_state <= brn;
                            control_state <= "01";
                            curr_control_state <="0101";
                        else --halt
                            control_fsm_state <= halt;
                            control_state <= "11";
                            curr_control_state <="0110";
                        end if;
                    when shift_dp_read =>
                            control_fsm_state <= shift_dp_write;
                            curr_control_state <= "1111";
                    when shift_dp_write =>
                            control_fsm_state <= arith;
                            curr_control_state <= "0011";
                    when shift_dt =>
                            control_fsm_state <= addr;
                            curr_control_state <= "0100";
                    when arith =>             
                        control_fsm_state <= res2RF;
                        control_state <= "01";
                        curr_control_state <="0111";
                    when addr =>
                        if LD_bit = '1' then
                            control_fsm_state <= mem_rd;
                            curr_control_state <="1001";
                        else
                            control_fsm_state <= mem_wr;
                            curr_control_state <="1000";
                        end if;
                   when mem_rd =>
                        control_fsm_state <= mem2RF;
                        curr_control_state <="1010";
                   when mem2RF =>
                        control_fsm_state <= dt_incr;
                        control_state <= "01";
                        curr_control_state<="1101";
                   when mem_wr =>
                        control_fsm_state <= dt_incr;
                        control_state <= "01";
                        curr_control_state<="1101";
                   when others => --These are the red conditions
                        control_fsm_state <= fetch;
                        control_state <= "00";
                        curr_control_state <="0000";
                end case;
            end if;
        end if;
end process;
end Behavioral;
