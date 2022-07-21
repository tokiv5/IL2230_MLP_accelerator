library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types_and_constants.all;

entity parallel_fir is

  port (
    --! clock signal
    clk          : in  std_logic;
    --! asyncronous active low reset
    nrst         : in  std_logic;
    --! new sample flag
    new_sample   : in  std_logic;
    all_samples  : in  sample_file;
    all_coeffs   : in  coeff_file;
    --! new sample
    -- sample_in    : in  signed(SAMPLE_WIDTH-1 downto 0);
    --! output of the FIR filter
    -- output : out signed(RESULT_WIDTH-1 downto 0);
    output       : out signed(SAMPLE_WIDTH-1 downto 0);
    --! output ready flag
    output_ready : out std_logic);

end entity parallel_fir;

architecture structure of parallel_fir is

  -- signal all_coeffs       : coeff_file;
  -- signal all_samples      : sample_file;
  signal result           : signed (result_width-1 downto 0);
  signal sigmoid_result   : signed (result_width-3 downto 0);
  signal output_ready_tmp : std_logic;
  constant ALIGN_END: integer := (integer(ieee.math_real.ceil(ieee.math_real.log2(real(SAMPLE_WIDTH))))-2)*5;
begin  -- architecture structure
  -- Move rom_coefficients to the top module
  -- ROM_COEFFICIENTS_1 : entity work.rom_coefficients
  --   port map (
  --     coeff_out => all_coeffs);

  -- Move shift register to layer module
  -- SHIFT_REGISTER_1 : entity work.shift_register
  --   port map (
  --     clk         => clk,
  --     nrst        => nrst,
  --     new_sample  => new_sample,
  --     sample_in   => sample_in,
  --     all_samples => all_samples);

  FSM_1 : entity work.FSM
    port map (
      clk          => clk,
      nrst         => nrst,
      new_sample   => new_sample,
      output_ready => output_ready_tmp);

  ARITHMETIC_UNIT_1 : entity work.arithmetic_unit
    port map (
      all_samples      => all_samples,
      all_coefficients => all_coeffs,
      result           => result);

  -- OUT_REG : process (clk, nrst)
  -- begin
  --   if nrst = '0' then
  --     output <= (others => '0');
  --   elsif rising_edge(clk) then
  --     if output_ready_tmp = '1' then      
  --       -- Align, shorten, and use stimulation function 
  --       -- ! Sigmoid
  --       -- if SAMPLE_WIDTH = 8 then
  --       --     if (signed(result(result_width-1 downto 10)) > 4 ) then
  --       --         Y <= "00100000";
  --       --     elsif (signed(result(result_width-1 downto 10)) <-4 ) then
  --       --         Y <= (others => '0');
  --       --     else
  --       --         sigmoid_result <= result(RESULT_WIDTH-1 downto 2) + 512;
  --       --         Y <= result(RESULT_WIDTH-1) & sigmoid_result(11 downto 5);
  --       --     end if;
  --       -- end if;
  --       -- ! ReLU
  --       if result(RESULT_WIDTH-1) = '0' then
  --         output <= result(RESULT_WIDTH-1) & result(ALIGN_END+SAMPLE_WIDTH-2 downto ALIGN_END);
  --       else
  --         output <= (others => '0');
  --       end if;
  --     else
  --       output <= (others => '0');
  --     end if;
  --   end if;
  -- end process;
  output <= result(RESULT_WIDTH-1) & result(ALIGN_END+SAMPLE_WIDTH-2 downto ALIGN_END) when output_ready_tmp = '1' and result(RESULT_WIDTH-1) = '0'
          else (others => '0');
  output_ready <= output_ready_tmp;

end architecture structure;
