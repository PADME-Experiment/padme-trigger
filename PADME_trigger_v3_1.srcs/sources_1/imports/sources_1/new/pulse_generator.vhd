library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity pulse_generator is
generic (
  Nwidth_in              : integer
);
port (
  rst                    : in  std_logic;
  clk                    : in  std_logic;
  enable_in              : in  std_logic;
  pulse_out              : out std_logic;
  delay_in               : in  std_logic_vector (Nwidth_in - 1 downto 0)
);
end pulse_generator;

architecture behave of pulse_generator is

constant zeros           : std_logic_vector (Nwidth_in - 1 downto 0) := (others=>'0');
signal   count           : std_logic_vector (Nwidth_in - 1 downto 0) := (others=>'0');
signal   delay           : std_logic_vector (Nwidth_in - 1 downto 0) := (others=>'0');

begin

timer_pr: process (clk) is
begin
if clk'event and clk='1' then
  if (rst = '1') or (enable_in/='1') then
    count <= zeros;
    pulse_out <= '0';
    delay <= delay_in;
  else
    pulse_out <= '0';
    count <= count + '1';
    if count = delay then
        count <= zeros;
        delay <= delay_in;
        pulse_out <= '1';
    end if;
  end if;
end if;
end process;

end architecture;