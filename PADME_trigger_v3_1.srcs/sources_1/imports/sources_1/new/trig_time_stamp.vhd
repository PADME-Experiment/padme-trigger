library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity trig_time_stamp is
generic(
  Ntrig_in               : integer;
  Ntrig_out              : integer
);
port(
  rst                    : in  std_logic;
  clk                    : in  std_logic;
  trig_in                : in  std_logic_vector (Ntrig_out-1 downto 0);
  trig_vector_in         : in  std_logic_vector (Ntrig_in-1 downto 0);
  trig_type              : in  std_logic;
  time_stamp_out         : out std_logic_vector (63 downto 0);
  time_stamp_v_out       : out std_logic
);
end entity trig_time_stamp;

architecture behav of trig_time_stamp is

----
-- Signals
----
signal counter            : std_logic_vector (39 downto 0) := (others => '0');
signal trig_in_reg        : std_logic_vector (Ntrig_out-1 downto 0);
signal trig_vect_reg      : std_logic_vector (Ntrig_in-1 downto 0);
signal time_stamp_valid   : std_logic;
signal trig_num           : std_logic_vector  (55 -40 -Ntrig_in downto 0);

begin

time_stamp_pr: process (clk) is
begin
if clk'event and clk='1' then
  if rst = '1' then
    counter <= (others => '0');
    trig_in_reg <= (others => '0');
    trig_vect_reg <= (others => '0');
    time_stamp_valid <= '0';
    trig_num <= (others => '0');
  else
    counter <= counter + 1;
    trig_in_reg <= trig_in;
    trig_vect_reg <= trig_vector_in;
    time_stamp_valid <= '0';
    trig_num <= trig_num;
    if trig_in(0)= '1' and trig_in_reg(0)='0' then -- all trig in are identical in this case; split otherwise.
      time_stamp_valid <= '1';
      trig_num <= trig_num + 1;
    end if;
  end if;
end if;
end process;

time_stamp_v_out                        <= time_stamp_valid;
time_stamp_out(39 downto  0)            <= counter       when time_stamp_valid = '1' else (others => '0');
time_stamp_out(40+Ntrig_in-1 downto 40) <= trig_vect_reg when time_stamp_valid = '1' else (others => '0');
time_stamp_out(55 downto 40+Ntrig_in)   <= trig_num;
time_stamp_out(56)                      <= '0';
time_stamp_out(57)                      <= trig_type;
time_stamp_out(time_stamp_out'high downto 58) <= (others => '0');
time_stamp_out(time_stamp_out'high downto 58) <= (others => '0');

end architecture behav;