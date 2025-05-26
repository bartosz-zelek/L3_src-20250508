LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY frequencies_generator IS
    PORT (
        clk_100M : IN STD_LOGIC;
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
END ENTITY;

ARCHITECTURE Behavioral OF frequencies_generator IS
    COMPONENT clock_div_counter
        GENERIC (
            WIDTH : INTEGER -- Counter width determines division ratio
        );
        PORT (
            clk : IN STD_LOGIC; -- Input clock
            tick : OUT STD_LOGIC -- Output clock pulse (MSB of counter)
        );
    END COMPONENT;
BEGIN
    -- Instantiate clock dividers for each frequency
    gen_50M : clock_div_counter
        GENERIC MAP (WIDTH => 1)
        PORT MAP (clk => clk_100M, tick => f_50M);

    gen_25M : clock_div_counter
        GENERIC MAP (WIDTH => 2)
        PORT MAP (clk => clk_100M, tick => f_25M);

    gen_12_5M : clock_div_counter
        GENERIC MAP (WIDTH => 3)
        PORT MAP (clk => clk_100M, tick => f_12_5M);

    gen_6_25M : clock_div_counter
        GENERIC MAP (WIDTH => 4)
        PORT MAP (clk => clk_100M, tick => f_6_25M);

    gen_3_125M : clock_div_counter
        GENERIC MAP (WIDTH => 5)
        PORT MAP (clk => clk_100M, tick => f_3_125M);

    gen_1_562M : clock_div_counter
        GENERIC MAP (WIDTH => 6)
        PORT MAP (clk => clk_100M, tick => f_1_562M);

    gen_781_2K : clock_div_counter
        GENERIC MAP (WIDTH => 7)
        PORT MAP (clk => clk_100M, tick => f_781_2K);

    gen_195_3K : clock_div_counter
        GENERIC MAP (WIDTH => 9)
        PORT MAP (clk => clk_100M, tick => f_195_3K);

    gen_97_65K : clock_div_counter
        GENERIC MAP (WIDTH => 10)
        PORT MAP (clk => clk_100M, tick => f_97_65K);

    gen_6_103K : clock_div_counter
        GENERIC MAP (WIDTH => 14)
        PORT MAP (clk => clk_100M, tick => f_6_103K);

    gen_1_525K : clock_div_counter
        GENERIC MAP (WIDTH => 16)
        PORT MAP (clk => clk_100M, tick => f_1_525K);

    gen_7629Hz : clock_div_counter
        GENERIC MAP (WIDTH => 17)
        PORT MAP (clk => clk_100M, tick => f_762_9Hz);

    gen_95Hz : clock_div_counter
        GENERIC MAP (WIDTH => 20)
        PORT MAP (clk => clk_100M, tick => f_95_35Hz);
END ARCHITECTURE;