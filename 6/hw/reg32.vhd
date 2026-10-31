library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity reg32 is
port(
    clock  : in  std_logic;
    resetn : in  std_logic;
    we     : in  std_logic;
    d      : in  std_logic_vector(31 downto 0);  -- data to write
    q      : out std_logic_vector(31 downto 0)
);
end entity;


architecture a of reg32 is

begin
    process(resetn, clock)
    begin
        if resetn='1' THEN
            q <= x"00000000";
        elsif rising_edge(clock) then
            if we='1' then
                q <= d;
            end if;
        end if;
    end process;

end architecture;
