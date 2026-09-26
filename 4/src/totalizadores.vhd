library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity totalizadores is
    port (
        clk        : in  std_logic;
        reset      : in  std_logic;
        data_in    : in  std_logic_vector(4 downto 0);
        out_for    : out std_logic_vector(2 downto 0);
        out_while  : out std_logic_vector(2 downto 0);
        out_var_if : out std_logic_vector(2 downto 0);
        out_case   : out std_logic_vector(2 downto 0);
        out_sig_if : out std_logic_vector(2 downto 0);
        out_soma   : out std_logic_vector(2 downto 0);
        out_demux  : out std_logic_vector(2 downto 0)
    );
end entity totalizadores;

architecture rtl of totalizadores is

    component demux_1to2 is
        port (
            d_in : in  std_logic;
            sel  : in  std_logic;
            y0   : out std_logic;
            y1   : out std_logic
        );
    end component demux_1to2;

    signal sig_lut  : std_logic_vector(2 downto 0);
    signal b0, b1, b2, b3, b4 : unsigned(2 downto 0);
    signal soma_if  : unsigned(2 downto 0);
    signal soma_dir : unsigned(2 downto 0);
    signal dmx_bits : std_logic_vector(4 downto 0);
    signal soma_dmx : unsigned(2 downto 0);

begin

    -- b.1) Variables FOR
    process(clk, reset)
        variable cnt : unsigned(2 downto 0);
    begin
        if reset = '1' then
            out_for <= (others => '0');
        elsif rising_edge(clk) then
            cnt := (others => '0');
            for i in 0 to 4 loop
                if data_in(i) = '1' then
                    cnt := cnt + 1;
                end if;
            end loop;
            out_for <= std_logic_vector(cnt);
        end if;
    end process;

    -- b.2) Variables WHILE
    process(clk, reset)
        variable cnt : unsigned(2 downto 0);
        variable idx : integer range 0 to 5;
    begin
        if reset = '1' then
            out_while <= (others => '0');
        elsif rising_edge(clk) then
            cnt := (others => '0');
            idx := 0;
            while idx < 5 loop
                if data_in(idx) = '1' then
                    cnt := cnt + 1;
                end if;
                idx := idx + 1;
            end loop;
            out_while <= std_logic_vector(cnt);
        end if;
    end process;

    -- b.3) Variables IF
    process(clk, reset)
        variable cnt : unsigned(2 downto 0);
    begin
        if reset = '1' then
            out_var_if <= (others => '0');
        elsif rising_edge(clk) then
            cnt := (others => '0');
            if data_in(0) = '1' then cnt := cnt + 1; end if;
            if data_in(1) = '1' then cnt := cnt + 1; end if;
            if data_in(2) = '1' then cnt := cnt + 1; end if;
            if data_in(3) = '1' then cnt := cnt + 1; end if;
            if data_in(4) = '1' then cnt := cnt + 1; end if;
            out_var_if <= std_logic_vector(cnt);
        end if;
    end process;

    -- b.4) Signals CASE
    process(data_in)
    begin
        case data_in is
            when "00000" =>
                sig_lut <= "000";
            when "00001" | "00010" | "00100" | "01000" | "10000" =>
                sig_lut <= "001";
            when "00011" | "00101" | "00110" | "01001" | "01010" |
                 "01100" | "10001" | "10010" | "10100" | "11000" =>
                sig_lut <= "010";
            when "00111" | "01011" | "01101" | "01110" | "10011" |
                 "10101" | "10110" | "11001" | "11010" | "11100" =>
                sig_lut <= "011";
            when "01111" | "10111" | "11011" | "11101" | "11110" =>
                sig_lut <= "100";
            when "11111" =>
                sig_lut <= "101";
            when others =>
                sig_lut <= "000";
        end case;
    end process;

    process(clk, reset)
    begin
        if reset = '1' then
            out_case <= (others => '0');
        elsif rising_edge(clk) then
            out_case <= sig_lut;
        end if;
    end process;

    -- b.5) Signals IF (5 sinais somados)
    process(data_in)
    begin
        if data_in(0) = '1' then b0 <= "001"; else b0 <= "000"; end if;
        if data_in(1) = '1' then b1 <= "001"; else b1 <= "000"; end if;
        if data_in(2) = '1' then b2 <= "001"; else b2 <= "000"; end if;
        if data_in(3) = '1' then b3 <= "001"; else b3 <= "000"; end if;
        if data_in(4) = '1' then b4 <= "001"; else b4 <= "000"; end if;
    end process;

    soma_if <= b0 + b1 + b2 + b3 + b4;

    process(clk, reset)
    begin
        if reset = '1' then
            out_sig_if <= (others => '0');
        elsif rising_edge(clk) then
            out_sig_if <= std_logic_vector(soma_if);
        end if;
    end process;

    -- b.6) Signals Soma direta
    soma_dir <= unsigned'("00" & data_in(0)) +
                unsigned'("00" & data_in(1)) +
                unsigned'("00" & data_in(2)) +
                unsigned'("00" & data_in(3)) +
                unsigned'("00" & data_in(4));

    process(clk, reset)
    begin
        if reset = '1' then
            out_soma <= (others => '0');
        elsif rising_edge(clk) then
            out_soma <= std_logic_vector(soma_dir);
        end if;
    end process;

    -- b.7) Signals 5 DEMUX
    gen_dmx: for i in 0 to 4 generate
        u_dmx: demux_1to2
            port map (
                d_in => '1',
                sel  => data_in(i),
                y0   => open,
                y1   => dmx_bits(i)
            );
    end generate gen_dmx;

    soma_dmx <= unsigned'("00" & dmx_bits(0)) +
                unsigned'("00" & dmx_bits(1)) +
                unsigned'("00" & dmx_bits(2)) +
                unsigned'("00" & dmx_bits(3)) +
                unsigned'("00" & dmx_bits(4));

    process(clk, reset)
    begin
        if reset = '1' then
            out_demux <= (others => '0');
        elsif rising_edge(clk) then
            out_demux <= std_logic_vector(soma_dmx);
        end if;
    end process;

end architecture rtl;
