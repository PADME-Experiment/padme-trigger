#!/bin/bash -f
# ****************************************************************************
# Vivado (TM) v2017.4 (64-bit)
#
# Filename    : elaborate.sh
# Simulator   : Xilinx Vivado Simulator
# Description : Script for elaborating the compiled design
#
# Generated by Vivado on Thu Nov 15 10:17:48 CET 2018
# SW Build 2086221 on Fri Dec 15 20:54:30 MST 2017
#
# Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
#
# usage: elaborate.sh
#
# ****************************************************************************
ExecStep()
{
"$@"
RETVAL=$?
if [ $RETVAL -ne 0 ]
then
exit $RETVAL
fi
}
ExecStep xelab -wto c2d1fe49525d42f5ac50f424f7cb4450 --incr --debug typical --relax --mt 8 -L fifo_generator_v13_2_1 -L xil_defaultlib -L xilinx_vip -L unisims_ver -L unimacro_ver -L secureip -L xpm --snapshot e_behav xil_defaultlib.e xil_defaultlib.glbl -log elaborate.log
