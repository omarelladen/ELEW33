library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity totalizadores_tb is
end entity totalizadores_tb;

architecture sim of totalizadores_tb is

    signal clk        : std_logic := '0';
    signal reset      : std_logic := '0';
    signal data_in    : std_logic_vector(4 downto 0) := (others => '0');

    signal out_for    : std_logic_vector(2 downto 0);
    signal out_while  : std_logic_vector(2 downto 0);
    signal out_var_if : std_logic_vector(2 downto 0);
    signal out_case   : std_logic_vector(2 downto 0);
    signal out_sig_if : std_logic_vector(2 downto 0);
    signal out_soma   : std_logic_vector(2 downto 0);
    signal out_demux  : std_logic_vector(2 downto 0);

    constant CLK_PERIOD : time := 20 ns;

begin

    -- Instância do circuito sob teste (DUT)
    dut: entity work.totalizadores
        port map (
            clk        => clk,
            reset      => reset,
            data_in    => data_in,
            out_for    => out_for,
            out_while  => out_while,
            out_var_if => out_var_if,
            out_case   => out_case,
            out_sig_if => out_sig_if,
            out_soma   => out_soma,
            out_demux  => out_demux
        );

    -- Gerador de Clock
    clk_process: process
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
        data_in <= "00000";
        wait for 25 ns;
        reset <= '0';
        wait until falling_edge(clk);

        -- Teste 1: "00001" (1 bit '1')
        data_in <= "00001";
        wait until falling_edge(clk);

        -- Teste 2: "00110" (2 bits '1')
        data_in <= "00110";
        wait until falling_edge(clk);

        -- Teste 3: "10101" (3 bits '1')
        data_in <= "10101";
        wait until falling_edge(clk);

        -- Teste 4: "11110" (4 bits '1')
        data_in <= "11110";
        wait until falling_edge(clk);

        -- Teste 5: "11111" (5 bits '1')
        data_in <= "11111";
        wait until falling_edge(clk);

        -- Teste 6: "00000" (0 bits '1')
        data_in <= "00000";
        wait until falling_edge(clk);

        -- Teste 7: "10010" (2 bits '1')
        data_in <= "10010";
        wait until falling_edge(clk);

        -- Teste 8: "11001" (3 bits '1')
        data_in <= "11001";
        wait until falling_edge(clk);

        wait for 40 ns;
        wait;
    end process;

end architecture sim;
