##############################################################################
# FILLER CELLS
##############################################################################
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

saveDesign db/final
