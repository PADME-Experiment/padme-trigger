-- Shaper has been removed and replaced by registers.
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity shaper is
generic(
  Ndata                  : integer;
  Nwidth                 : integer
);
port(
  clk                    : in  std_logic;
  rst                    : in  std_logic;
  input                  : in  std_logic_vector (Ndata-1 downto 0);
  width_in               : in  std_logic_vector (Nwidth-1 downto 0);
  output                 : out std_logic_vector (Ndata-1 downto 0)
);
end entity shaper;

architecture rtl of shaper is

----
-- Type
----
type sample_t           is array(2**Nwidth+1 downto 0) of std_logic_vector (Ndata-1 downto 0);
----
-- Signals
----
signal sampled_in       : sample_t := (others => (others => '0'));
signal async_rst        : std_logic_vector(Ndata-1 downto 0);

begin

--samp_pr: process (clk) is
--begin
--if clk'event and clk='1' then
--  if rst = '1' then
--    sampled_in <= (others => (others => '0'));
--  else
--    sampled_in <= sampled_in(sampled_in'range)(2**Nwidth-2 downto 0) & input;
--  end if;
--end if;
--end process;

edg_gen: for i in 0 to Ndata-1 generate
edge_pr: process (all) is
begin

  if async_rst(i)='1' then
    sampled_in(0)(i) <= '0';
  elsif input(i)'event and input(i)='1' then
    sampled_in(0)(i) <= '1';
  end if;
end process;
end generate;

s_pr: process(clk) is
begin
if clk'event and clk='1' then
  if rst = '1' then
    sampled_in(sampled_in'high downto 1) <= (others => (others => '0'));
  else
    sampled_in(sampled_in'high downto 1) <= sampled_in(sampled_in'high-1 downto 0);
  end if;
end if;
end process;
async_rst <= sampled_in(conv_integer(unsigned(width_in))+1);

output <= sampled_in(conv_integer(unsigned(width_in))+1) and not sampled_in(conv_integer(unsigned(width_in))+2);
  

end architecture rtl;
