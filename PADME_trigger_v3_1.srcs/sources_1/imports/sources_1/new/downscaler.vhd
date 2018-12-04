-- downscale_factor_in: 
--       0: output disbled
--       1: bypass
--       N: output 1 over N

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity downscaler is
generic (
  Ndownscale_factor     : integer
);
port (
  rst                    : in  std_logic;
  clk                    : in  std_logic;
  downscale_factor_in    : in  std_logic_vector(Ndownscale_factor-1 downto 0);
  data_in                : in  std_logic;
  data_out               : out std_logic
);
end entity downscaler;

architecture behavioral of downscaler is

constant  ones     : std_logic_vector(Ndownscale_factor-1 downto 0) := (others => '1');
constant  zeros    : std_logic_vector(Ndownscale_factor-1 downto 0) := (others => '1');

signal downscale_factor_r : std_logic_vector(Ndownscale_factor-1 downto 0);
signal count       : std_logic_vector(Ndownscale_factor-1 downto 0);
signal count_reg   : std_logic_vector(Ndownscale_factor-1 downto 0);

begin

timer_pr: process (clk) is
begin
if clk'event and clk='1' then
  if rst = '1' then
    count_reg   <= (others => '0');
    downscale_factor_r   <= (others => '0');
  else
    -- Reg
    downscale_factor_r <= downscale_factor_in;
    count_reg   <= count;
    -- Preventing wrap around
    if count=ones then
      count_reg <= count_reg;
    end if;
    -- Reset Counter
    if count = downscale_factor_r then
      count_reg <= (others => '0');
    end if;
    if downscale_factor_in /= downscale_factor_r then
      count_reg <= (others => '0');
    end if;
  end if;
end if;
end process;
count <= count_reg + data_in;

data_out <= data_in      when count = downscale_factor_r else '0';

end architecture behavioral;