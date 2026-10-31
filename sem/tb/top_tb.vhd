library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity top_tb is
end entity;


architecture a of top_tb is

component top
port(
    rst       : in  std_logic;
    clk       : in  std_logic;
    disp_sem1 : out std_logic_vector(6 downto 0);
    disp_sem2 : out std_logic_vector(6 downto 0)
);
end component;

signal s_rst,
       s_clk : std_logic;

signal s_disp_sem1,
       s_disp_sem2 : std_logic_vector(6 downto 0);

signal s_finished : std_logic;

constant c_duration : time := 2  ms;
constant c_period   : time := 20 ns;  -- 50 MHz
constant c_hw_rst   : time := 15 ns;

begin
    uut: top port map(
        rst       => s_rst,
        clk       => s_clk,
        disp_sem1 => s_disp_sem1,
        disp_sem2 => s_disp_sem2
    );

    finish: process
    begin
        s_finished <= '0';
        wait for 1 ms;
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

end architecture;
