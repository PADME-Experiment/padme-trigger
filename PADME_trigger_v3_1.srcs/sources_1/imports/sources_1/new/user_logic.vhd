library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity user_logic is
generic(
  fclock                 : integer := 80;
  Ntrig_in               : integer := 6;
  Ntrig_out              : integer := 3;
  Nshaper_width          : integer := 2;
  Nbusy_in               : integer := 4;
  Nbusy_out              : integer := 2;
  Nshutter_out           : integer := 2;
  S_AXI_DATA_WIDTH       : integer := 32;
  S_AXI_ADDR_WIDTH       : integer := 8;
  CR_N_REGISTER          : integer := 32;
  CR_N_RW_REGISTER       : integer := 15;
  CR_N_SC_REGISTER       : integer := 1;
  CR_N_FF_REGISTER       : integer := 2
);
port(
  clk                    : in  std_logic;
  clk_ps_1MHz_in         : in  std_logic;
  rst_in                 : in  std_logic;
  trig_in                : in  std_logic_vector (Ntrig_in-1 downto 0);
  sin_fb                 : in  std_logic;
  busy_in                : in  std_logic_vector (Nbusy_in-1 downto 0);
  trig_out               : out std_logic_vector (Ntrig_out-1 downto 0);
  busy_out               : out std_logic_vector (Nbusy_out-1 downto 0);
  shutter_out            : out std_logic_vector (Nshutter_out-1 downto 0);
  S_AXI_ACLK	           : in std_logic;
  S_AXI_ARESETN          : in std_logic;
  S_AXI_AWADDR           : in std_logic_vector (S_AXI_ADDR_WIDTH-1 downto 0);
  S_AXI_AWPROT           : in std_logic_vector (2 downto 0);
  S_AXI_AWVALID          : in std_logic;
  S_AXI_AWREADY          : out std_logic;
  S_AXI_WDATA            : in std_logic_vector (S_AXI_DATA_WIDTH-1 downto 0);
  S_AXI_WSTRB            : in std_logic_vector ((S_AXI_DATA_WIDTH/8)-1 downto 0);
  S_AXI_WVALID           : in std_logic;
  S_AXI_WREADY           : out std_logic;
  S_AXI_BRESP            : out std_logic_vector (1 downto 0);
  S_AXI_BVALID           : out std_logic;
  S_AXI_BREADY           : in std_logic;
  S_AXI_ARADDR           : in std_logic_vector (S_AXI_ADDR_WIDTH-1 downto 0);
  S_AXI_ARPROT           : in std_logic_vector (2 downto 0);
  S_AXI_ARVALID          : in std_logic;
  S_AXI_ARREADY          : out std_logic;
  S_AXI_RDATA            : out std_logic_vector (S_AXI_DATA_WIDTH-1 downto 0);
  S_AXI_RRESP            : out std_logic_vector (1 downto 0);
  S_AXI_RVALID           : out std_logic;
  S_AXI_RREADY           : in std_logic
);
end entity user_logic;


architecture rtl of user_logic is

----
-- Functions
----
function clog2( i : integer) return integer is
  variable t    : integer := i;
  variable r : integer := 0; 
begin         
  while t > 0 loop
    r := r + 1;
    t := t / 2;
  end loop;
  return r;
end function;

function or_reduce(x : std_logic_vector) return std_logic is
  variable r : std_logic := '0';
begin
  for i in x'range loop
    r := r or x(i);
  end loop;
  return r;
end or_reduce;

function and_reduce(x : std_logic_vector) return std_logic is
  variable r : std_logic := '1';
begin
  for i in x'range loop
    r := r and x(i);
  end loop;
  return r;
end and_reduce;

----
-- Component Dec
----
component shaper is
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
end component shaper;

component masker is
generic(
  Ndata                  : integer
);
port(
  input                  : in  std_logic_vector (Ndata-1 downto 0);
  mask_in                : in  std_logic_vector (Ndata-1 downto 0);
  veto_in                : in  std_logic_vector (Ndata-1 downto 0);
  output                 : out std_logic_vector (Ndata-1 downto 0)
);
end component masker;

component timer is
generic(
  Ncounter               : integer;
  Ntimeout               : integer
);
port(
  clk                    : in  std_logic;
  rst                    : in  std_logic;
  timer_count_in         : in  std_logic_vector (Ncounter-1 downto 0);
  timeout_count_in       : in  std_logic_vector (Ntimeout-1 downto 0);
  start_in               : in  std_logic;
  done_out               : out std_logic
);
end component timer;

--component trigger_logic is
--generic(
--  Ndata_in               : integer;
--  Ndata_out              : integer;
--  Nthreshold             : integer
--);
--port(
--  clk                    : in  std_logic;
--  rst                    : in  std_logic;
--  trig_in                : in  std_logic_vector(Ndata_in-1 downto 0);
--  veto_in                : in  std_logic;
--  threshold_in           : in  std_logic_vector(Nthreshold-1 downto 0);
--  trig_out               : out std_logic_vector(Ndata_out-1 downto 0)
--);
--end component trigger_logic;

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

