--------------------------------------------------------------------------------
-- lab VHDL
-- simple frequency meter fsm, reset asynchro
--------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY f_meter_fsm IS
    PORT (
        clk, reset, time_base_pulse, count_end_pulse : IN STD_LOGIC;
        memory_en : OUT STD_LOGIC;
        time_base_rst : OUT STD_LOGIC;
        time_base_on : OUT STD_LOGIC;
        count_on : OUT STD_LOGIC
        );
END ENTITY;

ARCHITECTURE behav OF f_meter_fsm IS
    TYPE state_type IS (IDLE, BASE_ON, BASE_OFF, MEM_WRITE, COUNT, CLEAR);
    SIGNAL c_state, n_state : state_type;
BEGIN

    proc_fsm : PROCESS (c_state, time_base_pulse, count_end_pulse) BEGIN
        time_base_rst <= '0';
        time_base_on <= '0';
        memory_en <= '0';
        count_on <= '0';

        CASE c_state IS
            WHEN IDLE =>
                n_state <= BASE_ON;
            WHEN BASE_ON =>
                IF time_base_pulse = '1' THEN
                    n_state <= BASE_OFF;
                ELSE
                    n_state <= BASE_ON;
                END IF;
                time_base_on <= '1';
            WHEN BASE_OFF =>
                n_state <= MEM_WRITE;
            WHEN MEM_WRITE =>
                n_state <= COUNT;
                memory_en <= '1';
            WHEN COUNT =>
                IF count_end_pulse = '1' THEN
                    n_state <= CLEAR;
                ELSE
                    n_state <= COUNT;
                END IF;
                count_on <= '1';
            WHEN CLEAR =>
                n_state <= BASE_ON;
                time_base_rst <= '1';
                count_on <= '0';
        END CASE;
    END PROCESS;

    proc_memory : PROCESS (clk, reset)
    BEGIN
        IF (reset = '1') THEN
            c_state <= IDLE;
        ELSIF rising_edge(clk) THEN
            c_state <= n_state;
        END IF;
    END PROCESS;

END behav;