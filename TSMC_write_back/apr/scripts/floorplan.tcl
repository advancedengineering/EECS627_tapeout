##############################################################################
# Set Some Variables
##############################################################################
## Block Dimension
set x_dim 800
set y_dim 1800

## Core Offsets
set left_offset   20
set right_offset  20
set top_offset    20
set bottom_offset 20

##############################################################################
# FloorPlan
##############################################################################
floorPlan -s $x_dim $y_dim $left_offset $bottom_offset $right_offset $top_offset -noSnapToGrid

loadIoFile -noAdjustDieSize ${io_file}

setFlipping s
redraw
fit