component daq_manager is
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
  --veto_out               : out std_logic;
  busy_out               : out std_logic;
  busy_counter_out       : out std_logic_vector (Nbusy_counter*Nbusy-1 downto 0)
);
end component daq_manager;

component trig_time_stamp is
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
end component trig_time_stamp;

component fifo_generator_0
port(
  rst                    : in  std_logic;
  clk                    : in  std_logic;
  din                    : in  std_logic_vector(63 downto 0);
  wr_en                  : in  std_logic;
  rd_en                  : in  std_logic;
  dout                   : out std_logic_vector(63 downto 0);
  full                   : out std_logic;
  empty                  : out std_logic
);
end component fifo_generator_0;

component random_trigger is
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
end component random_trigger;

component corr_trigger is
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
end component corr_trigger;

component downscaler is
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
end component downscaler;

component nzs_zs_selector is
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
end component;

component nzs_zs_shaper is
generic(
  Nshape_factor           : integer;
  Ntrig_in                : integer;
  Ndead_time              : integer
);
port(
  rst                     : in  std_logic;
  clk                     : in  std_logic;
  zs_width                : in  std_logic_vector(Nshape_factor-1 downto 0);
  nzs_width               : in  std_logic_vector(Nshape_factor-1 downto 0);
  dead_time_width         : in  std_logic_vector(Ndead_time-1 downto 0);
  zs_in                   : in  std_logic_vector(Nshape_factor-1 downto 0);
  nzs_in                  : in  std_logic_vector(Nshape_factor-1 downto 0);
  trig_out                : out std_logic;
  trig_type               : out std_logic;
  trig_map                : out std_logic_vector(Ntrig_in-1 downto 0);
  veto_out                : out std_logic
);
end component;

component pulse_generator is
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
end component pulse_generator;

component axi4lite_reg is
generic(
  N_REGISTER             : integer;
  N_RW_REGISTER          : integer;
  N_SC_REGISTER          : integer;
  N_FF_REGISTER          : integer;
  S_AXI_DATA_WIDTH       : integer;
  S_AXI_ADDR_WIDTH       : integer -- AXI_ADDR_WIDTH>= (C_S_AXI_DATA_WIDTH/32) + log2(N_REGISTER) + 1
);
port(
  rw_def                 : in  std_logic_vector (S_AXI_DATA_WIDTH*N_RW_REGISTER-1 downto 0);
  rw_reg                 : out std_logic_vector (S_AXI_DATA_WIDTH*N_RW_REGISTER-1 downto 0);
  sc_reg                 : out std_logic_vector (S_AXI_DATA_WIDTH*N_SC_REGISTER-1 downto 0);
  ro_reg                 : in  std_logic_vector (S_AXI_DATA_WIDTH*(N_REGISTER-N_RW_REGISTER-N_SC_REGISTER-N_FF_REGISTER)-1 downto 0);
  ff_reg                 : in  std_logic_vector (S_AXI_DATA_WIDTH*N_FF_REGISTER-1 downto 0);
  ff_req                 : out std_logic_vector (N_FF_REGISTER-1 downto 0);
  S_AXI_ACLK	           : in  std_logic;
  S_AXI_ARESETN	         : in  std_logic;
  S_AXI_AWADDR	         : in  std_logic_vector (S_AXI_ADDR_WIDTH-1 downto 0);
  S_AXI_AWPROT	         : in  std_logic_vector (2 downto 0);
  S_AXI_AWVALID	         : in  std_logic;
  S_AXI_AWREADY	         : out std_logic;
  S_AXI_WDATA	           : in  std_logic_vector (S_AXI_DATA_WIDTH-1 downto 0);
  S_AXI_WSTRB	           : in  std_logic_vector ((S_AXI_DATA_WIDTH/8)-1 downto 0);
  S_AXI_WVALID	         : in  std_logic;
  S_AXI_WREADY	         : out std_logic;
  S_AXI_BRESP	           : out std_logic_vector (1 downto 0);
  S_AXI_BVALID	         : out std_logic;
  S_AXI_BREADY	         : in  std_logic;
  S_AXI_ARADDR	         : in  std_logic_vector (S_AXI_ADDR_WIDTH-1 downto 0);
  S_AXI_ARPROT	         : in  std_logic_vector (2 downto 0);
  S_AXI_ARVALID	         : in  std_logic;
  S_AXI_ARREADY	         : out std_logic;
  S_AXI_RDATA	           : out std_logic_vector (S_AXI_DATA_WIDTH-1 downto 0);
  S_AXI_RRESP	           : out std_logic_vector (1 downto 0);
  S_AXI_RVALID           : out std_logic;
  S_AXI_RREADY           : in  std_logic
);
end component axi4lite_reg;

----
-- Constant
----
constant btf_periodicity : integer := 50; -- [Hz]
constant btf_dead_time   : integer := 205; -- [usec]
constant timer_count_int : integer := 1e6*fclock/btf_periodicity-fclock*btf_dead_time-1;
constant Ntimer_counter  : integer := S_AXI_DATA_WIDTH;--clog2(timer_count_int);
constant timeout_time    : integer := 1000000; -- [usec]
constant timeout_count_i : integer := fclock*timeout_time-1;
constant Ntimeout        : integer := S_AXI_DATA_WIDTH;--clog2(timeout_count_i);
constant timer_count_d   : std_logic_vector(Ntimer_counter-1 downto 0) := std_logic_vector(conv_unsigned(timer_count_int, Ntimer_counter));
constant timeout_count_d : std_logic_vector(Ntimeout-1 downto 0) := std_logic_vector(conv_unsigned(timeout_count_i, Ntimeout));
constant Ntrig_threshold : integer := clog2(Ntrig_in);
constant Nbusy_counter   : integer := S_AXI_DATA_WIDTH;
-- Num of internal triggers
constant Ntrig_int       : integer := 2;

