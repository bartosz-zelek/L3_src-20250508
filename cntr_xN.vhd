--------------------------------------------------------------------------------
-- lab VHDL
-- x stage decimal counter, async reset, generate for
--------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY cntr_xN IS
    GENERIC (N : NATURAL := 6);
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        ce : IN STD_LOGIC;
        ceo : OUT STD_LOGIC;
        q : OUT STD_LOGIC_VECTOR(4 * N - 1 DOWNTO 0)
    );
END ENTITY cntr_xN;

ARCHITECTURE struct OF cntr_xN IS
    SIGNAL cei : STD_LOGIC_VECTOR(N DOWNTO 0);
BEGIN
    cei(0) <= ce;
    ceo <= cei(N);
    gen : FOR i IN 1 TO N GENERATE
        cntr : ENTITY work.d_cntr4Aceo
            PORT MAP(clk, rst, cei(i - 1), OPEN, cei(i), q((i * 4) - 1 DOWNTO (i - 1) * 4));
    END GENERATE;

END ARCHITECTURE struct;