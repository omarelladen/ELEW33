library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity top_tb is
end entity;


architecture a of top_tb is

component top
port(
    rst     : in  std_logic;
    clk     : in  std_logic;
--  en      : in  std_logic;
    clr_n   : in  std_logic;
    ss_n    : in  std_logic;
    disp_c0 : out std_logic_vector(6 downto 0);
    disp_c1 : out std_logic_vector(6 downto 0);
    disp_s0 : out std_logic_vector(6 downto 0);
    disp_s1 : out std_logic_vector(6 downto 0)
);
end component;

signal s_rst,
       s_clk,
--     s_en,
       s_clr_n,
       s_ss_n : std_logic;

signal s_disp_c0,
       s_disp_c1,
       s_disp_s0,
       s_disp_s1 : std_logic_vector(6 downto 0);

signal s_finished : std_logic;

constant c_period : time := 20 ns;  -- 50 MHz

begin
    uut: top port map(
        rst     => s_rst,
        clk     => s_clk,
--      en      => s_en,
        ss_n    => s_ss_n,
        clr_n   => s_clr_n,
        disp_c0 => s_disp_c0,
        disp_c1 => s_disp_c1,
        disp_s0 => s_disp_s0,
        disp_s1 => s_disp_s1
    );

    process
    begin
        s_finished <= '0';
        wait for 1 ms;
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

--    process
--    begin
--        s_en <= '1';
--        wait for 900 us;
--        s_en <= '0';
--        wait;
--    end process;

    process
    begin
        s_clr_n <= '1';
        wait for 3 us;
        s_clr_n <= '0';
        wait for 1 us;
        s_clr_n <= '1';
        wait for 150 us;
        s_clr_n <= '0';
        wait for 1 us;
        s_clr_n <= '1';
        wait for 10 us;
        s_clr_n <= '0';
        wait for 1 us;
        s_clr_n <= '1';
        wait;
    end process;

    process
    begin
        s_ss_n <= '1';
        wait for 100 ns;
        s_ss_n <= '0';   -- press (start)
        wait for 2 us;   -- 30 ms (real)
        s_ss_n <= '1';   -- unpress
        wait for 100 us;
        s_ss_n <= '0';   -- press (stop)
        wait for 2 us;   -- 30 ms (real)
        s_ss_n <= '1';   -- unpress
        wait for 100 us;
        s_ss_n <= '0';   -- press (restart)
        wait for 2 us;   -- 30 ms (real)
        s_ss_n <= '1';   -- unpress
        wait for 650 us; -- t ~ 900 us
        s_ss_n <= '0';   -- press (stop)
        wait for 2 us;   -- 30 ms (real)
        s_ss_n <= '1';   -- unpress
        wait for 50 us;
        s_ss_n <= '0';   -- press (restart)
        wait for 2 us;   -- 30 ms (real)
        s_ss_n <= '1';   -- unpress
        wait;
    end process;

end architecture;
