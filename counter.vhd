library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clock_div_counter is
    generic (
        WIDTH : integer := 24  -- Counter width determines division ratio
    );
    port (
        clk  : in  std_logic;      -- Input clock
        tick : out std_logic       -- Output clock pulse (MSB of counter)
    );
end entity;

architecture Behavioral of clock_div_counter is
    signal count : unsigned(WIDTH - 1 downto 0) := (others => '0');
begin

    process(clk)
    begin
        if rising_edge(clk) then
            count <= count + 1;
        end if;
    end process;

    tick <= count(WIDTH - 1);  -- MSB toggles every 2^(WIDTH-1) input clock cycles

end architecture;
