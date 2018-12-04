library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
--use ieee.std_logic_arith.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

entity e is
end entity e;

architecture aa of e is

----
-- Component Dec
----
component user_logic is
generic(
  fclock                 : integer;
  Ntrig_in               : integer;
  Ntrig_out              : integer;
  Nshaper_width          : integer;
  Nbusy_in               : integer;
  Nbusy_out              : integer;
  Nshutter_out           : integer;
  S_AXI_DATA_WIDTH       : integer;
  S_AXI_ADDR_WIDTH       : integer;
  CR_N_REGISTER          : integer;
  CR_N_RW_REGISTER       : integer;
  CR_N_SC_REGISTER       : integer;
  CR_N_FF_REGISTER       : integer
);
port(
  clk                    : in  std_logic;
  clk_ps_1MHz_in         : in  std_logic;
  rst_in                 : in  std_logic;
  trig_in                : in  std_logic_vector (Ntrig_in-1 downto 0);
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
end component user_logic;

----
-- Functions
----
function log2( i : integer) return integer is
  variable t : integer := i-1;
  variable r : integer := 0; 
begin         
  while t > 1 loop
    r := r + 1;
    t := t / 2;
  end loop;
  r := r + 1;
  return r;
end function;

----
-- Constant
----
constant fclock          : integer := 200;
constant Ntrig_in        : integer := 6;
constant Ntrig_out       : integer := 3;
constant Nshaper_width   : integer := 2;
constant Nbusy_in        : integer := 4;
constant Nbusy_out       : integer := 2;
constant Nshutter_out    : integer := 2;
constant CR_N_REGISTER   : integer := 32;
constant CR_N_RW_REGISTER: integer := 15;
constant CR_N_SC_REGISTER: integer := 1;
constant CR_N_FF_REGISTER: integer := 2;
constant S_AXI_DATA_WIDTH: integer := 32;
constant S_AXI_ADDR_WIDTH: integer := (S_AXI_DATA_WIDTH/32) + log2(CR_N_REGISTER) + 1;

constant clk_period      : time := 1 us / fclock;
constant axi_clk_period  : time := 10 ns;

----
-- Signals
----
signal clk               : std_logic;
signal clk_ps_1mhz       : std_logic;
signal trig_in           : std_logic_vector (Ntrig_in-1 downto 0) := (others => '0');
signal busy_in           : std_logic_vector (Nbusy_in-1 downto 0) := (others => '0');
signal trig_out          : std_logic_vector (Ntrig_out-1 downto 0);
signal busy_out          : std_logic_vector (Nbusy_out-1 downto 0);
signal shutter_out       : std_logic_vector (Nshutter_out-1 downto 0);
signal S_AXI_ACLK        : std_logic := '0';
signal S_AXI_ARESETN     : std_logic := '1';
signal S_AXI_AWADDR      : std_logic_vector (S_AXI_ADDR_WIDTH-1 downto 0) := (others => '0');
signal S_AXI_AWPROT      : std_logic_vector (2 downto 0) := (others => '0');
signal S_AXI_AWVALID     : std_logic := '0';
signal S_AXI_AWREADY     : std_logic;
signal S_AXI_WDATA       : std_logic_vector (S_AXI_DATA_WIDTH-1 downto 0) := (others => '0');
signal S_AXI_WSTRB       : std_logic_vector ((S_AXI_DATA_WIDTH/8)-1 downto 0) := (others => '0');
signal S_AXI_WVALID      : std_logic := '0';
signal S_AXI_WREADY      : std_logic;
signal S_AXI_BRESP       : std_logic_vector (1 downto 0);
signal S_AXI_BVALID      : std_logic;
signal S_AXI_BREADY      : std_logic := '0';
signal S_AXI_ARADDR      : std_logic_vector (S_AXI_ADDR_WIDTH-1 downto 0) := (others => '0');
signal S_AXI_ARPROT      : std_logic_vector (2 downto 0) := (others => '0');
signal S_AXI_ARVALID     : std_logic:= '0';
signal S_AXI_ARREADY     : std_logic;
signal S_AXI_RDATA       : std_logic_vector (S_AXI_DATA_WIDTH-1 downto 0);
signal S_AXI_RRESP       : std_logic_vector (1 downto 0);
signal S_AXI_RVALID      : std_logic;
signal S_AXI_RREADY      : std_logic := '0';
-- Test Signals
signal axi_rx_data       : std_logic_vector (S_AXI_DATA_WIDTH-1 downto 0) := x"0000_0000"; 
signal axi_rx_dv         : std_logic := '0';

begin

uut: user_logic
generic map(
  fclock                 => fclock          ,
  Ntrig_in               => Ntrig_in        ,
  Ntrig_out              => Ntrig_out       ,
  Nshaper_width          => Nshaper_width   ,
  Nbusy_in               => Nbusy_in        ,
  Nbusy_out              => Nbusy_out       ,
  Nshutter_out           => Nshutter_out    ,
  S_AXI_DATA_WIDTH       => S_AXI_DATA_WIDTH,
  S_AXI_ADDR_WIDTH       => S_AXI_ADDR_WIDTH,
  CR_N_REGISTER          => CR_N_REGISTER   ,
  CR_N_RW_REGISTER       => CR_N_RW_REGISTER,
  CR_N_SC_REGISTER       => CR_N_SC_REGISTER,
  CR_N_FF_REGISTER       => CR_N_FF_REGISTER
)
port map(
  clk                    => clk          ,
  clk_ps_1MHz_in         => clk_ps_1mhz          ,
  rst_in                 => '0',
  trig_in                => trig_in      ,
  busy_in                => busy_in      ,
  trig_out               => trig_out     ,
  busy_out               => busy_out     ,
  shutter_out            => shutter_out  ,
  S_AXI_ACLK	           => S_AXI_ACLK	 ,
  S_AXI_ARESETN          => S_AXI_ARESETN,
  S_AXI_AWADDR           => S_AXI_AWADDR ,
  S_AXI_AWPROT           => S_AXI_AWPROT ,
  S_AXI_AWVALID          => S_AXI_AWVALID,
  S_AXI_AWREADY          => S_AXI_AWREADY,
  S_AXI_WDATA            => S_AXI_WDATA  ,
  S_AXI_WSTRB            => S_AXI_WSTRB  ,
  S_AXI_WVALID           => S_AXI_WVALID ,
  S_AXI_WREADY           => S_AXI_WREADY ,
  S_AXI_BRESP            => S_AXI_BRESP  ,
  S_AXI_BVALID           => S_AXI_BVALID ,
  S_AXI_BREADY           => S_AXI_BREADY ,
  S_AXI_ARADDR           => S_AXI_ARADDR ,
  S_AXI_ARPROT           => S_AXI_ARPROT ,
  S_AXI_ARVALID          => S_AXI_ARVALID,
  S_AXI_ARREADY          => S_AXI_ARREADY,
  S_AXI_RDATA            => S_AXI_RDATA  ,
  S_AXI_RRESP            => S_AXI_RRESP  ,
  S_AXI_RVALID           => S_AXI_RVALID ,
  S_AXI_RREADY           => S_AXI_RREADY 
);

----
-- CLK GEN
----
process begin
  clk <= '0';
  wait for 400 ns; -- Wait for global reset
  while true loop
    clk <= '0';
    wait for clk_period/2;
    clk <= '1'; 
    wait for clk_period/2;
  end loop;
end process;

process begin
  clk_ps_1mhz <= '0';
  wait for 400 ns; -- Wait for global reset
  while true loop
    clk_ps_1mhz <= '0';
    wait for 500 ns;
    clk_ps_1mhz <= '1'; 
    wait for 500 ns;
  end loop;
end process;

----
-- AXI CLK GEN
----
--process begin
--  S_AXI_ACLK <= '0';
--  wait for 400 ns; -- Wait for global reset
--  while 1 = 1 loop
--    S_AXI_ACLK <= '0';
--    wait for axi_clk_period/2;
--    S_AXI_ACLK <= '1'; 
--    wait for axi_clk_period/2;
--  end loop;
--end process;
S_AXI_ACLK <= clk;

----
-- AXI RST GEN
----
process begin
  S_AXI_ARESETN <= '0';
  wait for 1000 ns;
  S_AXI_ARESETN <= '1';
  wait;
end process;

----
-- TRIGGER
----
process 
variable i : integer range 0 to Ntrig_in-1 := 1;
begin
  trig_in <= (others => '0');
  wait until S_AXI_ARESETN = '1';
  wait for 1.1 us;
  
  wait for 50 us;
--  while true loop
--    trig_in(i) <= '1';
--    wait for 11 ns *i+11 ns;
--    trig_in(i) <= '0';
--    wait for 100 ns;
--    wait for 500 ns;
--    i := i+1;
--    if i = Ntrig_in then
--      i := 0;
--    end if;
--  end loop;
  while true loop
    trig_in(0) <= '1';
    wait for 101 ns;
    trig_in(0) <= '0';
    --wait for 10 us;
    wait for 1500 us;
  end loop;
  wait;
end process;

----
-- BUSY
----
process 
variable i : integer range 0 to Nbusy_in-1 := 0;
begin
  busy_in <= (others => '0');
  wait for 1.1 us;
  while true loop
    busy_in(i) <= '1';
    wait for 1157 ns;
    busy_in(i) <= '0';
    wait for 670 ns;
    i := i+1;
    if i = Nbusy_in then
      i := 0;
    end if;
  end loop;

  wait;
end process;

----
-- AXI TRANS GEN
----
axi_pr: process
constant ADDR_LSB          : integer := (S_AXI_DATA_WIDTH/32)+ 1;
constant OPT_MEM_ADDR_BITS : integer := log2(CR_N_REGISTER)-1;
--------------------
-- AXI Idle
--------------------
procedure axi_idle is
begin
  wait until falling_edge(S_AXI_ACLK);
  -- Address Write Channel
  S_AXI_AWADDR  <= (others => '0');
  S_AXI_AWPROT  <= (others => '0');
  S_AXI_AWVALID <= '0';
  -- Data Write Channel
  S_AXI_WDATA   <= x"0000_0000";
  S_AXI_WSTRB   <= (others => '0');
  S_AXI_WVALID  <= '0';
  -- Write Response Channel
  S_AXI_BREADY  <= '0';
  -- Address Read Channel
  S_AXI_ARADDR  <= (others => '0');
  S_AXI_ARPROT  <= (others => '0');
  S_AXI_ARVALID <= '0';
  -- Data Read Channel
  S_AXI_RREADY  <= '0';
  wait until rising_edge(S_AXI_ACLK);
end procedure;
--------------------
-- AXI Read
--------------------
--procedure axi_read (Address: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0) ) is
procedure axi_read (Address: integer ) is
begin
  wait until rising_edge(S_AXI_ACLK);
  -- Set Read Address
  S_AXI_ARADDR <= std_logic_vector(to_unsigned(Address, OPT_MEM_ADDR_BITS+1)) & std_logic_vector(to_unsigned(0, ADDR_LSB));
  -- Assert Read Address Valid
  S_AXI_ARVALID <= '1';
  wait until S_AXI_ARREADY='1';
  wait until rising_edge(S_AXI_ACLK); 
  -- Read Address Channel Done
  S_AXI_ARVALID <= '0';
  -- Ready to read data
  S_AXI_RREADY <= '1';
  -- Wait for read valid data
  wait until S_AXI_RVALID='1';
  wait until rising_edge(S_AXI_ACLK);
  -- Check read response is successful
  if (S_AXI_RRESP = "00") then
    axi_rx_data <= S_AXI_RDATA;
    axi_rx_dv   <= '1';
  else
    axi_rx_data <= x"FF00_00FF";
  end if;
  -- Read Data Channel Done 
  S_AXI_RREADY <= '0';
  wait until rising_edge(S_AXI_ACLK);
  axi_rx_dv   <= '0';
