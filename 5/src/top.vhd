library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity top is
port(
    clk   : in  std_logic;
    rst   : in  std_logic;
    q_out : out std_logic_vector(7 downto 0)
);
end entity;


architecture a of top is

component bram is
port(
    address : in  std_logic_vector(10 downto 0);
    clock   : in  std_logic;
    data    : in  std_logic_vector(7  downto 0);
    wren    : in  std_logic;
    q       : out std_logic_vector(7  downto 0)
);
end component;

component fifo is
port(
    clock        : in  std_logic;
    data         : in  std_logic_vector(7 downto 0);
    rdreq        : in  std_logic;  -- rd_en
    wrreq        : in  std_logic;  -- wr_en
    almost_empty : out std_logic;
    almost_full  : out std_logic;
    empty        : out std_logic;
    q            : out std_logic_vector(7 downto 0);
    usedw        : out std_logic_vector(9 downto 0)  ------- cnt
);
end component;

component div_7
port(
    clk : in  std_logic;
    rst : in  std_logic;
    en  : in  std_logic;
    div : out std_logic
);
end component;

signal s_q_br1,
       s_q_fifo : std_logic_vector(7 downto 0);

signal s_rdreq,
       s_wrreq,
       s_almost_empty,
       s_almost_full,
       s_empty : std_logic;

signal s_addr_br1 : std_logic_vector(10 downto 0) := (others => '0');
signal s_addr_br2 : std_logic_vector(10 downto 0);

signal s_usedw : std_logic_vector(9 downto 0);  ------- cnt

signal s_complete_br1,
       s_complete_br2 : std_logic;
signal s_data_br1 : std_logic_vector(7 downto 0);
signal s_wren_br1,
       s_wren_br2 : std_logic;

signal s_div : std_logic;
signal s_rd_fifo : std_logic;

type   t_state_wr is (RESET, LD_BRAM, WR_FIFO, WR_WAIT);
type   t_state_rd is (RESET, RD_FIFO, RD_WAIT);

signal s_state_wr : t_state_wr;
signal s_state_rd : t_state_rd;

begin
    br1: bram port map(
        address => s_addr_br1,
        clock   => clk,
        data    => s_data_br1,
        wren    => s_wren_br1,
        q       => s_q_br1
    );
    br2: bram port map(
        address => s_addr_br2,
        clock   => clk,
        data    => s_q_fifo,
        wren    => s_wren_br2,
        q       => q_out  -------GATE open
    );
    -- q_out <= s_q_br1;  -------GATE
    fifo1: fifo port map(
        clock        => clk,
        data         => s_q_br1,  -------GATE (others => '0'),
        rdreq        => s_rdreq,
        wrreq        => s_wrreq,
        almost_empty => s_almost_empty,
        almost_full  => s_almost_full,
        empty        => s_empty,
        q            => s_q_fifo,
        usedw        => s_usedw
    );

    div: div_7 port map(
        clk => clk,
        rst => rst,
        en  => '1',
        div => s_div
    );

    s_rdreq <= s_div and s_rd_fifo;  -- 7x slower

    s_data_br1 <= s_addr_br1(7  downto 0);  -- 0-255-0-255-...

    wr_br1: process(clk, rst)
    begin
        if rst='1' then
            s_addr_br1 <= (others => '0');
            s_complete_br1 <= '0';
            s_wren_br1 <= '1';
        elsif rising_edge(clk) then
            s_addr_br1 <= std_logic_vector(unsigned(s_addr_br1) + 1);

            if s_complete_br1='1' then
                s_wren_br1 <= '0';
            else
                if unsigned(s_addr_br1)=2047 then  -- finished populating
                    s_complete_br1 <= '1';
                end if;
            end if;
        end if;
    end process;

    wr_br2: process(clk, rst)
    begin
        if rst='1' then
            s_addr_br2 <= (others => '0');
            s_complete_br2 <= '0';
            s_wren_br2 <= '1';
        elsif rising_edge(clk) and s_rdreq='1' then
            s_addr_br2 <= std_logic_vector(unsigned(s_addr_br2) + 1);

            if s_complete_br2='0' and s_rdreq='1' then
                if unsigned(s_addr_br2)=2047 then  -- finished reading
                    s_complete_br2 <= '1';
                end if;
            end if;
        end if;
    end process;

    state_machine_wr: process(clk, rst)
    begin
        if rst='1' then
            s_state_wr <= RESET;
            s_wrreq <= '0';
        elsif rising_edge(clk) then
            case s_state_wr is
                when RESET =>
                    s_state_wr <= LD_BRAM;  -- no condition
                    s_wrreq <= '0';
                when LD_BRAM =>
                    if s_complete_br1='1' then
                        s_state_wr <= WR_FIFO;
                        s_wrreq <= '1';  -------
                    else
                        s_state_wr <= LD_BRAM;  -- same
                        s_wrreq <= '0';
                    end if;
                when WR_FIFO =>
                    if s_almost_full='1' then
                        s_state_wr <= WR_WAIT;
                        s_wrreq <= '0';
                    else
                        s_state_wr <= WR_FIFO;  -- same
                        s_wrreq <= '1';
                    end if;
                when WR_WAIT =>
                    if s_almost_empty='1' then
                        s_state_wr <= WR_FIFO;
                        s_wrreq <= '1';
                    else
                        s_state_wr <= WR_WAIT;  -- same
                        s_wrreq <= '0';
                    end if;
            end case;
        end if;
    end process;

    state_machine_rd: process(clk, rst)
    begin
        if rst='1' then
            s_state_rd <= RESET;
            s_rd_fifo <= '0';
        elsif rising_edge(clk) then
            case s_state_rd is
                when RESET =>
                    if s_empty='1' then
                        s_state_rd <= RD_WAIT;
                        s_rd_fifo <= '0';
                    else
                        s_state_rd <= RD_FIFO;
                        s_rd_fifo <= '1';  -------
                    end if;
                when RD_FIFO =>
                    if s_empty='1' then
                        s_state_rd <= RD_WAIT;
                        s_rd_fifo <= '0';
                    else
                        s_state_rd <= RD_FIFO;  -- same
                        s_rd_fifo <= '1';
                    end if;
                when RD_WAIT =>
                    if s_empty='1' then
                        s_state_rd <= RD_WAIT;  -- same
                        s_rd_fifo <= '0';
                    else
                        s_state_rd <= RD_FIFO;
                        s_rd_fifo <= '1';  -------
                    end if;
            end case;
        end if;
    end process;

end architecture;
