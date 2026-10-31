library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity top_tb is
end entity;


architecture a of top_tb is

component top is
port(
    clk   : in  std_logic;
    rst   : in  std_logic;
    q_out : out std_logic_vector(7 downto 0)
);
end component;

signal s_clk,
       s_rst : std_logic;

signal s_q_out : std_logic_vector(7  downto 0);

signal s_finished : std_logic;

constant c_duration : time := 2  ms;
constant c_period   : time := 20 ns;  -- 50 MHz
constant c_hw_rst   : time := 15 ns;

begin
    uut: top port map(
        clk   => s_clk,
        rst   => s_rst,
        q_out => s_q_out
    );

    finish: process
    begin
        s_finished <= '0';
        wait for c_duration;
        s_finished <= '1';
        wait;
    end process;

    clk: process
    begin
        while s_finished /= '1' loop
            s_clk <= '0';
            wait for c_period/2;
            s_clk <= '1';
            wait for c_period/2;
        end loop;
        wait;
    end process;

    hw_rst: process
    begin
        s_rst <= '1';
        wait for c_hw_rst;
        s_rst <= '0';
        wait;
    end process;

    wr: process
    begin
        wait until falling_edge(s_rst);

        wait until falling_edge(s_clk);
        wait until falling_edge(s_clk);

        wait until falling_edge(s_clk);
        wait until falling_edge(s_clk);

        wait until falling_edge(s_clk);
        wait until falling_edge(s_clk);

        wait;
    end process;

end architecture;
