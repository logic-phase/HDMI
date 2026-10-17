library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_TMDS_Encdr is
end tb_TMDS_Encdr;

architecture sim of tb_TMDS_Encdr is

    -- Component Declaration
    component TMDS_Encdr is
        generic (
            DATA_WIDTH : integer := 8
        );
        Port (
            PxlClk : in  std_logic;
            nRst   : in  std_logic;
            Data   : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            c0     : in  std_logic;
            c1     : in  std_logic;
            de     : in  std_logic;
            Q_out  : out std_logic_vector(9 downto 0)
        );
    end component;

    -- Signals
    signal PxlClk : std_logic := '0';
    signal nRst   : std_logic := '0';
    signal Data   : std_logic_vector(7 downto 0) := (others => '0');
    signal c0     : std_logic := '0';
    signal c1     : std_logic := '0';
    signal de     : std_logic := '0';
    signal Q_out  : std_logic_vector(9 downto 0);

    -- Clock period ? 74.25 MHz (13.468 ns)
    constant CLK_PERIOD : time := 13.468 ns;

begin

    -- Instantiate DUT
    uut : TMDS_Encdr
        generic map (
            DATA_WIDTH => 8
        )
        port map (
            PxlClk => PxlClk,
            nRst   => nRst,
            Data   => Data,
            c0     => c0,
            c1     => c1,
            de     => de,
            Q_out  => Q_out
        );

    -- Clock generation
    PxlClk <= not PxlClk after CLK_PERIOD / 2;

    -- Stimulus
    stim_proc : process
    begin
        -- ======================
        -- Reset
        -- ======================
        nRst <= '0';
        de   <= '0';
        Data <= (others => '0');
        c0   <= '0';
        c1   <= '0';
        wait for CLK_PERIOD * 5;

        nRst <= '1';
        wait for CLK_PERIOD * 2;

        report "=== Start of TMDS Encoder Test ===" severity note;

        -- ======================
        -- 1. Control Period Tests
        -- ======================
        report "--- Testing Control Period ---" severity note;
        de <= '0';

        c1 <= '0'; c0 <= '0';
        wait for CLK_PERIOD;
        report "Ctrl 00 -> Q_out = " & to_hstring(Q_out) severity note;

        c1 <= '0'; c0 <= '1';
        wait for CLK_PERIOD;
        report "Ctrl 01 -> Q_out = " & to_hstring(Q_out) severity note;

        c1 <= '1'; c0 <= '0';
        wait for CLK_PERIOD;
        report "Ctrl 10 -> Q_out = " & to_hstring(Q_out) severity note;

        c1 <= '1'; c0 <= '1';
        wait for CLK_PERIOD;
        report "Ctrl 11 -> Q_out = " & to_hstring(Q_out) severity note;

        -- ======================
        -- 2. Video Data Tests (Sequential)
        -- ======================
        report "--- Testing Video Data Period (Sequential) ---" severity note;
        de <= '1';

        -- Sequence that previously caused issues
        Data <= x"00";
        wait for CLK_PERIOD;
        report "Data=0x00 -> Q_out = " & to_hstring(Q_out) severity note;

        Data <= x"FF";
        wait for CLK_PERIOD;
        report "Data=0xFF -> Q_out = " & to_hstring(Q_out) severity note;

        Data <= x"55";
        wait for CLK_PERIOD;
        report "Data=0x55 -> Q_out = " & to_hstring(Q_out) severity note;

        Data <= x"AA";
        wait for CLK_PERIOD;
        report "Data=0xAA -> Q_out = " & to_hstring(Q_out) severity note;

        Data <= x"80";
        wait for CLK_PERIOD;
        report "Data=0x80 -> Q_out = " & to_hstring(Q_out) severity note;

        Data <= x"01";
        wait for CLK_PERIOD;
        report "Data=0x01 -> Q_out = " & to_hstring(Q_out) severity note;

        Data <= x"F0";
        wait for CLK_PERIOD;
        report "Data=0xF0 -> Q_out = " & to_hstring(Q_out) severity note;

        Data <= x"0F";
        wait for CLK_PERIOD;
        report "Data=0x0F -> Q_out = " & to_hstring(Q_out) severity note;

        -- ======================
        -- 3. Fast consecutive data (stress test)
        -- ======================
        report "--- Stress Test: Fast consecutive data ---" severity note;

        for i in 0 to 15 loop
            Data <= std_logic_vector(to_unsigned(i * 17, 8));  -- ????? ?????
            wait for CLK_PERIOD;
            report "Data=0x" & to_hstring(Data) & " -> Q_out = " & to_hstring(Q_out) severity note;
        end loop;

        -- ======================
        -- 4. Back to Control
        -- ======================
        report "--- Back to Control Period ---" severity note;
        de <= '0';
        c1 <= '0'; c0 <= '0';
        wait for CLK_PERIOD * 3;
        report "Ctrl 00 again -> Q_out = " & to_hstring(Q_out) severity note;

        report "=== Test Finished ===" severity note;
        wait;
    end process;

end sim;