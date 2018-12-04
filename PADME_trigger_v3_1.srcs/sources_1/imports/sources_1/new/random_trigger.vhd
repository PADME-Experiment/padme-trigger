library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity random_trigger is
generic (
  Nperiodicity           : integer
);
port (
  rst                    : in  std_logic;
  clk                    : in  std_logic;
  pulse102_4us_in        : in  std_logic; -- 102.4 us pulse
  enable_in              : in  std_logic;
  periodicity_in         : in  std_logic_vector (Nperiodicity-1 downto 0);
  trigger_out            : out std_logic
);
end entity random_trigger;

architecture behavioral of random_trigger is

signal count            : std_logic_vector(Nperiodicity-1 downto 0);
signal compare_res      : std_logic;

begin

ms_counter_pr: process (clk) is
begin
if clk'event and clk='1' then
  if (rst = '1') or (enable_in/='1') then
    count <= (others => '0');
    trigger_out <= '0';
  else
    count <= count+pulse102_4us_in;
    trigger_out <= '0';
    if (compare_res = '1') then
      count <= (others => '0');
      trigger_out <= '1';
    end if;
  end if;
end if;
end process;

compare_res <= '1'      when count = periodicity_in else '0';

end architecture behavioral;