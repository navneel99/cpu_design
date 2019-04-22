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
  mul_decide: in std_logic;
  clk,reset: in std_logic;
  in_execution_state: in std_logic_vector(2 downto 0);
  LD_bit: in std_logic;
  out_code: in std_logic_vector(5 downto 0);
  control_state: out std_logic_vector(1 downto 0); --if red then 01 else if halt then 11 else 00
  curr_control_state: out std_logic_vector(4 downto 0) --This will give the state of this FSM as a bit vector
  );
end control_state_FSM;

architecture Behavioral of control_state_FSM is
type control_state_fsm_type is (fetch, decode, instr_class_state, shift_dp_read, shift_dp_write,mul_write,mul2RF, shift_dt, dt_incr, arith, res2RF, mul_state, addr, mem_wr, mem_rd, mem2RF, brn, halt);

signal control_fsm_state: control_state_fsm_type;
signal instr_class_slice: std_logic_vector(1 downto 0);
signal execution_state_slice: std_logic_vector(1 downto 0);
begin

--Current Control State gives these:
--fetch as 00000
--decode as 00001
--instr_class_state as 00010
--arith as 00011
--addr as 00100
--brn as 00101
--halt as 00110
--res2RF as 00111
--mem_wr as 01000
--mem_rd as 01001
--mem2RF as 01010
--shift_dp_read as 01011
--shift_dp_write as 01111
--shift_dt as 01100
--dt_incr as 01101
--mul_state as 01110
--mul_write as 10000
--mul2RF as 10001

instr_class_slice <= out_code(5 downto 4);
execution_state_slice <= in_execution_state(1 downto 0);

process(clk, control_fsm_state, reset)
    begin
        if reset = '1' then
            control_fsm_state <= fetch;
            control_state <= "00";
            curr_control_state <="00000";
        elsif rising_edge(clk) then
            if (execution_state_slice /= "00") then
                case control_fsm_state is
                    when fetch =>
                        control_fsm_state <= decode;
                        curr_control_state <="00001";
                    when decode =>
                        control_fsm_state <= instr_class_state;
                        curr_control_state <="00010";
                    when instr_class_state =>
                        if (instr_class_slice = "00" or out_code ="110000") then --DP
                            if(mul_decide='0') then
                                control_fsm_state <= shift_dp_read;
                                curr_control_state <="01011";
                            else
                                control_fsm_state<= mul_state;
                                curr_control_state <= "01110";                            
                            end if;
                        elsif ( instr_class_slice = "01") then --DT
                            control_fsm_state <= shift_dt;
                            curr_control_state <="01100";
                        elsif ( instr_class_slice = "10") then --branch
                            control_fsm_state <= brn;
                            control_state <= "01";
                            curr_control_state <="00101";
                        else --halt
                            control_fsm_state <= halt;
                            control_state <= "11";
                            curr_control_state <="00110";
                        end if;   
                    when shift_dp_read =>
                            control_fsm_state <= shift_dp_write;
                            curr_control_state <= "01111";
                    when shift_dp_write =>
                            control_fsm_state <= arith;
                            curr_control_state <= "00011";
                    when shift_dt =>
                            control_fsm_state <= addr;
                            curr_control_state <= "00100";
                    when arith =>             
                        control_fsm_state <= res2RF;
                        control_state <= "01";
                        curr_control_state <="00111";
                    when addr =>
                        if LD_bit = '1' then
                            control_fsm_state <= mem_rd;
                            curr_control_state <="01001";
                        else
                            control_fsm_state <= mem_wr;
                            curr_control_state <="01000";
                        end if;
                   when mem_rd =>
                        control_fsm_state <= mem2RF;
                        curr_control_state <="01010";
                   when mem2RF =>
                        control_fsm_state <= dt_incr;
                        control_state <= "01";
                        curr_control_state<="01101";
                   when mem_wr =>
                        control_fsm_state <= dt_incr;
                        control_state <= "01";
                        curr_control_state<="01101";
                   when mul_state => 
                        control_fsm_state <= mul_write;
                        control_state <= "01";
                        curr_control_state <= "10000";
                   when mul_write =>
                        control_fsm_state <= mul2RF;
                        control_state <= "01";
                        curr_control_state <= "10001";
                   when others => --These are the red conditions
                        control_fsm_state <= fetch;
                        control_state <= "00";
                        curr_control_state <="00000";
                end case;
            end if;
        end if;
end process;
end Behavioral;
