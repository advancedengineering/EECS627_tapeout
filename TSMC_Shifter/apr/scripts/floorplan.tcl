##############################################################################
# Set Some Variables
##############################################################################
## Block Dimension
set x_dim 300
set y_dim 50

## Core Offsets
set left_offset   10
set right_offset  10
set top_offset    10
set bottom_offset 10

##############################################################################
# FloorPlan
##############################################################################
floorPlan -s $x_dim $y_dim $left_offset $bottom_offset $right_offset $top_offset -noSnapToGrid

loadIoFile -noAdjustDieSize ${io_file}

setFlipping s
redraw
fit

