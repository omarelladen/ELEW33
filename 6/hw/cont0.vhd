library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity cont0 is
port(
    input  : in  std_logic_vector(7 downto 0);
    cont0s : out std_logic_vector(3 downto 0)
);
end entity;


architecture a of cont0 is

begin

    process(input)
    variable count : unsigned(3 downto 0) := "0000";
    begin
        count := "0000";   -- inicializa variável count
        for i in 0 to 7 loop
            if(input(i)='0') then -- se o bit for 0...
                count := count + 1; -- incrementa a contagem
            end if;
        end loop;
        cont0s <= std_logic_vector(count);    -- output recebe contagem
    end process;

end architecture;
