library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity top_tb is
end entity;


architecture a of top_tb is

component top is
port(
    address : in  std_logic_vector(10 downto 0);
    clock   : in  std_logic;
    data    : in  std_logic_vector(7  downto 0);
    wren    : in  std_logic;
    q       : out std_logic_vector(7  downto 0)
);
end component;

signal s_address : std_logic_vector(10 downto 0);

signal s_clk,
       s_wren : std_logic;

signal s_data,
       s_q : std_logic_vector(7  downto 0);

signal s_finished : std_logic;

constant c_period : time := 20 ns;  -- 50 MHz
constant c_hw_rst : time := 15 ns;

begin
    uut: top port map(
        address => s_address,
        clock   => s_clk,
        data    => s_data,
        wren    => s_wren,
        q       => s_q
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
        s_wren <= '0';
        wait for c_hw_rst;
        s_wren <= '1';
        wait;
    end process;

    wr: process
    begin
        wait until rising_edge(s_wren);
        s_address <= "00000000000";
        s_data <= "00000000";
        wait until falling_edge(s_clk);
        wait until falling_edge(s_clk);
        s_data <= "00000001";
        wait until falling_edge(s_clk);
        wait until falling_edge(s_clk);
        s_address <= "00000000001";
        s_data <= "00000010";
        wait until falling_edge(s_clk);
        wait until falling_edge(s_clk);
        s_address <= "00000000001";
        wait;
    end process;

end architecture;
