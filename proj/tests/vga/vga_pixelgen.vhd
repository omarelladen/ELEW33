-- https://embarcados.com.br/controlador-vga-parte-2/
-- 800x600, 72 Hz
-- DE2 - ADV7123 DAC

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity vga_pixelgen is
port(
    reset     : in  std_logic;
    f_clock   : in  std_logic;  -- 50 MHz
    f_on      : in  std_logic;  -- active frame region
    f_row     : in  std_logic_vector(9  downto 0);  -- row index
    f_column  : in  std_logic_vector(10 downto 0);  -- col index
    r_out     : out std_logic_vector(9  downto 0);
    g_out     : out std_logic_vector(9  downto 0);
    b_out     : out std_logic_vector(9  downto 0);
    vgaclock  : out std_logic;
    vgablank  : out std_logic;
    vgasync   : out std_logic
);
end entity vga_pixelgen;


architecture a of vga_pixelgen is

signal rgbp,                                 -- previous
       rgbn : std_logic_vector(2 downto 0);  -- next

begin

    -- Control
    vgaclock <= f_clock;
    vgablank <= f_on;
    vgasync  <= '0';

    -- RGB ON only if the frame is on the active region
    r_out <= (others => (rgbp(2) and f_on));
    g_out <= (others => (rgbp(1) and f_on));
    b_out <= (others => (rgbp(0) and f_on));

    -- New RGB values based on the column index
    rgbn <= "000" when f_column="00000000000" else  -- BLK (col = 0)
            "001" when f_column="00001100100" else  -- BLU (col = 100)
            "010" when f_column="00011001000" else  -- GRN (col = 200)
            "011" when f_column="00100101100" else  -- CYN (col = 300)
            "100" when f_column="00110010000" else  -- RED (col = 400)
            "101" when f_column="00111110100" else  -- MAG (col = 500)
            "110" when f_column="01001011000" else  -- YLW (col = 600)
            "111" when f_column="01010111100" else  -- WHI (col = 700)
            rgbp;

    process(f_clock, reset)
    begin
        if reset='0' then
            rgbp <= (others => '0');
        elsif rising_edge(f_clock) then
            rgbp <= rgbn;
        end if;
    end process;

end architecture;
