-- https://embarcados.com.br/controlador-vga-parte-2/
-- 800x600, 72 Hz
-- DE2

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity sync is
port(
    reset         : in  std_logic;
    f_clock       : in  std_logic;  -- 50 MHz
    f_hsync       : out std_logic;
    f_vsync       : out std_logic;
    f_row         : out std_logic_vector(9  downto 0); -- row index
    f_column      : out std_logic_vector(10 downto 0); -- col ind
    f_disp_enable : out std_logic  -- active frame region
);
end entity;


architecture a of sync is

-- Horizontal control
signal h_cmp1,  -- counter = D
       h_cmp2,  -- counter = D+E
       h_cmp3,  -- counter = D+E+B
       h_cmp4,  -- counter = D+E+B+C
       hsync_next,
       hsync_prior,
       hdataon_next,
       hdataon_prior : std_logic;
signal hcount_next,
       hcount_prior : std_logic_vector(10 downto 0);

-- Vertical control
signal v_cmp1,  -- counter = R
       v_cmp2,  -- counter = R+S
       v_cmp3,  -- counter = R+S+P
       v_cmp4,  -- counter = R+S+P+Q
       vsync_next,
       vsync_prior,
       vdataon_next,
       vdataon_prior : std_logic;
signal vcount_next,
       vcount_prior : std_logic_vector(9 downto 0);

begin

    -- Control ---------------------------------------------------------------

    f_hsync  <= hsync_prior;
    f_vsync  <= vsync_prior;
    f_row    <= vcount_prior;
    f_column <= hcount_prior;

    f_disp_enable <= hdataon_prior and vdataon_prior;

    -- Update output ---------------------------------------------------------

    process(f_clock, reset)
    begin
        if reset='0' then
            hcount_prior  <= (others => '0');
            vcount_prior  <= (others => '0');
            hsync_prior   <= '0';
            vsync_prior   <= '0';
            hdataon_prior <= '0';
            vdataon_prior <= '0';
        elsif rising_edge(f_clock) then
            -- counters
            hcount_prior <= hcount_next;
            vcount_prior <= vcount_next;

            -- sync
            hsync_prior   <= hsync_next;
            vsync_prior   <= vsync_next;
            hdataon_prior <= hdataon_next;
            vdataon_prior <= vdataon_next;
        end if;

    end process;

    -- Counters --------------------------------------------------------------

    -- Horizontal counter (reset after 1040 clks)
    hcount_next <= (others => '0') when h_cmp4='1' else
                   hcount_prior+1;

    -- Vertical counter (reset after 666 clks, when a line ends)
    vcount_next <= (others => '0') when v_cmp4='1' else
                   vcount_prior+1  when h_cmp4='1' else
                   vcount_prior;

    -- Comparators -----------------------------------------------------------

    h_cmp1 <= '1' when hcount_prior=799  else '0';  -- D       (800)
    h_cmp2 <= '1' when hcount_prior=855  else '0';  -- D+E     (800+56=856)
    h_cmp3 <= '1' when hcount_prior=975  else '0';  -- D+E+B   (800+56+120=976)
    h_cmp4 <= '1' when hcount_prior=1039 else '0';  -- D+E+B+C (800+56+120+64=1040)

    v_cmp1 <= '1' when vcount_prior=599  else '0';  -- R       (600)
    v_cmp2 <= '1' when vcount_prior=636  else '0';  -- R+S     (600+37=637)
    v_cmp3 <= '1' when vcount_prior=642  else '0';  -- R+S+P   (600+37+6=643)
    v_cmp4 <= '1' when vcount_prior=665  else '0';  -- R+S+P+Q (600+37+6+23=666)

    -- Output ----------------------------------------------------------------

    -- Horizontal sync
    hsync_next <= '0' when h_cmp2='1' else    -- reset (after 856 clks, stays for 976)
                  '1' when h_cmp3='1' else    -- set
                  hsync_prior;                -- memory

    -- Vertical sync
    vsync_next <= '0' when v_cmp2='1' else    -- reset (after 637 clks, stays for 643)
                  '1' when v_cmp3='1' else    -- set
                  vsync_prior;                -- memory

    -- Horizontal active region
    hdataon_next <= '0' when h_cmp1='1' else  -- reset
                    '1' when h_cmp4='1' else  -- set
                    hdataon_prior;            -- memory

    -- Vertical active region
    vdataon_next <= '0' when v_cmp1='1' else  -- reset
                    '1' when v_cmp4='1' else  -- set
                    vdataon_prior;            -- memory

end architecture;
