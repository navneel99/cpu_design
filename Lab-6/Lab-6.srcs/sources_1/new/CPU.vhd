library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
use Ieee.std_logic_unsigned.all;

entity CPU is
Port(
clk: in std_logic;
step: in std_logic;
go: in std_logic;
program_select: in bit_vector(2 downto 0);
reset: in std_logic;
pmem,dfmem: in std_logic_vector(31 downto 0);
rf_select: in std_logic_vector(3 downto 0);
dtmem,admem: out std_logic_vector(31 downto 0);
apmem: out std_logic_vector(31 downto 0);
we: out std_logic;
state: out std_logic_vector(1 downto 0);
register_element: out std_logic_vector(31 downto 0)
);
end CPU;

architecture arch_CPU of CPU is

type instr_class_type is (DP, DT, branch, unknown);
type i_decoded_type is (add,sub,cmp,mov,ldr,str,beq,bne,b,halt,unknown);
type fsm_state_type is(initial,onestep, cont, done);
type rf_type is array (0 to 15) of std_logic_vector(31 downto 0);

signal fsm_state: fsm_state_type := initial;
signal rf : rf_type;
signal instr_class : instr_class_type;
signal i_decoded : i_decoded_type;

signal temp_we: std_logic;
--signal temp_ldr_sig: std_logic := '0';

signal cond : std_logic_vector (3 downto 0);
signal F_field : std_logic_vector (1 downto 0);
signal I_bit : std_logic;
signal Opcode : std_logic_vector (3 downto 0);
signal U_bit,L_bit: std_logic;
signal Rn: std_logic_vector(3 downto 0 );
signal Rd: std_logic_vector(3 downto 0 );
signal Rotspec: std_logic_vector(3 downto 0);
signal shift_spec : std_logic_vector (7 downto 0);
signal Imm8: std_logic_vector(7 downto 0);
signal Rm: std_logic_vector(3 downto 0 );
signal pc: std_logic_vector(7 downto 0):="00000000" ;
signal flags: std_logic_vector(7 downto 0);
signal Imm24: std_logic_vector(23 downto 0); 
signal Imm12: std_logic_vector(11 downto 0);
signal temp, temp2: std_logic_vector(31 downto 0);
signal halty: std_logic;

begin 

    cond <= pmem (31 downto 28);
    F_field <= pmem (27 downto 26);
    I_bit <= pmem (25);
    shift_spec <= pmem (11 downto 4);
    Opcode <= pmem (24 downto 21);
    U_bit <= pmem(23);
    L_bit <= pmem(20); 
    Rn <= pmem(19 downto 16);
    Rd <= pmem(15 downto 12);
    Rm <= pmem(3 downto 0);
    Imm8 <= pmem(7 downto 0);
    Imm24 <= pmem(23 downto 0);
    Imm12 <= pmem(11 downto 0);
--for DP instructions
 
 i_decoded <= add  WHEN cond="1110" and F_field="00" and I_bit='1' and Opcode="0100" else
    sub WHEN cond="1110" and F_field="00" and I_bit='1' and Opcode="0010" else
    mov WHEN cond="1110" and F_field="00" and I_bit='1' and Opcode="1101" else
    cmp WHEN cond="1110" and F_field="00" and I_bit='1' and Opcode="1010" else
    add WHEN cond="1110" and F_field="00" and I_bit='0' and Opcode="0100" else
    sub WHEN cond="1110" and F_field="00" and I_bit='0' and Opcode="0010" else
    mov WHEN cond="1110" and F_field="00" and I_bit='0' and Opcode="1101" else
    cmp WHEN cond="1110" and F_field="00" and I_bit='0' and Opcode="1010" else
    
--for DT instructions
    str WHEN cond="1110" and F_field="01" and I_bit='0' and U_bit='0' and L_bit='0' else
    str WHEN cond="1110" and F_field="01" and I_bit='0' and U_bit='1' and L_bit='0' else
    ldr WHEN cond="1110" and F_field="01" and I_bit='0' and U_bit='0' and L_bit='1' else
    ldr WHEN cond="1110" and F_field="01" and I_bit='0' and U_bit='1' and L_bit='1' else
    
    b   WHEN cond="1110" else
    beq WHEN cond="0000" else
    bne WHEN cond="0001" ;
    
