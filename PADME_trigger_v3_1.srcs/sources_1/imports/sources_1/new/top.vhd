--Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2017.4 (lin64) Build 2086221 Fri Dec 15 20:54:30 MST 2017
--Date        : Thu Mar  1 13:10:44 2018
--Host        : selfcad2 running 64-bit Scientific Linux release 7.4 (Nitrogen)
--Command     : generate_target System_wrapper.bd
--Design      : System_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity top is
generic(
  Ntrig_in               : integer  := 6;
  Ntrig_out              : integer  := 3;
  Nshaper_width          : integer  := 2;
  Nbusy_in               : integer  := 4;
  Nbusy_out              : integer  := 2;
  Nshutter_out           : integer  := 2;
  CR_N_REGISTER          : integer  := 32;
  CR_N_RW_REGISTER       : integer  := 15;
  CR_N_SC_REGISTER       : integer  :=  1;
  CR_N_FF_REGISTER       : integer  :=  2;
  CR_S_AXI_DATA_WIDTH    : integer  := 32;
  CR_S_AXI_ADDR_WIDTH    : integer  := 7 -- AXI_ADDR_WIDTH>= (C_S_AXI_DATA_WIDTH/32) + log2(N_REGISTER) + 1
);
port (
  clk_in_p               : in  std_logic;
  clk_in_n               : in  std_logic;
  EN_40MHz               : out std_logic;
  RST_I2C                : out std_logic;
  pTrigger_in_0          : in  std_logic;
  nTrigger_in_0          : in  std_logic;
  pTrigger_in_1          : in  std_logic;
  nTrigger_in_1          : in  std_logic;
  pTrigger_in_2          : in  std_logic;
  nTrigger_in_2          : in  std_logic;
  pTrigger_in_3          : in  std_logic;
  nTrigger_in_3          : in  std_logic;
  pTrigger_in_4          : in  std_logic;
  nTrigger_in_4          : in  std_logic;
  pTrigger_in_5          : in  std_logic;
  nTrigger_in_5          : in  std_logic;
  pBUSY_in_0             : in  std_logic;
  nBUSY_in_0             : in  std_logic;
  pBUSY_in_1             : in  std_logic;
  nBUSY_in_1             : in  std_logic;
  pBUSY_in_2             : in  std_logic;
  nBUSY_in_2             : in  std_logic;
  pBUSY_in_3             : in  std_logic;
  nBUSY_in_3             : in  std_logic;
  pT2PIX3                : out std_logic;
  nT2PIX3                : out std_logic;
  pTSHUTTERPIX3          : out std_logic;
  nTSHUTTERPIX3          : out std_logic;
  pT2MIMOSA              : out std_logic;
  nT2MIMOSA              : out std_logic;
  pTSHUTTER_MIMOSA       : out std_logic;
  nTSHUTTER_MIMOSA       : out std_logic;
  pTRG_CAL               : out std_logic;
  nTRG_CAL               : out std_logic;
--  pVETO_0                : out std_logic;
--  nVETO_0                : out std_logic;
--  pVETO_1                : out std_logic;
--  nVETO_1                : out std_logic;
  pBUSY_out_0            : out std_logic;
  nBUSY_out_0            : out std_logic;
  pBUSY_out_1            : out std_logic;
  nBUSY_out_1            : out std_logic;
  DDR_addr               : inout STD_LOGIC_VECTOR ( 14 downto 0 );
  DDR_ba                 : inout STD_LOGIC_VECTOR ( 2 downto 0 );
  DDR_cas_n              : inout STD_LOGIC;
  DDR_ck_n               : inout STD_LOGIC;
  DDR_ck_p               : inout STD_LOGIC;
  DDR_cke                : inout STD_LOGIC;
  DDR_cs_n               : inout STD_LOGIC;
  DDR_dm                 : inout STD_LOGIC_VECTOR ( 3 downto 0 );
  DDR_dq                 : inout STD_LOGIC_VECTOR ( 31 downto 0 );
  DDR_dqs_n              : inout STD_LOGIC_VECTOR ( 3 downto 0 );
  DDR_dqs_p              : inout STD_LOGIC_VECTOR ( 3 downto 0 );
  DDR_odt                : inout STD_LOGIC;
  DDR_ras_n              : inout STD_LOGIC;
  DDR_reset_n            : inout STD_LOGIC;
  DDR_we_n               : inout STD_LOGIC;
  FIXED_IO_ddr_vrn       : inout STD_LOGIC;
  FIXED_IO_ddr_vrp       : inout STD_LOGIC;
  FIXED_IO_mio           : inout STD_LOGIC_VECTOR ( 53 downto 0 );
  FIXED_IO_ps_clk        : inout STD_LOGIC;
  FIXED_IO_ps_porb       : inout STD_LOGIC;
  FIXED_IO_ps_srstb      : inout STD_LOGIC;
  IIC_0_0_scl_io         : inout STD_LOGIC;
  IIC_0_0_sda_io         : inout STD_LOGIC;
  IIC_1_0_scl_io         : inout STD_LOGIC;
  IIC_1_0_sda_io         : inout STD_LOGIC
);
end top;

