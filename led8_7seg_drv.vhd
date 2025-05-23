-------------------------------------------------------------------------------
-- Project: IP components lib
-- Author(s): Hus Takocem
-- Created: Dec 2015  v.0 
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY led8_7seg_drv IS
    GENERIC (
        MAIN_CLK : NATURAL := 100E6; -- main frequency in Hz
        CLKDIV_INTERNAL : BOOLEAN := True); -- 
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
        sseg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0); -- active Low
        an : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)); -- active Low
END led8_7seg_drv;

ARCHITECTURE Behavioral OF led8_7seg_drv IS
    CONSTANT DONTCARE : STD_LOGIC_VECTOR(6 DOWNTO 0) := "-------";
    CONSTANT F_SLOW : NATURAL := 500; -- display freq in Hz
    CONSTANT H_PERIOD : NATURAL := MAIN_CLK/F_SLOW/2;
    SIGNAL clkdiv_counter : NATURAL RANGE 0 TO H_PERIOD := 0;
    SIGNAL slow_clk : STD_LOGIC := '0';
    SIGNAL digit : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
    SIGNAL one_hot, address : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"FE";
    SIGNAL seg : STD_LOGIC_VECTOR(6 DOWNTO 0);

BEGIN
    addr_reg : PROCESS (slow_clk)
    BEGIN
        IF rising_edge(slow_clk) THEN
            one_hot <= one_hot(6 DOWNTO 0) & one_hot(7);
            -- otputs
            an_out : an <= one_hot;
            sseg_out : sseg <= NOT(seg);
            --
        END IF;
    END PROCESS;
    address <= one_hot;

    data_mux : WITH address SELECT
    seg <= a WHEN x"fe",
        b WHEN x"fd",
        c WHEN x"fb",
        d WHEN x"f7",
        e WHEN x"ef",
        f WHEN x"df",
        g WHEN x"bf",
        h WHEN x"7f",
        DONTCARE WHEN OTHERS;

    -- clock signals
    clkdiv_true : IF CLKDIV_INTERNAL GENERATE
        PROCESS (clk_in) BEGIN
            IF rising_edge(clk_in) THEN
                IF clkdiv_counter = H_PERIOD - 1 THEN
                    clkdiv_counter <= 0;
                    slow_clk <= NOT slow_clk;
                ELSE
                    clkdiv_counter <= clkdiv_counter + 1;
                END IF;
            END IF;
        END PROCESS;
    END GENERATE;

    clkdiv_false : IF NOT CLKDIV_INTERNAL GENERATE
        slow_clk <= clk_in;
    END GENERATE;

END Behavioral;