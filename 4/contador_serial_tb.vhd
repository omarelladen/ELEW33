library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity contador_serial_tb is
end entity contador_serial_tb;

architecture sim of contador_serial_tb is
    signal clk       : std_logic := '0';
    signal reset     : std_logic := '0';
    signal start     : std_logic := '0';
    signal data_in   : std_logic_vector(4 downto 0) := (others => '0');
    signal done      : std_logic;
    signal count_out : std_logic_vector(2 downto 0);

    constant CLK_PERIOD : time := 10 ns;
begin

    -- Instância do circuito sob teste (DUT)
    dut: entity work.contador_serial
        port map (
            clk       => clk,
            reset     => reset,
            start     => start,
            data_in   => data_in,
            done      => done,
            count_out => count_out
        );

    -- Gerador de Clock
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- Processo de estímulos
    stim_proc: process
    begin
        -- Reset inicial
        reset <= '1';
        wait for 20 ns;
        reset <= '0';
        wait until rising_edge(clk);

        -- Teste 1: "10110"
        data_in <= "10110";
        start   <= '1';
        wait until rising_edge(clk);
        start   <= '0';
        wait until done = '1';
        wait for 20 ns;

        -- Teste 2: "11111"
        wait until rising_edge(clk);
        data_in <= "11111";
        start   <= '1';
        wait until rising_edge(clk);
        start   <= '0';
        wait until done = '1';
        wait for 20 ns;

        -- Teste 3: "00000"
        wait until rising_edge(clk);
        data_in <= "00000";
        start   <= '1';
        wait until rising_edge(clk);
        start   <= '0';
        wait until done = '1';

        wait;
    end process;

end architecture sim;
