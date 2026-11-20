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
signal s_current_row    : std_logic_vector(9  downto 0);
signal s_current_column : std_logic_vector(10 downto 0);
signal s_disp_enable    : std_logic;

signal s_hsync,
       s_vsync,
       s_vgablank,
       s_vgasync : std_logic;

signal s_rp,
       s_gp,
       s_bp : std_logic_vector(9 downto 0);

begin

    vgaclock <= clock_50;

    sync_def : sync port map(
        reset         => reset,
        f_clock       => clock_50,
        f_hsync       => s_hsync,
        f_vsync       => s_vsync,
        f_row         => s_current_row,
        f_column      => s_current_column,
        f_disp_enable => s_disp_enable
    );

    pixelgen_def : pixelgen port map(
        reset    => reset,
        f_clock  => clock_50,
        f_on     => s_disp_enable,
        f_row    => s_current_row,
        f_column => s_current_column,
        r_out    => s_rp,
        g_out    => s_gp,
        b_out    => s_bp,
        vgaclock => open,
        vgablank => s_vgablank,
        vgasync  => s_vgasync
    );

    process(clock_50)
    begin
        if rising_edge(clock_50) then
            v_sync   <= s_vsync;
            h_sync   <= s_hsync;
            r        <= s_rp;
            g        <= s_gp;
            b        <= s_bp;
            vgablank <= s_vgablank;
            vgasync  <= s_vgasync;
        end if;
    end process;

end architecture;
