LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY simple_f_meter_with_driver IS
    PORT (
        clk_100M : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        f_in : IN STD_LOGIC;
        sw1 : IN STD_LOGIC;
        sw2 : IN STD_LOGIC;
        sw3 : IN STD_LOGIC;
        sw4 : IN STD_LOGIC;
        sw5 : IN STD_LOGIC;
        sw6 : IN STD_LOGIC;
        sw7 : IN STD_LOGIC;
        sw8 : IN STD_LOGIC;
        sw9 : IN STD_LOGIC;
        sw10 : IN STD_LOGIC;
        sw11 : IN STD_LOGIC;
        sw12 : IN STD_LOGIC;
        sw13 : IN STD_LOGIC;
        sseg : OUT STD_LOGIC_VECTOR (7 DOWNTO 0); -- active Low
        an : OUT STD_LOGIC_VECTOR (7 DOWNTO 0) -- active Low
    );
END ENTITY simple_f_meter_with_driver;

ARCHITECTURE struct OF simple_f_meter_with_driver IS
    COMPONENT frequencies_generator
        PORT (
            clk_100M : IN STD_LOGIC;
            -- Outputs for various frequencies
            f_50M : OUT STD_LOGIC; -- 1
            f_25M : OUT STD_LOGIC; -- 2
            f_12_5M : OUT STD_LOGIC; -- 3
            f_6_25M : OUT STD_LOGIC; -- 4
            f_3_125M : OUT STD_LOGIC; -- 5
            f_1_562M : OUT STD_LOGIC; -- 6
            f_781_2K : OUT STD_LOGIC; -- 7
            f_195_3K : OUT STD_LOGIC; -- 9
            f_97_65K : OUT STD_LOGIC; -- 10
            f_6_103K : OUT STD_LOGIC; -- 14
            f_1_525K : OUT STD_LOGIC; -- 16
            f_762_9Hz : OUT STD_LOGIC; -- 17
            f_95_35Hz : OUT STD_LOGIC -- 20
        );
    END COMPONENT;

    COMPONENT led8_7seg_drv
        PORT (
            a : IN STD_LOGIC_VECTOR (6 DOWNTO 0); -- digit AN0
            b : IN STD_LOGIC_VECTOR (6 DOWNTO 0); -- digit AN1
            c : IN STD_LOGIC_VECTOR (6 DOWNTO 0); -- digit AN2
            d : IN STD_LOGIC_VECTOR (6 DOWNTO 0); -- digit AN3
            e : IN STD_LOGIC_VECTOR (6 DOWNTO 0); -- digit AN4
            f : IN STD_LOGIC_VECTOR (6 DOWNTO 0); -- digit AN5
            g : IN STD_LOGIC_VECTOR (6 DOWNTO 0); -- digit AN6
            h : IN STD_LOGIC_VECTOR (6 DOWNTO 0); -- digit AN7
            clk_in : IN STD_LOGIC; -- main_clk or slow_clk (external)
            sseg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0); -- active Low, includes dot
            an : OUT STD_LOGIC_VECTOR (7 DOWNTO 0) -- active Low
        );
    END COMPONENT;

    COMPONENT simple_f_meter
        PORT (
            clk_10M : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            f_in : IN STD_LOGIC;
            q : OUT STD_LOGIC_VECTOR (39 DOWNTO 0);
            first_none_zero_idx : OUT NATURAL;
            dot_pos : OUT NATURAL;
            symbol : OUT NATURAL
        );
    END COMPONENT;

    FUNCTION bin_to_7seg(bcd : STD_LOGIC_VECTOR(3 DOWNTO 0)) RETURN STD_LOGIC_VECTOR IS
        VARIABLE seg_s : STD_LOGIC_VECTOR(6 DOWNTO 0);
    BEGIN
        CASE bcd IS
            WHEN "0001" => seg_s := "0000110"; -- digit 1
            WHEN "0010" => seg_s := "1011011";
            WHEN "0011" => seg_s := "1001111";
            WHEN "0100" => seg_s := "1100110";
            WHEN "0101" => seg_s := "1101101";
            WHEN "0110" => seg_s := "1111101";
            WHEN "0111" => seg_s := "0000111";
            WHEN "1000" => seg_s := "1111111";
            WHEN "1001" => seg_s := "1101111";
            WHEN "0000" => seg_s := "0111111";
            WHEN "1010" => seg_s := "1110111";
            WHEN "1011" => seg_s := "1111100";
            WHEN "1100" => seg_s := "0101011";
            WHEN "1101" => seg_s := "1110101";
            WHEN "1110" => seg_s := "0011011";
            WHEN "1111" => seg_s := "1110110";
            WHEN OTHERS => seg_s := "1111111"; -- blank for invalid codes (all segments off)
        END CASE;
        RETURN seg_s;
    END FUNCTION;

    SIGNAL q : STD_LOGIC_VECTOR(39 DOWNTO 0);
    SIGNAL first_none_zero_idx : NATURAL;
    SIGNAL dot_pos : NATURAL;
    SIGNAL symbol : NATURAL;
    SIGNAL tick_to_fin : STD_LOGIC;
    SIGNAL f_50M, f_25M, f_12_5M, f_6_25M, f_3_125M, f_1_562M, f_781_2K, f_195_3K, f_97_65K, f_6_103K, f_1_525K, f_762_9Hz, f_95_35Hz : STD_LOGIC;

    TYPE seg_array_t IS ARRAY(0 TO 7) OF STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL seg : seg_array_t := (OTHERS => (OTHERS => '1'));
    SIGNAL sseg_without_dot : STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL an_tmp : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '1');

