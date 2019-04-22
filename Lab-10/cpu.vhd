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
  Port (   
      clk,reset,step,go,instr, slice_select: in std_logic;
      led_vector: out std_logic_vector(15 downto 0);
      reg_select: in std_logic_vector(3 downto 0);
      display_select: in std_logic_vector(1 downto 0)  
    );
end cpu;

architecture Behavioral of cpu is

component control_state_FSM
Port ( 
  mul_decide : in std_logic;
  clk,reset: in std_logic;
  in_execution_state: in std_logic_vector(2 downto 0);
  LD_bit: in std_logic;
  out_code: in std_logic_vector(5 downto 0);
  control_state: out std_logic_vector(1 downto 0); --if red then 01 else if halt then 11 else 00
  curr_control_state: out std_logic_vector(4 downto 0) --This will give the state of this FSM as a bit vector
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

--component dist_mem_gen_1
--PORT (
--    a : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
--    d : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
--    clk : IN STD_LOGIC;
--    we : IN STD_LOGIC;
--    spo : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
--  );
--end component;

component multiplier 
PORT (
    instr : in std_logic_vector(31 downto 0);
    op1,op2,op3,op4 : in std_logic_vector(31 downto 0);
    res1 : out std_logic_vector(31 downto 0);
    res2 : out std_logic_vector(31 downto 0)       
    );
end component;

component dist_mem_gen_2
PORT (
    a : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    d : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    clk : IN STD_LOGIC;
    we : IN STD_LOGIC;
    spo : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
end component;

component ALU
PORT (
    clk : in std_logic;
	rd1 : in std_logic_vector(31 downto 0); 
	rd2 : in std_logic_vector(31 downto 0);
	if_branch : in std_logic;
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
	wd1 : in std_logic_vector(31 downto 0);
--	wd2 : in std_logic_vector(31 downto 0);
	rad1 : in std_logic_vector(3 downto 0);
	rad2 : in std_logic_vector(3 downto 0);
	pc_in : in std_logic_vector(31 downto 0);  
	wad1 : in std_logic_vector(3 downto 0);
--	wad2: in std_logic_vector(3 downto 0);
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
    control_state: in std_logic_vector(4 downto 0);   
    pc: in std_logic_vector(31 downto 0); 
    led_vector:out std_logic_vector(15 downto 0);
    rf_element: in std_logic_vector(31 downto 0)
 );
end component;

component shifter
Port (
    op1 : in std_logic_vector(31 downto 0);
    res : out std_logic_vector(31 downto 0);
    sel : in std_logic_vector(1 downto 0);
    shift : in std_logic_vector(31 downto 0);
    carry : out std_logic
 );
end component;

component proc_dm_datapath
Port(
    word: in std_logic;
    ldr_or_str : in std_logic; --1 if ldr, 0 if str
    SH : in std_logic_vector(1 downto 0); -- 00 for unsigned byte, 01 for unsigned half word, 10 for signed byte and 11 for signed half word
    full_word: in std_logic_vector(31 downto 0);
    we_or_select: in std_logic_vector(1 downto 0); --when ldr then use select and when str then we
    out_word: out std_logic_vector(31 downto 0)  --this word can be either going to the memory(after replication) or going from the memory(extracting hw or byte)
);
end component;

signal slow_clk, debounced_reset, debounced_go, debounced_step,debounced_instr, temp_enable : std_logic;
signal temp_ex_state: std_logic_vector(2 downto 0);
signal temp_ctrl_state: std_logic_vector(1 downto 0);
signal temp_rd1, temp_rd2, temp_res: std_logic_vector(31 downto 0);
signal temp_sel, temp_out_code: std_logic_vector(5 downto 0);
signal temp_carry, temp_flagwe: std_logic;
signal temp_pmem, temp_wd,temp_wd2: std_logic_vector(31 downto 0);
signal temp_flag: std_logic_vector(3 downto 0);
signal test_branch: std_logic;
signal res_shift : std_logic_vector(31 downto 0);

signal temp_rad1,temp_rad2,temp_rad3,temp_rad4, temp_wad, temp_wad2: std_logic_vector(3 downto 0);
signal temp_rf_rd1, temp_rf_rd2, temp_rf_rd3, temp_rf_rd4: std_logic_vector(31 downto 0);
signal temp_disp_rd: std_logic_vector(31 downto 0);
signal temp_flag_we: std_logic;

signal temp_pcin : std_logic_vector(31 downto 0);
signal temp_pcout : std_logic_vector(31 downto 0);
signal temp_curr_control_state: std_logic_vector(4 downto 0);

signal temp_dtmem, temp_admem :std_logic_vector(31 downto 0);
signal temp_dfmem: std_logic_vector(31 downto 0);
signal temp_dmem_we: std_logic;
signal reg_a,reg_b: std_logic_vector(31 downto 0);

signal temp_pc_enable: std_logic;

signal temp_rn_data,temp_rm_data,temp_rd_data,temp_rs_data: std_logic_vector(31 downto 0);

signal cond : std_logic_vector (3 downto 0);
signal F_field : std_logic_vector (1 downto 0);
signal I_bit : std_logic;
signal Opcode : std_logic_vector (3 downto 0);
signal U_bit,L_bit,W_bit: std_logic;
signal Rn: std_logic_vector(3 downto 0 );
signal Rd: std_logic_vector(3 downto 0 );
signal Rs: std_logic_vector(3 downto 0);
signal Imm8: std_logic_vector(7 downto 0);
signal Rm: std_logic_vector(3 downto 0 );
signal Imm24: std_logic_vector(23 downto 0); 
signal Imm12: std_logic_vector(11 downto 0);
signal shift_spec: std_logic_vector(7 downto 0);
signal temp_op1 : std_logic_vector(31 downto 0);
signal shift_sel : std_logic_vector(1 downto 0);
signal shift_amnt : std_logic_vector(31 downto 0);
signal shift_carry : std_logic;
signal X_bit : std_logic;
signal Imm5 : std_logic_vector(4 downto 0);
signal sel2 : std_logic_vector(1 downto 0);
signal temp_spec : std_logic_vector(3 downto 0);

signal offset_dt_add : std_logic_vector(31 downto 0); --It'll contain the sum of Rn_data and the shifter.
signal dt_add: std_logic_vector(31 downto 0); --this depends on the P_bit
signal decoded_we: std_logic_vector(3 downto 0);
signal full_data_to_modules: std_logic_vector(31 downto 0);
signal word_to_put_in_dataprocessor: std_logic_vector(31 downto 0);

signal temp_instr : std_logic_vector(31 downto 0);
signal temp_p_flag : std_logic_vector(3 downto 0);
signal temp_p : std_logic;
signal mul_instr : std_logic_vector(31 downto 0);
signal mul_op1,mul_op2,mul_op3,mul_op4,mul_res1,mul_res2 : std_logic_vector(31 downto 0); 
signal temp_mul_decide : std_logic;
signal A_bit : std_logic;

begin

temp_multiplier: multiplier
port map(
instr => mul_instr,
op1 => mul_op1,
op2 => mul_op2,
op3 => mul_op3,
op4 => mul_op4,
res1 => mul_res1,
res2 => mul_res2
);


word_to_put_in_dataprocessor <= temp_rd_data when L_bit = '0' else
                                temp_dfmem when L_bit = '1';

temp_proc_dm_datapath: proc_dm_datapath
port map(
  word => F_field(0),
  ldr_or_str => L_bit,
  sh => sel2,
  full_word => word_to_put_in_dataprocessor,
  we_or_select => dt_add(1 downto 0),
  out_word => full_data_to_modules
);

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
    mul_decide => temp_mul_decide,
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
    if_branch => test_branch,
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
--Old 32 Bit data memory
--data_memory: dist_mem_gen_1 
--port map(
--    a => temp_admem(7 downto 0),
--    d => temp_dtmem,
--    clk => clk,
--    we => temp_dmem_we,
--    spo => temp_dfmem
--);

data_memory_0: dist_mem_gen_2
port map(
    a => temp_admem(7 downto 0),
    d => full_data_to_modules(7 downto 0),
    clk => clk,
    we => decoded_we(0),
    spo => temp_dfmem(7 downto 0)
);

data_memory_1: dist_mem_gen_2
port map(
    a => temp_admem(7 downto 0),
    d => full_data_to_modules(15 downto 8),
    clk => clk,
    we => decoded_we(1),
    spo => temp_dfmem(15 downto 8)
);

data_memory_2: dist_mem_gen_2
port map(
    a => temp_admem(7 downto 0),
    d => full_data_to_modules(23 downto 16),
    clk => clk,
    we => decoded_we(2),
    spo => temp_dfmem(23 downto 16)
);

data_memory_3: dist_mem_gen_2
port map(
    a => temp_admem(7 downto 0),
    d => full_data_to_modules(31 downto 24),
    clk => clk,
    we => decoded_we(3),
    spo => temp_dfmem(31 downto 24)
);

temp_rf: rf
port map(
    disp_rad =>reg_select,
    disp_rd =>temp_disp_rd,
    wd1 => temp_wd,
--    wd2 => temp_wd2,
    rad1 => temp_rad1,
    rad2 => temp_rad2,
    
    pc_in => temp_pcin,
    pc_out => temp_pcout,
    
    wad1 => temp_wad,
--    wad2 => temp_wad2,
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
rf_element => temp_disp_rd
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
Rs <= temp_pmem(11 downto 8);
Imm8 <= temp_pmem(7 downto 0);
Imm24 <= temp_pmem(23 downto 0);
Imm12 <= temp_pmem(11 downto 0);
X_bit <= temp_pmem(4);
Imm5 <= temp_pmem(11 downto 7);
sel2 <= temp_pmem(6 downto 5);
temp_spec <= temp_pmem(11 downto 8);
A_bit <= temp_pmem(21);
W_bit <= temp_pmem(21);

temp_mul_decide <= '1' when I_bit='0' and Imm8(7 downto 4)="1001" else
                   '0';

decoded_we <=     "0000" when temp_dmem_we = '0' else
                  "1111" when temp_dmem_we = '1' and F_field = "01" else --str
                  "0011" when sel2(0)='1' and dt_add(1) = '0' else --strh
                  "1100" when sel2(0)='1' and dt_add(1) = '1' else 
                  "0001" when dt_add(1 downto 0) = "00" else   --Only for strb instructions.
                  "0010" when dt_add(1 downto 0) = "01" else
                  "0100" when dt_add(1 downto 0) = "10" else
                  "1000" when dt_add(1 downto 0) = "11";

process(clk,reset)
begin

if (temp_out_code(5 downto 4)="10") then 
test_branch <= '1';
 else
 test_branch <= '0';
 end if;
 
if reset = '1' then
    temp_pcin <= X"00000000";
else 
   case temp_curr_control_state is
        when "00000" => --Fetch Statement
            temp_carry <= '0'; 
            temp_dmem_we <= '0';
            temp_enable <= '0';

            --reset all the enables.
            temp_pc_enable <= '1'; --this will increase the pc
            temp_rd1 <= temp_pcin; --Put the current pc in the ALU's first port
            temp_rd2 <= X"00000004"; --Put 4 as the second port
            temp_sel <= "000100"; --Give add command
            temp_flag_we <= '0'; --Don't update the flags.
        when "00001" =>
           temp_pc_enable <='0'; -- stop increasing pc             
           temp_rad1 <= Rn;       --Rn is the address in pmem which is put in register file
           temp_rad2 <= Rm;        --Rm is the address in pmem which is put in register file
           temp_pcin <= temp_res;  -- PC = PC + 4 result stored in temp_pcin from ALU
           temp_rn_data <= temp_rf_rd1;  --data from register file
           temp_rm_data <= temp_rf_rd2;  -- data from register file

        when "00010" => --Instruction_class state
            temp_rad1 <= Rd;        -- Rd is the address. This is necessary for DT instructions
            temp_rd_data <= temp_rf_rd1; --The data we get now stored
            temp_rad2 <= Rs;
            temp_rs_data <= temp_rf_rd2;
        when "01011" => --shift_dp_read state
            if I_bit = '1' then 
                temp_op1 <= std_logic_vector(resize(unsigned(Imm8),32));  --The operand is the Imm8
                shift_sel <= "11"; --explicitly define ROR as the only possible shift method.
                shift_amnt <= std_logic_vector(resize(unsigned(temp_spec&'0'),32)); --multiplied temp_spec(rotspec) with 2 and considered it the shift.
            else 
                temp_op1 <= temp_rm_data;
                shift_sel <= sel2; --shift type
                
                if X_bit = '0' then
                    shift_amnt <= std_logic_vector(resize(unsigned(Imm5),32));
                else 
                    temp_rad1 <= temp_spec;
--                    temp_rd1 <= std_logic_vector(resize(unsigned(temp_spec),32));
--                    shift_amnt <= std_logic_vector(resize(unsigned(temp_rad1),32));
                end if;
            end if;
        when "01111" => --shift_dp_write stage
            if (I_bit = '0') then
                if X_bit = '1' then
                    shift_amnt <= temp_rf_rd1;  
                end if;
            end if; 
        when "00011" =>  --arith instruction
            temp_flag_we <= temp_pmem(20); --S bit which tells whether to set the flag or not. 
            --It toggles the flag_enable in ALU
            temp_carry <= (shift_carry or temp_flag(1));  
            if temp_out_code = "001101" then --mov instruction
                temp_rd1 <= X"00000000";  --explicitly  give the 1st argument to the ALU as 0
            elsif temp_out_code = "001111" then    --mvn instruction
                temp_rd1 <= X"00000000";  --explicitly  give the 1st argument to the ALU as 0
            else  --for all other instructions...
                temp_rd1 <= temp_rn_data;  -- The first argument is the register Rn's data
            end if;
            temp_sel <= temp_out_code;  --instruction for ALU is the same as given in the  decoder out code
            temp_rd2 <= res_shift;  --Second argument for all cases is the Shifted data from the shifter.
             
        when "10000" =>    --mul_write instruction
            temp_enable <= '1';        
            if temp_pmem(23)='0' then  
                temp_wad <= Rn;
                temp_wd <= mul_res1;                       
            else            
                temp_wad <= Rn;
--                temp_wad2 <= Rd;
                temp_wd <= mul_res1;
--                temp_wd2 <= mul_res2;               
            end if;    
            
        when "10001" =>  --mul2RF instruction
        temp_enable <= '1';      
        if temp_pmem(23)='1' then
            temp_wad <= Rd;
            temp_wd <= mul_res2;
        end if;    
            
        when "00111" => --res2RF instruction
            if (Rd /= "1111") then
                temp_wad <= Rd;   --write address is the Rd register
                temp_wd <= temp_res; -- the data to write will be the data from the ALU
                if (temp_out_code(5 downto 2) /= "0010") then  --If the instruction was anything else than cmp or cmn
                    temp_enable <= '1';  --then allow writing the data in the Rd register
                else --else if the instruction was cmp/cmn
                    temp_enable <= '0';  --Don't write the data in the final register
                end if;
            else
                temp_pcin<=temp_res;                 
            end if;
            
        when "01100" => --shift_dt state
           --We would like to shift for all instruction irrespective of the P and the W bit. Store it in a different variable.
            if (F_field = "00") then  --str/ldr sh
                if temp_pmem(22) = '1' then
                    temp_op1 <= std_logic_vector(resize(unsigned(temp_pmem(11 downto 8) & temp_pmem(3 downto 0)),32));
                else
                    temp_op1 <= temp_rm_data;
                end if;
                shift_amnt <= X"00000000";
                shift_sel <= sel2;
            elsif (F_field ="01") then --str/ldr
                if I_bit = '0' then
                   temp_op1 <= std_logic_vector(resize(unsigned(Imm12),32));
                   shift_amnt <= X"00000000";
                   shift_sel <= "00";
                   --dummy shifting by 0
                else
                    temp_op1 <= temp_rm_data;
                    shift_amnt <= std_logic_vector(resize(unsigned(Imm5),32));
                    shift_sel <= sel2; 
                end if;
                -- answer in res_shift
            end if;   
            
        when "00100" => --addr instruction
            temp_rd1 <= temp_rn_data;
            temp_rd2 <= res_shift;
            if U_bit = '1' then
                temp_sel <= "000100";
            else
                temp_sel <= "000010";
            end if;
            offset_dt_add <= temp_res;   
            --offset_dt_add has the sum of rn_data and shift addition.
            -- If P_bit is 0 then just use the rn_data else use the temp_res.
--            if (P_bit = '1') then
                dt_add <= temp_res;
--            else
                dt_add <= temp_rn_data;
--            end if;
            
        when "01001" =>--mem_rd (ldr instruction)
                temp_admem <= dt_add;
        when "01010" => -- mem2RF
            temp_wad <= Rd;
            temp_enable <= '1';
            temp_wd <= full_data_to_modules;
            --New state after this for increment/decrement
            
        when "01000" => --mem_wr (str instruction)
            temp_admem <= dt_add;
            temp_dmem_we <= '1';
            --New state after this for auto increment/decrement
        when "01101" =>
            --offset_dt_add has the sum of Rn_data and shift result. We will write the answer now.
            if (W_bit = '1') then
                temp_wad <= Rn;
                temp_enable <= '1';
                temp_wd <= offset_dt_add;    
            end if;
                 
        when "00101" => --brn instruction   
            if temp_out_code <= "100110" then  --b
                temp_carry <= '1';
                temp_rd1 <= temp_pcout;
                temp_rd2 <= std_logic_vector(to_signed((to_integer(shift_left(signed(Imm24),2))),32));
                temp_sel <= "000101";
                temp_pcin <=temp_res;
                if (temp_pmem(24) = '1') then
                    temp_wad <= "1110"; --r14
                    temp_enable <= '1';
                    temp_wd <= temp_pcin; --write the old PC+4 to the link register.
                end if;

            elsif temp_out_code <= "100111" then  --beq
                if temp_flag(2) = '1' then
                            temp_carry <= '1';
                            temp_rd1 <= temp_pcout;
                            temp_rd2 <= std_logic_vector(to_signed((to_integer(shift_left(signed(Imm24),2))),32));
                            temp_sel <= "000101";
                            temp_pcin <=temp_res;    
                end if;
            else
                if temp_flag(2) = '0' then  --bne
                            temp_carry <= '1';
                            temp_rd1 <= temp_pcout;
                            temp_rd2 <= std_logic_vector(to_signed((to_integer(shift_left(signed(Imm24),2))),32));
                            temp_sel <= "000101";
                            temp_pcin <=temp_res;    
                end if;
            end if;
            
            when "01110" =>                          --multiplication instruction
                mul_instr <= temp_pmem;
                
                if temp_pmem(23)='0' then           --simple 32 bit multiplication
                    if A_bit='0' then               --No Addition
--                        temp_rad1 <= Rm;
                        mul_op1 <= temp_rm_data;
--                        temp_rad2 <= Rs;
                        mul_op2 <= temp_rs_data;
                    else
--                        temp_rad1 <= Rm;
                        mul_op1 <= temp_rm_data;
--                        temp_rad2 <= Rs;
                        mul_op2 <= temp_rs_data;              --with addition       
--                        temp_rad3 <= Rn;
                        mul_op3 <= temp_rd_data;      
                    end if;
                else                               --Long Multiplication
                    if A_bit='0' then               --No Addition
--                        temp_rad1 <= Rm;
                        mul_op1 <= temp_rm_data;
--                        temp_rad2 <= Rs;
                        mul_op2 <= temp_rs_data;
                    else                            --Addition
--                        temp_rad1 <= Rm;
                        mul_op1 <= temp_rm_data;
--                        temp_rad2 <= Rs;
                        mul_op2 <= temp_rs_data;              --with addition       
--                        temp_rad3 <= Rn;
                        mul_op3 <= temp_rn_data;  
--                        temp_rad4 <= Rd;
                        mul_op4 <= temp_rd_data;                       
                    end if;                     
                end if;
        when others =>
   end case;
end if;
end process;


end Behavioral;
