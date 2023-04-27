puts "########################################"
puts "###"
puts "### Floorplan and Place Instances..."
puts "###"
puts "########################################"

####################
# Floorplanning ...
####################
loadIoFile -noAdjustDieSize $SCRIPTS_PATH/${DESIGN_NAME}.io
# loadIoFile -noAdjustDieSize /afs/umich.edu/class/eecs627/w23/groups/group3/pad_gen_template/verilog/TOP_chip.save.io

floorPlan -noSnapToGrid -s $CORE_WIDTH $CORE_HEIGHT \
    $LEFT_OFFSET $BOTTOM_OFFSET $RIGHT_OFFSET $TOP_OFFSET

saveDesign db/${DESIGN_NAME}_floor_planned.enc

###################
# Place instance ...
###################

# Place controller
placeInstance c0 200 1650 R0 -fixed
addHaloToBlock 50 50 50 50 c0 

# Place shifter
placeInstance shift0 900 1350 R0 -fixed
addHaloToBlock 50 50 50 50 shift0 

# Place ring(clk generator)
placeInstance clk_gen 1800 1350 R0 -fixed
addHaloToBlock 50 50 50 50 clk_gen 

# Place SA_array_part
placeInstance SA_p0 460 1650 R0 -fixed
addHaloToBlock 50 50 50 50 SA_p0

# Place write_back_part
placeInstance WB_p0 2060 1650 R0 -fixed
addHaloToBlock 50 50 50 50 WB_p0

# todo: Place SRAM
placeInstance sram0 460 300 R0 -fixed
addHaloToBlock 50 50 50 50 sram0

placeInstance sram1 2060 300 R0 -fixed
addHaloToBlock 50 50 50 50 sram1

saveDesign db/${DESIGN_NAME}_insts_placed.enc
