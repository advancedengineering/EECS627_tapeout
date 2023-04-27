# Design specific definitions
set DESIGN_NAME TOP

# Floorplan Variables
#x_dim
set CHIP_WIDTH     3100 
#y_dim
set CHIP_HEIGHT    3700

######################
#SA_array needs changing
######################
set PAD_HEIGHT        0 
set LEFT_PAD_WIDTH    $PAD_HEIGHT
set BOTTOM_PAD_WIDTH  $PAD_HEIGHT
set RIGHT_PAD_WIDTH   $PAD_HEIGHT
set TOP_PAD_WIDTH     $PAD_HEIGHT

## Power Ring and Stripes
    # VDD: Logic Supply. Typically 1.2V
set RING_LIST  {VDD VSS}
set RING_WIDTH   4
set RING_SPACE   4

set SUPPLY_RING_WIDTH  [expr ([llength $RING_LIST] * ($RING_WIDTH + $RING_SPACE) + 2 * $RING_SPACE)]
set LEFT_OFFSET   $SUPPLY_RING_WIDTH
set RIGHT_OFFSET  $SUPPLY_RING_WIDTH
set TOP_OFFSET    $SUPPLY_RING_WIDTH
set BOTTOM_OFFSET $SUPPLY_RING_WIDTH

set CORE_WIDTH    [expr $CHIP_WIDTH - $LEFT_OFFSET - $RIGHT_OFFSET - 2*$PAD_HEIGHT]
set CORE_HEIGHT   [expr $CHIP_HEIGHT - $TOP_OFFSET - $BOTTOM_OFFSET - 2*$PAD_HEIGHT]

set VSS_NETS "VSS DVSS"
set VDD_NETS "VDD DVDD"


set VERILOG_FILE "${DESIGN_PATH}/${DESIGN_NAME}.syn.v"
set SDC_FILE "${DESIGN_PATH}/${DESIGN_NAME}.syn.sdc"

set io_file         "${SCRIPTS_PATH}/${DESIGN_NAME}.io"
# set io_file          "/afs/umich.edu/class/eecs627/w23/groups/group3/pad_gen_template/verilog/TOP_chip.save.io"

# CPF File
set cpf_file        ""

# Clock Tree Specification File
set ccopt_file      "${SCRIPTS_PATH}/ccopt.spec"