end procedure;
--------------------
-- AXI Write
--------------------
--procedure axi_write (Address: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0); Data: STD_LOGIC_VECTOR (C_S_AXI_DATA_WIDTH-1 downto 0) ) is
procedure axi_write (Address: integer; Data: integer ) is
  constant timeout      : integer   := 8;
  variable timeout_cnt  : integer   := 0;
  variable awready_flag : std_logic := '0';
  variable wready_flag  : std_logic := '0';
begin
  wait until rising_edge(S_AXI_ACLK);
  -- Ready to accept BRESP
  S_AXI_BREADY <= '1';
  -- Set Write Address
  S_AXI_AWADDR <= std_logic_vector(to_unsigned(Address, OPT_MEM_ADDR_BITS+1)) & std_logic_vector(to_unsigned(0, ADDR_LSB));
  -- Assert Write Address Valid
  S_AXI_AWVALID <= '1';
  -- Set Write Data
  S_AXI_WDATA <= std_logic_vector(to_unsigned(Data, S_AXI_DATA_WIDTH));
  -- Assert Write Data Valid
  S_AXI_WVALID <= '1';
  -- Write Enable for All Bytes
  S_AXI_WSTRB <= (others => '1');
  while (awready_flag /= '1' or wready_flag /= '1') and (timeout_cnt /= timeout) loop
    wait until rising_edge(S_AXI_ACLK); 
    if (S_AXI_AWREADY='1') then
      S_AXI_AWVALID <= '0';
      awready_flag  := '1';
    end if;
    if (S_AXI_WREADY='1') then
      S_AXI_WVALID <= '0';
      wready_flag  := '1';
    end if;
    timeout_cnt := timeout_cnt + 1;
  end loop;
  S_AXI_AWVALID <= '0';
  S_AXI_WVALID <= '0';
  if S_AXI_BVALID/='1' then
    wait until S_AXI_BVALID='1';
  end if;
  assert (S_AXI_BRESP = "00") report " ------  ERROR: WRITE PROCESS FAILED." severity FAILURE;
  wait until rising_edge(S_AXI_ACLK);
  S_AXI_BREADY <= '0';
