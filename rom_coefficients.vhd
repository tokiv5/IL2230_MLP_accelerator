library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use work.types_and_constants.all;

-- The rom_coefficients entity simulates an asynchronous ROM that stores the
-- FIR coefficients. The coefficients are initialized in a "triangular" pattern.
-- You are free to change the coefficinets to any value but this pattern makes
-- it easy to verify the correct output when an impulse input is applied.
entity rom_coefficients is

  port (
    --! Coefficient output
    coeff_out  : out coeff_MLP);

end entity rom_coefficients;

architecture behavior of rom_coefficients is
  signal all_coeffs: coeff_file;
begin
  -- Permanently connect the coefficients to their value to emulate the ROM
  ROM: for i in 0 to FILTER_TAPS-1 generate
    I0: if i=0 generate
      all_coeffs(i) <= (others => '0');
    end generate ;
    I1: if i>0 generate
      all_coeffs(i) <= to_signed(2**(i-1), SAMPLE_WIDTH);
    end generate;
  end generate ;
      
  -- Select the coefficient position specified in coeff_addr
  -- coeff_out <= all_coeffs(conv_integer(unsigned(coeff_addr)));
  coeff_out <= (others => (others => all_coeffs));
  
end architecture behavior;
