library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity div_7 is
port(
    clk : in  std_logic;
    rst : in  std_logic;
    en  : in  std_logic;
    div : out std_logic
);
end entity;


architecture a of div_7 is

constant c_cnt_max : integer := 7-1;  -- 50 MHz

signal s_cnt: integer range 0 to c_cnt_max;

begin
    process(rst, clk)
    begin
        if rst='1' then
            div <= '0';
            s_cnt <= 0;
        elsif rising_edge(clk) then
            if en='1' then
                if s_cnt=c_cnt_max then
                    div <= '1';
                    s_cnt <= 0;
                else
                    s_cnt <= s_cnt+1;
                    div <= '0';
                end if;
            else
                div <= '0';  -- no output clk when disabled
            end if;
        end if;
    end process;

end architecture;
