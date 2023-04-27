#####################################
# DESIGN NAME & DIRECTORIES
#####################################
set my_toplevel shifter

set sc_dir      /afs/umich.edu/class/eecs627/tsmc180/sc_x_oa_utm
set cap_dir     /afs/umich.edu/class/eecs627/tsmc180/captable/1_2
set map_dir     /afs/umich.edu/class/eecs627/tsmc180

set root_dir    ..
set net_dir     ${root_dir}/verilog
set syn_dir     ${root_dir}/syn
set apr_dir     ${root_dir}/apr
set script_dir  ${apr_dir}/scripts

##############################################################################
# main implementation
##############################################################################
source ${script_dir}/suppress.tcl

# initialization
source ${script_dir}/init.tcl
init_design

# Process & Multi-Process
setDesignMode -process $process_node
setMultiCpuUsage -acquireLicense $num_cpu -localCpu $num_cpu

# Floorplan
source ${script_dir}/floorplan.tcl

# Power Routing
source ${script_dir}/power.tcl

# Place Design
source ${script_dir}/place.tcl

# Clock, Route, Optimization
source ${script_dir}/route.tcl

# Physical Cells
source ${script_dir}/physical.tcl

# Verification and Output
source ${script_dir}/final.tcl

# Make netlist files and check report
make spice
make check

######################################
# FINISH
######################################

puts "***************************"
puts "* Innovus Script Finished *"
puts "***************************"

win
