LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY measure_range_count IS
    GENERIC (
        N : NATURAL
    );
    PORT (
        q : IN STD_LOGIC_VECTOR(N * 4 - 1 DOWNTO 0);
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        enable : IN STD_LOGIC;
        done : OUT STD_LOGIC;
        first_none_zero_idx : OUT natural -- 3 is minimum value
    );
END ENTITY measure_range_count;

ARCHITECTURE behav OF measure_range_count IS
    SIGNAL done_tmp : STD_LOGIC;
    SIGNAL first_none_zero_idx_tmp : natural; -- Change type to match output
BEGIN
    PROCESS (clk, rst)
    BEGIN
        IF rst = '1' THEN
            done_tmp <= '0';
            first_none_zero_idx_tmp <= 3; -- Reset to initial value
        ELSIF rising_edge(clk) THEN
            IF enable = '1' THEN
                FOR i IN N - 1 DOWNTO 4 LOOP -- N less than 4 is not allowed
                    IF q(i * 4 - 1 DOWNTO i * 4 - 4) /= "0000" THEN
                        first_none_zero_idx_tmp <= i;
                        EXIT;
                    END IF;
                END LOOP;
                done_tmp <= '1';
            ELSE
                done_tmp <= '0';
                first_none_zero_idx_tmp <= 3; -- Reset to initial value
            END IF;
        END IF;
    END PROCESS;

    done <= done_tmp;
    first_none_zero_idx <= first_none_zero_idx_tmp; -- Assign the output
END ARCHITECTURE behav;