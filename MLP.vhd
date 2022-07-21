library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use IEEE.std_logic_arith.all;
use work.types_and_constants.all;

entity MLP is
    port (
    --! clock signal
    clk          : in  std_logic;
    --! asyncronous active low reset
    nrst         : in  std_logic;
    --! new sample flag
    new_sample   : in  std_logic;
    --! new sample
    sample_in    : in  signed (SAMPLE_WIDTH-1 downto 0);
    --! output of the FIR filter
    -- output : out signed(RESULT_WIDTH-1 downto 0);
    output       : out sample_file;
    --! output ready flag
    output_ready : out std_logic);
end MLP;

architecture behave of MLP is

    signal new_sample_neuron, output_ready_tmp, input_prop: std_logic;
    signal input_samples, output_samples, first_samples: sample_file;
    signal output_readys: std_logic_vector(FILTER_TAPS-1 downto 0);
    -- signal layer_samples: all_sample_layer;
    signal layer_coeff: coeff_layer; -- all coefficients needed for a layer N*N
    signal all_coeff: coeff_MLP; -- all coefficients of all layers
    signal layer_address: integer range 0 to LAYER-2; -- which layer is working

begin
input_process : process(clk, nrst)
begin
    if nrst='0' then
        input_samples <= first_samples;
    elsif rising_edge(clk) then
        if input_prop='0' then
            input_samples <= first_samples;
        else
            if output_readys(0)='1' then
                input_samples <= output_samples;
            end if ;
        end if ;  
    end if ;
end process ; -- input_process
-- input_samples <= first_samples when input_prop='0'
--                 else output_samples;
layer_coeff <= all_coeff(layer_address);

R0 : entity work.rom_coefficients
port map(
    coeff_out => all_coeff
);

S0: entity work.shift_register
port map(
    clk => clk,
    nrst => nrst,
    new_sample => new_sample,
    sample_in => sample_in,
    all_samples => first_samples
);

F0: entity work.MLP_FSM
port map(
    clk => clk,
    nrst => nrst,
    new_sample => new_sample,
    output_ready => output_ready_tmp,
    new_sample_neuron => new_sample_neuron,
    input_prop => input_prop,
    layer_address => layer_address
);

G0 : for i in 0 to FILTER_TAPS-1 generate
    NEURON_1: entity work.parallel_fir
    port map(
        clk => clk,
        nrst => nrst,
        new_sample => new_sample_neuron,
        all_samples => input_samples, -- all_sample from layers
        all_coeffs => layer_coeff(i),
        output => output_samples(i),
        output_ready => output_readys(i)
    );
end generate ; -- identifier

output_ready <= output_ready_tmp;
output <= output_samples when output_ready_tmp = '1' else (others => (others => '0'));

end behave ; -- behave