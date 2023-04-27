##############################################################################
# VERIFICATION
##############################################################################
# Note: For 20nm or below, use verify_drc along with verifyGeometry
#       For 28nm or above, use verifyGeometry alone.

verifyGeometry -reportAllCell -noRoutingBlkg -noMinArea -noOverlap -report ${my_toplevel}.geom.rpt
fixVia -minCut
verifyConnectivity -noAntenna -report ${my_toplevel}.conn.rpt
verifyProcessAntenna -report ${my_toplevel}.antenna.rpt

##############################################################################
# OUTPUT
##############################################################################
#--- Create LEF/DEF
set lefDefOutVersion 5.8 ;# Default=5.8
defOut ${my_toplevel}.def -floorplan -routing 
write_lef_abstract ${my_toplevel}.lef -stripePin -PGPinLayers {6}

#--- Create Netlist
saveNetlist -excludeLeafCell -excludeCellInst ${antenna_cells} ${my_toplevel}.apr.v
saveNetlist -excludeLeafCell -includePowerGround ${my_toplevel}.apr.pg.v

#--- Create GDS
streamOut ${my_toplevel}.gds \
    -mapFile ${map_file} \
    -libName ${my_toplevel} \
    -structureName ${my_toplevel} \
    -units 2000 \
    -mode ALL

#--- Create SPF/SPEF
setExtractRCMode -engine postRoute -effortLevel low -relative_c_th 0.01 -total_c_th 0.01 -specialNet true
extractRC -outfile ${my_toplevel}.cap
#rcOut -spf ${my_toplevel}.spf ; # not supported in innovus-21 version
rcOut -spef ${my_toplevel}.spef

#--- Create Liberty Files
set_analysis_view -setup maxAnalysis -hold maxAnalysis
do_extract_model ${my_toplevel}_max.lib -view maxAnalysis \
    -cell_name ${my_toplevel} -lib_name ${my_toplevel}_max

set_analysis_view -setup minAnalysis -hold minAnalysis
do_extract_model ${my_toplevel}_min.lib -view minAnalysis \
    -cell_name ${my_toplevel} -lib_name ${my_toplevel}_min

## Generate .lib Added by Qianhao
set_analysis_view -setup {typAnalysis} -hold {typAnalysis}
do_extract_model -view typAnalysis ${my_toplevel}.lib

#--- Create SDF
set_analysis_view -setup maxAnalysis -hold minAnalysis
setUseDefaultDelayLimit 10000
write_sdf -version 3.0 -max_view maxAnalysis -min_view minAnalysis \
    -process 1::1 -temperature 0::125 -voltage 1.32::1.08 \
    -target_application verilog ${my_toplevel}.apr.sdf
