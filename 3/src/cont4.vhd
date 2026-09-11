library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity cont4 is
port(
    rst  : in  std_logic;
    clk  : in  std_logic;
    en   : in  std_logic;
    clr  : in  std_logic;
    ld   : in  std_logic;
    load : in  std_logic_vector(3 downto 0);
    q    : out std_logic_vector(3 downto 0)
);
end entity;


architecture a of cont4 is

signal s_cont : std_logic_vector(3 downto 0);

begin
    process(clk, rst)
    begin
        if rst='1' then
            s_cont <= "0000";
        elsif rising_edge(clk) then
            if clr='1' then
                s_cont <= "0000";
            elsif en='1' then
                if ld='1' then
                   s_cont <= load;
                else
                    s_cont <= std_logic_vector(unsigned(s_cont)+1);
                end if;
            end if;
        end if;
    end process;

    q <= s_cont;

end architecture;
