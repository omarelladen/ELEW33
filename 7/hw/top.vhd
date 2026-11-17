library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity top is
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


architecture a of top is

signal s_char_0,
       s_char_1,
       s_char_2,
       s_char_3,
       s_char_out_0,
       s_char_out_1,
       s_char_out_2,
       s_char_out_3 : std_logic_vector(7 downto 0);

signal s_reg_add  : std_logic_vector(9  downto 0);
-- signal s_reg_data : std_logic_vector(31 downto 0) := x"61616161";
signal s_reg_ctrl : std_logic_vector(1  downto 0);

signal s_wren : std_logic;

signal s_reset : std_logic;

begin
    s_reset <= not resetn;

    s_char_0 <= writedata(7  downto 0);
    s_char_1 <= writedata(15 downto 8);
    s_char_2 <= writedata(23 downto 16);
    s_char_3 <= writedata(31 downto 24);

    process(clock, s_reset)
    begin
        if s_reset='1' then
            s_reg_add    <= (others => '0');
            -- s_reg_data   <= x"62626262";
            s_reg_ctrl   <= (others => '0');

            -- s_char_out_0 <= (others => '0');
            -- s_char_out_1 <= (others => '0');
            -- s_char_out_2 <= (others => '0');
            -- s_char_out_3 <= (others => '0');
        elsif rising_edge(clock) then
            s_reg_ctrl <= "00";

            if chipselect='1' and write_en='1' then

                if add="01" then
                    -- s_reg_data <= x"64646464";  -- writedata;  -- data to wr to output

                    if s_char_0 /= x"F7" then
                        s_char_out_0 <= std_logic_vector(unsigned(s_char_0)+1);
                    else
                        s_char_out_0 <= x"00";
                    end if;

                    if s_char_1 /= x"F7" then
                        s_char_out_1 <= std_logic_vector(unsigned(s_char_1)+1);
                    else
                        s_char_out_1 <= x"00";
                    end if;

                    if s_char_2 /= x"F7" then
                        s_char_out_2 <= std_logic_vector(unsigned(s_char_2)+1);
                    else
                        s_char_out_2 <= x"00";
                    end if;

                    if s_char_3 /= x"F7" then
                        s_char_out_3 <= std_logic_vector(unsigned(s_char_3)+1);
                    else
                        s_char_out_3 <= x"00";
                    end if;

                end if;

            end if;
        end if;
    end process;

    readdata <= s_char_out_3 &
                s_char_out_2 &
                s_char_out_1 &
                s_char_out_0   when (chipselect='1' and read_en='1')
                else (others => 'Z');

    -- readdata <= s_reg_data when (chipselect='1' and read_en='1')
    --             else (others => 'Z');

    -- readdata <= x"61616161";

end architecture;