architecture rtl of top is

----
-- Constant
----
constant fclock_in       : integer := 40; -- [MHz]
constant clk_mult        : integer := 2;
constant clk_div         : integer := 1;
constant fclock          : integer := fclock_in*clk_mult/clk_div;

component clk_wiz_0
port
 (-- Clock in ports
  -- Clock out ports
  clk_out1          : out    std_logic;
  -- Status and control signals
  locked            : out    std_logic;
  clk_in1_p         : in     std_logic;
  clk_in1_n         : in     std_logic
 );
end component;

component System_wrapper is
port (
  -- IO PORT
  DDR_addr               : inout STD_LOGIC_VECTOR ( 14 downto 0 );
  DDR_ba                 : inout STD_LOGIC_VECTOR ( 2 downto 0 );
  DDR_cas_n              : inout STD_LOGIC;
  DDR_ck_n               : inout STD_LOGIC;
  DDR_ck_p               : inout STD_LOGIC;
  DDR_cke                : inout STD_LOGIC;
  DDR_cs_n               : inout STD_LOGIC;
  DDR_dm                 : inout STD_LOGIC_VECTOR ( 3 downto 0 );
  DDR_dq                 : inout STD_LOGIC_VECTOR ( 31 downto 0 );
  DDR_dqs_n              : inout STD_LOGIC_VECTOR ( 3 downto 0 );
  DDR_dqs_p              : inout STD_LOGIC_VECTOR ( 3 downto 0 );
  DDR_odt                : inout STD_LOGIC;
  DDR_ras_n              : inout STD_LOGIC;
  DDR_reset_n            : inout STD_LOGIC;
  DDR_we_n               : inout STD_LOGIC;
  FIXED_IO_ddr_vrn       : inout STD_LOGIC;
  FIXED_IO_ddr_vrp       : inout STD_LOGIC;
  FIXED_IO_mio           : inout STD_LOGIC_VECTOR ( 53 downto 0 );
  FIXED_IO_ps_clk        : inout STD_LOGIC;
  FIXED_IO_ps_porb       : inout STD_LOGIC;
  FIXED_IO_ps_srstb      : inout STD_LOGIC;
  IIC_0_0_scl_io         : inout STD_LOGIC;
  IIC_0_0_sda_io         : inout STD_LOGIC;
  IIC_1_0_scl_io         : inout STD_LOGIC;
  IIC_1_0_sda_io         : inout STD_LOGIC;
  LOCKED                 : in  STD_LOGIC;
  rst                    : out STD_LOGIC_VECTOR ( 0 to 0 );
  FCLK_CLK1_MHZ          : out STD_LOGIC;
  -- M00_AXI4
  ACLK                   : in  STD_LOGIC;
  ARESETN                : out STD_LOGIC;
  M00_AXI_0_araddr       : out STD_LOGIC_VECTOR ( 31 downto 0 );
  M00_AXI_0_arprot       : out STD_LOGIC_VECTOR ( 2 downto 0 );
  M00_AXI_0_arready      : in  STD_LOGIC;
  M00_AXI_0_arvalid      : out STD_LOGIC;
  M00_AXI_0_awaddr       : out STD_LOGIC_VECTOR ( 31 downto 0 );
  M00_AXI_0_awprot       : out STD_LOGIC_VECTOR ( 2 downto 0 );
  M00_AXI_0_awready      : in  STD_LOGIC;
  M00_AXI_0_awvalid      : out STD_LOGIC;
  M00_AXI_0_bready       : out STD_LOGIC;
  M00_AXI_0_bresp        : in  STD_LOGIC_VECTOR ( 1 downto 0 );
  M00_AXI_0_bvalid       : in  STD_LOGIC;
  M00_AXI_0_rdata        : in  STD_LOGIC_VECTOR ( CR_S_AXI_DATA_WIDTH-1 downto 0 );
  M00_AXI_0_rready       : out STD_LOGIC;
  M00_AXI_0_rresp        : in  STD_LOGIC_VECTOR ( 1 downto 0 );
  M00_AXI_0_rvalid       : in  STD_LOGIC;
  M00_AXI_0_wdata        : out STD_LOGIC_VECTOR ( CR_S_AXI_DATA_WIDTH-1 downto 0 );
  M00_AXI_0_wready       : in  STD_LOGIC;
  M00_AXI_0_wstrb        : out STD_LOGIC_VECTOR ( 3 downto 0 );
  M00_AXI_0_wvalid       : out STD_LOGIC
);
end component System_wrapper;

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
  sin_fb                 : in  std_logic;
  trig_in                : in  std_logic_vector (Ntrig_in-1 downto 0);
  busy_in                : in  std_logic_vector (Nbusy_in-1 downto 0);
  trig_out               : out std_logic_vector (Ntrig_out-1 downto 0);
  busy_out               : out std_logic_vector (Nbusy_out-1 downto 0);
  shutter_out            : out std_logic_vector (Nshutter_out-1 downto 0);
  S_AXI_ACLK	           : in  std_logic;
  S_AXI_ARESETN          : in  std_logic;
  S_AXI_AWADDR           : in  std_logic_vector (S_AXI_ADDR_WIDTH-1 downto 0);
  S_AXI_AWPROT           : in  std_logic_vector (2 downto 0);
  S_AXI_AWVALID          : in  std_logic;
  S_AXI_AWREADY          : out std_logic;
  S_AXI_WDATA            : in  std_logic_vector (S_AXI_DATA_WIDTH-1 downto 0);
  S_AXI_WSTRB            : in  std_logic_vector ((S_AXI_DATA_WIDTH/8)-1 downto 0);
  S_AXI_WVALID           : in  std_logic;
  S_AXI_WREADY           : out std_logic;
  S_AXI_BRESP            : out std_logic_vector (1 downto 0);
  S_AXI_BVALID           : out std_logic;
  S_AXI_BREADY           : in  std_logic;
  S_AXI_ARADDR           : in  std_logic_vector (S_AXI_ADDR_WIDTH-1 downto 0);
  S_AXI_ARPROT           : in  std_logic_vector (2 downto 0);
  S_AXI_ARVALID          : in  std_logic;
  S_AXI_ARREADY          : out std_logic;
  S_AXI_RDATA            : out std_logic_vector (S_AXI_DATA_WIDTH-1 downto 0);
  S_AXI_RRESP            : out std_logic_vector (1 downto 0);
  S_AXI_RVALID           : out std_logic;
  S_AXI_RREADY           : in  std_logic
);
end component user_logic;

