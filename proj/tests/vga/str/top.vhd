-- https://embarcados.com.br/caracteres-ascii-com-controlador-vga-parte-3/
-- DE2

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity top is
port(
    clock_50 : in  std_logic;
    reset    : in  std_logic;  -- SW0
    h_sync   : out std_logic;
    v_sync   : out std_logic;
    r        : out std_logic_vector(9  downto 0);
    g        : out std_logic_vector(9  downto 0);
    b        : out std_logic_vector(9  downto 0);
    vgaclock : out std_logic;
    vgablank : out std_logic;
    vgasync  : out std_logic
);
end entity;


architecture a of top is

component sync is
port(
    reset         : in  std_logic;
    f_clock       : in  std_logic;
    f_hsync       : out std_logic;
    f_vsync       : out std_logic;
    f_row         : out std_logic_vector(9  downto 0);
    f_column      : out std_logic_vector(10 downto 0);
    f_disp_enable : out std_logic
);
end component sync;

component pixelgen is
port(
    reset    : in  std_logic;
    f_clock  : in  std_logic;
    f_on     : in  std_logic;
    f_row    : in  std_logic_vector(9  downto 0);
    f_column : in  std_logic_vector(10 downto 0);
    r_out    : out std_logic_vector(9  downto 0);
    g_out    : out std_logic_vector(9  downto 0);
    b_out    : out std_logic_vector(9  downto 0);
    vgaclock : out std_logic;
    vgablank : out std_logic;
    vgasync  : out std_logic
);
end component pixelgen;

--Índice da linha/coluna atual
signal current_row    : std_logic_vector(9  downto 0);
signal current_column : std_logic_vector(10 downto 0);
signal disp_enable    : std_logic;

signal hsync,
       vsync,
       s_vgablank,
       s_vgasync : std_logic;

signal rp,
       gp,
       bp : std_logic_vector(9 downto 0);

begin

    vgaclock <= clock_50;

    sync_def : sync port map(
        reset         => reset,
        f_clock       => clock_50,
        f_hsync       => hsync,
        f_vsync       => vsync,
        f_row         => current_row,
        f_column      => current_column,
        f_disp_enable => disp_enable
    );

    pixelgen_def : pixelgen port map(
        reset    => reset,
        f_clock  => clock_50,
        f_on     => disp_enable,
        f_row    => current_row,
        f_column => current_column,
        r_out    => rp,
        g_out    => gp,
        b_out    => bp,
        vgaclock => open,
        vgablank => s_vgablank,
        vgasync  => s_vgasync
    );

    process(clock_50)
    begin
        if rising_edge(clock_50) then
            v_sync   <= vsync;
            h_sync   <= hsync;
            r        <= rp;
            g        <= gp;
            b        <= bp;
            vgablank <= s_vgablank;
            vgasync  <= s_vgasync;
        end if;
    end process;

end architecture;
