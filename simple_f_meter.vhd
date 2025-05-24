--------------------------------------------------------------------------------
-- lab VHDL
-- simple frequency meter
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;  -- added for to_integer/unsigned

entity simple_f_meter is
    port (
        clk_10M : in std_logic;
        rst : in std_logic;
        f_in : in std_logic;
        q : out std_logic_vector(39 downto 0);
        first_none_zero_idx : out natural;
        dot_pos :  out natural;
        symbol :  out natural
    );
end entity simple_f_meter;

architecture struct of simple_f_meter is
    signal time_base_rst, time_base_on, count_end_pulse, count_on : std_logic;
    signal freq_counter_full : std_logic;
    signal time_base_pulse, memory_en : std_logic;
    signal q_cntr : std_logic_vector(q'range);
    signal first_none_zero_idx_tmp : natural range 3 to q'length/4-1;  -- use natural to match measure_range_count output
    type int_arr_3_to_10 is array(3 to 10) of integer;

    subtype idx_range_t is natural range 3 to 10;
    type lookup_t is array(idx_range_t) of natural;
    constant symbol_map : lookup_t := (
        3 => 0, 4 => 1, 5 => 1, 6 => 1,
        7 => 2, 8 => 2, 9 => 2, 10 => 2
    );
    constant dot_pos_map : lookup_t := (
        3 => 0, 4 => 3, 5 => 2, 6 => 1,
        7 => 3, 8 => 2, 9 => 1, 10 => 0
    );
    constant first_idx_map : lookup_t := (
        3 => 3, 4 => 3, 5 => 4, 6 => 5,
        7 => 6, 8 => 7, 9 => 8, 10 => 9
    );
begin

    time_base_counter: entity work.cntr_xN
    generic map(8)
    port map(clk_10M,time_base_rst,time_base_on,time_base_pulse,open);

    freq_counter: entity work.cntr_xN
    generic map(q'length/4)
    port map(f_in,time_base_rst,time_base_on,freq_counter_full,q_cntr );

    range_counter: entity work.measure_range_count
    generic map(q'length/4)
    port map(q_cntr, clk_10M, rst, count_on, count_end_pulse,
    first_none_zero_idx_tmp);

    simple_fsm: entity work.f_meter_fsm
    port map(clk_10M, rst, time_base_pulse, count_end_pulse,
        memory_en, time_base_rst, time_base_on, count_on);

    memory: process(clk_10M, memory_en)
    begin
        if rising_edge(clk_10M) then
            if memory_en = '1' then
                q <= q_cntr;
            end if;
            if count_end_pulse = '1' then
                -- use natural index directly for lookup
                first_none_zero_idx <= first_idx_map(first_none_zero_idx_tmp);
                dot_pos            <= dot_pos_map(first_none_zero_idx_tmp);
                symbol             <= symbol_map(first_none_zero_idx_tmp);
            end if;
        end if;
    end process;

end architecture struct;