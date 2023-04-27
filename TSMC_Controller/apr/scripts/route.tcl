##############################################################################
# CLOCK TREE SYNTHESIS
##############################################################################

# Optimization Options
setOptMode -verbose true
setOptMode -restruct false
setOptMode -addPortAsNeeded false
setOptMode -honorFence true
setOptMode -fixFanoutLoad true
setOptMode -enableDataToDataChecks true
setOptMode -usefulskew true 
set_interactive_constraint_modes typConst

setDelayCalMode -engine aae -SIAware true -reportOutBound true
setAnalysisMode -analysisType onChipVariation -cppr both
setExtractRCMode -engine preRoute
extractRC


set_ccopt_mode -cts_opt_priority insertion_delay \
               -cts_opt_type full \
		-cts_target_skew 0.5

set_ccopt_property inverter_cells $clk_inv_cells 
set_ccopt_property use_inverters true
set_ccopt_property routing_top_min_fanout 10000

set_ccopt_effort   -high 

create_ccopt_clock_tree_spec -file ${ccopt_file}

# Clock Tree Synthesis
source ${ccopt_file}
report_ccopt_clock_trees -file pre_ccopt.rpt -histograms -list_special_pins -no_invalidate
ccopt_design
report_ccopt_clock_trees -file post_ccopt.rpt -histograms -list_special_pins -no_invalidate

# Post-CTS Optimization
setOptMode -addInst true -addInstancePrefix POSTCTS_HOLD_
optDesign -postCTS -hold

timeDesign -postCTS
timeDesign -postCTS -hold 

##############################################################################
# ROUTE
##############################################################################

# Optimization Options
setOptMode -verbose true
setOptMode -restruct false
setOptMode -addPortAsNeeded false
setOptMode -honorFence true
setOptMode -fixFanoutLoad true
setOptMode -enableDataToDataChecks true
setOptMode -holdTargetSlack 0.1

setOptMode -setupTargetSlack 0.1
#setOptMode -maxLength 500      ;# NOTE: The level converter (SRAM Isolate) input wires are very long (>1mm). Need to re-locate PD3P6 in a next re-spin
#setOptMode -optimizeNetAcrossDiffVoltPDs false  ;# NOTE: Check whether it affects the power domains

# Timing Analysis Options 
setDelayCalMode -engine aae -SIAware true -reportOutBound true
setAnalysisMode -analysisType onChipVariation -cppr both
setExtractRCMode -engine postRoute -effortLevel low
extractRC

# Set the Routing Options
setNanoRouteMode -envNumberFailLimit 10
setNanoRouteMode -routeWithTimingDriven true
setNanoRouteMode -routeSiEffort medium
setNanoRouteMode -routeWithSiDriven true
setNanoRouteMode -routeWithSiPostRouteFix true  
setNanoRouteMode -routeHonorPowerDomain false
setNanoRouteMode -routeWithViaInPin false
setNanoRouteMode -routeWithViaOnlyForStandardCellPin "1:1"
setNanoRouteMode -routeMergeSpecialWire true
setNanoRouteMode -routeTopRoutingLayer 4
setNanoRouteMode -routeBottomRoutingLayer 1
#setNanoRouteMode -routeAntennaCellName ${antenna_cells}
#setNanoRouteMode -routeInsertAntennaDiode true
setNanoRouteMode -routeSelectedNetOnly false
setNanoRouteMode -routeStrictlyHonorNonDefaultRule true
setNanoRouteMode -drouteAutoStop false
setNanoRouteMode -drouteHonorStubRuleForBlockPin true
setNanoRouteMode -drouteUseMultiCutViaEffort high
setNanoRouteMode -drouteSearchAndRepair true
#setNanoRouteMode -drouteFixAntenna true

# Route
routeDesign

saveDesign db/routed

##############################################################################
# POST-ROUTE OPTIMIZATION
##############################################################################

setOptMode -addInst true -addInstancePrefix POSTROUTE_SETUP_
optDesign -postRoute
timeDesign -postRoute

setOptMode -addInst true -addInstancePrefix POSTROUTE_HOLD_
optDesign -postRoute -hold
timeDesign -postRoute -hold

saveDesign db/optimized