-- IO signals
signal trig_in_p              : std_logic_vector (Ntrig_in-1 downto 0);
signal trig_in_n              : std_logic_vector (Ntrig_in-1 downto 0);
signal busy_in_p              : std_logic_vector (Nbusy_in-1 downto 0);
signal busy_in_n              : std_logic_vector (Nbusy_in-1 downto 0);
signal trig_out_p             : std_logic_vector (Ntrig_out-1 downto 0);
signal trig_out_n             : std_logic_vector (Ntrig_out-1 downto 0);
signal busy_out_p             : std_logic_vector (Nbusy_out-1 downto 0);
signal busy_out_n             : std_logic_vector (Nbusy_out-1 downto 0);
signal shutter_out_p          : std_logic_vector (Nshutter_out-1 downto 0);
signal shutter_out_n          : std_logic_vector (Nshutter_out-1 downto 0);

signal clk_in            : std_logic;
signal clk               : std_logic;
signal clk_ps_1MHz       : std_logic;
signal locked            : std_logic;
signal rst               : std_logic;
signal trig_in           : std_logic_vector (Ntrig_in-1 downto 0);
signal trig_in_remapped  : std_logic_vector (Ntrig_in-1 downto 0);
signal sin_fb            : std_logic;
signal busy_in           : std_logic_vector (Nbusy_in-1 downto 0);
signal trig_out          : std_logic_vector (Ntrig_out-1 downto 0);
signal busy_out          : std_logic_vector (Nbusy_out-1 downto 0);
signal shutter_out       : std_logic_vector (Nshutter_out-1 downto 0);
  
