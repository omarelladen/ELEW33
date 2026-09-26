library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity contador_serial_tb is
end entity contador_serial_tb;


architecture a of contador_serial_tb is

signal s_clk       : std_logic := '0';
signal s_reset     : std_logic := '0';
signal s_start     : std_logic := '0';
signal s_data_in   : std_logic_vector(4 downto 0) := (others => '0');
signal s_done      : std_logic;
signal s_count_out : std_logic_vector(2 downto 0);

signal s_finished : std_logic;

constant c_period : time := 10 ns;

begin
    uut: entity work.contador_serial
        port map(
            clk       => s_clk,
            reset     => s_reset,
            start     => s_start,
            data_in   => s_data_in,
            done      => s_done,
            count_out => s_count_out
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
        -- Reset inicial
        s_reset <= '1';
        wait for 20 ns;
        s_reset <= '0';

        -- Teste 1: "10110"
        wait until rising_edge(s_clk);
        s_data_in <= "10110";
        s_start   <= '1';
        wait until rising_edge(s_clk);
        s_start   <= '0';
        wait until s_done='1';
        wait for 20 ns;

        -- Teste 2: "11111"
        wait until rising_edge(s_clk);
        s_data_in <= "11111";
        s_start   <= '1';
        wait until rising_edge(s_clk);
        s_start   <= '0';
        wait until s_done='1';
        wait for 20 ns;

        -- Teste 3: "00000"
        wait until rising_edge(s_clk);
        s_data_in <= "00000";
        s_start   <= '1';
        wait until rising_edge(s_clk);
        s_start   <= '0';
        wait until s_done='1';

        wait;
    end process;

end architecture a;
