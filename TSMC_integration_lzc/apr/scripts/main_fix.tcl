puts "########################"
puts "###"
puts "### Fix and Finalize ..."
puts "###"
puts "########################"

########################################
## Fix Finalize the design
########################################

# Pre-CapFill (Post-Route) DRC and Fix - 2 Iterations for this design
clearDrc
verifyGeometry -error 1000000000
verifyConnectivity -type regular -error 1000000 -warning 500000
verifyProcessAntenna -error 1000000
editDeleteViolations
globalDetailRoute

clearDrc
verifyGeometry -error 1000000000
verifyConnectivity -type regular -error 1000000 -warning 500000
verifyProcessAntenna -error 1000000
editDeleteViolations
globalDetailRoute

# Add Filler Cells
addFiller   -cell $FILL_CELLS -prefix FILLCELL
myConnectStdCellsToPower

# Final DRC and Fix
fixVia -minCut
fixVia -minStep
fixVia -short

clearDrc
verifyGeometry -error 1000000000
verifyConnectivity -type regular -error 1000000 -warning 500000
verifyProcessAntenna -error 1000000
detailRoute -fix_drc
# Or a Stronger Violation Fix Method:
#editDeleteViolations
#globalDetailRoute

saveDesign db/${DESIGN_NAME}_final_prefill.enc

# Metal Fill: up-to M8, the topmost metal
# Report timing before metal fill so that sta mode works
# set floorplan_width  [dbDBUToMicrons [lindex [dbFPlanBox [dbHeadFPlan]] 2]]
# set floorplan_height [dbDBUToMicrons [lindex [dbFPlanBox [dbHeadFPlan]] 3]]
# report_timing     
# set window_size 3000
# setMetalFill -layer {1 2 3 4 5 6} -minDensity 20 -preferredDensity 25 -maxDensity 80 -maxLength 4 -maxWidth 1 -windowSize $window_size $window_size -windowStep $window_size $window_size 
# for {set i 0} {[expr $i < $floorplan_width]} {set i [expr $i + $window_size]} {
#     for {set j 0} {[expr $j < $floorplan_height]} {set j [expr $j + $window_size]} {
#         addMetalFill -layer {1 2 3 4 5 6 7 8} -onCells -timingAware sta -area $i $j [expr min($floorplan_width,$i+$window_size)] [expr min($floorplan_height,$j+$window_size)]
#     }
# }


##############################################################################
# METAL FILL
##############################################################################

--- Prevent Spacing violations
# set metal_fill_margin_h 0.28
# set metal_fill_margin_v 0.60
# createRouteBlk -layer all -box 0 0 $metal_fill_margin_h $y_dim
# createRouteBlk -layer all -box [expr $x_dim - $metal_fill_margin_h] 0 $x_dim $y_dim
# createRouteBlk -layer all -box 0 0 $x_dim $metal_fill_margin_v
# createRouteBlk -layer all -box 0 [expr $y_dim - $metal_fill_margin_v] $x_dim $y_dim
# createRouteBlk -layer all -box 1750 1750 1850 1850

addMetalFill -area 0 0 $CHIP_WIDTH  $CHIP_HEIGHT -layer {1 2 3 4 5 6}

deleteRouteBlk -all


clearDrc
verifyGeometry -error 1000000000
verifyConnectivity -type regular -error 1000000 -warning 500000
verifyProcessAntenna -error 1000000
trimMetalFill -deleteViols


saveDesign db/${DESIGN_NAME}_final.enc