-- AXI4LITE COMMON
signal AXI_ACLK          : STD_LOGIC;
signal AXI_ARESETN       : STD_LOGIC;
-- AXI4LITE Config Regs
signal CR_AXI_araddr     : STD_LOGIC_VECTOR ( 31 downto 0 ) := (others => '0');
signal CR_AXI_arprot     : STD_LOGIC_VECTOR ( 2 downto 0 );
signal CR_AXI_arready    : STD_LOGIC;
signal CR_AXI_arvalid    : STD_LOGIC;
signal CR_AXI_awaddr     : STD_LOGIC_VECTOR ( 31 downto 0 ) := (others => '0');
signal CR_AXI_awprot     : STD_LOGIC_VECTOR ( 2 downto 0 );
signal CR_AXI_awready    : STD_LOGIC;
signal CR_AXI_awvalid    : STD_LOGIC;
signal CR_AXI_bready     : STD_LOGIC;
signal CR_AXI_bresp      : STD_LOGIC_VECTOR ( 1 downto 0 );
signal CR_AXI_bvalid     : STD_LOGIC;
signal CR_AXI_rdata      : STD_LOGIC_VECTOR ( CR_S_AXI_DATA_WIDTH-1 downto 0 );
signal CR_AXI_rready     : STD_LOGIC;
signal CR_AXI_rresp      : STD_LOGIC_VECTOR ( 1 downto 0 );
signal CR_AXI_rvalid     : STD_LOGIC;
signal CR_AXI_wdata      : STD_LOGIC_VECTOR ( CR_S_AXI_DATA_WIDTH-1 downto 0 );
signal CR_AXI_wready     : STD_LOGIC;
signal CR_AXI_wstrb      : STD_LOGIC_VECTOR ( 3 downto 0 );
signal CR_AXI_wvalid     : STD_LOGIC;

begin

-- IO assignments
--  Ntrig_in               : integer  := 6;
trig_in_p(0)           <= pTrigger_in_0;
trig_in_n(0)           <= nTrigger_in_0;
trig_in_p(1)           <= pTrigger_in_1;
trig_in_n(1)           <= nTrigger_in_1;
trig_in_p(2)           <= pTrigger_in_2;
trig_in_n(2)           <= nTrigger_in_2;
trig_in_p(3)           <= pTrigger_in_3;
trig_in_n(3)           <= nTrigger_in_3;
trig_in_p(4)           <= pTrigger_in_4;
trig_in_n(4)           <= nTrigger_in_4;
trig_in_p(5)           <= pTrigger_in_5;
trig_in_n(5)           <= nTrigger_in_5;
--  Ntrig_out              : integer  := 3;
pTRG_CAL               <= trig_out_p(0);
nTRG_CAL               <= trig_out_n(0);
pT2MIMOSA              <= trig_out_p(1);
nT2MIMOSA              <= trig_out_n(1);
pT2PIX3                <= trig_out_p(2);
nT2PIX3                <= trig_out_n(2);
--  Nbusy_in               : integer  := 4;
busy_in_p(0)           <= pBUSY_in_0;
busy_in_n(0)           <= nBUSY_in_0;
busy_in_p(1)           <= pBUSY_in_1;
busy_in_n(1)           <= nBUSY_in_1;
busy_in_p(2)           <= pBUSY_in_2;
busy_in_n(2)           <= nBUSY_in_2;
busy_in_p(3)           <= pBUSY_in_3;
busy_in_n(3)           <= nBUSY_in_3;
--  Nbusy_out              : integer  := 2;
pBUSY_out_0            <= busy_out_p(0);
nBUSY_out_0            <= busy_out_n(0);
pBUSY_out_1            <= busy_out_p(1);
nBUSY_out_1            <= busy_out_n(1);
--  Nshutter_out           : integer  := 2;
pTSHUTTER_MIMOSA       <= shutter_out_p(0);
nTSHUTTER_MIMOSA       <= shutter_out_n(0);
pTSHUTTERPIX3          <= shutter_out_p(1);
nTSHUTTERPIX3          <= shutter_out_n(1);


