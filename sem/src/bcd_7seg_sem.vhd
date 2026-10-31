library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity bcd_7seg_sem is
port(
    bcd  : in  std_logic_vector(3 downto 0);
    seg7 : out std_logic_vector(6 downto 0)
);
end entity;


architecture a of bcd_7seg_sem is
begin
    --        --a--
    --       f     b
    --        --g--
    --       e     c
    --        --d--

    --           gfedcba (not: common anode)
    seg7 <= not "0000001" when bcd=x"0" else  -- RED
            not "1000000" when bcd=x"1" else  -- YLW
            not "0001000" when bcd=x"2";      -- GRN
end architecture;
