library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library work;
use work.fsm_pkg.all;

entity nzs_zs_shaper is
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
  zs_in                   : in  std_logic_vector(Ntrig_in-1 downto 0);
  nzs_in                  : in  std_logic_vector(Ntrig_in-1 downto 0);
  trig_out                : out std_logic;
  trig_type               : out std_logic;
  trig_map                : out std_logic_vector(Ntrig_in-1 downto 0);
  veto_out                : out std_logic
);
end entity;

architecture behav of nzs_zs_shaper is

function or_reduce(x : std_logic_vector) return std_logic is
  variable r : std_logic := '0';
begin
  for i in x'range loop
    r := r or x(i);
  end loop;
  return r;
end or_reduce;

-- FSM sigs
--type cstate is (idle, reset, start, run, freerun);
-- FSM Counter Constant
constant N_fsm_counter : integer := Ndead_time;
-- FSM Counter Signals
signal cns   : cstate;
signal cvalue : std_logic_vector(N_fsm_counter - 1 downto 0);
signal cvalid : std_logic;

-- State machine signals
type xstate is (wait_for_trig, run_nzs, wait_nzs_to_zs_dead_time, run_zs, wait_dead_time);
signal pstate               : xstate := wait_for_trig;
signal nstate               : xstate;

-- 
signal zs                   : std_logic; 
signal nzs                  : std_logic;
signal zs_width_int         : std_logic_vector(Ndead_time-1 downto 0) := (others => '0'); 
signal nzs_width_int        : std_logic_vector(Ndead_time-1 downto 0) := (others => '0');
signal trig_map_int         : std_logic_vector(Ntrig_in-1 downto 0);
signal trig_type_int        : std_logic;

begin


zs  <= or_reduce(zs_in);
nzs <= or_reduce(nzs_in);

zs_width_int (Nshape_factor-1 downto 0)  <= zs_width;
nzs_width_int(Nshape_factor-1 downto 0)  <= nzs_width;

-------- COUNTER -------
fsm_cnt: entity work.fsm_counter
  generic map(
    Ncnt       => N_fsm_counter
  )
  port map(
    clk    => clk,
    rst    => rst,
    cns    => cns,
    cvalue => cvalue, 
    cvalid => cvalid
  );

-------- PROTOCOL -------
-- Sequential network
xseq_pr: process(clk) is
begin
if clk='1' and clk'event then
  if rst = '1' then
    pstate <= wait_for_trig;
    trig_map_int  <= (others => '0');
    trig_type_int <= '0';
  else
    pstate <= nstate;
    trig_map_int  <= trig_map_int;
    trig_type_int <= trig_type_int;
    if pstate = wait_for_trig then
      trig_map_int  <= zs_in or nzs_in;
      trig_type_int <= zs;
    end if;
  end if;
end if;
end process;
trig_map  <= trig_map_int;
trig_type <= trig_type_int;


-- State Transition Process
xcomb_pr: process(all) is
begin
  -- Default 
  cvalue <= (others => '0');
  cns    <= start;
  nstate <= pstate;
  trig_out  <= '0';
  veto_out  <= '0';
  case pstate is
  when wait_for_trig =>
    if nzs = '1' then
      -- NZS has priority over ZS
      nstate <= run_nzs;
    elsif zs = '1' then
      nstate <= run_zs;
    end if;
      
  when run_nzs =>
    cns <= run;
    cvalue <= nzs_width_int-1;
    trig_out  <= '1';
    veto_out  <= '1';
    if cvalid = '1' then
      nstate <= wait_dead_time;
    end if;
    
  when run_zs =>
    cns <= run;
    cvalue <= zs_width_int-1;
    trig_out  <= '1';
    veto_out  <= '1';
    if cvalid = '1' then
      --nstate <= wait_dead_time;
      nstate <= wait_nzs_to_zs_dead_time;
    end if;
  
  when wait_nzs_to_zs_dead_time =>
    cns <= run;
    cvalue <= (nzs_width_int-zs_width_int)-1;
    trig_out  <= '0';
    veto_out  <= '1';
    if cvalid = '1' then
      nstate <= wait_dead_time;
    end if;
  
  when wait_dead_time =>
    cns <= run;
    cvalue <= dead_time_width-1;
    trig_out  <= '0';
    veto_out  <= '1';
    if cvalid = '1' then
      nstate <= wait_for_trig;
    end if;
    
  end case;
  -- Reset Counter on stante change
  if nstate /= pstate then
    cns <= start;
  end if;
end process;

end architecture behav;