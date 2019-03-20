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
use IEEE.NUMERIC_STD.ALL;

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

component ALU
PORT (
    clk : in std_logic;
	rd1 : in std_logic_vector(31 downto 0); 
	rd2 : in std_logic_vector(31 downto 0);
--	operand inputs
	sel : in std_logic_vector(5 downto 0); --add or subtract only
	res : out std_logic_vector(31 downto 0); --result
	carry : in std_logic;
	flag : out std_logic; --flag output
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
	wd : in std_logic_vector(31 downto 0);
	rad1 : in std_logic_vector(3 downto 0);
	rad2 : in std_logic_vector(3 downto 0);
	pc_in : in std_logic_vector(31 downto 0);  
	wad : in std_logic_vector(3 downto 0);
	enable : in std_logic;
	clk: in std_logic;
	reset : in std_logic;
	rd1 : out std_logic_vector(31 downto 0);
	rd2 : out std_logic_vector(31 downto 0);	
	pc_out : out std_logic_vector(31 downto 0);
	pc_enable: in std_logic
);
end component;

signal clk, reset, step, instr, go, temp_enable : std_logic;
signal temp_ex_state: std_logic_vector(2 downto 0);
signal temp_ctrl_state: std_logic_vector(1 downto 0);
signal temp_rd1, temp_rd2, temp_res: std_logic_vector(31 downto 0);
signal temp_sel, temp_out_code: std_logic_vector(5 downto 0);
signal temp_carry, temp_flag, temp_flagwe: std_logic;
signal temp_pmem, temp_wd: std_logic_vector(31 downto 0);

signal temp_rad1,temp_rad2, temp_wad: std_logic_vector(3 downto 0);

signal temp_rf_rd1, temp_rf_rd2: std_logic_vector(31 downto 0);

signal temp_flag_we: std_logic;

signal temp_pcin : std_logic_vector(31 downto 0);
signal temp_pcout : std_logic_vector(31 downto 0);
signal temp_curr_control_state: std_logic_vector(3 downto 0);

signal temp_dtmem, temp_admem, temp_dfmem:std_logic_vector(31 downto 0);
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


begin

temp_csFSM: control_state_FSM
port map(
    clk => clk,
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
    rd2 => temp_rf_rd2,
    pc_enable => temp_pc_enable
);

temp_Decoder: Decoder
port map(
    clk => clk,
    pmem => temp_pmem,
    out_code => temp_out_code
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


process(clk,reset)
begin
if reset = '1' then
--    temp_pcin <= "00000000000000000000000000000000";
    temp_pcin <= X"00000000";
else 
   case temp_curr_control_state is
        when "0000" => --Fetch Statement
            temp_carry <= '0';
            temp_dmem_we <= '0';
            temp_enable <= '0';
            temp_pc_enable <= '1'; --this will increase the pc
            temp_rd1 <= temp_pcin;
            temp_rd2 <= X"00000004";
--            temp_sel <= "000000";
            temp_sel <= "000100";
            temp_flag_we <= '0';
        when "0001" =>
           temp_pc_enable <='0'; -- stop increasing pc
           temp_rad1 <= Rn;
           temp_rad2 <= Rm;
           temp_pcin <= temp_res;
           temp_rn_data <= temp_rf_rd1;
           temp_rm_data <= temp_rf_rd2;
        when "0010" =>
            temp_rad1 <= Rd;
            temp_rd_data <= temp_rf_rd1;
        when "0011" =>
            temp_flag_we <= '1';
            if temp_out_code = "001101" then
                temp_rd1 <= X"00000000";
                temp_sel <= "000100";
            elsif temp_out_code = "001111" then    
                temp_rd1 <= X"00000000";
                temp_sel <= "000010";            
            else 
                temp_sel <= temp_out_code;
                temp_rd1 <= temp_rn_data;
            if I_bit = '1' then
                temp_rd2 <= std_logic_vector(resize(unsigned(Imm8),32));
            else 
                temp_rd2 <= temp_rm_data;
            end if;
        when "0111" =>
            temp_wad <= Rd;
            temp_wd <= temp_res;
            if (temp_out_code /= "001010") then
                temp_enable <= '1';
                temp_flag_we <= '0';
            else
                temp_enable <= '0';
                temp_flag_we <= '1';
             end if;
        when "0100" => --addr instruction
            temp_rd1 <= temp_rn_data;
            temp_rd2 <= std_logic_vector(resize(unsigned(Imm12),32));
            if U_bit = '1' then
                temp_sel <= "000100";
            else
                temp_sel <= "000010";
            end if;
        when "1001" =>--mem_rd (ldr instruction)
            temp_admem <= temp_res;
        when "1010" => -- mem2RF
            temp_wad <= Rd;
            temp_enable <= '1';
            temp_dfmem <= temp_wd;
        when "1000" => --mem_wr (str instruction)
            temp_admem <= temp_res;
            temp_dtmem <= temp_rd_data;
            temp_dmem_we <= '1';
        when "0101" => --brn instruction        
            if temp_out_code <= "100110" then
                temp_carry <= '1';
                temp_rd1 <= temp_pcout;
                temp_rd2 <= std_logic_vector(to_signed((to_integer(shift_left(signed(Imm24),2))),32));
                temp_sel <= "000100";
                temp_pcin <=temp_res;    

            elsif temp_out_code <= "100111" then
                if temp_flag = '1' then
                            temp_carry <= '1';
                            temp_rd1 <= temp_pcout;
                            temp_rd2 <= std_logic_vector(to_signed((to_integer(shift_left(signed(Imm24),2))),32));
                            temp_sel <= "000100";
                            temp_pcin <=temp_res;    

                end if;
            else
                if temp_flag = '0' then
                            temp_carry <= '1';
                            temp_rd1 <= temp_pcout;
                            temp_rd2 <= std_logic_vector(to_signed((to_integer(shift_left(signed(Imm24),2))),32));
                            temp_sel <= "000100";
                            temp_pcin <=temp_res;    
                end if;
            end if;
        when others =>
--            temp_pcin <= temp_pcout;
   end case;
end if;
end process;


end Behavioral;