----
-- Signals
----
signal trig_redge        : std_logic_vector (Ntrig_in downto 0);
signal trig0_delay_taps  : std_logic_vector (255 downto 0);
signal trig_dwnscl0      : std_logic;
signal trig_mask_in_v    : std_logic_vector (Ntrig_int+Ntrig_in-1 downto 0);
signal trig_masked       : std_logic_vector (Ntrig_int+Ntrig_in-1 downto 0);
signal trig_mask_int     : std_logic_vector (Ntrig_int+Ntrig_in-1 downto 0);
signal trig_vect         : std_logic_vector (Ntrig_int+Ntrig_in-1 downto 0);
signal trig_mask_veto    : std_logic_vector (Ntrig_int+Ntrig_in-1 downto 0);
signal trig_dwnscl       : std_logic_vector (Ntrig_int+Ntrig_in-1 downto 0);
signal trig_nzs          : std_logic_vector (Ntrig_int+Ntrig_in-1 downto 0);
signal trig_zs           : std_logic_vector (Ntrig_int+Ntrig_in-1 downto 0);
signal timer_reset       : std_logic;
signal trig_dead_time_veto : std_logic;
signal sin_fb_r          : std_logic_vector(1 downto 0);
signal sin_r             : std_logic_vector(7 downto 0);
signal sin_int           : std_logic;
signal trig              : std_logic_vector (Ntrig_out-1 downto 0);
signal trig_nzs_zs_shaped: std_logic;
signal trig_type         : std_logic;
signal trig_map          : std_logic_vector (Ntrig_int+Ntrig_in-1 downto 0);
signal trig_to_delay     : std_logic;
signal trig_dead_time    : std_logic_vector (15 downto 0);
signal busy              : std_logic;
signal busy_int          : std_logic_vector (Nbusy_in downto 0);
signal run               : std_logic;
signal run_reg           : std_logic_vector(7 downto 0);
signal time_stamp        : std_logic_vector(63 downto 0);
signal time_stamp_v      : std_logic;
signal fifo_wr_en        : std_logic;
signal fifo_din          : std_logic_vector(63 downto 0);
signal fifo_rd_en        : std_logic;
signal fifo_data_out     : std_logic_vector(63 downto 0);
signal fifo_full         : std_logic;
signal fifo_empty        : std_logic;
signal partially_open    : std_logic_vector(7 downto 0);
-- Downscalers
type   trig_def_type is array (0 to Ntrig_int+Ntrig_in-1) of std_logic_vector(15 downto 0);
signal dwnscl_fact       : trig_def_type;
signal nzs_dwnscl_fact   : trig_def_type;
-- NZS triggers
signal pulse1us_in      : std_logic;
signal rand_trig            : std_logic;
signal rand_trig_dwns       : std_logic;
signal rand_trig_en         : std_logic;
signal rand_trig_period     : std_logic_vector(15 downto 0);
signal rand_trig_dwnscalef  : std_logic_vector(7 downto 0);
signal corr_trig            : std_logic;
signal corr_trig_dwns       : std_logic;
signal corr_trig_en         : std_logic;
signal corr_trig_delay      : std_logic_vector(15 downto 0);
signal corr_trig_dwnscalef  : std_logic_vector(7 downto 0);

signal sin                  : std_logic;
-- TimPix3
signal shutter              : std_logic;
signal tp3_shut_delay       : std_logic_vector(7 downto 0);
signal tp3_shut_width       : std_logic_vector(7 downto 0);

----
-- Registers
----
signal rw_def            : std_logic_vector (S_AXI_DATA_WIDTH*CR_N_RW_REGISTER-1 downto 0) := (others => '0');
signal rw_reg            : std_logic_vector (S_AXI_DATA_WIDTH*CR_N_RW_REGISTER-1 downto 0);
signal sc_reg            : std_logic_vector (S_AXI_DATA_WIDTH*CR_N_SC_REGISTER-1 downto 0);
signal ro_reg            : std_logic_vector (S_AXI_DATA_WIDTH*(CR_N_REGISTER-CR_N_RW_REGISTER-CR_N_SC_REGISTER-CR_N_FF_REGISTER)-1 downto 0) := (others => '0');
signal ff_req            : std_logic_vector (1  downto 0);
signal ff_reg            : std_logic_vector (63 downto 0);
  -- rw regs