System_inst: System_wrapper 
  port map(
  -- IO PORT
  DDR_addr               => DDR_addr         ,
  DDR_ba                 => DDR_ba           ,
  DDR_cas_n              => DDR_cas_n        ,
  DDR_ck_n               => DDR_ck_n         ,
  DDR_ck_p               => DDR_ck_p         ,
  DDR_cke                => DDR_cke          ,
  DDR_cs_n               => DDR_cs_n         ,
  DDR_dm                 => DDR_dm           ,
  DDR_dq                 => DDR_dq           ,
  DDR_dqs_n              => DDR_dqs_n        ,
  DDR_dqs_p              => DDR_dqs_p        ,
  DDR_odt                => DDR_odt          ,
  DDR_ras_n              => DDR_ras_n        ,
  DDR_reset_n            => DDR_reset_n      ,
  DDR_we_n               => DDR_we_n         ,
  FIXED_IO_ddr_vrn       => FIXED_IO_ddr_vrn ,
  FIXED_IO_ddr_vrp       => FIXED_IO_ddr_vrp ,
  FIXED_IO_mio           => FIXED_IO_mio     ,
  FIXED_IO_ps_clk        => FIXED_IO_ps_clk  ,
  FIXED_IO_ps_porb       => FIXED_IO_ps_porb ,
  FIXED_IO_ps_srstb      => FIXED_IO_ps_srstb,
  IIC_0_0_scl_io         => IIC_0_0_scl_io   ,
  IIC_0_0_sda_io         => IIC_0_0_sda_io   ,
  IIC_1_0_scl_io         => IIC_1_0_scl_io   ,
  IIC_1_0_sda_io         => IIC_1_0_sda_io   ,
  locked                 => locked           ,
  rst(0)                 => rst,--open             ,
  FCLK_CLK1_MHZ          => clk_ps_1MHz,
  -- M00_AXI4
  ACLK                   => AXI_ACLK      ,
  ARESETN                => AXI_ARESETN   ,
  M00_AXI_0_araddr       => CR_AXI_araddr ,
  M00_AXI_0_arprot       => CR_AXI_arprot ,
  M00_AXI_0_arready      => CR_AXI_arready,
  M00_AXI_0_arvalid      => CR_AXI_arvalid,
  M00_AXI_0_awaddr       => CR_AXI_awaddr ,
  M00_AXI_0_awprot       => CR_AXI_awprot ,
  M00_AXI_0_awready      => CR_AXI_awready,
  M00_AXI_0_awvalid      => CR_AXI_awvalid,
  M00_AXI_0_bready       => CR_AXI_bready ,
  M00_AXI_0_bresp        => CR_AXI_bresp  ,
  M00_AXI_0_bvalid       => CR_AXI_bvalid ,
  M00_AXI_0_rdata        => CR_AXI_rdata  ,
  M00_AXI_0_rready       => CR_AXI_rready ,
  M00_AXI_0_rresp        => CR_AXI_rresp  ,
  M00_AXI_0_rvalid       => CR_AXI_rvalid ,
  M00_AXI_0_wdata        => CR_AXI_wdata  ,
  M00_AXI_0_wready       => CR_AXI_wready ,
  M00_AXI_0_wstrb        => CR_AXI_wstrb  ,
  M00_AXI_0_wvalid       => CR_AXI_wvalid 
);

user_logic_i: user_logic
generic map(
  fclock                 => fclock              ,
  Ntrig_in               => Ntrig_in            ,
  Ntrig_out              => Ntrig_out           ,
  Nshaper_width          => Nshaper_width       ,
  Nbusy_in               => Nbusy_in            ,
  Nbusy_out              => Nbusy_out           ,
  Nshutter_out           => Nshutter_out        ,
  S_AXI_DATA_WIDTH       => CR_S_AXI_DATA_WIDTH ,
  S_AXI_ADDR_WIDTH       => CR_S_AXI_ADDR_WIDTH ,
  CR_N_REGISTER          => CR_N_REGISTER       ,
  CR_N_RW_REGISTER       => CR_N_RW_REGISTER    ,
  CR_N_SC_REGISTER       => CR_N_SC_REGISTER    ,
  CR_N_FF_REGISTER       => CR_N_FF_REGISTER 
)
port map(
  clk                    => clk            ,
  clk_ps_1MHz_in         => clk_ps_1MHz    ,
  rst_in                 => rst            ,
  trig_in                => trig_in_remapped        ,
  sin_fb                 => sin_fb,
  busy_in                => busy_in        ,
  trig_out               => trig_out       ,
  busy_out               => busy_out       ,
  shutter_out            => shutter_out    ,
  S_AXI_ACLK	           => AXI_ACLK       ,
  S_AXI_ARESETN          => AXI_ARESETN    ,
  S_AXI_AWADDR           => CR_AXI_AWADDR(CR_S_AXI_ADDR_WIDTH-1 downto 0)  ,
  S_AXI_AWPROT           => CR_AXI_AWPROT  ,
  S_AXI_AWVALID          => CR_AXI_AWVALID ,
  S_AXI_AWREADY          => CR_AXI_AWREADY ,
  S_AXI_WDATA            => CR_AXI_WDATA   ,
  S_AXI_WSTRB            => CR_AXI_WSTRB   ,
  S_AXI_WVALID           => CR_AXI_WVALID  ,
  S_AXI_WREADY           => CR_AXI_WREADY  ,
  S_AXI_BRESP            => CR_AXI_BRESP   ,
  S_AXI_BVALID           => CR_AXI_BVALID  ,
  S_AXI_BREADY           => CR_AXI_BREADY  ,
  S_AXI_ARADDR           => CR_AXI_ARADDR(CR_S_AXI_ADDR_WIDTH-1 downto 0)  ,
  S_AXI_ARPROT           => CR_AXI_ARPROT  ,
  S_AXI_ARVALID          => CR_AXI_ARVALID ,
  S_AXI_ARREADY          => CR_AXI_ARREADY ,
  S_AXI_RDATA            => CR_AXI_RDATA   ,
  S_AXI_RRESP            => CR_AXI_RRESP   ,
  S_AXI_RVALID           => CR_AXI_RVALID  ,
  S_AXI_RREADY           => CR_AXI_RREADY  
);

