#placeInstance ISCAN 44 55 R0

##############################################################################
# ROW-CUT
##############################################################################
##cutRow -area 0 0 5.94 $y_dim
##cutRow -area [expr $x_dim - 5.94] 0 $x_dim $y_dim
#cutRow -area $leda_llx $leda_lly $leda_urx $leda_ury
#createRouteBlk -layer all -box $leda_llx $leda_lly $leda_urx $leda_ury

############################################################################
# POWER DOMAIN VDD SROUTE
############################################################################
#sroute -nets {VDD VSS} -connect corePin -allowLayerChange 0 -allowJogging 0

############################################################################
# Routing Blockage
############################################################################

#--- Create blockage on existing wires (Import from LEF)

#--- Prevent Spacing violations
#createRouteBlk -layer all -box 0 0 0.28 $y_dim
#createRouteBlk -layer all -box [expr $x_dim - 0.28] 0 $x_dim $y_dim

############################################################################
# PLACE STANDARD CELLS
############################################################################

# Place Options
setPlaceMode -prerouteAsObs {1 2}
setPlaceMode -congEffort high
setPlaceMode -timingDriven true

# Trial Route Options
setTrialRouteMode -maxRouteLayer 3

# Optimization Options
setOptMode -verbose true
setOptMode -restruct false
setOptMode -addPortAsNeeded false
setOptMode -honorFence true
setOptMode -fixFanoutLoad true
setOptMode -enableDataToDataChecks true
#setOptMode -maxLength 500
#setOptMode -optimizeNetAcrossDiffVoltPDs false  ;# NOTE: Check whether it affects the power domains

# Timing Analysis Options 
#--- Note: (IMPOPT-6080) AAE-SI Optimization can only be turned on when the timing analysis mode is set to OCV.
setDelayCalMode -engine aae -SIAware true -reportOutBound true
setAnalysisMode -analysisType onChipVariation -cppr both
setExtractRCMode -engine preRoute

# Place the Standard Cells
timeDesign -prePlace
placeDesign -noPrePlaceOpt
congRepair

# Add TIEHI / TIELO Cells
setTieHiLoMode -cell $tie_cells -createHierPort false -prefix $tie_prefix -maxDistance $tie_max_distance -maxFanout $tie_max_fanout
addTieHiLo

saveDesign db/placed