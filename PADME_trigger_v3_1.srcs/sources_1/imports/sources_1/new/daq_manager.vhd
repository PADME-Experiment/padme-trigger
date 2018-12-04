library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity daq_manager is
generic(
  Nbusy                  : integer;
  Nbusy_counter          : integer;
  Nrun_window            : integer
);
port(
  clk                    : in  std_logic;
  rst                    : in  std_logic;
  start_of_run_in        : in  std_logic;
  stop_of_run_in         : in  std_logic;
  fifo_rst_out           : out std_logic;
  fifo_is_rst_in         : in  std_logic;
  busy_in                : in  std_logic_vector (Nbusy-1 downto 0);
  busy_counter_rst_in    : in  std_logic_vector (Nbusy-1 downto 0);
  run_width_in           : in  std_logic_vector (Nrun_window-1 downto 0);
  run_delay_in           : in  std_logic_vector (Nrun_window-1 downto 0);
  run_out                : out std_logic;
--  veto_out               : out std_logic;
  busy_out               : out std_logic;
  busy_counter_out       : out std_logic_vector (Nbusy_counter*Nbusy-1 downto 0)
);
end entity daq_manager;

architecture rtl of daq_manager is

----
-- Functions
----
function or_reduce(x : std_logic_vector) return std_logic is
  variable r : std_logic := '0';
begin
  for i in x'range loop
    r := r or x(i);
  end loop;
  return r;
end or_reduce;

----
-- Component Dec
----
component window_generator is
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
end component window_generator;

component counter is
generic(
  N_counter              : integer
);
port(
  clk                    : in  std_logic;
  rst                    : in  std_logic;
  input                  : in  std_logic;
  count_out              : out std_logic_vector (N_counter-1 downto 0)
);
end component counter;

----
-- Signals
----
signal busy              : std_logic;
signal window            : std_logic;
signal window_rst        : std_logic;
signal counter_rst       : std_logic_vector(Nbusy-1 downto 0);

-- fifo rst
signal rst_fifo_v      : std_logic_vector(3 downto 0);
signal wait_ff_rst     : std_logic;
signal start_of_run_int: std_logic;

begin

-- FIFO RESET BEFORE START OF RUN
s_proc: process(clk) is
begin
if clk'event and clk='1' then
  if rst = '1' then
    rst_fifo_v  <= (others => '0');
    wait_ff_rst <= '0';
    start_of_run_int <= '0';
  else
    rst_fifo_v  <= rst_fifo_v(rst_fifo_v'high downto 1) & start_of_run_in;
    wait_ff_rst <= start_of_run_in;
    start_of_run_int <= '0';
    if wait_ff_rst='1' then
      wait_ff_rst <= fifo_is_rst_in;
      start_of_run_int <= not fifo_is_rst_in;
    end if;
  end if;
end if;
end process;
fifo_rst_out <= or_reduce(rst_fifo_v);


window_rst <= rst or stop_of_run_in;
window_generator_i: window_generator
generic map(
  Nrun_window            => Nrun_window
)
port map(
  clk                    => clk,
  rst                    => window_rst,
  width_in               => run_width_in,
  delay_in               => run_delay_in,
  start_in               => start_of_run_int,
  window_out             => window
);

counter_gen: for i in 0 to Nbusy-1 generate
counter_i_x: counter
generic map(
  N_counter              => Nbusy_counter
)
port map(
  clk                    => clk,
  rst                    => counter_rst(i),
  input                  => busy_in(i),
  count_out              => busy_counter_out(Nbusy_counter*(i+1)-1 downto Nbusy_counter*i)
);
counter_rst(i) <= busy_counter_rst_in(i) or rst;
end generate;

busy <= or_reduce( busy_in );

busy_out <= busy;
--veto_out <= busy or not window;
--veto_out <= busy;
run_out <= window;


end architecture rtl;