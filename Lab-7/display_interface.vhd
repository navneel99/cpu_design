----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/19/2019 12:41:35 AM
-- Design Name: 
-- Module Name: display_interface - Behavioral
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
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity display_interface is
Port (
    clk: in std_logic;
    display_select: in std_logic_vector(1 downto 0);
    slice_select: in std_logic;
    ex_state: in std_logic_vector(2 downto 0);
    control_state: in std_logic_vector(3 downto 0);   
    pc: in std_logic_vector(31 downto 0); 
    led_vector:out std_logic_vector(15 downto 0);
    rf_element: in std_logic_vector(31 downto 0)
 );
end display_interface;

architecture Behavioral of display_interface is
    signal ful_instr: std_logic_vector(31 downto 0);
    signal ms_half,ls_half: std_logic_vector(15 downto 0);
begin
--    apmem is 0
--    pmem is 1
--    state is 2
--    dfmem is 3
--    admem is 4
--    dtmem is 5
    ful_instr <=
         std_logic_vector(resize((unsigned(ex_state)),32)) when display_select = "00" else
         std_logic_vector(resize((unsigned(control_state)),32)) when display_select = "01" else
         pc when display_select = "10" else
         rf_element;
        
    ms_half <= ful_instr(31 downto 16);
    ls_half <= ful_instr(15 downto 0);
    led_vector <= ms_half when slice_select = '1' else
        ls_half;
--    process(clk)
--        begin
--            if rising_edge(clk) then
--                if slice_select = '1' then
--                    led_vector <= ms_half;
--                else
--                    led_vector <= ls_half;
--                end if;
--            end if;
--    end process;
end Behavioral;