--------------------------------------------------------------------------------
-- lab VHDL
-- simple frequency meter
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

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
    signal first_none_zero_idx_tmp : natural;
    type int_arr_3_to_10 is array(3 to 10) of integer;
begin

    time_base_counter: entity work.cntr_xN
    generic map(7)
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

    memory: process(clk_10M) 
    VARIABLE symbol_map : int_arr_3_to_10 := (
        3 => 0, 4 => 1, 5 => 1, 6 => 1,
        7 => 2, 8 => 2, 9 => 2, 10 => 2
    ); -- 0 -> Hz, 1 -> kHz, 2 -> MHz
    VARIABLE dot_pos_map : int_arr_3_to_10 := (
        3 => 0, 4 => 3, 5 => 2, 6 => 1,
        7 => 3, 8 => 2, 9 => 1, 10 => 0
    );
    begin
        if rising_edge(clk_10M) and memory_en='1' then
            q <= q_cntr;
        end if;
        if rising_edge(clk_10M) then
            if count_end_pulse = '1' then
                if symbol_map(first_none_zero_idx_tmp) /= 0 then
                    first_none_zero_idx <= first_none_zero_idx_tmp-1;
                else
                    first_none_zero_idx <= first_none_zero_idx_tmp;
                end if;
                dot_pos <= dot_pos_map(first_none_zero_idx_tmp);
                symbol <= symbol_map(first_none_zero_idx_tmp);
            end if;
        end if;
    end process;

end architecture struct;