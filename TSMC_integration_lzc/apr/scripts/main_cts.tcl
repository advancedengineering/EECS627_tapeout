puts "##############"
puts "###"
puts "### Run CTS..."
puts "###"
puts "##############"

#####################################
# Clock Tree Synthesis
#####################################
setTrialRouteMode   -maxRouteLayer 6 
setAnalysisMode -cppr both -analysisType onChipVariation
setExtractRCMode -engine preRoute -effortLevel medium
extractRC

# Set CCOPT Modes and Properties
set_ccopt_mode	\
                -cts_opt_priority insertion_delay \
                -cts_opt_type full \
                -cts_target_nonleaf_slew 0.1 \
                -cts_target_skew 0.1 \
                -route_top_top_preferred_layer 6 \
                -route_top_bottom_preferred_layer 2 

#The setCCOptMode/set_ccopt_mode command is obsolete and will be removed in a future release. This command still works in this release, but to avoid this warning and to ensure compatibility with future releases, transition to set_ccopt_property.

set_ccopt_property use_inverters true
set_ccopt_property target_max_trans 0.1
set_ccopt_property target_skew 0.1
set_ccopt_property target_insertion_delay 0.1
set_ccopt_effort   -high

#The command 'set_ccopt_effort' will be obsolete and no longer supported. 'set_ccopt_effort -high' is mapped to 'setOptMode -usefulSkewCCOpt extreme'.

# Create CCOPT Spec
create_ccopt_clock_tree_spec -file ccopt.spec
source ccopt.spec

# Run CTS
ccopt_design -outDir ${REPORT_PATH}/${DESIGN_NAME}_cts
report_ccopt_clock_trees -file ${REPORT_PATH}/post_ccopt.rpt -histograms -list_special_pins -no_invalidate
saveDesign db/${DESIGN_NAME}_ccopt.enc

# Post CTS timing opimizations
# puts "POSTCTS ITER 0"
# setOptMode -addInst true -addInstancePrefix POSTCTS
# optDesign -postCTS -outDir ${REPORT_PATH}/${DESIGN_NAME}_cts_0
# optDesign -postCTS -hold -outDir ${REPORT_PATH}/${DESIGN_NAME}_cts_0_hold

# Post-CTS Optimization: changed 
setOptMode -addInst true -addInstancePrefix POSTCTS_HOLD_
optDesign -postCTS -hold

timeDesign -postCTS
timeDesign -postCTS -hold 

#puts "POSTCTS ITER 1"
#optDesign -postCTS -incr -outDir ${REPORT_PATH}/${DESIGN_NAME}_cts_1
#optDesign -postCTS -hold -incr -outDir ${REPORT_PATH}/${DESIGN_NAME}_cts_1_hold

#puts "POSTCTS ITER 2"
#optDesign -postCTS -incr -outDir ${REPORT_PATH}/${DESIGN_NAME}_cts_1
#optDesign -postCTS -hold -incr -outDir ${REPORT_PATH}/${DESIGN_NAME}_cts_2_hold

myConnectStdCellsToPower
report_ccopt_skew_groups > ${REPORT_PATH}/post_cts_skewgroups.rpt 
saveDesign db/${DESIGN_NAME}_placed_cts.enc
