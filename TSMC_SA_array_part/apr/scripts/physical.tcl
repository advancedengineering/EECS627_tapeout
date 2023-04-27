##############################################################################
# FILLER CELLS
##############################################################################

# addFiller -cell $filler_cells -prefix $filler_prefix

##############################################################################
# METAL FILL
##############################################################################

########################################
#drc fix
########################################
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
addFiller -cell $filler_cells -prefix $filler_prefix

# Final DRC and Fix
fixVia -minCut
fixVia -minStep
fixVia -short

clearDrc
verifyGeometry -error 1000000000
verifyConnectivity -type regular -error 1000000 -warning 500000
verifyProcessAntenna -error 1000000
editDeleteViolations
globalDetailRoute

#--- Prevent Spacing violations
#set metal_fill_margin_h 0.28
#set metal_fill_margin_v 0.60
#createRouteBlk -layer all -box 0 0 $metal_fill_margin_h $y_dim
#createRouteBlk -layer all -box [expr $x_dim - $metal_fill_margin_h] 0 $x_dim $y_dim
#createRouteBlk -layer all -box 0 0 $x_dim $metal_fill_margin_v
#createRouteBlk -layer all -box 0 [expr $y_dim - $metal_fill_margin_v] $x_dim $y_dim
#
#addMetalFill -area 0 0 $x_dim $y_dim -layer {1 2 3 4 5}
#
#deleteRouteBlk -all
#
saveDesign db/final
