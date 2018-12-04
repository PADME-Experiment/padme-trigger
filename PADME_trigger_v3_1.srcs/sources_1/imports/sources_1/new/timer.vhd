library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;


library work;
use work.fsm_pkg.all;


entity timer is
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
end entity timer;

architecture rtl of timer is

----
-- Constants
----
constant zeros           : std_logic_vector (Ncounter-1 downto 0) := (others => '0');
constant N_fsm_counter : integer := 32;
-- FSM Counter Signals
signal cns   : cstate;
signal cvalue : std_logic_vector(N_fsm_counter - 1 downto 0);
signal cvalid : std_logic;

-- State machine signals
type xstate is (wait_for_start, wait_for_timer_count, wait_for_timeout_count);
signal pstate               : xstate := wait_for_start;
signal nstate               : xstate;

----
-- Signals
----
signal count             : std_logic_vector (Ncounter-1 downto 0);
signal count_timeout     : std_logic_vector (Ntimeout-1 downto 0);
signal done              : std_logic;

begin

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

-- Sequential network
xseq_pr: process(clk) is
begin
if clk='1' and clk'event then
  if rst = '1' then
    pstate <= wait_for_start;
    count <= zeros;
    count_timeout <= (others => '0');
  else
    pstate <= nstate;
    count <= timer_count_in;
    count_timeout <= timeout_count_in;
  end if;
end if;
end process;

-- State Transition Process
xcomb_pr: process(all) is
begin
  -- Default 
  cvalue <= (others => '0');
  cns    <= start;
  nstate <= pstate;
  done <= '0';

  case pstate is
  when wait_for_start =>
    nstate <= wait_for_start;
    if start_in = '1' then
      nstate <= wait_for_timer_count;
    end if;
  
  when wait_for_timer_count =>
    if start_in = '1' then
      cns    <= start;
    elsif count /= timer_count_in then
      cns    <= start;
    else
      cns    <= run;
    end if;
    cvalue(Ncounter-1 downto 0) <=  count-1;
    nstate <= wait_for_timer_count;
    if cvalid = '1' then
      nstate <= wait_for_timeout_count;
    end if;
  
  when wait_for_timeout_count =>
    done <= '1';
    if count_timeout /= timeout_count_in then
      cns    <= start;
    else
      cns    <= run;
    end if;
    cvalue(Ntimeout-1 downto 0) <=  count_timeout-1;
    nstate <= wait_for_timeout_count;
    if start_in = '1' then
      nstate <= wait_for_timer_count;
    elsif cvalid = '1' then
      nstate <= wait_for_start;
    end if;
    
    
  end case;
  
  -- Reset Counter on stante change
  if nstate /= pstate then
    cns <= start;
  end if;

end process;

done_out <= done;

--timer_pr: process (clk) is
--begin
--if clk'event and clk='1' then
--  if rst = '1' then
--    count <= zeros;
--    count_timeout <= (others => '0');
--    done  <= '0';
--  else
--    count_timeout  <= (others => '0');
--    if count = zeros then
--      count <= zeros;
--      done  <= done;
--      if start_in = '1' then 
--        count <= count + 1;
--        done  <= '0';
--      end if;
--    elsif count = timer_count_in then
--      count <= zeros;
--      done  <= '1';
--    else
--      count <= count + '1';
--      done  <= '0';
--    end if;
--    -- Whatchodog: 1 sec
--    if done = '1' then
--      count_timeout <= count_timeout +1;
--    end if;
--    if count_timeout = timeout_count_in then
--      done <= '0';
--      count_timeout <= (others => '0');
--    end if;
--  end if;
--end if;
--end process;

--done_out <= done;

end architecture rtl;