BEGIN
    -- Instantiate the simple_f_meter component
    simple_f_meter_inst : simple_f_meter
    PORT MAP(
        clk_10M => clk_100M,
        rst => rst,
        f_in => tick_to_fin,
        q => q,
        first_none_zero_idx => first_none_zero_idx,
        dot_pos => dot_pos,
        symbol => symbol
    );

    driver : led8_7seg_drv
    PORT MAP(
        a => seg(0),
        b => seg(1),
        c => seg(2),
        d => seg(3),
        e => seg(4),
        f => seg(5),
        g => seg(6),
        h => (OTHERS => '0'), -- Placeholder for unused segment
        clk_in => clk_100M,
        sseg => sseg_without_dot,
        an => an_tmp
    );

    -- Instantiate the frequencies_generator component
    frequencies_gen : frequencies_generator
    PORT MAP(
        clk_100M => clk_100M,
        f_50M => f_50M, -- 1
        f_25M => f_25M, -- 2
        f_12_5M => f_12_5M, -- 3
        f_6_25M => f_6_25M, -- 4
        f_3_125M => f_3_125M, -- 5
        f_1_562M => f_1_562M, -- 6
        f_781_2K => f_781_2K, -- 7
        f_195_3K => f_195_3K, -- 9
        f_97_65K => f_97_65K, -- 10
        f_6_103K => f_6_103K, -- 14
        f_1_525K => f_1_525K, -- 16
        f_762_9Hz => f_762_9Hz, -- 17
        f_95_35Hz => f_95_35Hz -- 20
    );

    SEG_UPDATE : PROCESS (clk_100M)
    BEGIN
        IF rising_edge(clk_100M) THEN
            IF first_none_zero_idx /= 0 THEN
                FOR i IN 0 TO 3 LOOP
                    seg(3 - i) <= bin_to_7seg(
                    q((first_none_zero_idx * 4 + 3) - 4 * i DOWNTO (first_none_zero_idx * 4) - 4 * i)
                    );
                END LOOP;
                seg(4) <= bin_to_7seg("1110"); -- Z
                seg(5) <= bin_to_7seg("1111"); -- H
                CASE symbol IS
                    WHEN 1 => seg(6) <= bin_to_7seg("1101"); -- kHz
                    WHEN 2 => seg(6) <= bin_to_7seg("1100"); -- MHz
                    WHEN OTHERS => seg(6) <= (OTHERS => '0'); -- blank
                END CASE;
            END IF;
        END IF;
    END PROCESS SEG_UPDATE;

    dot_insert_proc : PROCESS (clk_100M, rst)
    BEGIN
        IF rst = '1' THEN
            sseg <= (OTHERS => '1');
        ELSIF rising_edge(clk_100M) THEN
            -- Insert dot when the corresponding anode is active (low)
            IF dot_pos < 8 AND an_tmp(dot_pos) = '0' THEN
                sseg <= '0' & sseg_without_dot; -- Dot active (bit 7 = 0)
            ELSE
                sseg <= '1' & sseg_without_dot; -- Dot inactive (bit 7 = 1)
            END IF;
        END IF;
    END PROCESS dot_insert_proc;

    -- Mux external input or one of the generated clocks based on sw1..sw13
    freq_mux_proc : PROCESS (
        sw1, sw2, sw3, sw4, sw5, sw6, sw7,
        sw8, sw9, sw10, sw11, sw12, sw13,
        f_in,
        f_50M, f_25M, f_12_5M, f_6_25M, f_3_125M,
        f_1_562M, f_781_2K, f_195_3K, f_97_65K,
        f_6_103K, f_1_525K, f_762_9Hz, f_95_35Hz
        )
    BEGIN
        IF sw1 = '1' THEN
            tick_to_fin <= f_50M;
        ELSIF sw2 = '1' THEN
            tick_to_fin <= f_25M;
        ELSIF sw3 = '1' THEN
            tick_to_fin <= f_12_5M;
        ELSIF sw4 = '1' THEN
            tick_to_fin <= f_6_25M;
        ELSIF sw5 = '1' THEN
            tick_to_fin <= f_3_125M;
        ELSIF sw6 = '1' THEN
            tick_to_fin <= f_1_562M;
        ELSIF sw7 = '1' THEN
            tick_to_fin <= f_781_2K;
        ELSIF sw8 = '1' THEN
            tick_to_fin <= f_195_3K;
        ELSIF sw9 = '1' THEN
            tick_to_fin <= f_97_65K;
        ELSIF sw10 = '1' THEN
            tick_to_fin <= f_6_103K;
        ELSIF sw11 = '1' THEN
            tick_to_fin <= f_1_525K;
        ELSIF sw12 = '1' THEN
            tick_to_fin <= f_762_9Hz;
        ELSIF sw13 = '1' THEN
            tick_to_fin <= f_95_35Hz;
        ELSE
            tick_to_fin <= f_in; -- external clock as fallback
        END IF;
    END PROCESS;

    an <= an_tmp;

END ARCHITECTURE struct;