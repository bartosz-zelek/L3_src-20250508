LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY simple_f_meter_with_driver IS
    PORT (
        clk_100M : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        -- f_in : IN STD_LOGIC;
        sw1 : IN STD_LOGIC;
        sw2 : IN STD_LOGIC;
        sw3 : IN STD_LOGIC;
        sseg : OUT STD_LOGIC_VECTOR (7 DOWNTO 0); -- active Low
        an : OUT STD_LOGIC_VECTOR (7 DOWNTO 0) -- active Low
    );
END ENTITY simple_f_meter_with_driver;

ARCHITECTURE struct OF simple_f_meter_with_driver IS
    COMPONENT clk_wiz_1
        PORT (
            clk_in1: IN STD_LOGIC;
            clk_out1: OUT STD_LOGIC;
            clk_out2: OUT STD_LOGIC;
            clk_out3: OUT STD_LOGIC
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
    SIGNAL clk1, clk2, clk3 : STD_LOGIC;
    SIGNAL clk_to_fin : STD_LOGIC;

    -- SIGNAL seg0, seg1, seg2, seg3, seg4, seg5, seg6 : STD_LOGIC_VECTOR(6 DOWNTO 0) := (OTHERS => '1');
    type seg_array_t is array(0 to 7) of std_logic_vector(6 downto 0);
    SIGNAL seg : seg_array_t := (OTHERS => (OTHERS => '1'));
    SIGNAL sseg_without_dot : STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL an_tmp : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '1');

BEGIN

    clk_wiz_1_clk_wiz_inst : clk_wiz_1
    PORT MAP(
        clk_in1 => clk_100M,
        clk_out1 => clk1,
        clk_out2 => clk2,
        clk_out3 => clk3
    );

    -- Instantiate the simple_f_meter component
    simple_f_meter_inst : simple_f_meter
    PORT MAP(
        clk_10M => clk_100M,
        rst => rst,
        f_in => clk_to_fin,
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

    -- Generate the clock signal for the frequency input
    SELECT_CLK : PROCESS(clk_100M)
    BEGIN
        IF rising_edge(clk_100M) THEN
            IF sw1 = '1' THEN
                clk_to_fin <= clk1;
            ELSIF sw2 = '1' THEN
                clk_to_fin <= clk2;
            -- ELSIF sw3 = '1' THEN
            --     clk_to_fin <= clk3;
            ELSE
                clk_to_fin <= '0'; -- Default to low if no switch is pressed
            END IF;
        END IF;
    END PROCESS SELECT_CLK;

    SEG_UPDATE : PROCESS (clk_100M)
    BEGIN
        IF rising_edge(clk_100M) THEN
            IF first_none_zero_idx /= 0 THEN
                for i in 0 to 3 loop
                    seg(3-i) <= bin_to_7seg(
                      q((first_none_zero_idx*4+3) - 4*i downto (first_none_zero_idx*4) - 4*i)
                    );
                end loop;
                seg(4) <= bin_to_7seg("1110"); -- Z
                seg(5) <= bin_to_7seg("1111"); -- H
                CASE symbol IS
                    WHEN 1 => seg(6) <= bin_to_7seg("1101"); -- kHz
                    WHEN 2 => seg(6) <= bin_to_7seg("1100"); -- MHz
                    WHEN OTHERS => seg(6) <= (OTHERS => '0');        -- blank
                END CASE;
            END IF;
        END IF;
    END PROCESS SEG_UPDATE;

    dot_insert_proc : PROCESS(clk_100M, rst)
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

    an <= an_tmp;

END ARCHITECTURE struct;