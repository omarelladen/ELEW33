library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity contador_serial is
port(
    clk       : in  std_logic;
    reset     : in  std_logic;
    start     : in  std_logic;  -- clk_en
    data_in   : in  std_logic_vector(4 downto 0);
    done      : out std_logic;
    count_out : out std_logic_vector(2 downto 0)
);
end entity contador_serial;


architecture a of contador_serial is

signal s_shift_reg : std_logic_vector(4 downto 0);
signal s_bit_index : integer range 0 to 5;
signal s_acc_count : unsigned(2 downto 0);
signal s_done      : std_logic;

begin
    process(clk, reset)
    begin
        if reset='1' then
            s_shift_reg <= (others => '0');
            s_bit_index <= 0;
            s_acc_count <= (others => '0');
            s_done      <= '0';
            count_out   <= (others => '0');
        elsif rising_edge(clk) then
            if start='1' then
                s_shift_reg <= data_in;
                s_bit_index <= 0;
                s_acc_count <= (others => '0');
                s_done      <= '0';
            elsif s_bit_index < 5 then
                if s_shift_reg(s_bit_index)='1' then
                    s_acc_count <= s_acc_count+1;
                end if;
                s_bit_index <= s_bit_index + 1;
            elsif s_bit_index=5 and s_done='0' then
                count_out <= std_logic_vector(s_acc_count);
                s_done    <= '1';
            end if;
        end if;
    end process;

    done <= s_done;

end architecture a;
