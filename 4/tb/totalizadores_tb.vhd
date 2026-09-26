library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity totalizadores_tb is
end entity totalizadores_tb;


architecture a of totalizadores_tb is

signal s_clk        : std_logic := '0';
signal s_reset      : std_logic := '0';
signal s_data_in    : std_logic_vector(4 downto 0) := (others => '0');
signal s_out_for    : std_logic_vector(2 downto 0);
signal s_out_while  : std_logic_vector(2 downto 0);
signal s_out_var_if : std_logic_vector(2 downto 0);
signal s_out_case   : std_logic_vector(2 downto 0);
signal s_out_sig_if : std_logic_vector(2 downto 0);
signal s_out_soma   : std_logic_vector(2 downto 0);
signal s_out_demux  : std_logic_vector(2 downto 0);

signal s_finished : std_logic;

constant c_period : time := 20 ns;

begin
    uut: entity work.totalizadores
        port map(
            clk        => s_clk,
            reset      => s_reset,
            data_in    => s_data_in,
            out_for    => s_out_for,
            out_while  => s_out_while,
            out_var_if => s_out_var_if,
            out_case   => s_out_case,
            out_sig_if => s_out_sig_if,
            out_soma   => s_out_soma,
            out_demux  => s_out_demux
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
        s_data_in <= "00000";
        wait for 25 ns;
        s_reset <= '0';
        wait until falling_edge(s_clk);

        -- Teste 1: "00001" (1 bit '1')
        s_data_in <= "00001";
        wait until falling_edge(s_clk);

        -- Teste 2: "00110" (2 bits '1')
        s_data_in <= "00110";
        wait until falling_edge(s_clk);

        -- Teste 3: "10101" (3 bits '1')
        s_data_in <= "10101";
        wait until falling_edge(s_clk);

        -- Teste 4: "11110" (4 bits '1')
        s_data_in <= "11110";
        wait until falling_edge(s_clk);

        -- Teste 5: "11111" (5 bits '1')
        s_data_in <= "11111";
        wait until falling_edge(s_clk);

        -- Teste 6: "00000" (0 bits '1')
        s_data_in <= "00000";
        wait until falling_edge(s_clk);

        -- Teste 7: "10010" (2 bits '1')
        s_data_in <= "10010";
        wait until falling_edge(s_clk);

        -- Teste 8: "11001" (3 bits '1')
        s_data_in <= "11001";
        wait until falling_edge(s_clk);

        wait for 40 ns;
        wait;
    end process;

end architecture a;
