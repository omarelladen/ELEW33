-- https://embarcados.com.br/controlador-vga-parte-2/
-- 800x600, 72 Hz

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
signal s_h_cmp1,  -- counter = D
       s_h_cmp2,  -- counter = D+E
       s_h_cmp3,  -- counter = D+E+B
       s_h_cmp4,  -- counter = D+E+B+C
       s_hsync_next,
       s_hsync_prior,
       s_hdataon_next,
       s_hdataon_prior : std_logic;
signal s_hcount_next,
       s_hcount_prior : std_logic_vector(10 downto 0);

-- Vertical control
signal s_v_cmp1,  -- counter = R
       s_v_cmp2,  -- counter = R+S
       s_v_cmp3,  -- counter = R+S+P
       s_v_cmp4,  -- counter = R+S+P+Q
       s_vsync_next,
       s_vsync_prior,
       s_vdataon_next,
       s_vdataon_prior : std_logic;
signal s_vcount_next,
       s_vcount_prior : std_logic_vector(9 downto 0);

begin

    -- Control ---------------------------------------------------------------

    f_hsync  <= s_hsync_prior;
    f_vsync  <= s_vsync_prior;
    f_row    <= s_vcount_prior;
    f_column <= s_hcount_prior;

    f_disp_enable <= s_hdataon_prior and s_vdataon_prior;

    -- Update output ---------------------------------------------------------

    process(f_clock, reset)
    begin
        if reset='0' then
            s_hcount_prior  <= (others => '0');
            s_vcount_prior  <= (others => '0');
            s_hsync_prior   <= '0';
            s_vsync_prior   <= '0';
            s_hdataon_prior <= '0';
            s_vdataon_prior <= '0';
        elsif rising_edge(f_clock) then
            -- counters
            s_hcount_prior <= s_hcount_next;
            s_vcount_prior <= s_vcount_next;

            -- sync
            s_hsync_prior   <= s_hsync_next;
            s_vsync_prior   <= s_vsync_next;
            s_hdataon_prior <= s_hdataon_next;
            s_vdataon_prior <= s_vdataon_next;
        end if;

    end process;

    -- Counters --------------------------------------------------------------

    -- Horizontal counter (reset after 1040 clks)
    s_hcount_next <= (others => '0') when s_h_cmp4='1' else
                     s_hcount_prior+1;

    -- Vertical counter (reset after 666 clks, when a line ends)
    s_vcount_next <= (others => '0') when s_v_cmp4='1' else
                     s_vcount_prior+1  when s_h_cmp4='1' else
                     s_vcount_prior;

    -- Comparators -----------------------------------------------------------

    s_h_cmp1 <= '1' when s_hcount_prior=799  else '0';  -- D       (800)
    s_h_cmp2 <= '1' when s_hcount_prior=855  else '0';  -- D+E     (800+56=856)
    s_h_cmp3 <= '1' when s_hcount_prior=975  else '0';  -- D+E+B   (800+56+120=976)
    s_h_cmp4 <= '1' when s_hcount_prior=1039 else '0';  -- D+E+B+C (800+56+120+64=1040)

    s_v_cmp1 <= '1' when s_vcount_prior=599  else '0';  -- R       (600)
    s_v_cmp2 <= '1' when s_vcount_prior=636  else '0';  -- R+S     (600+37=637)
    s_v_cmp3 <= '1' when s_vcount_prior=642  else '0';  -- R+S+P   (600+37+6=643)
    s_v_cmp4 <= '1' when s_vcount_prior=665  else '0';  -- R+S+P+Q (600+37+6+23=666)

    -- Output ----------------------------------------------------------------

    -- Horizontal sync
    s_hsync_next <= '0' when s_h_cmp2='1' else    -- reset (after 856 clks, stays for 976)
                    '1' when s_h_cmp3='1' else    -- set
                    s_hsync_prior;                -- memory

    -- Vertical sync
    s_vsync_next <= '0' when s_v_cmp2='1' else    -- reset (after 637 clks, stays for 643)
                    '1' when s_v_cmp3='1' else    -- set
                    s_vsync_prior;                -- memory

    -- Horizontal active region
    s_hdataon_next <= '0' when s_h_cmp1='1' else  -- reset
                      '1' when s_h_cmp4='1' else  -- set
                      s_hdataon_prior;            -- memory

    -- Vertical active region
    s_vdataon_next <= '0' when s_v_cmp1='1' else  -- reset
                      '1' when s_v_cmp4='1' else  -- set
                      s_vdataon_prior;            -- memory

end architecture;
