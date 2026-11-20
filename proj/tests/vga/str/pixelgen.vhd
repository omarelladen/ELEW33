-- https://embarcados.com.br/caracteres-ascii-com-controlador-vga-parte-3/
-- 800x600, 72 Hz
-- DE2

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity pixelgen is
port(
    reset    : in  std_logic;
    f_clock  : in  std_logic;
    f_on     : in  std_logic;  -- active frame region
    f_row    : in  std_logic_vector(9  downto 0);  -- row index
    f_column : in  std_logic_vector(10 downto 0);  -- col index
    r_out    : out std_logic_vector(9  downto 0);
    g_out    : out std_logic_vector(9  downto 0);
    b_out    : out std_logic_vector(9  downto 0);
    vgaclock : out std_logic;
    vgablank : out std_logic;
    vgasync  : out std_logic
);
end entity;


architecture a of pixelgen is

component font_rom is
port(
    clk  : in  std_logic;
    addr : in  std_logic_vector(10 downto 0);
    data : out std_logic_vector(7  downto 0)
);
end component font_rom;

signal pix_x,
       pix_y      : unsigned(9 downto 0);
signal rom_addr   : std_logic_vector(10 downto 0);
signal char_addr  : std_logic_vector(6  downto 0);  -- ascii code (part of rom_addr)
signal row_addr   : std_logic_vector(3  downto 0);  -- y px
signal bit_addr   : std_logic_vector(2  downto 0);  -- x px
signal font_word  : std_logic_vector(7  downto 0);  -- value in rom_addr
signal font_bit   : std_logic;                      -- bit_addr value in font_word
signal font_rgb   : std_logic_vector(2  downto 0);
signal txt_on     : std_logic;                      -- show or not

begin

    -- ADV7123 DAC control signals
    vgaclock <= f_clock;
    vgablank <= f_on;
    vgasync  <= '0';

    pix_x <= unsigned(f_column(9 downto 0));
    pix_y <= unsigned(f_row);

    font_unit: font_rom port map(
        clk  => not f_clock,
        addr => rom_addr,
        data => font_word
    );

    row_addr <= std_logic_vector(pix_y(3 downto 0));
    rom_addr <= char_addr & row_addr;

    txt_on <= '1' when (pix_x >= 320 and pix_x <= 415) and (pix_y >= 288 and pix_y <= 303) else
              '0';

    with pix_x(7 downto 3) select
        char_addr <=
            "1001111" when "01000",  -- O
            "1101101" when "01001",  -- m
            "1100001" when "01010",  -- a
            "1110010" when "01011",  -- r
            "0000000" when "01100",  --
            "1010101" when "01101",  -- U
            "1010100" when "01110",  -- T
            "1000110" when "01111",  -- F
            "1010000" when "10000",  -- P
            "1010010" when "10001",  -- R
            "0000000" when others;

    bit_addr <= not std_logic_vector(pix_x(2 downto 0));
    font_bit <= font_word(to_integer(unsigned(bit_addr)));

    font_rgb <= "111" when font_bit='1' else "000";

    process(f_on, font_rgb, txt_on)
    begin
        if f_on='0' or txt_on='0' then
             r_out <= (others => '0');
             g_out <= (others => '0');
             b_out <= (others => '0');
        else
             r_out <= (others => font_rgb(0));
             g_out <= (others => font_rgb(1));
             b_out <= (others => font_rgb(2));
        end if;
    end process;

end architecture;
