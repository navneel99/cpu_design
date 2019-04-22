library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity multiplier is 
  Port (
        instr : in std_logic_vector(31 downto 0);
        op1,op2,op3,op4 : in std_logic_vector(31 downto 0);
        res1 : out std_logic_vector(31 downto 0);
        res2 : out std_logic_vector(31 downto 0)       
        );
end multiplier;

architecture Arch_MUL of multiplier is 
signal A_bit : std_logic;
signal decider_bit : std_logic;
signal big_mul : std_logic_vector(63 downto 0);
signal zero : std_logic_vector(31 downto 0); 
signal U_bit : std_logic;
signal op1_64s : std_logic_vector(63 downto 0);
signal op2_64s : std_logic_vector(63 downto 0);
signal op3_64s : std_logic_vector(31 downto 0);
signal op4_64s : std_logic_vector(31 downto 0);
signal op1_64us : std_logic_vector(63 downto 0);
signal op2_64us : std_logic_vector(63 downto 0);
signal op3_64us : std_logic_vector(31 downto 0);
signal op4_64us : std_logic_vector(31 downto 0);


begin

A_bit <= instr(21);
decider_bit <= instr(23);
zero <= (others => '0');
U_bit <= instr(22);

op1_64s <= std_logic_vector(resize(signed(op1),64));
op2_64s <= std_logic_vector(resize(signed(op2),64));
op3_64s <= std_logic_vector(resize(signed(op3),32));
op4_64s <= std_logic_vector(resize(signed(op4),32));
op1_64us <= std_logic_vector(resize(unsigned(op1),64));
op2_64us <= std_logic_vector(resize(unsigned(op2),64));
op3_64us <= std_logic_vector(resize(unsigned(op3),32));
op4_64us <= std_logic_vector(resize(unsigned(op4),32));

big_mul <= 
        std_logic_vector(unsigned(op1_64us)*unsigned(op2_64us)) when A_bit='0' and decider_bit='1' and U_bit='0' else     
        std_logic_vector((unsigned(op1_64us)*unsigned(op2_64us))+(unsigned(op3) and unsigned(op4))) when A_bit='1' and decider_bit='1' and U_bit='0' else
        std_logic_vector(signed(op1_64us)*signed(op2_64us)) when A_bit='0' and decider_bit='1' and U_bit='1' else     
        std_logic_vector((signed(op1_64us)*signed(op2_64us))+(signed(op3)&signed(op4))) when A_bit='1' and decider_bit='1' and U_bit='1';
        

res1 <= 
        std_logic_vector(resize((unsigned(op1)*unsigned(op2)),32)) when (A_bit='0' and decider_bit='0') else
--        zero when (A_bit /= '1' and decider_bit /= '1') else
        std_logic_vector(resize(((unsigned(op1)*unsigned(op2))+unsigned(op3)),32)) when (A_bit='1' and decider_bit='0') else
        big_mul(31 downto 0) when decider_bit='1';

res2 <= 
         zero when A_bit='0' and decider_bit='0' else 
         zero when A_bit='1' and decider_bit='0' else
         big_mul(63 downto 32) when decider_bit='1';
    
end Arch_MUL;