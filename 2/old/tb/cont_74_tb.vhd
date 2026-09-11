library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity cont_74_tb is
end entity;


architecture a_cont_74_tb of cont_74_tb is

component cont_74
port(
    rst : in  std_logic;
    clk : in  std_logic;
    en  : in  std_logic;
    clr : in  std_logic;
    q   : out unsigned(7 downto 0)
);
end component;

signal s_rst,
       s_clk,
       s_en,
       s_clr : std_logic;

signal s_q : unsigned(7 downto 0);

signal s_finished : std_logic;

constant c_period : time := 20 ns;

begin
    uut: cont_74 port map(
        rst => s_rst,
        clk => s_clk,
        en  => s_en,
        clr => s_clr,
        q   => s_q
    );

    process
    begin
        s_finished <= '0';
        wait for 4000 ns;
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
        wait;
    end process;

    process
    begin
        s_clr <= '0';
        wait;
    end process;

end architecture;
