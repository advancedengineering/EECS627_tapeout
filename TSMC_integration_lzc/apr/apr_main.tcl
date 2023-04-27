#TSMC 3/25/23 4:44pm
setMultiCpuUsage -acquireLicense 6 -localCpu 6
set CURRENT_PATH [pwd]
set DESIGN_PATH  ../syn
set SCRIPTS_PATH $CURRENT_PATH/scripts
set REPORT_PATH  $CURRENT_PATH/reports
set OUTPUT_PATH  $CURRENT_PATH/data



#############################################################
#                       Main script                         #
#############################################################

## Initialize Design
source $SCRIPTS_PATH/main_init.tcl


## Floorplan and Place Instances
source $SCRIPTS_PATH/main_floorplan.tcl

## Power Routing
source $SCRIPTS_PATH/main_power.tcl

## Placement
source $SCRIPTS_PATH/main_place.tcl

## Clock Tree Synthesis
source $SCRIPTS_PATH/main_cts.tcl

## Signal Routing
source $SCRIPTS_PATH/main_route.tcl

#CTS and routing
# source $SCRIPTS_PATH/init.tcl
# source $SCRIPTS_PATH/route.tcl

## Fix and Finalize
source $SCRIPTS_PATH/main_fix.tcl

## Report and Output
source $SCRIPTS_PATH/main_output.tcl
# source $SCRIPTS_PATH/final.tcl

# Make netlist files and check report
make spice
make check
