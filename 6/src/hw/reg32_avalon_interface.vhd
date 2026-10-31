library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity reg32_avalon_interface is
port(
    clock      : in  std_logic;
    resetn     : in  std_logic;
    chipselect : in  std_logic;
    write_en   : in  std_logic;
    add        : in  std_logic;  ------- 2 bits
    read_en    : in  std_logic;
    writedata  : in  std_logic_vector(31 downto 0);  -- from NIOS
    readdata   : out std_logic_vector(31 downto 0)   -- to   NIOS
);
end entity;


architecture a of reg32_avalon_interface is

component reg32
port(
    clock  : in  std_logic;
    resetn : in  std_logic;
    we     : in  std_logic;
    d      : in  std_logic_vector(31 downto 0);
    q      : out std_logic_vector(31 downto 0)
);
end component;

component cont8bit
port(
    clk    : in  std_logic;
    cmd    : in  std_logic_vector (31 downto 0);
    output : out std_logic_vector (31 downto 0)
);
end component;

signal write_enable0,
       write_enable1,
       read_enable0,
       read_enable1,
       read_enable_cnt,
       reg_n_cont : std_logic;

signal readdata_internal,
       writedata_internal,
       reg32_0,
       reg32_1,
       saida : std_logic_vector(31 downto 0);

begin

    reg32_def0 : reg32
    port map(
        clock  => clock,
        resetn => resetn,
        we     => write_enable0,
        d      => writedata_internal,
        q      => reg32_0  -- readdata_internal
    );
    reg32_def1 : reg32
    port map(
        clock  => clock,
        resetn => resetn,
        we     => write_enable1,
        d      => writedata_internal,
        q      => reg32_1  -- readdata_internal
    );

    cont8bit_def : cont8bit
    port map(
        clk    => clock,
        output => saida,
        cmd    => reg32_0
    );

    --readdata  <= x"12345678" when read_enable = '1' else (others => '0');
    --readdata1 <= x"AAAA5555" when read_enable = '1' else (others => '0');
    --readdata_internal <= x"12345678" when add2 = '0' else x"AAAA5555";

    write_enable0 <= write_en and chipselect  and (not add);  -------
    write_enable1 <= write_en and chipselect  and      add;   -------

    reg_n_cont  <=   '0';  -- reg32_0(0);
    read_enable0    <= read_en and chipselect and (not add) and (not reg_n_cont);  -------
    read_enable1    <= read_en and chipselect and      add  and (not reg_n_cont);  -------
    read_enable_cnt <= read_en and chipselect and                    reg_n_cont ;

 -- readdata <= x"01234567" when read_enable0   ='1' else  -- reg32_0
 --             x"AAAA5555" when read_enable1   ='1' else  -- reg32_1
 --             x"89ABCdEF" when read_enable_cnt='1' else  -- saida
 --             (others => 'Z');

    -- Test communication with static value
    readdata <= x"00000043";

--  process(clock)
--  begin
--      if rising_edge(clock) then
--          if write_enable0 = '1' then
--              writedata_internal <= writedata;
--          elsif read_enable = '1' then
--              readdata <= saida;
--          end if;
--      end if;
--  end process;

end architecture;
