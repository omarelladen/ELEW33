library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity cont_74 is
port(
    rst : in  std_logic;  -- set to 13
    clk : in  std_logic;
    en  : in  std_logic;
    clr : in  std_logic;
    q   : out std_logic_vector(7 downto 0)
);
end entity;


architecture a_cont_74 of cont_74 is

component cont4
port(
    rst  : in  std_logic;
    clk  : in  std_logic;
    en   : in  std_logic;
    clr  : in  std_logic;
    ld   : in  std_logic;
    load : in  std_logic_vector(3 downto 0);
    q    : out std_logic_vector(3 downto 0)
);
end component;

signal s_en2,
       s_ld,
       s_clr1,
       s_clr2 : std_logic;

signal s_q1,
       s_q2,
       s_load1,
       s_load2 : std_logic_vector(3 downto 0);

begin
    c1: cont4 port map(
        rst  => rst,
        clk  => clk,
        en   => en,
        clr  => s_clr1,
        ld   => s_ld,
        load => s_load1,
        q    => s_q1
    );
    c2: cont4 port map(
        rst  => rst,
        clk  => clk,
        en   => s_en2,
        clr  => s_clr2,
        ld   => s_ld,
        load => s_load2,
        q    => s_q2
    );

    -- clr or when reaching 9
    s_clr1 <= '1' when clr='1' or s_q1="1001" else
              '0';
    s_clr2 <= '1' when clr='1' or s_q2="1001" else
              '0';

    -- values to load when restarting (86->13 or 00->13)
    s_load2 <= "0001";  -- 1
    s_load1 <= "0011";  -- 3

    s_en2 <= '1' when en='1' and (s_q1="1001" or s_ld='1') else
             '0';

    -- enable load when reaching 86 (BCD) or after rst
    s_ld <= '1' when (s_q2="1000" and
                      s_q1="0110")
                     or
                     (s_q2="0000" and
                      s_q1="0000" and
                      rst='0' and
                      clr='0')
            else '0';

    -- join 2 BCDs
    q <= s_q2 & s_q1;

end architecture;
