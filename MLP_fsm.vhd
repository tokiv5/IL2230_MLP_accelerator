library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_signed.all;
use work.types_and_constants.all;

entity MLP_FSM is
    port (
      clk          : in  std_logic;
      nrst         : in  std_logic;
      new_sample   : in  std_logic;
      output_ready, new_sample_neuron, input_prop : out std_logic;
      layer_address: out integer range 0 to LAYER-2
      ); 
      -- new_sample_neuron controls neurons output or not, input_prop decide which one will be input, 0 for shift_register, 1 for last output
end MLP_FSM;

architecture behave of MLP_FSM is
    type state_type is (IDLE, SHIFT, PROP, READY);
    signal pres_state, next_state: state_type;
    signal shift_counter: integer range 0 to FILTER_TAPS - 1;
    signal prop_counter: integer range 0 to LAYER+LAYER-3;
    signal layer_address_tmp: integer range 0 to LAYER-2;
    signal isIncrement: std_logic; -- Since each layer need two clock cycles, layer address is half of prop_counter
begin

    SHIFT_CONTROLLER : process(clk, nrst)
    begin
        if nrst='0' then
            shift_counter <= 0;
        elsif rising_edge(clk) then
            if pres_state=SHIFT then
                if shift_counter=FILTER_TAPS-1 then
                    shift_counter <= 0;
                else
                    shift_counter <= shift_counter + 1;
                end if ;
            else
                shift_counter <= 0; 
            end if ;
        end if ;
    end process ; -- SHIFT_CONTROLLER

    layer_address <= layer_address_tmp;

    PROP_CONTROLLER : process(clk, nrst)
    begin
        if nrst='0' then
            prop_counter <= 0;
            layer_address_tmp <= 0;
            isIncrement <= '0';
        elsif rising_edge(clk) then
            if pres_state=PROP then
                if prop_counter=LAYER+LAYER-3 then
                    prop_counter <= 0;
                    layer_address_tmp <= 0;
                    isIncrement <= '0';
                else
                    prop_counter <= prop_counter + 1;
                    if isIncrement = '1' then
                        layer_address_tmp <= layer_address_tmp + 1;
                    end if ;
                    isIncrement <= not(isIncrement);
                    
                end if ;
            else
                prop_counter <= 0; 
                layer_address_tmp <= 0;
                isIncrement <= '0';
            end if ;
        end if ;
    end process; --PROP_CONTROLLER

    StateProcess : process(clk, nrst)
    begin
        if nrst = '0' then
            pres_state <= IDLE;
        elsif rising_edge(clk) then
            pres_state <= next_state;
        end if ;
    end process ; -- StateProcess

    process(pres_state, new_sample, shift_counter, prop_counter)
    begin
        next_state <= pres_state;
        output_ready <= '0';
        case(pres_state) is
            when IDLE =>
                input_prop <= '0';
                new_sample_neuron <= '0';
                if new_sample = '1' then
                    next_state <= SHIFT;
                end if ;
            when SHIFT =>
                input_prop <= '0';
                if shift_counter=FILTER_TAPS-1 then
                    --new_sample_neuron <= '1';
                    next_state <= PROP;
                else
                    new_sample_neuron <= '0';
                end if ;
            when PROP =>
                if prop_counter=0 then
                    input_prop <= '0';
                else
                    input_prop <= '1';
                end if ;
                -- input_prop <= '1';
                new_sample_neuron <= '1';
                if prop_counter=LAYER+LAYER-4 then -- Each layer need two clk cyles for ready --> idle, so prop_counter <= 2*(Layer-1)-1. Set ready a cycle advance
                    next_state <= READY;
                end if ;
            when READY =>
                input_prop <= '0';
                new_sample_neuron <= '0';
                output_ready <= '1';
                next_state <= IDLE;
        end case;
    end process;
end behave ; -- behave