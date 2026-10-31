library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity top_tb is
end entity;


architecture a of top_tb is

component top is
port(
    clock        : in  std_logic;
    data         : in  std_logic_vector(7 downto 0);
    rdreq        : in  std_logic;
    wrreq        : in  std_logic;
    almost_empty : out std_logic;
    almost_full  : out std_logic;
    empty        : out std_logic;
    full         : out std_logic;
    q            : out std_logic_vector(7 downto 0);
    usedw        : out std_logic_vector(1 downto 0)
);
end component;

signal s_clk,
       s_rdreq,
       s_wrreq,
       s_almost_empty,
       s_almost_full,
       s_empty,
       s_full : std_logic;

signal s_data,
       s_q : std_logic_vector(7 downto 0);

signal s_usedw : std_logic_vector(1 downto 0);


signal s_finished : std_logic;

constant c_period : time := 20 ns;  -- 50 MHz
constant c_hw_rst : time := 15 ns;

begin
    uut: top port map(
        clock        => s_clk,
        data         => s_data,
        rdreq        => s_rdreq,
        wrreq        => s_wrreq,
        almost_empty => s_almost_empty,
        almost_full  => s_almost_full,
        empty        => s_empty,
        full         => s_full,
        q            => s_q,
        usedw        => s_usedw
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
        s_wrreq <= '0';
        wait for c_hw_rst;
        s_wrreq <= '1';
        wait;
    end process;

    wr: process
    begin
        s_rdreq <= '0';
        wait until rising_edge(s_wrreq);
        s_data <= "00000000";
        wait until falling_edge(s_clk);
        wait until falling_edge(s_clk);
        s_data <= "00000001";
        wait until falling_edge(s_clk);
        wait until falling_edge(s_clk);
        s_data <= "00000010";
        s_rdreq <= '1';
        wait until falling_edge(s_clk);
        wait until falling_edge(s_clk);
        s_data <= "00000011";
        wait;
    end process;

end architecture;
