library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity cont8bit is
port(
    clk    : in  std_logic;
    cmd    : in  std_logic_vector (31 downto 0);
    output : out std_logic_vector (31 downto 0)
);
end entity;


architecture a of cont8bit is

component cont0 is
port(
    input  : in  std_logic_vector(7 downto 0);
    cont0s : out std_logic_vector(3 downto 0)
);
end component;

component cont1 is
port(
    input  : in  std_logic_vector (7 downto 0);
    cont1s : out std_logic_vector (3 downto 0)
);
end component;

signal result0,
       result1 : std_logic_vector(3 downto 0);
signal ld : std_logic;
signal en : std_logic;
signal load : std_logic_vector(7 downto 0);

begin

    en <= cmd(6);
    ld <= cmd(7);

    cont0_def: cont0
    port map(
        input  => load,
        cont0s => result0
    );

    cont1_def: cont1
    port map(
        input  => load,
        cont1s => result1
    );

    count_process: process(clk)
    begin
        if rising_edge(clk) then
            if en='1' then
                if ld='1' then
                    load <= cmd(15 downto 8);
                end if;
            end if;
        end if;
    end process;

    output(31 downto 8) <= "000000000000000000000000";
    output(7  downto 4) <= result1;
    output(3  downto 0) <= result0;

end architecture;
