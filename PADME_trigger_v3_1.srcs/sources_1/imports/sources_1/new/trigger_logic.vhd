package fsm_pkg is
  -- FSM Counter
  type cstate is (idle, reset, start, run, freerun);
  
end package fsm_pkg;

package body fsm_pkg is

end package body fsm_pkg;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.fsm_pkg.all;

entity fsm_counter is
  generic(
    Ncnt : integer
  );
  port(
    clk    : in  std_logic;
    rst    : in  std_logic;
    cns    : in  cstate;
    cvalue : in  std_logic_vector(Ncnt - 1 downto 0);
    cvalid : out std_logic
  );
end entity fsm_counter;

architecture RTL of fsm_counter is

  signal ccnt  : std_logic_vector(Ncnt - 1 downto 0);
  --type cstate is (idle, reset, start, run, freerun);
  -- PS
  signal cps   : cstate                           := reset;
  signal ccntr : std_logic_vector(Ncnt - 1 downto 0) := (others => '0');
  --  NS
  -- signal cns   : cstate;

begin

  -- Counter Seq. Network
  cseq_pr : process(clk, rst) is
  begin
    if rst = '1' then
      cps   <= reset;
      ccntr <= (others => '0');
    elsif clk = '1' and clk'event then
      cps <= cns;
      if cps = start then
        ccntr <= (0 => '1', others => '0');
      else
        ccntr <= ccnt;
      end if;
    end if;
  end process;
  -- Counter Output Network
  ccomb_pr : process(cps, ccnt, ccntr, cvalue) is
  begin
    case cps is
      when reset =>
        -- Reset
        ccnt   <= (others => '0');
        cvalid <= '0';
      when idle =>
        -- Idle
        ccnt <= ccntr;
        if ccntr = cvalue then
          cvalid <= '1';
        else
          cvalid <= '0';
        end if;
      when start =>
        -- Start
        ccnt   <= (ccnt'low => '1', others => '0');
        cvalid <= '0';
      when run =>
        -- Run
        if ccntr = cvalue then
          ccnt   <= ccntr;
          cvalid <= '1';
        else
          ccnt   <= ccntr + 1;
          cvalid <= '0';
        end if;
      when freerun =>
        -- Free Run
        ccnt <= ccntr + 1;
        --if and_reduce(ccnt) = '1' then
        if ccnt = cvalue then
          cvalid <= '1';
        else
          cvalid <= '0';
        end if;
      when others =>
        -- Idle
        ccnt <= ccntr;
        if ccnt = cvalue then
          cvalid <= '1';
        else
          cvalid <= '0';
        end if;
    end case;
  end process;

end architecture RTL;






library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.fsm_pkg.all;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity trigger_logic is
generic(
  Ndata_in               : integer;
  Ndata_int_in           : integer;
  Ndata_out              : integer;
  Nthreshold             : integer
);
port(
  clk                    : in  std_logic;
  rst                    : in  std_logic;
  trig_in                : in  std_logic_vector (Ndata_in-1 downto 0);
  trig_internal_in       : in  std_logic_vector (Ndata_int_in-1 downto 0);
  veto_in                : in  std_logic;
  threshold_in           : in  std_logic_vector (Nthreshold-1 downto 0);
  trig_out               : out std_logic_vector (Ndata_out-1 downto 0);
  trig_map_out           : out std_logic_vector (Ndata_in+Ndata_int_in-1 downto 0)
);
end entity trigger_logic;


architecture behav of trigger_logic is

--------------------
-- or_reduce
--------------------
function or_reduce(x : std_logic_vector) return std_logic is
  variable r : std_logic := '0';
begin
  for i in x'range loop
    r := r or x(i);
  end loop;
  return r;
end or_reduce;
--------------------
-- and_reduce
--------------------
function and_reduce(x : std_logic_vector) return std_logic is
  variable r : std_logic := '1';
begin
  for i in x'range loop
    r := r and x(i);
  end loop;
  return r;
end and_reduce;

-- FSM Counter Constant
constant N_fsm_counter : integer := 5;
-- FSM Counter Signals
signal cns   : cstate;
signal cvalue : std_logic_vector(N_fsm_counter - 1 downto 0);
signal cvalid : std_logic;

-- State machine signals
signal done                 : std_logic;
type xstate is (idle, wait_trig_redge, wait_nzs, wait_zs, wait_trig_fedge);
signal pstate               : xstate := idle;
signal nstate               : xstate;

----
-- Signals
----
signal trig_all          : std_logic_vector (Ndata_in+Ndata_int_in-1 downto 0);
signal trig_map          : std_logic_vector (Ndata_in+Ndata_int_in-1 downto 0);
signal trig_map_reg      : std_logic_vector (Ndata_in+Ndata_int_in-1 downto 0);
signal trig_internal_reg : std_logic_vector (Ndata_int_in-1 downto 0);
signal trig_gen_rise     : std_logic_vector (Ndata_int_in downto 0);
signal trig_gen_rise_reg : std_logic_vector (Ndata_int_in downto 0);
signal trig_gen_fall     : std_logic_vector (Ndata_int_in downto 0);
signal trig_gen_fall_reg : std_logic_vector (Ndata_int_in downto 0);
signal sum_trig          : std_logic_vector (Nthreshold-1 downto 0);
signal trig_majority     : std_logic;
signal trig_majority_reg : std_logic;
signal trig              : std_logic;

begin

trig_all <= trig_internal_in & trig_in;

  -------- COUNTER -------
fsm_cnt: entity work.fsm_counter
generic map(
  Ncnt    => N_fsm_counter
)
port map(
  clk    => clk,
  rst    => rst,
  cns    => cns,
  cvalue => cvalue,
  cvalid => cvalid
);

-- Sequential network
xseq_pr: process(clk, rst) is
begin
if clk='1' and clk'event then
  if rst = '1' then
    pstate              <= idle;
    trig_internal_reg   <= (others => '0');
    trig_gen_rise_reg   <= (others => '0');
    trig_gen_fall_reg   <= (others => '0');
    trig_map_reg        <= (others => '0');
  else
    pstate <= nstate;
    trig_internal_reg   <= trig_internal_in;
    trig_gen_rise_reg   <= trig_gen_rise;
    trig_gen_fall_reg   <= trig_gen_fall;
    trig_map_reg        <= trig_map;
  end if;
end if;
end process;

-- State Transition Process
xcomb_pr: process(pstate) is
begin
  -- Default 
  trig_gen_rise <= trig_gen_rise_reg;
  trig_gen_fall <= trig_gen_fall_reg;
  trig_map      <= trig_map_reg;
  cvalue        <= (others => '0');
  cns           <= reset;
  trig          <= '0';
  case pstate is
  when idle =>
    nstate <= wait_trig_redge;
    trig_gen_fall <= (others => '0');
    trig_gen_rise <= (others => '0');

  when wait_trig_redge =>
    trig_gen_fall <= (others => '0');
    if veto_in = '0' then
      if or_reduce(trig_internal_in and not trig_internal_reg) = '1' then
        nstate <= wait_nzs;
        trig_gen_rise <= (trig_internal_in and not trig_internal_reg) & (trig_majority and not trig_majority_reg);
        trig_map <= trig_internal_in & trig_in;
      elsif (trig_majority and not trig_majority_reg) = '1' then
        nstate <= wait_zs;
        trig_gen_rise <= (trig_internal_in and not trig_internal_reg) & (trig_majority and not trig_majority_reg);
        trig_map <= trig_internal_in & trig_in;
      end if;
    end if;
    
  when wait_nzs =>
    cns <= run;
    cvalue <= std_logic_vector(to_unsigned( 8-1, N_fsm_counter));
    if cvalid='1' then
      nstate <= wait_trig_fedge;
      if and_reduce(trig_gen_fall_reg xnor trig_gen_rise_reg)='1' then
        nstate <= wait_trig_redge;
      end if;
    end if;
    trig_gen_fall <= trig_gen_fall_reg or (trig_internal_reg and not trig_internal_in);
    trig <= '1';
    
  when wait_zs =>
    cns <= run;
    cvalue <= std_logic_vector(to_unsigned( 16-1, N_fsm_counter));
    if cvalid='1' then
      nstate <= wait_trig_fedge;
      if and_reduce(trig_gen_fall_reg xnor trig_gen_rise_reg)='1' then
        nstate <= wait_trig_redge;
      end if;
    end if;
    trig_gen_fall <= trig_gen_fall_reg or (trig_internal_reg and not trig_internal_in);
    trig <= '1';
    
  when wait_trig_fedge =>
    trig_gen_fall <= trig_gen_fall_reg or (trig_internal_reg and not trig_internal_in);
    if and_reduce(trig_gen_fall_reg xnor trig_gen_rise_reg)='1' then
      nstate <= wait_trig_redge;
    end if;
    
  end case;
  -- Reset Counter on stante change
  if nstate /= pstate then
    cns <= reset;
  end if;
end process;

--trigg_pr: process (clk) is
--begin
--if clk'event and clk='1' then
--  if rst = '1' then
--    trig <= (others => '0');
--  else
--    if sum_trig >= threshold_in then
--      for i in 0 to Ndata_out-1 loop
--        trig(i) <= '1' and not veto_in;
--      end loop;
--    else
--      trig <= (others => '0');
--    end if;
--  end if;
--end if;
--end process;

sum_pr: process(trig_in) is
variable sum : std_logic_vector (Nthreshold-1 downto 0);
begin
sum := (others => '0');
for i in 0 to Ndata_in-1 loop
  sum := sum + trig_in(i);
end loop;
sum_trig <= sum;
end process;
trig_majority <= '1' when sum_trig >= threshold_in else '0';

trig_out <= (others => trig);
trig_map_out <= trig_map;

end architecture behav;