LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY measure_range_count IS
    GENERIC (
        N : NATURAL RANGE 4 TO INTEGER'HIGH
    );
    PORT (
        q                      : IN  std_logic_vector(N*4-1 DOWNTO 0);
        clk, rst, enable       : IN  STD_LOGIC;
        done                   : OUT STD_LOGIC;
        first_none_zero_idx    : OUT NATURAL RANGE 3 TO N-1
    );
END ENTITY;

ARCHITECTURE behav OF measure_range_count IS
BEGIN
    PROCESS(clk, rst)
    BEGIN
        IF rst = '1' THEN
            done                <= '0';
            first_none_zero_idx <= 3;
        ELSIF rising_edge(clk) THEN
            IF enable = '1' THEN
                first_none_zero_idx <= 3;
                FOR i IN N-1 DOWNTO 4 LOOP
                    IF q(i*4-1 DOWNTO i*4-4) /= "0000" THEN
                        first_none_zero_idx <= i;
                        EXIT;
                    END IF;
                END LOOP;
                done <= '1';
            ELSE
                first_none_zero_idx <= 3;
                done <= '0';
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;