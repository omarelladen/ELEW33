library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity div_10ms is
port(
    rst : in  std_logic;
    clk : in  std_logic;
    en  : in  std_logic;
    div : out std_logic
);
end entity;


architecture a of div_10ms is

-- 10ms/(1/50MHz) = 500_000
signal cont: integer range 0 to 5-1;  -- 500_000 (real), 5 (sim)

begin
    process(rst, clk)
    begin
        if rst = '1' then
            div <= '0';
            cont <= 0;
        elsif rising_edge(clk) then
            if en='1' then
                if cont = 5-1 then  -- 500_000 (real), 5 (sim)
                    div <= '1';
                    cont <= 0;
                else
                    cont <= cont+1;
                    div <= '0';
                end if;
            else
                div <= '0';  -- no output clk when disabled
            end if;
        end if;
    end process;

end architecture;
