library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;


entity counter is
generic(
  N_counter              : integer
);
port(
  clk                    : in  std_logic;
  rst                    : in  std_logic;
  input                  : in  std_logic;
  count_out              : out std_logic_vector (N_counter-1 downto 0)
);
end entity counter;

architecture behav of counter is

----
-- Signals
----
signal count             : std_logic_vector (N_counter-1 downto 0);

begin

cnt_pr: process ( clk ) is
begin
  if clk'event and clk='1' then
    if rst = '1' then
      count <= (others => '0');
    else
      count <= count + input;
    end if;
  end if;
end process;

count_out <= count;

end architecture behav;