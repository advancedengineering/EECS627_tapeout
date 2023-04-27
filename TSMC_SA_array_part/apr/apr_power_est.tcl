################################################
#  EECS 627 Final Lab                          #
#  Created by Qirui Zhang                      #
################################################
setMultiCpuUsage -acquireLicense 6 -localCpu 6
set CURRENT_PATH [pwd]
set DESIGN_PATH  $CURRENT_PATH/synth_res
set SCRIPTS_PATH $CURRENT_PATH/scripts
set REPORT_PATH  $CURRENT_PATH/reports
set OUTPUT_PATH  $CURRENT_PATH/data
set syn_dir      $CURRENT_PATH/../syn
set my_toplevel  SA_array_part
set sc_dir      /afs/umich.edu/class/eecs627/tsmc180/sc_x_oa_utm
set cap_dir     /afs/umich.edu/class/eecs627/tsmc180/captable/1_2
set script_dir $CURRENT_PATH/scripts
set map_dir     /afs/umich.edu/class/eecs627/tsmc180
set verilog_file    [list  \
                        ${syn_dir}/${my_toplevel}.syn.v \
                    ]
#############################################################
#                       Main script                         #
#############################################################

## Initialize Design
source $SCRIPTS_PATH/init.tcl
#source $SCRIPTS_PATH/apr_globals.tcl

## Restore Final Database
restoreDesign db/final.dat SA_array_part 

## Output power
read_activity_file -format VCD /afs/umich.edu/class/eecs627/w23/groups/group3/testcopy2/sim.dump.vcd -scope testbench/SA_p0
report_vector_profile -average_power -step 1ns -propagate -write_profiling_db true
report_power -outfile ${REPORT_PATH}/SA_array_part.power.rpt

exit
