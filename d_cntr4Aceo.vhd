--------------------------------------------------------------------------------
-- lab VHDL
-- decimal counter, rst asynchro
--------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY d_cntr4Aceo IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        ce : IN STD_LOGIC;
        tc : OUT STD_LOGIC;
        ceo : OUT STD_LOGIC;
        q : OUT STD_LOGIC_VECTOR(3 DOWNTO 0));
END ENTITY d_cntr4Aceo;

ARCHITECTURE behav OF d_cntr4Aceo IS
    SIGNAL q_tmp : STD_LOGIC_VECTOR(q'RANGE) := x"0";
    SIGNAL tci : STD_LOGIC;
BEGIN
    PROCESS (clk, rst) BEGIN
        IF rst = '1' THEN
            q_tmp <= x"0";
        ELSIF rising_edge(clk) THEN
            IF ce = '1' THEN
                IF tci = '1' THEN
                    q_tmp <= x"0";
                ELSE
                    q_tmp <= q_tmp + 1;
                END IF;
            END IF;
        END IF;
    END PROCESS;
    -- outputs
    tci <= '1' WHEN (q_tmp = 9) ELSE
        '0';
    ceo <= (tci AND ce);
    tc <= tci;
    q <= q_tmp;
END ARCHITECTURE behav;