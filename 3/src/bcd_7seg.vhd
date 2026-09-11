library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity bcd_7seg is
port(
    bcd  : in  std_logic_vector(3 downto 0);
    seg7 : out std_logic_vector(6 downto 0)
);
end entity;


architecture a of bcd_7seg is
begin
    --        --a--
    --       f     b
    --        --g--
    --       e     c
    --        --d--

    --          gfedcba (not: common anode)
    seg7 <= not "0111111" when bcd=x"0" else
            not "0000110" when bcd=x"1" else
            not "1011011" when bcd=x"2" else
            not "1001111" when bcd=x"3" else
            not "1100110" when bcd=x"4" else
            not "1101101" when bcd=x"5" else
            not "1111101" when bcd=x"6" else
            not "0000111" when bcd=x"7" else
            not "1111111" when bcd=x"8" else
            not "1100111" when bcd=x"9" else
            not "1110111" when bcd=x"A" else
            not "1111100" when bcd=x"B" else
            not "0111001" when bcd=x"C" else
            not "1011110" when bcd=x"D" else
            not "1111001" when bcd=x"E" else
            not "1110001" when bcd=x"F";
end architecture;
