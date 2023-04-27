puts "#####################"
puts "###"
puts "### Run Routing ..."
puts "###"
puts "#####################"

####################
# Signal Routing ...
####################

# setNanoRouteMode\
#     -routeWithTimingDriven true \
#     -routeWithSiDriven true \
#     -routeSiEffort max \
# 	-routeWithSiPostRouteFix true

# setNanoRouteMode\
#     -drouteFixAntenna true \
# 	-drouteAutoStop false \
#     -routeDeleteAntennaReroute true \
#     -routeAntennaCellName $ANTENNA_DIODES \
#     -routeInsertAntennaDiode true \

# setNanoRouteMode\
# 	-droutePostRouteSwapVia false \
#     -routeConcurrentMinimizeViaCountEffort medium \
#     -routeWithViaInPin true \
#     -drouteUseMultiCutViaEffort high \
#     -routeBottomRoutingLayer 2 \
#     -routeTopRoutingLayer 6 \
#     -drouteOnGridOnly none

# routeDesign -globalDetail
# saveDesign db/${DESIGN_NAME}_routed.enc

# TSMC 180 routing options
# Optimization Options
setOptMode -verbose true
setOptMode -restruct false
setOptMode -addPortAsNeeded false
setOptMode -honorFence true
setOptMode -fixFanoutLoad true
setOptMode -enableDataToDataChecks true
# setOptMode -holdTargetSlack 0.2
#setOptMode -setupTargetSlack 0.1
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
setNanoRouteMode -routeTopRoutingLayer 6
setNanoRouteMode -routeBottomRoutingLayer 1
setNanoRouteMode -routeAntennaCellName $ANTENNA_DIODES
setNanoRouteMode -routeInsertAntennaDiode true
setNanoRouteMode -routeSelectedNetOnly false
setNanoRouteMode -routeStrictlyHonorNonDefaultRule true
setNanoRouteMode -drouteAutoStop false
setNanoRouteMode -drouteHonorStubRuleForBlockPin true
setNanoRouteMode -drouteUseMultiCutViaEffort high
setNanoRouteMode -drouteSearchAndRepair true
setNanoRouteMode -drouteFixAntenna true

# Route
routeDesign

saveDesign db/${DESIGN_NAME}_routed.enc

# Post Route Optimizations
# setDelayCalMode -engine aae -SIAware true -reportOutBound true
# setAnalysisMode -analysisType onChipVariation -cppr both

puts "POSTROUTE ITER 0"
# setOptMode -addInst true -addInstancePrefix POSTROUTE 
# optDesign -postRoute -outDir ${REPORT_PATH}/${DESIGN_NAME}_route_0
# optDesign -postRoute -hold -outDir ${REPORT_PATH}/${DESIGN_NAME}_route_0_hold

# TSMC 180 postroute options
setOptMode -addInst true -addInstancePrefix POSTROUTE_SETUP_
optDesign -postRoute
timeDesign -postRoute

setOptMode -addInst true -addInstancePrefix POSTROUTE_HOLD_
optDesign -postRoute -hold
timeDesign -postRoute -hold
saveDesign db/${DESIGN_NAME}_postroute_0.enc

#puts "POSTROUTE ITER 1"
#optDesign -postRoute -outDir ${REPORT_PATH}/${DESIGN_NAME}_route_1
#optDesign -postRoute -setup -hold -outDir ${REPORT_PATH}/${DESIGN_NAME}_route_1
#saveDesign db/${DESIGN_NAME}_postroute_1.enc

#puts "POSTROUTE ITER 2"
#optDesign -postRoute -outDir ${REPORT_PATH}/${DESIGN_NAME}_route_2
#optDesign -postRoute -hold -outDir ${REPORT_PATH}/${DESIGN_NAME}_route_2_hold
#saveDesign db/${DESIGN_NAME}_postroute_2.enc

myConnectStdCellsToPower
saveDesign db/${DESIGN_NAME}_place_cts_route.enc

