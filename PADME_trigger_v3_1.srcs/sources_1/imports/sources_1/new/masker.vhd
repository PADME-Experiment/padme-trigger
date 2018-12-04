library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity masker is
generic(
  Ndata                  : integer
);
port(
  input                  : in  std_logic_vector (Ndata-1 downto 0);
  mask_in                : in  std_logic_vector (Ndata-1 downto 0);
  veto_in                : in  std_logic_vector (Ndata-1 downto 0);
  output                 : out std_logic_vector (Ndata-1 downto 0)
);
end entity masker;

architecture rtl of masker is

begin

output <= input and mask_in and not veto_in;

end architecture rtl;