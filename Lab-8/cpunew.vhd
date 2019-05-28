----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/27/2019 07:12:58 AM
-- Design Name: 
-- Module Name: cpunew - Behavioral
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

entity cpunew is
  Port ( 
        clk,reset,step,go,instr, slice_select: in std_logic;
        led_vector: out std_logic_vector(15 downto 0);
        reg_select: in std_logic_vector(3 downto 0);
        display_select: in std_logic_vector(1 downto 0);
        pselect: in bit_vector(2 downto 0)  
);
end cpunew;

architecture Behavioral of cpunew is

component control_state_FSM
Port ( 
  clk,reset: in std_logic;
  in_execution_state: in std_logic_vector(2 downto 0);
  LD_bit: in std_logic;
  out_code: in std_logic_vector(5 downto 0);
  control_state: out std_logic_vector(1 downto 0); --if red then 01 else if halt then 11 else 00
  curr_control_state: out std_logic_vector(3 downto 0) --This will give the state of this FSM as a bit vector
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

component dist_mem_gen_0
PORT (
    a : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    spo : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
end component;

component dist_mem_gen_1
PORT (
    a : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    d : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    clk : IN STD_LOGIC;
    we : IN STD_LOGIC;
    spo : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
end component;

component shifter is 
PORT (
    op1 : in std_logic_vector(31 downto 0);
    res : out std_logic_vector(31 downto 0);
    sel : in std_logic_vector(1 downto 0);
    shift : in std_logic_vector(31 downto 0);
    carry : out std_logic);
end component;

component ALU
PORT (
    clk : in std_logic;
	rd1 : in std_logic_vector(31 downto 0); 
	rd2 : in std_logic_vector(31 downto 0);
--	operand inputs
	sel : in std_logic_vector(5 downto 0); --add or subtract only
	res : out std_logic_vector(31 downto 0); --result
	carry : in std_logic;
	flag : out std_logic_vector(3 downto 0); --flag output
	flag_we: in std_logic
	
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
end component;

component Clock_Generator
    Port ( 
       clk_in : in STD_LOGIC;
       clk_out : out STD_LOGIC
      );
end component;

component debounce 
Port (
input,clk: in std_logic;
output: out std_logic
 );
end component;

component display_interface
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
end component;

signal slow_clk, debounced_reset, debounced_go, debounced_step,debounced_instr, temp_enable : std_logic;
signal temp_ex_state: std_logic_vector(2 downto 0);
signal temp_ctrl_state: std_logic_vector(1 downto 0);
signal temp_rd1, temp_rd2, temp_res, temp_result: std_logic_vector(31 downto 0);
signal temp_sel, temp_out_code: std_logic_vector(5 downto 0);
signal temp_carry, temp_flagwe: std_logic;
signal temp_flag: std_logic_vector(3 downto 0);
signal temp_pmem, temp_wd: std_logic_vector(31 downto 0);

signal temp_rad1,temp_rad2, temp_wad: std_logic_vector(3 downto 0);
signal temp_rf_rd1, temp_rf_rd2: std_logic_vector(31 downto 0);
signal temp_disp_rd: std_logic_vector(31 downto 0);
signal temp_flag_we: std_logic;

signal temp_pcin : std_logic_vector(31 downto 0);
signal temp_pcout : std_logic_vector(31 downto 0);
signal temp_curr_control_state: std_logic_vector(3 downto 0);

signal temp_dtmem, temp_admem, temp_dfmem, temp_DR:std_logic_vector(31 downto 0);
signal temp_dmem_we: std_logic;
signal reg_a,reg_b: std_logic_vector(31 downto 0);

signal temp_pc_enable: std_logic;

signal temp_rn_data,temp_rm_data,temp_rd_data: std_logic_vector(31 downto 0);

signal cond : std_logic_vector (3 downto 0);
signal F_field : std_logic_vector (1 downto 0);
signal I_bit : std_logic;
signal Opcode : std_logic_vector (3 downto 0);
signal U_bit,L_bit: std_logic;
signal Rn: std_logic_vector(3 downto 0 );
signal Rd: std_logic_vector(3 downto 0 );
signal Imm8: std_logic_vector(7 downto 0);
signal Rm: std_logic_vector(3 downto 0 );
signal Imm24: std_logic_vector(23 downto 0); 
signal Imm12: std_logic_vector(11 downto 0);
signal shift_spec: std_logic_vector(7 downto 0);
signal shift_sel : std_logic_vector(1 downto 0);
signal shift_amnt : std_logic_vector(31 downto 0);
signal shift_carry : std_logic;
signal res_shift : std_logic_vector(31 downto 0);
signal temp_op1 : std_logic_vector(31 downto 0);
signal sel2 : std_logic_vector(1 downto 0);
signal X_bit : std_logic;
signal Imm5: std_logic_vector(4 downto 0 );
signal temp_spec : std_logic_vector(3 downto 0);


begin

temp_Shifter: shifter
port map(
res => res_shift,
op1 => temp_op1,
sel => shift_sel,
shift => shift_amnt,
carry => shift_carry
);

temp_csFSM: control_state_FSM
port map(
    clk => clk,
--    reset => debounced_reset,
    reset => reset,
    in_execution_state =>temp_ex_state,
    LD_bit => L_bit,
    out_code => temp_out_code,
    control_state => temp_ctrl_state,
    curr_control_state => temp_curr_control_state
);

temp_esFSM: execution_state_FSM
port map(
    clk => clk,
--    reset => debounced_reset,
--    step => debounced_step,
--    instr => debounced_instr,
--    go => debounced_go,
    reset => reset,
    step => step,
    instr => instr,
    go => go,
    control_state => temp_ctrl_state,
    out_execution_state => temp_ex_state    
);

temp_alu: ALU
port map(
    clk => clk,
    rd1 => temp_rd1,
    rd2 => temp_rd2,
    sel => temp_sel,
    res => temp_res,
    carry => temp_carry,
    flag => temp_flag,
    flag_we => temp_flag_we
);

prog_memory: dist_mem_gen_0
port map(
    a => temp_pcout(9 downto 2),
    spo => temp_pmem
);

data_memory: dist_mem_gen_1
port map(
    a => temp_admem(7 downto 0),
    d => temp_dtmem,
    clk => clk,
    we => temp_dmem_we,
    spo => temp_dfmem
);

temp_rf: rf
port map(
    disp_rad =>reg_select,
    disp_rd =>temp_disp_rd,
    wd => temp_wd,
    rad1 => temp_rad1,
    rad2 => temp_rad2,
    
    pc_in => temp_pcin,
    pc_out => temp_pcout,
    
    wad => temp_wad,
    clk => clk,
    enable => temp_enable,
    rd1 => temp_rf_rd1,
    rd2 => temp_rf_rd2,
    pc_enable => temp_pc_enable
);

temp_Decoder: Decoder
port map(
    clk => clk,
    pmem => temp_pmem,
    out_code => temp_out_code
);

temp_Debouncer_reset: debounce
port map(
    input => reset,
    clk => slow_clk,
    output => debounced_reset
);

temp_Debouncer_step: debounce
port map(
    input => step,
    clk => slow_clk,
    output => debounced_step
);
temp_Debouncer_go: debounce
port map(
    input => go,
    clk => slow_clk,
    output => debounced_go
);
temp_Debouncer_instr: debounce
port map(
    input => instr,
    clk => slow_clk,
    output => debounced_instr
);

temp_Clock_Generator: Clock_generator
port map(
clk_in => clk,
clk_out => slow_clk
);

temp_display_interface: display_interface
port map(
clk => clk,
display_select => display_select,
slice_select => slice_select,
ex_state => temp_ex_state,
control_state => temp_curr_control_state,
pc => temp_pcout,
rf_element => temp_disp_rd,
led_vector =>led_vector
);


cond <= temp_pmem (31 downto 28);
F_field <= temp_pmem (27 downto 26);
I_bit <= temp_pmem (25);
shift_spec <= temp_pmem (11 downto 4);
Opcode <= temp_pmem (24 downto 21);
U_bit <= temp_pmem(23);
L_bit <= temp_pmem(20); 
Rn <= temp_pmem(19 downto 16);
Rd <= temp_pmem(15 downto 12);
Rm <= temp_pmem(3 downto 0);
Imm8 <= temp_pmem(7 downto 0);
Imm24 <= temp_pmem(23 downto 0);
Imm12 <= temp_pmem(11 downto 0);
sel2 <= temp_pmem(6 downto 5);
X_bit <= temp_pmem(4);
Imm5 <= temp_pmem(11 downto 7);
temp_spec <= temp_pmem(11 downto 8);


temp_rad1 <= Rn when temp_curr_control_state ="0001" else
          temp_spec when temp_curr_control_state="1011" and I_bit='1' and X_bit='1';
          
temp_rad2 <= Rd when temp_curr_control_state ="0001" else
             Rm when temp_curr_control_state ="0010";
             
temp_sel <= "000101" when temp_curr_control_state ="0000" else
             temp_out_code when temp_curr_control_state ="0011" else
             "000100" when temp_curr_control_state ="0100" and U_bit='1' else
             "000010" when temp_curr_control_state ="0100" else
             "000101" when temp_curr_control_state ="0101";              

temp_rd1 <= X"000000" & temp_pcout(9 downto 2) when temp_curr_control_state = "0000" else
            X"000000" & temp_pcout(9 downto 2) when temp_curr_control_state = "0101" else
            X"00000000" when temp_curr_control_state = "0011" and (temp_out_code = "001101" or temp_out_code = "001111") else
            temp_rn_data when temp_curr_control_state = "0011" or temp_curr_control_state = "0100" else
             X"00000000";

temp_rd2 <= X"00000000" when temp_curr_control_state ="0000" else
            res_shift when temp_curr_control_state="0011" else
            X"00000" & Imm12 when temp_curr_control_state ="0100" else
            std_logic_vector(to_signed((to_integer(signed(Imm24))),32)) when temp_curr_control_state ="0101" else
            X"00000000";
            
temp_op1 <= std_logic_vector(resize(unsigned(Imm8),32)) when I_bit='1' else
            temp_rm_data;
            
shift_sel <= sel2;

shift_amnt <= std_logic_vector(resize(unsigned(temp_spec),32)) when I_bit='1' else
             std_logic_vector(resize(unsigned(Imm5),32)) when I_bit='0' and X_bit='0' else
             temp_rf_rd1;
    
temp_carry <= '1' when temp_curr_control_state = "0000" or temp_curr_control_state ="0101" else
              (shift_carry or temp_flag(1)) when temp_curr_control_state="0011" else
              '0';

temp_flag_we <= temp_pmem(20) when temp_out_code(5 downto 2) ="0010" and (temp_curr_control_state ="0011") else
               '0';
               
temp_admem <= temp_result when temp_curr_control_state ="1000" or temp_curr_control_state ="1001";

process(clk,reset)
    begin
    if (reset = '1') then
        temp_pcin <= X"00000" & "00"& to_stdlogicvector(pselect) &"0000000";
        temp_pc_enable <= '1';
    elsif rising_edge(clk) then
        if (temp_ex_state(1 downto 0) /= "00") then
        if temp_pc_enable = '1' then
            temp_pc_enable <= '0';
        end if;
        if temp_enable = '1' then
            temp_enable <= '0';
        end if;
        if temp_dmem_we = '1' then
            temp_dmem_we <= '0';
        end if;
        case temp_curr_control_state is
            when "0000" =>
               temp_pc_enable <= '1';
               temp_pcin <= temp_res(29 downto 0) &"00"; 
            when "0001" =>
--                if temp_out_code = "000010" then
--                    temp_rn_data <= X"00000000";
--                else
                temp_rn_data <= temp_rf_rd1;
--                end if;
                temp_rd_data <= temp_rf_rd2;
            when "0010" =>
                temp_rm_data <= temp_rf_rd2;
            when "1111" => 
             if I_bit = '0' then 
                if X_bit = '1' then
                    shift_amnt <= temp_rf_rd1;
                end if;
            end if;                      
            when "0011" =>
                temp_result <= temp_res;
            when "0111" =>
                temp_wad <= Rd;
                temp_wd <= temp_result;
            if (temp_out_code(5 downto 2) /= "0010") then
                temp_enable <= '1'; 
            else
                temp_enable <= '0';
             end if;
            when "0100" =>
                temp_result <= temp_res;
            when "1000" =>
                temp_dmem_we <= '1';
                temp_dtmem <= temp_rd_data;
            when "1001" =>
                 temp_DR <= temp_dfmem;
            when "1010" =>
                temp_wad <= Rd;
                temp_wd <= temp_DR;
                temp_enable <= '1';
            when "0101" =>
                if temp_out_code = "101000" then
                    if temp_flag(2) = '0' then
                        temp_pcin <= temp_res(29 downto 0) & "00";
                    end if;
                elsif temp_out_code = "100111" then
                    if temp_flag(2) = '1' then
                        temp_pcin <= temp_res(29 downto 0) & "00";
                    end if;
                else
                    temp_pcin <= temp_res(29 downto 0) & "00";
                end if;
                temp_pc_enable <= '1';
            when others =>
        end case;
    end if;
    end if;

end process;
end Behavioral;
