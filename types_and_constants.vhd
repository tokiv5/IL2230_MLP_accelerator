library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.ceil;
use ieee.math_real.log2;

package types_and_constants is

  constant FILTER_TAPS   : integer                          := 8;
  constant SAMPLE_WIDTH  : integer                          := 8;
  constant LAYER         : integer                          := 2;
  constant ADDRESS_WIDTH : integer                          := integer(ceil(log2(real(FILTER_TAPS))));
  constant LAYER_WIDTH   : integer                          := integer(ceil(log2(real(LAYER))));
  constant MAX_TAP       : signed(ADDRESS_WIDTH-1 downto 0) := to_signed(FILTER_TAPS-1, ADDRESS_WIDTH);
  constant RESULT_WIDTH  : integer                          := (2 * SAMPLE_WIDTH) + integer(ceil(log2(real(FILTER_TAPS))));

  type sample_file is array (FILTER_TAPS-1 downto 0) of signed (SAMPLE_WIDTH-1 downto 0);
  type all_sample_layer is array(LAYER-1 downto 0) of sample_file;
  type coeff_file  is array (FILTER_TAPS-1 downto 0) of signed (SAMPLE_WIDTH-1 downto 0);
  type coeff_layer is array (FILTER_TAPS-1 downto 0) of coeff_file;
  type coeff_MLP is array (LAYER-2 downto 0) of coeff_layer;
  type result_type is array (FILTER_TAPS downto 0) of signed (RESULT_WIDTH-1  downto 0);
end package;