end procedure;
  
begin
  wait until S_AXI_ARESETN = '1';
  axi_idle;
  wait until rising_edge(S_AXI_ACLK);
  -- Test SC Reg 0
  --axi_write(0, 1);
  --axi_write(0, -2**30);
  -- Reset LOGIC
  axi_write(1, 1);
  report "-- Write 1 @ RW Reg 0 (Reset LOGIC):";
  -- Read Reg 0
  axi_read(1);
  report "   Read Reg 0: " & integer'image(to_integer(unsigned(axi_rx_data)));
  -- Reset LOGIC
  axi_write(1, 0);
  report "-- Write 1 @ RW Reg 0 (Reset LOGIC):";
  -- Read Test Registers
   -- Read Reg 16
  axi_read(16);
  report "   Read Reg 16: " & integer'image(to_integer(unsigned(axi_rx_data)));
  -- Read Reg 17
  axi_read(17);
  report "   Read Reg 17: " & integer'image(to_integer(unsigned(axi_rx_data)));

  -- Read FIFO still empty
  axi_read(30);
  report "   Read Reg 30: " & integer'image(to_integer(unsigned(axi_rx_data)));
  axi_read(31);
  report "   Read Reg 31: " & integer'image(to_integer(unsigned(axi_rx_data)));
 
 --Enable trig 0 
