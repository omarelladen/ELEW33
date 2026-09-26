library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity demux_1to2 is
port(
    d_in : in  std_logic;
    sel  : in  std_logic;
    y0   : out std_logic;
    y1   : out std_logic
);
end entity demux_1to2;


architecture a of demux_1to2 is
begin
    y0 <= d_in when sel='0' else '0';
    y1 <= d_in when sel='1' else '0';
end architecture a;
