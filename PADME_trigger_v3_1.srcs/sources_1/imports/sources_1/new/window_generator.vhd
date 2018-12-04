library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity window_generator is
generic(
  Nrun_window            : integer
);
port(
  clk                    : in  std_logic;
  rst                    : in  std_logic;
  width_in               : in  std_logic_vector (Nrun_window-1 downto 0);
  delay_in               : in  std_logic_vector (Nrun_window-1 downto 0);
  start_in               : in  std_logic;
  window_out             : out std_logic
);
end entity window_generator;

architecture behav of window_generator is

function or_reduce(x : std_logic_vector) return std_logic is
  variable r : std_logic := '0';
begin
  for i in x'range loop
    r := r or x(i);
  end loop;
  return r;
end or_reduce;
----
-- Constants
----
constant uno             : std_logic_vector (Nrun_window-1 downto 0) := (0 => '1', others => '0');

----
-- Signals
----
signal count_d           : std_logic_vector (Nrun_window-1 downto 0) := uno;
signal count_w           : std_logic_vector (Nrun_window-1 downto 0) := (others => '0');
signal width_r           : std_logic_vector (Nrun_window-1 downto 0) := (others => '0');
signal window            : std_logic := '0';
signal window_r          : std_logic_vector (3-1 downto 0) := (others => '0');
signal start             : std_logic := '0';
signal start_reg         : std_logic := '0';

begin

window_pr: process (clk) is
begin
if clk'event and clk='1' then
  width_r  <= width_in;
  if rst = '1' then
    start_reg <= '0';
    count_d   <= uno;
    count_w   <= width_in;
    window    <= '0';
    window_r  <= (others=>'0');
  else
    window_r  <= window_r(window_r'high downto 1) & window;
    start_reg <= start_in;
    count_w <= count_w + 1;
    window <= window;
    -- Window Counter
    if count_w=width_r then
      count_w <= width_in;
      window <= '0';
    end if;
    -- Delay counter
    if count_d = uno then
      count_d <= uno;
      if start = '1' then
        count_d <= count_d + 1;
      end if;
    elsif count_d = delay_in then
      count_d <= uno;
      count_w <= (0 => '1', others => '0');
      window <= '1';
    else
      count_d <= count_d + 1;
    end if;
  end if;
end if;
end process;

start <= start_in and not start_reg;

window_out <= window or or_reduce(window_r);

end architecture behav;