#!/bin/sh

# 
# Vivado(TM)
# runme.sh: a Vivado-generated Runs Script for UNIX
# Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
# 

if [ -z "$PATH" ]; then
  PATH=/eda/Xilinx/Vivado_HLS/2017.4/SDK/2017.4/bin:/eda/Xilinx/Vivado_HLS/2017.4/Vivado/2017.4/ids_lite/ISE/bin/lin64:/eda/Xilinx/Vivado_HLS/2017.4/Vivado/2017.4/bin
else
  PATH=/eda/Xilinx/Vivado_HLS/2017.4/SDK/2017.4/bin:/eda/Xilinx/Vivado_HLS/2017.4/Vivado/2017.4/ids_lite/ISE/bin/lin64:/eda/Xilinx/Vivado_HLS/2017.4/Vivado/2017.4/bin:$PATH
fi
export PATH

if [ -z "$LD_LIBRARY_PATH" ]; then
  LD_LIBRARY_PATH=/eda/Xilinx/Vivado_HLS/2017.4/Vivado/2017.4/ids_lite/ISE/lib/lin64
else
  LD_LIBRARY_PATH=/eda/Xilinx/Vivado_HLS/2017.4/Vivado/2017.4/ids_lite/ISE/lib/lin64:$LD_LIBRARY_PATH
fi
export LD_LIBRARY_PATH

HD_PWD='/home/alp/Documents/Xilinx/vivado17.4/PADME_trigger_v3_1/PADME_trigger_v3_1.runs/system_rst_ps7_0_1M_0_synth_1'
cd "$HD_PWD"

HD_LOG=runme.log
/bin/touch $HD_LOG

ISEStep="./ISEWrap.sh"
EAStep()
{
     $ISEStep $HD_LOG "$@" >> $HD_LOG 2>&1
     if [ $? -ne 0 ]
     then
         exit
     fi
}

EAStep vivado -log system_rst_ps7_0_1M_0.vds -m64 -product Vivado -mode batch -messageDb vivado.pb -notrace -source system_rst_ps7_0_1M_0.tcl