// Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2017.4 (lin64) Build 2086221 Fri Dec 15 20:54:30 MST 2017
// Date        : Tue Apr 17 15:13:50 2018
// Host        : selfcad2.lnf.infn.it running 64-bit Scientific Linux release 7.4 (Nitrogen)
// Command     : write_verilog -force -mode synth_stub
//               /home/alp/Documents/Xilinx/vivado17.4/PADME_trigger/PADME_trigger.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0_stub.v
// Design      : clk_wiz_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module clk_wiz_0(clk_out1, locked, clk_in1_p, clk_in1_n)
/* synthesis syn_black_box black_box_pad_pin="clk_out1,locked,clk_in1_p,clk_in1_n" */;
  output clk_out1;
  output locked;
  input clk_in1_p;
  input clk_in1_n;
endmodule
