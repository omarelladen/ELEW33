library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity reg32_avalon_interface is
port(
    clock      : in  std_logic;
    resetn     : in  std_logic;
    chipselect : in  std_logic;
    write_en   : in  std_logic;
    read_en    : in  std_logic;
    add        : in  std_logic_vector(1  downto 0);
    writedata  : in  std_logic_vector(31 downto 0);  -- from Nios
    readdata   : out std_logic_vector(31 downto 0)   -- to   Nios
);
end entity;


architecture a of reg32_avalon_interface is

component bram is
port(
    address : in  std_logic_vector(9 downto 0);
    clock   : in  std_logic;
    data    : in  std_logic_vector(7 downto 0);
    wren    : in  std_logic;
    q       : out std_logic_vector(7 downto 0)
);
end component;

signal s_reg_add  : std_logic_vector(9 downto 0);
signal s_reg_data : std_logic_vector(7 downto 0);
signal s_reg_ctrl : std_logic_vector(1 downto 0);

signal s_bram_q    : std_logic_vector(7 downto 0);
signal s_bram_wren : std_logic;

signal s_checksum_hw,
       s_checksum_sw : std_logic_vector(7 downto 0);

signal s_sequence_hw,
       s_sequence_sw : std_logic_vector(7 downto 0);

signal s_match_checksum : std_logic;
signal s_new_sequence : std_logic;

signal s_reset : std_logic;

begin
    s_reset <= not resetn;

    bram_def: bram
    port map(
        address => s_reg_add,
        clock   => clock,
        data    => s_reg_data,
        wren    => s_bram_wren,
        q       => s_bram_q
    );

    -- Write pulse
    s_bram_wren <= s_reg_ctrl(0);

    -- Compare sw and hw checksums
    s_match_checksum <= '1' when s_checksum_hw=s_checksum_sw else
                        '0';

    process(clock, s_reset)
    begin
        if s_reset='1' then
            s_reg_add      <= (others => '0');
            s_reg_data     <= (others => '0');
            s_reg_ctrl     <= (others => '0');
            s_checksum_hw  <= (others => '0');
            s_checksum_sw  <= (others => '0');
            s_sequence_hw  <= (others => '0');
            s_sequence_sw  <= (others => '0');
            s_new_sequence <= '0';
        elsif rising_edge(clock) then

            -- Self clear the control bits (for wr and wr pulse)
            s_reg_ctrl <= "00";

            if chipselect='1' and write_en='1' then
                if    add="00" then
                    s_reg_add  <= writedata(9 downto 0);  -- mem addr
                elsif add="01" then
                    s_reg_data <= writedata(7 downto 0);  -- data to wr to mem
                elsif add="10" then
                    s_reg_ctrl <= writedata(1 downto 0);  -- ctrl instructions

                    -- Write to memory
                    if writedata(0)='1' then  -- CTRL_WE_BIT
                        if s_new_sequence='1' then
                            s_checksum_hw <= s_reg_data;  -- restart
                            s_new_sequence <= '0';
                            s_sequence_hw  <= (others => '0');
                        else  -- update checksum
                            s_checksum_hw <= std_logic_vector(unsigned(s_checksum_hw) +
                                                              unsigned(s_reg_data));
                            s_sequence_hw <= std_logic_vector(unsigned(s_sequence_hw) + 1);
                        end if;
                    end if;

                    -- Handshake from software
                    if writedata(31 downto 16) /= x"0000" then
                        s_sequence_sw  <= writedata(31 downto 24); -- 31..24
                        s_checksum_sw  <= writedata(23 downto 16); -- 23..16
                        s_new_sequence <= '1';  -- flag to restart the checksum
                    end if;

                end if;
            end if;
        end if;
    end process;

    readdata <= s_sequence_hw &     -- 31..24
                s_checksum_hw &     -- 23..16
                s_match_checksum &  -- 15
                "0000000" &         -- 14..8
                s_bram_q            -- 7..0
                          when (chipselect='1' and read_en='1')
                else (others => 'Z');

end architecture;