clk_network : clk_wiz_0
   port map ( 
  -- Clock out ports  
   clk_out1 => clk_in,
  -- Status and control signals                
   locked => locked,
   -- Clock in ports
   clk_in1_p => clk_in_p,
   clk_in1_n => clk_in_n
 );
 --rst <= not locked;
 AXI_ACLK <= clk_in;
 clk <= clk_in;
 
 EN_40MHz <= '1';
 RST_I2C <= '1';
 
--IBUFDS_inst : IBUFDS
--generic map (
--  DIFF_TERM => TRUE,
--  IBUF_LOW_PWR => FALSE,
--  IOSTANDARD => "LVDS_25")
--port map (
--  O  => clk_in,
--  I  => clk_in_p, 
--  IB => clk_in_n
--);

g_trig_in: for i in 0 to Ntrig_in-1 generate
  IBUFDS_inst_x: IBUFDS
  generic map (
    DIFF_TERM => TRUE,
    IBUF_LOW_PWR => FALSE,
    IOSTANDARD => "LVDS_25")
  port map (
    O  => trig_in(i),
    I  => trig_in_p(i),
    IB => trig_in_n(i)
  );
end generate;
--trig_in_remapped <= not (trig_in(4) & trig_in(5) & trig_in(2) & trig_in(3) & trig_in(0) & trig_in(1));
trig_in_remapped <= not ('1' & trig_in(5) & trig_in(2) & trig_in(3) & trig_in(0) & trig_in(1));
sin_fb           <= not trig_in(4);

g_busy_in: for i in 0 to Nbusy_in-1 generate
  IBUFDS_inst_x : IBUFDS
  generic map (
    DIFF_TERM => TRUE,
    IBUF_LOW_PWR => FALSE,
    IOSTANDARD => "LVDS_25")
  port map (
    O  => busy_in(i),
    I  => busy_in_p(i),
    IB => busy_in_n(i)
  );
--  PULLUP_inst_x : PULLUP
--  port map (
--     O => busy_in(i)     -- Pullup output (connect directly to top-level port)
--  );
--  --PULLDOWN_inst_x : PULLDOWN
--  --port map (
--  --   O => trig_in_n(i)     -- Pulldown output (connect directly to top-level port)
--  --);
--  -- Nota: for pulldown run this tcl command: set_param iconstr.diffPairPulltype opposite
end generate;

g_trig_out: for i in 0 to Ntrig_out-1 generate
  OBUFDS_inst_x: OBUFDS
  generic map (
    IOSTANDARD => "LVDS_25",
    SLEW => "FAST")
  port map (
    O  => trig_out_p(i),
    OB => trig_out_n(i),
    I  => trig_out(i)
  );
end generate;

g_busy_out: for i in 0 to Nbusy_out-1 generate
  OBUFDS_inst_x: OBUFDS
  generic map (
    IOSTANDARD => "LVDS_25",
    SLEW => "FAST")
  port map (
    O  => busy_out_p(i),
    OB => busy_out_n(i),
    I  => busy_out(i)
  );
end generate;

g_shutter_out: for i in 0 to Nshutter_out-1 generate
  OBUFDS_inst_x: OBUFDS
  generic map (
    IOSTANDARD => "LVDS_25",
    SLEW => "FAST")
  port map (
    O  => shutter_out_p(i),
    OB => shutter_out_n(i),
    I  => shutter_out(i)
  );
end generate;


end rtl;
