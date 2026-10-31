library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity top is
port(
    rst       : in  std_logic;                     -- SW1   (PIN_N26)
    clk       : in  std_logic;                     -- 50MHZ (PIN_N2)
    disp_sem1 : out std_logic_vector(6 downto 0);  -- HEX1
    disp_sem2 : out std_logic_vector(6 downto 0)   -- HEX0
);
end entity;


architecture a of top is

component sem
port(
    rst      : in  std_logic;
    clk      : in  std_logic;
    en       : in  std_logic;
    bcd_sem1 : out std_logic_vector(3 downto 0);
    bcd_sem2 : out std_logic_vector(3 downto 0)
);
end component;

component div_1s
port(
    rst : in  std_logic;
    clk : in  std_logic;
    en  : in  std_logic;
    div : out std_logic
);
end component;

component bcd_7seg_sem
port(
    bcd  : in  std_logic_vector(3 downto 0);
    seg7 : out std_logic_vector(6 downto 0)
);
end component;

signal s_bcd_sem1,
       s_bcd_sem2 : std_logic_vector(3 downto 0);

signal s_en_1s  : std_logic;

begin
    traffic_light: sem port map(
        rst      => rst,
        clk      => clk,
        en       => s_en_1s,
        bcd_sem1 => s_bcd_sem1,
        bcd_sem2 => s_bcd_sem2
    );

    div: div_1s port map(
        rst => rst,
        clk => clk,
        en  => '1',
        div => s_en_1s
    );

    conv_1: bcd_7seg_sem port map(
        bcd  => s_bcd_sem1,
        seg7 => disp_sem1
    );
    conv_2: bcd_7seg_sem port map(
        bcd  => s_bcd_sem2,
        seg7 => disp_sem2
    );

end architecture;