--    halt when pmem = "00000000000000000000000000000000";
    
    instr_class <= DP when F_field = "00" else
                   DT when F_field = "01" else
                   branch when F_field = "10" else
                   unknown;
    we <= '1' when i_decoded = str else
           '0';
    temp <= rf(to_integer(unsigned(Rn))) + std_logic_vector(resize((unsigned(Imm12)),32));
    temp2 <= rf(to_integer(unsigned(Rn))) - std_logic_vector(resize((unsigned(Imm12)),32));
    admem <= temp when U_bit <= '1' and instr_class = DT else
             temp2 when instr_class = DT;
    dtmem <= rf(to_integer(unsigned(Rd))) when instr_class = DT;
            
    register_element <= rf(to_integer(unsigned(rf_select)));
 
    process (clk, fsm_state, reset)
    begin
        if ( reset = '1')then
            fsm_state <= initial;
            state <= "00";
        elsif rising_edge(clk) then
            if (fsm_state=initial and  step = '1') then
                fsm_state <= onestep;
                state <= "01";
            elsif (fsm_state=initial and go = '1') then
                fsm_state <= cont;
                state <= "10";
            elsif (fsm_state = onestep) then
                fsm_state <= done;
                state <= "11";
            elsif (fsm_state = cont) then
                    if pmem = "00000000000000000000000000000000" then
                        fsm_state <= done;
                        state <= "11";
                    end if;
            elsif fsm_state = done then
              if step = '1' or go = '1' then
                fsm_state <= done;
                state <= "11";
              else
                fsm_state<= initial;
                state <= "00"; 
              end if;
--                fsm_state <= initial;
            end if;
        end if;
    end process;
  
  process (clk,reset)
  begin
  if reset = '1' then
--    if program_select = "UUU" then
--        rf(15) <= "00000000000000000000000000000000";
--    else
        rf(15) <= "0000000000000000000000"&to_stdlogicvector(program_select)&"0000000";
--    end if;
  elsif (rising_edge(clk)) then
      if fsm_state = onestep or fsm_state = cont then
          rf(15) <= rf(15) + "00000000000000000000000000000100";
          case i_decoded is
            when add => 
                case I_bit is
                    when '0' =>
                        rf(to_integer(unsigned(Rd)))<= rf(to_integer(unsigned(Rn))) + rf(to_integer(unsigned(Rm)));
                    when '1' =>
                        rf(to_integer(unsigned(Rd)))<= rf(to_integer(unsigned(Rn))) + Imm8;
                    when others =>                    
                 end case;
            when sub =>
                case I_bit is
                    when '0' =>
                        rf(to_integer(unsigned(Rd)))<= rf(to_integer(unsigned(Rn))) - rf(to_integer(unsigned(Rm)));
                    when '1' =>
                        rf(to_integer(unsigned(Rd)))<= rf(to_integer(unsigned(Rn))) - Imm8;
                    when others =>                         
                 end case;
    --         pc <= pc + "00000001";        
            when mov =>
                case I_bit is
                    when '0' =>
                        rf(to_integer(unsigned(Rd)))<= rf(to_integer(unsigned(Rn)));--rf(to_integer(unsigned(Rn)) + to_integer(unsigned(rf(to_integer(unsigned(Rm))))));
                    when '1' =>
                        rf(to_integer(unsigned(Rd)))<= std_logic_vector(resize((unsigned(Imm8)),32));   --rf(to_integer(unsigned(Rn)) + to_integer(unsigned(Imm8)));                    
                 when others =>     
                 end case;
    --            pc <= pc + "00000001";
            when cmp =>
                case I_bit is
                    when '0' =>
                        if ( rf(to_integer(unsigned(Rn))) = rf(to_integer(unsigned(Rm)))) then
                            flags <= "00000001";
                        else
                            flags <= "00000000";
                        end if;
                     when '1' =>
                        if ( rf(to_integer(unsigned(Rn))) = std_logic_vector(resize((unsigned(Imm8)),32)))then
                            flags <= "00000001";
                        else
                            flags <= "00000000";
                        end if;
                     when others =>                         
                end case;
    --            pc <= pc + "00000001";
            when str => --only immediate offset
            when ldr =>
                 rf(to_integer(unsigned(Rd))) <= dfmem;
            when b =>
    --            pc <= pc + sliced_Imm24;
                rf(15) <= rf(15) +  std_logic_vector(to_signed((to_integer(shift_left(signed(Imm24),2)) + 8),32));
            when beq =>
                case flags is 
                    when "00000001" =>
                          rf(15) <= rf(15) +  std_logic_vector(to_signed((to_integer(shift_left(signed(Imm24),2)) + 8),32));
    --                    pc <= pc + sliced_Imm24;
                    when others =>     
                end case;
            when bne =>
                case flags is 
                    when "00000000" =>
                        rf(15) <= rf(15) +  std_logic_vector(to_signed((to_integer(shift_left(signed(Imm24),2)) + 8),32));
    --                    pc <= pc;
                    when others =>                    
               end case;
             when halt =>
             halty <= '1';
             when others =>
           end case;
--       we <= temp_we;
--       if temp_we = '1' then
--        temp_we <= '0';
--       end if;
    end if;
  end if;
  end process;
  apmem <= rf(15);
--  we <= temp_we;
end arch_CPU;