--axi_write(2, 500*(2**16)+255);
  
  -- Enable BTF trig and Correlated trigg, with about 1 ms delay (1.024 ms)
  axi_write( 2, (2**10-1)*2**16 + 2**7 + 1);
  axi_write(14, 2**16 + 1);
    
  -- Enable All triggers
  --axi_write(2, 2**8-1 + (2**4-1)*2**8);
  
  -- Start of run
  axi_write(0, 1);
  
--  --Read fifo with data
--  wait for 2 us;
--  axi_read(30);
--  report "   Read Reg 30: " & integer'image(to_integer(unsigned(axi_rx_data)));
--  axi_read(31);
--  report "   Read Reg 31: " & integer'image(to_integer(unsigned(axi_rx_data)));
  
--  -- Read busy reg
--  wait for 20 us;
--  for i in 0 to Nbusy_in loop
--    axi_read(i+20);
--    report "   Read Reg " & integer'image(i+20) & ": " & integer'image(to_integer(unsigned(axi_rx_data)));
--  end loop;
--  -- Reset busy reg
--    axi_write(0, (2**(Nbusy_in+1)-1)*2**4);
--  -- Read busy reg
--  for i in 0 to Nbusy_in loop
--    axi_read(i+20);
--    report "   Read Reg " & integer'image(i+20) & ": " & integer'image(to_integer(unsigned(axi_rx_data)));
--  end loop;
  
  
  wait for 100 us;
  
  --Read fifo with data
  axi_read(30);
  report "   Read Reg 30: " & integer'image(to_integer(unsigned(axi_rx_data)));
  axi_read(31);
  report "   Read Reg 31: " & integer'image(to_integer(unsigned(axi_rx_data)));
  --Read fifo with data
  axi_read(30);
  report "   Read Reg 30: " & integer'image(to_integer(unsigned(axi_rx_data)));
  axi_read(31);
  report "   Read Reg 31: " & integer'image(to_integer(unsigned(axi_rx_data)));
  --Read fifo with data
  axi_read(30);
  report "   Read Reg 30: " & integer'image(to_integer(unsigned(axi_rx_data)));
  axi_read(31);
  report "   Read Reg 31: " & integer'image(to_integer(unsigned(axi_rx_data)));
  
  wait for 10 us;
  
   -- Stop of run
   --axi_write(0, 2);
  
  -- Enable corr trig
  --axi_write(15, 2+2**17+2**16);
  -- Enable rand trig
  --axi_write(14, 3+2**17);
  wait;
  
end process;

end architecture aa;