signal rst               : std_logic := '0';
signal rst_reg           : std_logic_vector(1 downto 0) := (others => '0');
signal rst_fifo          : std_logic;
signal rst_fifo_from_daq_man : std_logic;
signal fifo_is_rst       : std_logic;
signal shaper_width      : std_logic_vector (Nshaper_width-1 downto 0);
signal trig0_input_delay : std_logic_vector (7 downto 0);
signal trig_mask         : std_logic_vector (Ntrig_in+Ntrig_int -1 downto 0);
signal busy_mask         : std_logic_vector (Nbusy_in downto 0);
signal timer_rst         : std_logic;
signal timer_veto        : std_logic;
signal trig_threshold    : std_logic_vector (Ntrig_threshold-1 downto 0);
signal run_width         : std_logic_vector (2*S_AXI_DATA_WIDTH-1 downto 0);
signal run_delay         : std_logic_vector (2*S_AXI_DATA_WIDTH-1 downto 0);
signal timer_count       : std_logic_vector(Ntimer_counter-1 downto 0);
signal timeout_count     : std_logic_vector(Ntimeout-1 downto 0);
  -- sc regs
signal start_of_run      : std_logic;
signal stop_of_run       : std_logic;
signal busy_counter_rst  : std_logic_vector (Nbusy_in downto 0);
  -- ro regs
signal busy_counter      : std_logic_vector ((Nbusy_in+1)*Nbusy_counter-1 downto 0);

-- Dbg
signal trigger_in        : std_logic_vector(Ntrig_in downto 0);
attribute MARK_DEBUG : string;
attribute MARK_DEBUG of trigger_in : signal is "TRUE";
attribute MARK_DEBUG of trig_mask_in_v : signal is "TRUE";
attribute MARK_DEBUG of trig_mask_int : signal is "TRUE";
attribute MARK_DEBUG of trig_masked : signal is "TRUE";
attribute MARK_DEBUG of trig_dwnscl : signal is "TRUE";
attribute MARK_DEBUG of trig_zs : signal is "TRUE";
attribute MARK_DEBUG of trig_nzs : signal is "TRUE";
attribute MARK_DEBUG of trig_type : signal is "TRUE";
attribute MARK_DEBUG of trig_map : signal is "TRUE";
attribute MARK_DEBUG of trig_dead_time_veto : signal is "TRUE";
attribute MARK_DEBUG of trig : signal is "TRUE";
attribute MARK_DEBUG of shutter : signal is "TRUE";
attribute MARK_DEBUG of busy_int : signal is "TRUE";
attribute MARK_DEBUG of busy : signal is "TRUE";
attribute MARK_DEBUG of run : signal is "TRUE";
attribute MARK_DEBUG of rst : signal is "TRUE";
attribute MARK_DEBUG of time_stamp : signal is "TRUE";
attribute MARK_DEBUG of time_stamp_v : signal is "TRUE";

begin

-- Dbg signal trigger_in
trigger_in <= rand_trig & trig_in;

