library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity top is
port(
    rst     : in  std_logic;                     -- SW1   (PIN_N26)
    clk     : in  std_logic;                     -- 50MHZ (PIN_N2)
--  en      : in  std_logic;                     -- SW0   (PIN_N25) ?
    clr_n   : in  std_logic;                     -- KEY1  (PIN_N23)
    ss_n    : in  std_logic;                     -- KEY0  (PIN_G26)  -- start/stop (negative logic)
    disp_c0 : out std_logic_vector(6 downto 0);  -- HEX0
    disp_c1 : out std_logic_vector(6 downto 0);  -- HEX1
    disp_s0 : out std_logic_vector(6 downto 0);  -- HEX2
    disp_s1 : out std_logic_vector(6 downto 0)   -- HEX3
);
end entity;


architecture a of top is

component cron_60s
port(
    rst : in  std_logic;
    clk : in  std_logic;
    en  : in  std_logic;
    clr : in  std_logic;
    q   : out std_logic_vector(15 downto 0)
);
end component;

component div_10ms
port(
    rst : in  std_logic;
    clk : in  std_logic;
    en  : in  std_logic;
    div : out std_logic
);
end component;

component bcd_7seg
port(
    bcd  : in  std_logic_vector(3 downto 0);
    seg7 : out std_logic_vector(6 downto 0)
);
end component;

signal s_bcd_c0,
       s_bcd_c1,
       s_bcd_s0,
       s_bcd_s1 : std_logic_vector(3 downto 0);

signal s_q : std_logic_vector(15 downto 0);

signal s_clr,
       s_ss,
       s_en_10ms,
       s_clr_cron : std_logic;
signal s_en_div   : std_logic := '0';

begin
    -- Negative logic (PB)
    s_clr <= not clr_n;
    s_ss  <= not ss_n;

    cron: cron_60s port map(
        rst  => rst,
        clk  => clk,
        en   => s_en_10ms,
        clr  => s_clr_cron,
        q    => s_q
    );
    div: div_10ms port map(
        rst => rst,
        clk => clk,
        en  => s_en_div,
        div => s_en_10ms
    );
    -- conv_s1 conv_s0 : conv_c1 conv_c0
    conv_c0: bcd_7seg port map(
        bcd  => s_bcd_c0,
        seg7 => disp_c0
    );
    conv_c1: bcd_7seg port map(
        bcd  => s_bcd_c1,
        seg7 => disp_c1
    );
    conv_s0: bcd_7seg port map(
        bcd  => s_bcd_s0,
        seg7 => disp_s0
    );
    conv_s1: bcd_7seg port map(
        bcd  => s_bcd_s1,
        seg7 => disp_s1
    );

    process(s_ss)
    begin
        if s_ss='1' then
            s_en_div <= not s_en_div;
        end if;
    end process;

    s_clr_cron <= '1' when s_clr='1' and s_en_div='0' else  -- only when paused
                  '0';

    s_bcd_c0 <= s_q(3  downto  0);
    s_bcd_c1 <= s_q(7  downto  4);
    s_bcd_s0 <= s_q(11 downto  8);
    s_bcd_s1 <= s_q(15 downto 12);

end architecture;
