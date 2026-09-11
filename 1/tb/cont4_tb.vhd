library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity cont4_tb is
end entity;


architecture a_cont4_tb of cont4_tb is

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

signal s_rst,
       s_clk,
       s_en,
       s_clr : std_logic;
signal s_ld  : std_logic := '0';

signal s_q    : std_logic_vector(3 downto 0);
signal s_load : std_logic_vector(3 downto 0) := "0000";

signal s_finished : std_logic;

constant c_period : time := 20 ns;

begin
    uut: cont4 port map(
        rst  => s_rst,
        clk  => s_clk,
        en   => s_en,
        clr  => s_clr,
        ld   => s_ld,
        load => s_load,
        q    => s_q
    );

    process
    begin
        s_finished <= '0';
        wait for 400 ns;
        s_finished <= '1';
        wait;
    end process;

    process
    begin
        while s_finished /= '1' loop
            s_clk <= '0';
            wait for c_period/2;
            s_clk <= '1';
            wait for c_period/2;
        end loop;
        wait;
    end process;

    process
    begin
        s_rst <= '1';
        wait for 15 ns;
        s_rst <= '0';
        wait;
    end process;

    process
    begin
        s_en <= '1';
        wait for 185 ns;
        s_en <= '0';
        wait;
    end process;

    process
    begin
        s_clr <= '0';
        wait for 75 ns;
        s_clr <= '1';
        wait for 20 ns;  -- 95 ns
        s_clr <= '0';
        wait for 30 ns;  -- 125 ns
        s_clr <= '1';
        wait for 20 ns;  -- 145 ns
        s_clr <= '0';
        wait;
    end process;

end architecture;
