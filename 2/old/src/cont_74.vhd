library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity cont_74 is
port(
    rst : in  std_logic;
    clk : in  std_logic;
    en  : in  std_logic;
    clr : in  std_logic;
    q   : out unsigned(7 downto 0)
);
end entity;


architecture a_cont_74 of cont_74 is

component cont4
port(
    rst : in  std_logic;
    clk : in  std_logic;
    en  : in  std_logic;
    clr : in  std_logic;
    q   : out unsigned(3 downto 0)
);
end component;

signal s_en_c2,
       s_clr : std_logic;

signal s_q1,
       s_q2,
       s_q1_offs : unsigned(3 downto 0);

begin
    c1: cont4 port map(
        rst => rst,
        clk => clk,
        en  => en,
        clr => s_clr,
        q   => s_q1
    );
    c2: cont4 port map(
        rst => rst,
        clk => clk,
        en  => s_en_c2,
        clr => s_clr,
        q   => s_q2
    );

    -- 15 (1111)
    s_en_c2 <= en and
               s_q1_offs(3) and
               s_q1_offs(2) and
               s_q1_offs(1) and
               s_q1_offs(0);

    -- 86 (0101 0110)
    s_clr <= clr or (
             not s_q2(3) and
                 s_q2(2) and
             not s_q2(1) and
                 s_q2(0) and
             not s_q1_offs(3) and
                 s_q1_offs(2) and
                 s_q1_offs(1) and
             not s_q1_offs(0)
             );

    s_q1_offs <= s_q1 + 13;
    q <= s_q2 & s_q1_offs;

end architecture;
