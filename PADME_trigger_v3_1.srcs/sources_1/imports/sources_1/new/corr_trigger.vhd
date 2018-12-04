library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity corr_trigger is
generic (
  Nwidth_in              : integer
);
port (
  rst                    : in  std_logic;
  clk                    : in  std_logic;
  enable_in              : in  std_logic;
  trig_in                : in  std_logic;
  delay_in               : in  std_logic_vector (Nwidth_in - 1 downto 0);
  trig_out               : out std_logic
);
end corr_trigger;

architecture behave of corr_trigger is

constant Nc_1us          : integer := 7;
constant c_1us           : std_logic_vector (Nc_1us-1 downto 0) := "101" & x"0"; 
constant zeros           : std_logic_vector (Nc_1us+Nwidth_in - 1 downto 0) := (others=>'0'); 
signal   count           : std_logic_vector (Nc_1us+Nwidth_in - 1 downto 0) := (others=>'0'); 
signal   run             : std_logic;
signal   delay           : std_logic_vector (Nc_1us+Nwidth_in-1 downto 0) := (others=>'0'); 

begin

timer_pr: process (clk) is
begin
if clk'event and clk='1' then
  if (rst = '1') or (enable_in/='1') then
    delay <= (others => '0');
    count <= zeros;
    run   <= '0';
    trig_out <= '0';
  else
    delay <= delay_in * c_1us-1;
    trig_out <= '0';
    if run = '0' then
      run <= trig_in;
      count <= zeros+1;
    else
      count <= count+1;
      if count = delay then
        run <= trig_in;
        count <= zeros;
        trig_out <= '1';
      end if;
    end if;
  end if;
end if;
end process;

end architecture;