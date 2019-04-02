library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
use Ieee.std_logic_unsigned.all;

entity Main is
Port(
clk: std_logic;
step: in std_logic;
go: in std_logic;
reset: in std_logic;
pselect: in bit_vector(2 downto 0);
display_select: in std_logic_vector(2 downto 0);
slice_select: in std_logic;
led_vector: out std_logic_vector(15 downto 0);
register_select: in std_logic_vector(3 downto 0)
);


 end Main;
 
architecture arch_main of Main is 
component display_interface
Port (
    clk: in std_logic;
    display_select: in std_logic_vector(2 downto 0);
    slice_select: in std_logic;
    state: in std_logic_vector(1 downto 0);
    pmem,apmem,admem,dtmem,dfmem:in std_logic_vector(31 downto 0);
    led_vector:out std_logic_vector(15 downto 0);
    rf_element: in std_logic_vector(31 downto 0)
 );
end component;

component CPU
    Port (
    clk: in std_logic;
    step: in std_logic;
    go: in std_logic;
    program_select: in bit_vector(2 downto 0);
    reset: in std_logic;
    pmem: in std_logic_vector(31 downto 0);
    dfmem: in std_logic_vector(31 downto 0); 
    admem,dtmem: out std_logic_vector(31 downto 0);
    apmem: out std_logic_vector(31 downto 0);
    we: out std_logic;
    state: out std_logic_vector(1 downto 0);
    rf_select: in std_logic_vector(3 downto 0);
    register_element: out std_logic_vector(31 downto 0)
    );
end component;

component Clock_Generator
    PORT(
    clk_in: in STD_LOGIC;
    clk_out: out STD_LOGIC
    );
end component;

component debounce
Port (
input,clk: in std_logic;
output: out std_logic
 );

end component;

component dist_mem_gen_0
    Port(
     a : IN STD_LOGIC_VECTOR(7 DOWNTO 0);  --the program counter
     spo : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) --the instruction
    );
end component;
 
component dist_mem_gen_1
    Port(
     a : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
     d : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
     clk : IN std_logic;
     we : IN STD_LOGIC;
     spo : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );

end component; 
--signal reset,clk : std_logic;
signal temp_apmem : std_logic_vector(31 downto 0);
signal temp_dtmem : std_logic_vector(31 downto 0);
signal temp_we : std_logic;
signal temp_admem,temp_dfmem : std_logic_vector(31 downto 0);
signal temp_pmem : std_logic_vector(31 downto 0):="00000000000000000000000000000000";
signal slow_clk : std_logic;
signal deb_reset : std_logic;
signal deb_step : std_logic;
signal deb_go : std_logic;
signal temp_state: std_logic_vector(1 downto 0);
signal register_element: std_logic_vector(31 downto 0);
begin 

temp_CPU : CPU
PORT MAP(
        reset => reset,
        clk => clk,
        pmem  => temp_pmem,
        apmem => temp_apmem,
        dtmem => temp_dtmem,
        admem => temp_admem,
        dfmem => temp_dfmem,
        we => temp_we,
        program_select => pselect,
        step => deb_step,
        go => go,
        state => temp_state,
        rf_select =>register_select,
        register_element=>register_element
        );
        
Prog_Mem : dist_mem_gen_0
port map(
         a => temp_apmem(9 downto 2),
         spo => temp_pmem
); 

data_Mem : dist_mem_gen_1
port map (
    a => temp_admem(7 downto 0),
    d => temp_dtmem,--32 bit vector
    clk => clk,
    we => temp_we,
    spo => temp_dfmem--32 bit output
);
 

div : Clock_Generator
port map (
    clk_in => clk,
    clk_out => slow_clk
);

display : display_interface
port map (
    clk => clk,
    display_select =>display_select,
    slice_select =>slice_select,
    state => temp_state,
    pmem => temp_pmem,
    apmem => temp_apmem,
    admem => temp_admem,
    dtmem => temp_dtmem,
    dfmem => temp_dfmem,
    led_vector => led_vector,
    rf_element => register_element
);

debouncer_reset : debounce
port map ( 
   input => reset,
   clk => slow_clk,
   output => deb_reset   
);

debouncer_step : debounce
port map ( 
   input => step,
    clk => slow_clk,
    output => deb_step    
);

debouncer_go : debounce
port map ( 
   input => go,
    clk => slow_clk,
    output => deb_go    
);

end architecture;