-- v3_3: Brutally added in logic: BRAM usage much higher than logic
trig0_delay_taps <= trig0_delay_taps(trig0_delay_taps'high-1 downto 0) & trig_dwnscl(0);
dly_pr: process (clk) is
begin
if clk'event and clk='1' then
  if rst = '1' then
    trig_dwnscl0 <= '0';
  else
    trig_dwnscl0 <= trig0_delay_taps(conv_integer(unsigned(trig0_input_delay)));
  end if;
end if;
end process;

trigger_shaper_i: shaper
generic map(
  Ndata                  => Ntrig_in+1,
  Nwidth                 => Nshaper_width
)
port map(
  clk                    => clk,
  rst                    => rst,
  input(Ntrig_in)        => rand_trig,
  input(Ntrig_in-1 downto 0)=> trig_in,
  width_in               => shaper_width,
  output                 => trig_redge
);
shaper_width <= std_logic_vector(conv_unsigned(1, Nshaper_width));

trigger_masker_i: masker
generic map(
  Ndata                  => Ntrig_in+Ntrig_int
)
port map(
  --input(Ntrig_in+Ntrig_int-1) => corr_trig,
  --input(Ntrig_in+1 downto 0)  => trig_redge,
  input                  => trig_masked,--trig_mask_in_v,
  mask_in                => trig_mask_int,
  veto_in                => trig_mask_veto,
  output                 => trig_dwnscl--trig_masked
);
trig_mask_int <= trig_mask and not trig_vect;
trig_vect <= (others=> (trig_dead_time_veto or busy) );
trig_mask_in_v <= corr_trig & trig_redge;

timer_i: timer
generic map(
  Ncounter               => Ntimer_counter,
  Ntimeout               => Ntimeout
)
port map(
  clk                    => clk,
  rst                    => timer_reset,
  timer_count_in         => timer_count,
  timeout_count_in       => timeout_count,
  -- v3_3:
  --start_in               => trig_dwnscl(0),
  start_in               => trig_dwnscl0,
  done_out               => timer_veto
);

timer_reset <= timer_rst or rst;

trig_mask_veto <= ( 0 =>'0', others => timer_veto );


-- Downscalers
trig_downscaler_gen: for i in 1 to Ntrig_in + Ntrig_int-1 generate
  trig_downscaler: downscaler
  generic map(
    Ndownscale_factor     => 16
  )
  port map(
    rst                    => rst,
    clk                    => clk,
    downscale_factor_in    => dwnscl_fact(i),
    data_in                => trig_mask_in_v(i),--trig_masked(i),
    data_out               => trig_masked(i)--trig_dwnscl(i)
  );
end generate;
trig_masked(0) <= trig_mask_in_v(0);

--ZS/NZS
-- v3_3:
nzs_zs_select0: nzs_zs_selector
generic map(
  Ndownscale_factor     => 16
)
port map(
  rst => rst,
  clk => clk,
  nzs_downscale_factor_in => nzs_dwnscl_fact(0),
  data_in => trig_dwnscl0,
  zs_out  => trig_zs(0),
  nzs_out => trig_nzs(0)
);
-- v3_3:
--trig_zs_nzs_gen: for i in 0 to Ntrig_in + Ntrig_int-1 generate
trig_zs_nzs_gen: for i in 1 to Ntrig_in + Ntrig_int-1 generate
  nzs_zs_select: nzs_zs_selector
  generic map(
    Ndownscale_factor     => 16
  )
  port map(
    rst => rst,
    clk => clk,
    nzs_downscale_factor_in => nzs_dwnscl_fact(i),
    data_in => trig_dwnscl(i),
    zs_out  => trig_zs(i),
    nzs_out => trig_nzs(i)
  );
end generate;

nzs_zs_shape: nzs_zs_shaper
generic map(
  Nshape_factor     => 8,
  Ntrig_in          => Ntrig_in+Ntrig_int,
  Ndead_time        => 16
)
port map(
  rst       => rst,
  clk       => clk,
  zs_width  => std_logic_vector(conv_unsigned(8, 8)),
  nzs_width => std_logic_vector(conv_unsigned(16, 8)),
  dead_time_width => trig_dead_time,
  zs_in     => trig_zs,
  nzs_in    => trig_nzs,
  -- out_alp 4-2-19
  --trig_out  => trig(0),
  -- in_alp: 4-2-19
  trig_out  => trig_nzs_zs_shaped,
  -- end_alp: 4-2-19
  trig_type => trig_type,
  trig_map  => trig_map,
  veto_out  => trig_dead_time_veto
);
-- in_alp: 4-2-19
trig(0) <= trig_nzs_zs_shaped and not fifo_full and not rst;
-- end_alp: 4-2-19
trig(1) <= '0';
trig(2) <= '0';

--trigger_logic_i: trigger_logic
--generic map(
--  Ndata_in               => Ntrig_in,
--  Ndata_out              => Ntrig_out,
--  Nthreshold             => Ntrig_threshold
--)
--port map(
--  clk                    => clk,
--  rst                    => rst,
--  trig_in                => trig_masked,
--  veto_in                => veto,
--  threshold_in           => trig_threshold,
--  trig_out               => trig
--);

daq_manager_i: daq_manager
generic map(
  Nbusy                  => Nbusy_in+1,
  Nbusy_counter          => Nbusy_counter,
  Nrun_window            => 2*S_AXI_DATA_WIDTH
)
port map(
  clk                    => clk,
  rst                    => rst,
  start_of_run_in        => start_of_run,
  stop_of_run_in         => stop_of_run,
  fifo_rst_out           => rst_fifo_from_daq_man,
  fifo_is_rst_in         => fifo_is_rst,
  busy_in                => busy_int,
  busy_counter_rst_in    => busy_counter_rst,
  run_width_in           => run_width,
  run_delay_in           => run_delay,
  run_out                => run,
  --veto_out               => open,
  busy_out               => busy,
  busy_counter_out       => busy_counter
);
--busy_int <= (fifo_full & busy_in) and busy_mask;
-- busy2: TP3, busy3: MIMOSA
busy_int <= (fifo_full & busy_in(busy_in'high downto 3) & (not busy_in(2)) & busy_in(1 downto 0)) and busy_mask;
busy_out <= (0 => sin, others => busy);
--sin <= run xor run_reg(0);-- 100 ns pulse to toggle the sin state in the sin distribution board --not run;
sin_pr: process(rst,clk)
begin
  if rst='1' then
    sin_int <= '0';
    sin_r <= (others => '0');
    sin_fb_r <= "00";
  elsif clk'event and clk='1' then
    sin_fb_r <= sin_fb_r(0) & sin_fb;
    sin_r    <= sin_r(sin_r'high-1 downto 0) & sin_int;
    sin_int <= '0';
    if (run /= sin_fb_r(1)) and (sin='0') then
      sin_int <= '1';
    end if;
  end if;
end process;
sin <= or_reduce(sin_r);

-- Shutter1: TP3, shutter0: MIMOSA
--shutter_out  <= (others => run);
TP3_shutter_window_generator_i: window_generator
generic map(
  Nrun_window            => 8+3
)
port map(
  clk                    => clk,
  rst                    => rst,
  width_in(8+3-1 downto 3) => tp3_shut_width,
  width_in(2 downto 0)       => "001",
  delay_in(8+3-1 downto 8)   => "000",
  delay_in(7 downto 0)       => tp3_shut_delay,
  -- v3_3:
  --start_in               => trig(0),
  start_in               => trig_dwnscl(0),
  window_out             => shutter
);
shutter_out <= (others => (not shutter));
-- trig2: TP3, trig1: MIMOSA
trig_out(0) <= trig(0);
trig_out(1) <= '0';
-- TP3 timer_reset:
-- v3_3:
--trig_out(2) <= run and not and_reduce(run_reg);
trig_out(2) <= run and or_reduce(run_reg);
tp3_proc: process(clk) is
begin
if clk'event and clk='1' then
  if rst = '1' then
    run_reg <= (others => '0');
  else
    -- v3_3:
    --run_reg <= run & run_reg(run_reg'high downto 1);
    run_reg <= trig_dwnscl(0) & run_reg(run_reg'high downto 1);
  end if;
end if;
end process;

trig_time_stamp_i: trig_time_stamp
generic map(
  Ntrig_in               => Ntrig_in+Ntrig_int,
  Ntrig_out              => Ntrig_out
)
port map(
  rst                    => rst         ,
  clk                    => clk         ,
  trig_in                => trig        , -- only 0 is used now
  trig_vector_in         => trig_map    ,
  trig_type              => trig_type   , 
  --time_stamp_out(63 downto 56) => partially_open ,
  --time_stamp_out(55 downto 0)  => time_stamp(55 downto 0) ,
  time_stamp_out         => time_stamp  ,
  time_stamp_v_out       => time_stamp_v
);

fifo_rd_en <= ff_req(1) and not rst;
time_stamp_fifo: fifo_generator_0
port map(
  rst                    => rst_fifo,
  clk                    => clk,
  din                    => fifo_din,
  wr_en                  => fifo_wr_en,
  rd_en                  => fifo_rd_en,
  dout                   => fifo_data_out,
  full                   => fifo_full,
  empty                  => fifo_empty
);
-- in_alp: 4-2-19
fifo_wr_en <= time_stamp_v;
-- out_alp: 4-2-19
--fifo_wr_en <= time_stamp_v and not fifo_full and not rst;
-- end_alp: 4-2-19
--ff_reg(63 downto 56)   <= (56 => fifo_empty, others => '0');
ff_reg(63 downto 57)   <= fifo_data_out(63 downto 57);
ff_reg(56)             <= fifo_empty;
ff_reg(55 downto 0)    <= fifo_data_out(55 downto 0);
fifo_din               <= time_stamp;
rst_fifo               <= rst or rst_fifo_from_daq_man;
fifo_is_rst            <= fifo_empty and fifo_full;




Inst_ConfRegister: axi4lite_reg
generic map(
  N_REGISTER             => CR_N_REGISTER,
  N_RW_REGISTER          => CR_N_RW_REGISTER,
  N_SC_REGISTER          => CR_N_SC_REGISTER,
  N_FF_REGISTER          => CR_N_FF_REGISTER,
  S_AXI_DATA_WIDTH       => S_AXI_DATA_WIDTH,
  S_AXI_ADDR_WIDTH       => S_AXI_ADDR_WIDTH
)
port map(
  rw_def                 => rw_def,
  rw_reg                 => rw_reg,
  sc_reg                 => sc_reg,
  ro_reg                 => ro_reg,
  ff_reg                 => ff_reg,
  ff_req                 => ff_req,
  S_AXI_ACLK	           => S_AXI_ACLK,
  S_AXI_ARESETN	         => S_AXI_ARESETN,
  S_AXI_AWADDR	         => S_AXI_AWADDR(S_AXI_ADDR_WIDTH-1 downto 0),
  S_AXI_AWPROT	         => S_AXI_AWPROT,
  S_AXI_AWVALID	         => S_AXI_AWVALID,
  S_AXI_AWREADY	         => S_AXI_AWREADY,
  S_AXI_WDATA	           => S_AXI_WDATA,
  S_AXI_WSTRB	           => S_AXI_WSTRB,
  S_AXI_WVALID	         => S_AXI_WVALID,
  S_AXI_WREADY	         => S_AXI_WREADY,
  S_AXI_BRESP	           => S_AXI_BRESP,
  S_AXI_BVALID	         => S_AXI_BVALID,
  S_AXI_BREADY	         => S_AXI_BREADY,
  S_AXI_ARADDR	         => S_AXI_ARADDR(S_AXI_ADDR_WIDTH-1 downto 0),
  S_AXI_ARPROT	         => S_AXI_ARPROT,
  S_AXI_ARVALID	         => S_AXI_ARVALID,
  S_AXI_ARREADY	         => S_AXI_ARREADY,
  S_AXI_RDATA	           => S_AXI_RDATA,
  S_AXI_RRESP	           => S_AXI_RRESP,
  S_AXI_RVALID           => S_AXI_RVALID,
  S_AXI_RREADY           => S_AXI_RREADY
);

--rand_trigger_gen: random_trigger
--generic map(
--  Nperiodicity           => 16
--)
--port map(
--  rst                    => rst,
--  clk                    => clk,
--  pulse102_4us_in        => pulse102_4us_in, -- 102.4 us pulse
--  enable_in              => rand_trig_en,
--  periodicity_in         => rand_trig_period,
--  trigger_out            => rand_trig
--);
-- ADD NEW RAND TRIG as uncorrelated clock running @ 1MHz
--rand_trig <= clk_ps_1MHz_in;
rtrig_downscaler: downscaler
generic map(
  Ndownscale_factor     => 12
)
port map(
  rst                    => '0',
  clk                    => clk_ps_1MHz_in,
  downscale_factor_in    => x"3E7",
  data_in                => '1',
  data_out               => rand_trig
);


--rand_trig_downscaler: downscaler
--generic map(
--  Ndownscale_factor     => 8
--)
--port map(
--  rst                    => rst,
--  clk                    => clk,
--  downscale_factor_in    => rand_trig_dwnscalef,
--  data_in                => rand_trig,
--  data_out               => rand_trig_dwns
--);

corr_trig_gen: corr_trigger
generic map(
  Nwidth_in              => 16
)
port map(
  rst                    => rst,
  clk                    => clk,
  enable_in              => corr_trig_en,
  trig_in                => trig_to_delay,
  delay_in               => corr_trig_delay, --us
  trig_out               => corr_trig
);
corr_trig_en  <= '0' when or_reduce(corr_trig_delay)='0' else '1';
trig_to_delay <= trig(0) and trig_map(0);

--corr_trig_downscaler: downscaler
--generic map(
--  Ndownscale_factor     => 8
--)
--port map(
--  rst                    => rst,
--  clk                    => clk,
--  downscale_factor_in    => corr_trig_dwnscalef,
--  data_in                => corr_trig,
--  data_out               => corr_trig_dwns
--);

----
-- Registers
----
  -- rw regs
process (clk) begin
if clk'event and clk='1' then
rst_reg(0)        <= rw_reg(0) or rst_in;
rst_reg(1)        <= rst_reg(0);
rst               <= rst_reg(1) or rst_reg(0) or rw_reg(0) or rst_in;
end if;
end process;
--rst_fifo          <= rw_reg(0);                                         rw_def(0)                                       <= '0';
--timer_rst         <= rw_reg(4);                                         rw_def(4)                                       <= '0';
timer_rst <= '0';
--timer_veto        <= rw_reg(8);
trig_dead_time <= rw_reg(31 downto 16); rw_def(31 downto 16) <= x"3E7F";

trig_mask         <= rw_reg(32*1 + Ntrig_in + Ntrig_int -1          downto 32*1 );  rw_def(32*1 + Ntrig_in + Ntrig_int -1         downto 32*1 ) <= x"00";
busy_mask         <= rw_reg(32*1 + Nbusy_in +1 -1 +8    downto 32*1+8); rw_def(32*1 + Nbusy_in +1 -1 +8   downto 32*1+8)<= '1' & x"0";
corr_trig_delay   <= rw_reg(32*1 + 31 downto 32*1 + 16 );  rw_def(32*1 + 31 downto 32*1 + 16 ) <= std_logic_vector(conv_unsigned(500, 16)); -- 500 us
--shaper_width      <= rw_reg(32*2 + Nshaper_width-1      downto 32*2 );  rw_def(32*2 + Nshaper_width-1     downto 32*2 ) <= std_logic_vector(conv_unsigned(1, Nshaper_width));
--trig_threshold    <= rw_reg(32*3 + Ntrig_threshold-1    downto 32*3 );  rw_def(32*3 + Ntrig_threshold-1   downto 32*3 ) <= std_logic_vector(conv_unsigned(1, Ntrig_threshold));

run_width         <= rw_reg(32*2 + 2*S_AXI_DATA_WIDTH-1 downto 32*2 );  rw_def(32*2+ 2*S_AXI_DATA_WIDTH-1 downto 32*2 ) <= (others => '1');--X"0000_0001_1E1A_3000";--std_logic_vector(conv_unsigned(60*fclock*1e6-1, 2*S_AXI_DATA_WIDTH)); -- 1min
--run_delay         <= rw_reg(32*6 + 2*S_AXI_DATA_WIDTH-1 downto 32*6 );  rw_def(32*6+ 2*S_AXI_DATA_WIDTH-1 downto 32*6 ) <= std_logic_vector(conv_unsigned((fclock*100)/1000, 2*S_AXI_DATA_WIDTH)); -- 100 ns
-- halved delay
--run_delay         <= rw_reg(32*6 + S_AXI_DATA_WIDTH-1 downto 32*6 );  rw_def(32*6+ S_AXI_DATA_WIDTH-1 downto 32*6 ) <= std_logic_vector(conv_unsigned((fclock*100)/1000, S_AXI_DATA_WIDTH));
-- completely removed delay, set to 112.5 ns
run_delay(3 downto 0) <= x"A";
run_delay(run_delay'high downto 4) <= (others => '0'); 

-- v3_3:
trig0_input_delay <= rw_reg(32*4 + 31 downto 32*4 + 24 );  rw_def(32*4 + 31 downto 32*4 + 24 ) <= std_logic_vector(conv_unsigned(   126, 8 )); -- 1.6 us
-- Added TimePix shutter def
tp3_shut_delay    <= rw_reg(32*4 +  7 downto 32*4      );  rw_def(32*4 +  7 downto 32*4      ) <= std_logic_vector(conv_unsigned(   17, 8 )); -- 200ns
tp3_shut_width    <= rw_reg(32*4 + 15 downto 32*4 + 8  );  rw_def(32*4 + 15 downto 32*4 + 8  ) <= std_logic_vector(conv_unsigned( 100, 8 )); -- 10 us

timer_count       <= rw_reg(32*5 + S_AXI_DATA_WIDTH-1   downto 32*5 );  rw_def(32*5+ S_AXI_DATA_WIDTH-1   downto 32*5 ) <= timer_count_d;
timeout_count     <= rw_reg(32*6 + S_AXI_DATA_WIDTH-1   downto 32*6 );  rw_def(32*6+ S_AXI_DATA_WIDTH-1   downto 32*6 ) <= timeout_count_d;

-- Tigger Downscale factors
dwnscl_fact(0)      <= rw_reg(7*32+15 downto 7*32);
rw_def(7*32+15 downto 7*32) <= std_logic_vector(conv_unsigned(1,16));
nzs_dwnscl_fact(0)  <= rw_reg(7*32+31 downto 7*32+16);
rw_def(7*32+31 downto 7*32+16) <= std_logic_vector(conv_unsigned(0,16));

dwnscl_fact(1)      <= rw_reg(8*32+15 downto 8*32);
rw_def(8*32+15 downto 8*32) <= std_logic_vector(conv_unsigned(1,16));
nzs_dwnscl_fact(1)  <= rw_reg(8*32+31 downto 8*32+16);
rw_def(8*32+31 downto 8*32+16) <= std_logic_vector(conv_unsigned(0,16));

dwnscl_fact(2)      <= rw_reg(9*32+15 downto 9*32);
rw_def(9*32+15 downto 9*32) <= std_logic_vector(conv_unsigned(1,16));
nzs_dwnscl_fact(2)  <= rw_reg(9*32+31 downto 9*32+16);
rw_def(9*32+31 downto 9*32+16) <= std_logic_vector(conv_unsigned(0,16));

dwnscl_fact(3)      <= rw_reg(10*32+15 downto 10*32);
rw_def(10*32+15 downto 10*32) <= std_logic_vector(conv_unsigned(1,16));
nzs_dwnscl_fact(3)  <= rw_reg(10*32+31 downto 10*32+16);
rw_def(10*32+31 downto 10*32+16) <= std_logic_vector(conv_unsigned(0,16));

dwnscl_fact(4)      <= rw_reg(11*32+15 downto 11*32);
rw_def(11*32+15 downto 11*32) <= std_logic_vector(conv_unsigned(1,16));
nzs_dwnscl_fact(4)  <= rw_reg(11*32+31 downto 11*32+16);
rw_def(11*32+31 downto 11*32+16) <= std_logic_vector(conv_unsigned(0,16));

dwnscl_fact(5)      <= rw_reg(12*32+15 downto 12*32);
rw_def(12*32+15 downto 12*32) <= std_logic_vector(conv_unsigned(1,16));
nzs_dwnscl_fact(5)  <= rw_reg(12*32+31 downto 12*32+16);
rw_def(12*32+31 downto 12*32+16) <= std_logic_vector(conv_unsigned(0,16));

-- RAND TRIG
dwnscl_fact(6)      <= rw_reg(13*32+15 downto 13*32);
rw_def(13*32+15 downto 13*32) <= std_logic_vector(conv_unsigned(0,16));
nzs_dwnscl_fact(6)  <= rw_reg(13*32+31 downto 13*32+16);
rw_def(13*32+31 downto 13*32+16) <= std_logic_vector(conv_unsigned(1,16));

-- CORR TRIG
dwnscl_fact(7)      <= rw_reg(14*32+15 downto 14*32);
rw_def(14*32+15 downto 14*32) <= std_logic_vector(conv_unsigned(0,16));
nzs_dwnscl_fact(7)  <= rw_reg(14*32+31 downto 14*32+16);
rw_def(14*32+31 downto 14*32+16) <= std_logic_vector(conv_unsigned(1,16));


  -- sc regs
start_of_run      <= sc_reg(0);
stop_of_run       <= sc_reg(1);
busy_counter_rst  <= sc_reg(4+Nbusy_in downto 4);
  -- ro regs
-- Test
ro_reg (32*1-1  downto  32*0) <= X"0123_4567";
ro_reg (32*2-1  downto  32*1) <= X"89AB_CDEF";
ro_reg (32*3-1  downto  32*2) <= X"AAAA_5555";
ro_reg (32*4-1  downto  32*3) <= X"5555_AAAA";
gen_busy_cnt_reg: for i in 0 to Nbusy_in generate
  ro_reg(S_AXI_DATA_WIDTH*(i+4)+Nbusy_counter-1 downto S_AXI_DATA_WIDTH*(i+4)) <= busy_counter(S_AXI_DATA_WIDTH*i+Nbusy_counter-1 downto S_AXI_DATA_WIDTH*i); -- (Nbusy_in*Nbusy_counter-1 downto 0);
end generate;
ro_reg (32*9+Nbusy_in    downto  32* 9)           <= busy_int;
ro_reg (32*10+Ntrig_in+Ntrig_int-1 downto  32*10) <= trig_map;

--ro_reg (32*14-1 downto  32*13) <= x"0301_8B08";
ro_reg (32*14-1 downto  32*13) <= x"0303_9305";

end architecture rtl;