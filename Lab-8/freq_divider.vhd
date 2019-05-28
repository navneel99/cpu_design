
--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;



--entity freq_divider is
--Port(
--clk: in std_logic;
--out_clk: out std_logic
--);
--end freq_divider;

--architecture Behavioral of freq_divider is
--signal counter: std_logic_vector(19 downto 0):="00000000000000000000";
--signal temp_clk: std_logic;

--begin
--process(clk)
--begin 

--if(counter="00000000000000000000") then temp_clk<='1'
--end if;


    



--end Behavioral;



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Clock_Generator is
    Port ( 
           clk_in : in STD_LOGIC;
           clk_out : out STD_LOGIC
          );
end Clock_Generator;

architecture Behavioral of Clock_Generator is

signal count: integer range 0 to 2000000 :=0;
signal temp_clk: STD_LOGIC:='0';

begin
process(clk_in)
begin
    if(clk_in='1' and clk_in'EVENT)then
        if(count<1000000)then
            count<=count+1;
        else
            count<=0;
            temp_clk<=not(temp_clk);
        end if;
    end if;
end process;

clk_out<=temp_clk;

end Behavioral;
