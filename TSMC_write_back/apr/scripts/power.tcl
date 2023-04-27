##############################################################################
# GLOBAL NET CONNECTION
##############################################################################

globalNetConnect VSS -type pgpin -pin VSS -inst * -override -verbose
globalNetConnect VDD -type pgpin -pin VDD -inst * -override -verbose

applyGlobalNets

##############################################################################
# STRIPES & RINGS
##############################################################################
# addStripe gets worse performance with Multi CPU
setMultiCpuUsage -localCpu 1
setAddRingMode -ring_target stripe -avoid_short 1
setSrouteMode -blockPinRouteWithPinWidth true

set ring_width   2
set ring_space   0.6
proc myAddCoreRing {ringWidth ringSpacing met1 met2} \
{
    global VSS_NETS
    global VDD_NETS

    set coreSupplies "VDD VSS " ; # From the inner side
    addRing \
        -type core_rings \
        -around default_power_domain \
        -nets ${coreSupplies} \
        -width $ringWidth \
        -spacing $ringSpacing \
        -layer "top $met2 bottom $met2 left $met1 right $met1" \
        -rectangle 1 \
        -offset_adjustment fixed \
        -offset_top 1 \
        -offset_bottom 1 \
        -offset_left 1 \
        -offset_right 1
}
# myAddCoreRing $ring_width $ring_space METAL3 METAL2
myAddCoreRing $ring_width $ring_space METAL4 METAL3
sroute -nets {VDD VSS} -connect corePin -allowLayerChange 0 -allowJogging 0

# Power Stripes (Vertical)
# addStripe -nets {VSS VDD} -layer METAL2 -direction vertical -width 2 -spacing 0.6 \
#     -extend_to design_boundary \
#     -start_offset 20 \
#     -number_of_sets 1 \

addStripe \
    -nets {VDD VSS} \
    -direction vertical \
    -layer M2 \
	-width 2 -spacing 0.6 \
    -set_to_set_distance 40 \
	-start 50 \
	-stop 800

addStripe \
    -nets {VDD VSS} \
    -direction horizontal \
    -layer M3 \
	-width 2 -spacing 0.6 \
    -set_to_set_distance 40 \
	-start 60 \
	-stop 1800

addStripe \
    -nets {VDD VSS} \
    -direction vertical \
    -layer M4 \
	-width 2 -spacing 0.6 \
    -set_to_set_distance 40 \
	-start 50 \
	-stop 800


# setAddStripeMode -stacked_via_bottom_layer M3 -max_via_size {blockPin 100% 100% 100%}
# setAddStripeMode -stacked_via_top_layer    M5 -max_via_size {blockPin 100% 100% 100%}
# addStripe \
#     -nets {VDD VSS} \
#     -direction horizontal \
#     -layer METAL5 \
# 	-width 2 -spacing 0.6 \
#     -set_to_set_distance 60 \
# 	-start 100 \
# 	-stop 2100

# setAddStripeMode -stacked_via_bottom_layer METAL1 -max_via_size {blockPin 100% 100% 100%}
# setAddStripeMode -stacked_via_top_layer    METAL4 -max_via_size {blockPin 100% 100% 100%}
# addStripe \
#     -nets {VDD VSS} \
#     -direction vertical \
#     -layer M4 \
# 	-width 2 -spacing 0.6 \
#     -set_to_set_distance 60 \
# 	-start 100 \
# 	-stop 1200

