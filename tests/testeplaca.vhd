library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity testeplaca is
port(
    clk     : in  std_logic;  -- 50MHZ       (PIN_N2)
    rst     : in  std_logic;  -- SW0         (PIN_N25)
    led     : out std_logic;  -- LEDG0/LED19 (PIN_AE22)
    led_rst : out std_logic   -- LEDG1/LED20 (PIN_AF22)
);
end entity;


architecture a of testeplaca is

signal s_led : std_logic;

signal s_count : integer := 0;

begin
    process(clk, rst)
    begin
        if rst = '1' then
            s_led <= '0';
            s_count <= 0;
        elsif rising_edge(clk) then
            if s_count < 50_000_000 then  -- 1s (f=50MHz)
                s_count <= s_count+1;
            else
                s_count <= 0;
                s_led <= not s_led;  -- toggle
            end if;
        end if;
    end process;

    led <= s_led;
    led_rst <= not rst;

end architecture;
