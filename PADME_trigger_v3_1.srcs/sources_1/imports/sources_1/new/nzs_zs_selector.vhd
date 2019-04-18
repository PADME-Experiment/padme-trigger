library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;


entity nzs_zs_selector is
generic(
  Ndownscale_factor    : integer
);
port(
  rst                     : in  std_logic;
  clk                     : in  std_logic;
  nzs_downscale_factor_in : in  std_logic_vector(Ndownscale_factor-1 downto 0);
  data_in                 : in  std_logic;
  zs_out                  : out std_logic;
  nzs_out                 : out std_logic
);
end entity;


architecture behav of nzs_zs_selector is

constant  ones     : std_logic_vector(Ndownscale_factor-1 downto 0) := (others => '1');
constant  zeros    : std_logic_vector(Ndownscale_factor-1 downto 0) := (others => '0');

signal nzs_downscale_factor_r : std_logic_vector(Ndownscale_factor-1 downto 0);
signal count       : std_logic_vector(Ndownscale_factor-1 downto 0);
signal count_reg   : std_logic_vector(Ndownscale_factor-1 downto 0);

begin

timer_pr: process (clk) is
begin
if clk'event and clk='1' then
  if rst = '1' then
    count_reg   <= (others => '0');
    nzs_downscale_factor_r   <= (others => '0');
  else
    nzs_downscale_factor_r <= nzs_downscale_factor_in;
    -- Reg
    count_reg   <= count;
    -- Preventing wrap around
    --if count=ones then
    --  count_reg <= count_reg;
    --end if;
    -- Reset Counter
    if count = nzs_downscale_factor_r then
      count_reg <= (others => '0');
    end if;
    if nzs_downscale_factor_in /= nzs_downscale_factor_r then
      count_reg <= (others => '0');
    end if;
  end if;
end if;
end process;
count <= ones when nzs_downscale_factor_in=zeros else count_reg + data_in;

-- v3_3, added delay for timing
--nzs_out  <= data_in      when count  = nzs_downscale_factor_r else '0';
--zs_out   <= data_in      when count /= nzs_downscale_factor_r else '0';
out_pr: process (clk) is
begin
if clk'event and clk='1' then
  if rst = '1' then
    nzs_out   <= '0';
    zs_out    <= '0';
  else
    nzs_out   <= '0';
    zs_out    <= '0';
    if count  = nzs_downscale_factor_r then
      zs_out <= data_in;
    end if;
    if count /= nzs_downscale_factor_r then
      zs_out <= data_in;
    end if;
  end if;
end if;
end process;


end architecture behav;