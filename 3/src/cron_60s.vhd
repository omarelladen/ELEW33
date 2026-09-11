library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity cron_60s is
port(
    rst : in  std_logic;
    clk : in  std_logic;
    en  : in  std_logic;
    clr : in  std_logic;
    q   : out std_logic_vector(15 downto 0)
);
end entity;


architecture a of cron_60s is

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

signal s_en_c0,
       s_en_c1,
       s_en_s0,
       s_en_s1,
       s_clr_c0,
       s_clr_c1,
       s_clr_s0,
       s_clr_s1 : std_logic;

signal s_q_c0,
       s_q_c1,
       s_q_s0,
       s_q_s1 : std_logic_vector(3 downto 0);

begin
    -- s1 s0 : c1 c0
    -- -------------
    --  0  0 :  0  0
    --  5  9 :  9  9
    c0: cont4 port map(
        rst  => rst,
        clk  => clk,
        en   => s_en_c0,
        clr  => s_clr_c0,
        ld   => '0',
        load => x"0",
        q    => s_q_c0
    );
    c1: cont4 port map(
        rst  => rst,
        clk  => clk,
        en   => s_en_c1,
        clr  => s_clr_c1,
        ld   => '0',
        load => x"0",
        q    => s_q_c1
    );
    s0: cont4 port map(
        rst  => rst,
        clk  => clk,
        en   => s_en_s0,
        clr  => s_clr_s0,
        ld   => '0',
        load => x"0",
        q    => s_q_s0
    );
    s1: cont4 port map(
        rst  => rst,
        clk  => clk,
        en   => s_en_s1,
        clr  => s_clr_s1,
        ld   => '0',
        load => x"0",
        q    => s_q_s1
    );

    s_en_c0 <= en;  -- direct
    s_en_c1 <= '1' when en='1' and  s_q_c0=x"9" else
               '0';
    s_en_s0 <= '1' when en='1' and (s_q_c1=x"9" and
                                    s_q_c0=x"9") else
               '0';
    s_en_s1 <= '1' when en='1' and (s_q_s0=x"9" and
                                    s_q_c1=x"9" and
                                    s_q_c0=x"9") else
               '0';

    s_clr_c0 <= '1' when clr='1' or (s_en_c0='1' and s_q_c0=x"9") else
                '0';
    s_clr_c1 <= '1' when clr='1' or (s_en_c1='1' and s_q_c1=x"9") else
                '0';
    s_clr_s0 <= '1' when clr='1' or (s_en_s0='1' and s_q_s0=x"9") else
                '0';
    s_clr_s1 <= '1' when clr='1' or (s_en_s1='1' and s_q_s1=x"5") else
                '0';

    -- join 4 BCDs
    q <= s_q_s1 &
         s_q_s0 &
         s_q_c1 &
         s_q_c0;

end architecture;
