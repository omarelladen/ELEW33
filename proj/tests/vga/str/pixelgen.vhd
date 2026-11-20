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

signal s_pix_x,
       s_pix_y     : unsigned(9 downto 0);
signal s_rom_addr  : std_logic_vector(10 downto 0);
signal s_char_addr : std_logic_vector(6  downto 0);  -- ascii code (part of s_rom_addr)
signal s_row_addr  : std_logic_vector(3  downto 0);  -- y px
signal s_bit_addr  : std_logic_vector(2  downto 0);  -- x px
signal s_font_word : std_logic_vector(7  downto 0);  -- value in s_rom_addr
signal s_font_bit  : std_logic;                      -- s_bit_addr value in s_font_word
signal s_font_rgb  : std_logic_vector(2  downto 0);
signal s_txt_on    : std_logic;                      -- show or not

begin

    -- ADV7123 DAC control signals
    vgaclock <= f_clock;
    vgablank <= f_on;
    vgasync  <= '0';

    s_pix_x <= unsigned(f_column(9 downto 0));
    s_pix_y <= unsigned(f_row);

    font_unit: font_rom port map(
        clk  => not f_clock,
        addr => s_rom_addr,
        data => s_font_word
    );

    s_row_addr <= std_logic_vector(s_pix_y(3 downto 0));
    s_rom_addr <= s_char_addr & s_row_addr;

    s_txt_on <= '1' when (s_pix_x >= 320 and s_pix_x <= 415) and (s_pix_y >= 288 and s_pix_y <= 303) else
                '0';

    with s_pix_x(7 downto 3) select
        s_char_addr <=
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

    s_bit_addr <= not std_logic_vector(s_pix_x(2 downto 0));
    s_font_bit <= s_font_word(to_integer(unsigned(s_bit_addr)));

    s_font_rgb <= "111" when s_font_bit='1' else "000";

    process(f_on, s_font_rgb, s_txt_on)
    begin
        if f_on='0' or s_txt_on='0' then
            r_out <= (others => '0');
            g_out <= (others => '0');
            b_out <= (others => '0');
        else
            r_out <= (others => s_font_rgb(0));
            g_out <= (others => s_font_rgb(1));
            b_out <= (others => s_font_rgb(2));
        end if;
    end process;

end architecture;
