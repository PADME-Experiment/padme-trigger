# 
# Synthesis run script generated by Vivado
# 

proc create_report { reportName command } {
  set status "."
  append status $reportName ".fail"
  if { [file exists $status] } {
    eval file delete [glob $status]
  }
  send_msg_id runtcl-4 info "Executing : $command"
  set retval [eval catch { $command } msg]
  if { $retval != 0 } {
    set fp [open $status w]
    close $fp
    send_msg_id runtcl-5 warning "$msg"
  }
}
set_param xicom.use_bs_reader 1
set_param tcl.collectionResultDisplayLimit 0
create_project -in_memory -part xc7z010clg400-1

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_msg_config -source 4 -id {IP_Flow 19-2162} -severity warning -new_severity info
set_property webtalk.parent_dir /home/alp/Documents/Xilinx/vivado17.4/PADME_trigger_v3_1/PADME_trigger_v3_1.cache/wt [current_project]
set_property parent.project_path /home/alp/Documents/Xilinx/vivado17.4/PADME_trigger_v3_1/PADME_trigger_v3_1.xpr [current_project]
set_property XPM_LIBRARIES {XPM_CDC XPM_FIFO XPM_MEMORY} [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language VHDL [current_project]
set_property board_part em.avnet.com:microzed_7010:part0:1.1 [current_project]
set_property ip_output_repo /home/alp/Documents/Xilinx/vivado17.4/PADME_trigger_v3_1/PADME_trigger_v3_1.cache/ip [current_project]
set_property ip_cache_permissions {read write} [current_project]
read_vhdl -library xil_defaultlib {
  /home/alp/Documents/Xilinx/vivado17.4/PADME_trigger_v3_1/PADME_trigger_v3_1.srcs/sources_1/imports/sources_1/new/axi4lite_reg.vhd
  /home/alp/Documents/Xilinx/vivado17.4/PADME_trigger_v3_1/PADME_trigger_v3_1.srcs/sources_1/imports/sources_1/new/corr_trigger.vhd
  /home/alp/Documents/Xilinx/vivado17.4/PADME_trigger_v3_1/PADME_trigger_v3_1.srcs/sources_1/imports/sources_1/new/counter.vhd
  /home/alp/Documents/Xilinx/vivado17.4/PADME_trigger_v3_1/PADME_trigger_v3_1.srcs/sources_1/imports/sources_1/new/daq_manager.vhd
  /home/alp/Documents/Xilinx/vivado17.4/PADME_trigger_v3_1/PADME_trigger_v3_1.srcs/sources_1/imports/sources_1/new/downscaler.vhd
  /home/alp/Documents/Xilinx/vivado17.4/PADME_trigger_v3_1/PADME_trigger_v3_1.srcs/sources_1/imports/sources_1/new/masker.vhd
  /home/alp/Documents/Xilinx/vivado17.4/PADME_trigger_v3_1/PADME_trigger_v3_1.srcs/sources_1/imports/sources_1/new/nzs_zs_selector.vhd
  /home/alp/Documents/Xilinx/vivado17.4/PADME_trigger_v3_1/PADME_trigger_v3_1.srcs/sources_1/imports/sources_1/bd/system/hdl/system_wrapper.vhd
  /home/alp/Documents/Xilinx/vivado17.4/PADME_trigger_v3_1/PADME_trigger_v3_1.srcs/sources_1/imports/sources_1/new/trig_time_stamp.vhd
  /home/alp/Documents/Xilinx/vivado17.4/PADME_trigger_v3_1/PADME_trigger_v3_1.srcs/sources_1/imports/sources_1/new/trigger_logic.vhd
  /home/alp/Documents/Xilinx/vivado17.4/PADME_trigger_v3_1/PADME_trigger_v3_1.srcs/sources_1/imports/sources_1/new/user_logic.vhd
  /home/alp/Documents/Xilinx/vivado17.4/PADME_trigger_v3_1/PADME_trigger_v3_1.srcs/sources_1/imports/sources_1/new/window_generator.vhd
  /home/alp/Documents/Xilinx/vivado17.4/PADME_trigger_v3_1/PADME_trigger_v3_1.srcs/sources_1/imports/sources_1/new/top.vhd
}
read_vhdl -vhdl2008 -library xil_defaultlib {
  /home/alp/Documents/Xilinx/vivado17.4/PADME_trigger_v3_1/PADME_trigger_v3_1.srcs/sources_1/imports/sources_1/new/nzs_zs_shaper.vhd
  /home/alp/Documents/Xilinx/vivado17.4/PADME_trigger_v3_1/PADME_trigger_v3_1.srcs/sources_1/imports/sources_1/new/shaper.vhd
  /home/alp/Documents/Xilinx/vivado17.4/PADME_trigger_v3_1/PADME_trigger_v3_1.srcs/sources_1/imports/sources_1/new/timer.vhd
}
read_ip -quiet /home/alp/Documents/Xilinx/vivado17.4/PADME_trigger_v3_1/PADME_trigger_v3_1.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xci
set_property used_in_implementation false [get_files -all /home/alp/Documents/Xilinx/vivado17.4/PADME_trigger_v3_1/PADME_trigger_v3_1.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0_board.xdc]
set_property used_in_implementation false [get_files -all /home/alp/Documents/Xilinx/vivado17.4/PADME_trigger_v3_1/PADME_trigger_v3_1.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xdc]
set_property used_in_implementation false [get_files -all /home/alp/Documents/Xilinx/vivado17.4/PADME_trigger_v3_1/PADME_trigger_v3_1.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0_ooc.xdc]

read_ip -quiet /home/alp/Documents/Xilinx/vivado17.4/PADME_trigger_v3_1/PADME_trigger_v3_1.srcs/sources_1/ip/fifo_generator_0/fifo_generator_0.xci
set_property used_in_implementation false [get_files -all /home/alp/Documents/Xilinx/vivado17.4/PADME_trigger_v3_1/PADME_trigger_v3_1.srcs/sources_1/ip/fifo_generator_0/fifo_generator_0.xdc]
set_property used_in_implementation false [get_files -all /home/alp/Documents/Xilinx/vivado17.4/PADME_trigger_v3_1/PADME_trigger_v3_1.srcs/sources_1/ip/fifo_generator_0/fifo_generator_0_ooc.xdc]

add_files /home/alp/Documents/Xilinx/vivado17.4/PADME_trigger_v3_1/PADME_trigger_v3_1.srcs/sources_1/bd/system/system.bd
set_property used_in_implementation false [get_files -all /home/alp/Documents/Xilinx/vivado17.4/PADME_trigger_v3_1/PADME_trigger_v3_1.srcs/sources_1/bd/system/ip/system_processing_system7_0_0/system_processing_system7_0_0.xdc]
set_property used_in_implementation false [get_files -all /home/alp/Documents/Xilinx/vivado17.4/PADME_trigger_v3_1/PADME_trigger_v3_1.srcs/sources_1/bd/system/ip/system_rst_ps7_0_1M_0/system_rst_ps7_0_1M_0_board.xdc]
set_property used_in_implementation false [get_files -all /home/alp/Documents/Xilinx/vivado17.4/PADME_trigger_v3_1/PADME_trigger_v3_1.srcs/sources_1/bd/system/ip/system_rst_ps7_0_1M_0/system_rst_ps7_0_1M_0.xdc]
set_property used_in_implementation false [get_files -all /home/alp/Documents/Xilinx/vivado17.4/PADME_trigger_v3_1/PADME_trigger_v3_1.srcs/sources_1/bd/system/ip/system_rst_ps7_0_1M_0/system_rst_ps7_0_1M_0_ooc.xdc]
set_property used_in_implementation false [get_files -all /home/alp/Documents/Xilinx/vivado17.4/PADME_trigger_v3_1/PADME_trigger_v3_1.srcs/sources_1/bd/system/ip/system_auto_pc_0/system_auto_pc_0_ooc.xdc]
set_property used_in_implementation false [get_files -all /home/alp/Documents/Xilinx/vivado17.4/PADME_trigger_v3_1/PADME_trigger_v3_1.srcs/sources_1/bd/system/system_ooc.xdc]

# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
read_xdc /home/alp/Documents/Xilinx/vivado17.4/PADME_trigger_v3_1/PADME_trigger_v3_1.srcs/constrs_1/imports/new/IO.xdc
set_property used_in_implementation false [get_files /home/alp/Documents/Xilinx/vivado17.4/PADME_trigger_v3_1/PADME_trigger_v3_1.srcs/constrs_1/imports/new/IO.xdc]

read_xdc dont_touch.xdc
set_property used_in_implementation false [get_files dont_touch.xdc]

synth_design -top top -part xc7z010clg400-1


# disable binary constraint mode for synth run checkpoints
set_param constraints.enableBinaryConstraints false
write_checkpoint -force -noxdef top.dcp
create_report "synth_1_synth_report_utilization_0" "report_utilization -file top_utilization_synth.rpt -pb top_utilization_synth.pb"
