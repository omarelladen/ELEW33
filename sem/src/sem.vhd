library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity sem is
port(
    rst      : in  std_logic;
    clk      : in  std_logic;
    en       : in  std_logic;
    bcd_sem1 : out std_logic_vector(3 downto 0);
    bcd_sem2 : out std_logic_vector(3 downto 0)
);
end entity;


architecture a of sem is

constant c_max_cnt : integer := 40-1;
constant c_min_cnt : integer := 5-1;

signal s_cnt : integer range 0 to c_max_cnt+10;

type   t_state is (s0, s1, s2, s3, s4);

signal s_state : t_state;

begin

    state_machine_wr: process(clk, rst)
    begin
        if rst='1' then
            s_state <= s0;
            s_cnt <= 0;
        elsif rising_edge(clk) then

            if en='1' then  -- every 1s
                s_cnt <= s_cnt+1;
            end if;

            case s_state is
                when s0 =>
                    if s_cnt > c_min_cnt then
                        s_state <= s1;
                        s_cnt <= 0;
                    end if;
                when s1 =>
                    if s_cnt > c_max_cnt then
                        s_state <= s2;
                        s_cnt <= 0;
                    end if;
                when s2 =>
                    if s_cnt > c_min_cnt then
                        s_state <= s3;
                        s_cnt <= 0;
                    end if;
                when s3 =>
                    if s_cnt > c_max_cnt then
                        s_state <= s4;
                        s_cnt <= 0;
                    end if;
                when s4 =>
                    if s_cnt > c_min_cnt then
                        s_state <= s1;
                        s_cnt <= 0;
                    end if;
            end case;

        end if;
    end process;

    process(s_state)
    begin
        case s_state is
            when s0 =>  -- 5s
                bcd_sem1 <= x"1";  -- YLW (blink)
                bcd_sem2 <= x"1";  -- YLW (blink)
            when s1 =>  -- 40s
                bcd_sem1 <= x"0";  -- RED
                bcd_sem2 <= x"2";  -- GRN
            when s2 =>  -- 5s
                bcd_sem1 <= x"0";  -- RED
                bcd_sem2 <= x"1";  -- YLW
            when s3 =>  -- 40s
                bcd_sem1 <= x"2";  -- GRN
                bcd_sem2 <= x"0";  -- RED
            when s4 =>  -- 5s
                bcd_sem1 <= x"1";  -- YLW
                bcd_sem2 <= x"0";  -- RED
        end case;
    end process;

end architecture;
