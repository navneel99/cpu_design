----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/12/2019 08:19:03 PM
-- Design Name: 
-- Module Name: proc_dm_datapath - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity proc_dm_datapath is
  Port (
    word: in std_logic; --1 if we are passing full word
    ldr_or_str : in std_logic; --1 if ldr, 0 if str
    SH : in std_logic_vector(1 downto 0); -- 00 for unsigned byte, 01 for unsigned half word, 10 for signed byte and 11 for signed half word
    full_word: in std_logic_vector(31 downto 0);
    we_or_select: in std_logic_vector(1 downto 0); --when ldr then use select and when str then we
    out_word: out std_logic_vector(31 downto 0)  --this word can be either going to the memory(after replication) or going from the memory(extracting hw or byte)
   );
end proc_dm_datapath;

architecture Behavioral of proc_dm_datapath is
    signal temp_out_word : std_logic_vector(31 downto 0);
    signal str_out_word : std_logic_vector(31 downto 0);
    signal ldr_out_word : std_logic_vector(31 downto 0);
    signal slice_hw:std_logic_vector(15 downto 0);
    signal slice_b:std_logic_vector(7 downto 0);
    signal decoded_we:std_logic_vector(3 downto 0);
begin
    temp_out_word <= full_word when ldr_or_str = '1' else --ldr
                     std_logic_vector(resize(unsigned(full_word(7 downto 0)),32)) when ldr_or_str = '0' and SH = "00" else
                     std_logic_vector(resize(unsigned(full_word(15 downto 0)),32)) when ldr_or_str = '0' and SH = "01" else
                     std_logic_vector(resize(signed(full_word(7 downto 0)),32)) when ldr_or_str = '0' and SH = "10" else
                     std_logic_vector(resize(signed(full_word(15 downto 0)),32)) when ldr_or_str = '0' and SH = "11";

    slice_hw <= temp_out_word(31 downto 16) when we_or_select(0) = '1' else
                temp_out_word(15 downto 0);

    slice_b <= temp_out_word(31 downto 24) when we_or_select = "11" else
                temp_out_word(23 downto 16)when we_or_select = "10" else
                temp_out_word(15 downto 8)when we_or_select = "01" else
                temp_out_word(7 downto 0)when we_or_select = "00";

    str_out_word <= (temp_out_word(7 downto 0))&(temp_out_word(7 downto 0))&(temp_out_word(7 downto 0))&(temp_out_word(7 downto 0)) when SH(0) = '0' else
                    (temp_out_word(15 downto 0)) & (temp_out_word(15 downto 0)) when  SH(0) = '1';
     

    ldr_out_word <= std_logic_vector(resize(unsigned(slice_hw),32)) when SH = "01" else
                std_logic_vector(resize(signed(slice_HW),32)) when SH = "11" else
                std_logic_vector(resize(unsigned(slice_b),32)) when SH = "00" else
                std_logic_vector(resize(signed(slice_b),32)) when SH = "10";

    out_word <= full_word when word = '1' else
                ldr_out_word when ldr_or_str = '1' else
                str_out_word when ldr_or_str = '0';
                
end Behavioral;
