library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity contador_serial is
    port (
        clk       : in  std_logic;
        reset     : in  std_logic;
        start     : in  std_logic;
        data_in   : in  std_logic_vector(4 downto 0);
        done      : out std_logic;
        count_out : out std_logic_vector(2 downto 0)
    );
end entity contador_serial;

architecture rtl of contador_serial is
    signal shift_reg : std_logic_vector(4 downto 0);
    signal bit_index : integer range 0 to 5;
    signal acc_count : unsigned(2 downto 0);
    signal ready     : std_logic;
begin

    process(clk, reset)
    begin
        if reset = '1' then
            shift_reg <= (others => '0');
            bit_index <= 0;
            acc_count <= (others => '0');
            ready     <= '0';
            count_out <= (others => '0');
        elsif rising_edge(clk) then
            if start = '1' then
                shift_reg <= data_in;
                bit_index <= 0;
                acc_count <= (others => '0');
                ready     <= '0';
            elsif bit_index < 5 then
                if shift_reg(bit_index) = '1' then
                    acc_count <= acc_count + 1;
                end if;
                bit_index <= bit_index + 1;
            elsif bit_index = 5 and ready = '0' then
                count_out <= std_logic_vector(acc_count);
                ready     <= '1';
            end if;
        end if;
    end process;

    done <= ready;

end architecture rtl;