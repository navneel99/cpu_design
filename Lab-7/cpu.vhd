----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/26/2019 01:17:45 PM
-- Design Name: 
-- Module Name: cpu - Behavioral
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

entity cpu is
--  Port (     );
end cpu;

architecture Behavioral of cpu is

component control_state_FSM
Port ( 
  clk,reset: in std_logic;
  in_execution_state: in std_logic_vector(2 downto 0);
  LD_bit: in std_logic;
  out_code: in std_logic_vector(5 downto 0);
  control_state: out std_logic_vector(1 downto 0) --if red then 01 else if halt then 11 else 00
  );
end component;

component execution_state_FSM
Port ( 
clk,reset,step,instr,go: in std_logic;
control_state: in std_logic_vector(1 downto 0); --if red then 01 else if halt then 11 else 00
--  in_execution_state: in std_logic_vector(1 downto 0);
out_execution_state: out std_logic_vector(2 downto 0)
);
end component;

component ALU
PORT (
	rd1 : in std_logic_vector(31 downto 0); 
	rd2 : in std_logic_vector(31 downto 0);
--	operand inputs
	sel : in std_logic_vector(5 downto 0);
	res : out std_logic_vector(31 downto 0); --result
	carry : in std_logic;
	flag : out std_logic --flag output
	--flag write enabled input is left.
);
end component;

component Decoder 
Port(
clk: in std_logic;
pmem: in std_logic_vector(31 downto 0);
out_code: out std_logic_vector(5 downto 0)
);
end component;

component rf 
port(
	wd : in std_logic_vector(31 downto 0); --data input for write
	rad1 : in std_logic_vector(3 downto 0);
	rad2 : in std_logic_vector(3 downto 0);
	wad : in std_logic_vector(3 downto 0); --write address
	enable : in std_logic; --write enable
	clk: in std_logic;
	reset : in std_logic;
	rd1 : out std_logic_vector(31 downto 0);
	rd2 : out std_logic_vector(31 downto 0);
	pc_in : in std_logic_vector(31 downto 0);
	pc_out : out std_logic_vector(31 downto 0)	
--	Be sure to add the Program Counter Here
);
end component;

signal clk, reset, step, instr, go, temp_enable : std_logic;
signal temp_out_code: std_logic_vector(5 downto 0);
signal temp_ex_state: std_logic_vector(2 downto 0);
signal temp_LD_bit: std_logic;
signal temp_ctrl_state: std_logic_vector(1 downto 0);
signal temp_rd1, temp_rd2, temp_res: std_logic_vector(31 downto 0);
signal temp_sel: std_logic_vector(5 downto 0);
signal temp_carry, temp_flag, temp_flagwe: std_logic;
signal temp_pmem, temp_wd: std_logic_vector(31 downto 0);
signal temp_rad1,temp_rad2, temp_wad: std_logic_vector(3 downto 0);
signal temp_rf_rd1, temp_rf_rd2: std_logic_vector(31 downto 0);
signal temp_pcin, temp_pcout : std_logic_vector(31 downto 0);

begin

temp_csFSM: control_state_FSM
port map(
    clk => clk,
    reset => reset,
    in_execution_state =>temp_ex_state,
    LD_bit => temp_LD_bit,
    out_code => temp_out_code,
    control_state => temp_ctrl_state
);

temp_esFSM: execution_state_FSM
port map(
    clk => clk,
    reset => reset,
    step => step,
    instr => instr,
    go => go,
    control_state => temp_ctrl_state,
    out_execution_state => temp_ex_state    
);

temp_alu: ALU
port map(
    rd1 => temp_rd1,
    rd2 => temp_rd2,
    sel => temp_sel,
    res => temp_res,
    carry => temp_carry,
    flag => temp_flag
);

temp_rf: rf
port map(
    wd => temp_wd,
    rad1 => temp_rad1,
    rad2 => temp_rad2,
    pc_in => temp_pcin,
    pc_out => temp_pcout,
    wad => temp_wad,
    clk => clk,
    enable => temp_enable,
    reset => reset,
    rd1 => temp_rf_rd1,
    rd2 => temp_rf_rd2
);

temp_Decoder: Decoder
port map(
    clk => clk,
    pmem => temp_pmem,
    out_code => temp_out_code
);

end Behavioral;
