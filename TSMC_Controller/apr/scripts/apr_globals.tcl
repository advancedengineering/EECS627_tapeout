set TECH_PATH   /afs/umich.edu/class/eecs627/tsmc180/sc_x_oa_utm
set cap_dir     /afs/umich.edu/class/eecs627/tsmc180/captable/1_2
# set LEF_DIR     $CURRENT_PATH/../lef
set SRAM_DIR    $CURRENT_PATH/../SRAM

set defHierChar {/}
set locv_inter_clock_use_worst_derate false
set init_oa_search_lib ""
set lsgOCPGainMult 1.000000
set init_verilog $VERILOG_FILE
set init_design_netlisttype {Verilog}
set init_pwr_net $VDD_NETS
set init_top_cell $DESIGN_NAME
set init_gnd_net $VSS_NETS
set init_mmmc_file "${SCRIPTS_PATH}/apr_view.tcl"

# Insert the standard cell LEF file and other block LEF files
# LEF Files
set sc_dir      /afs/umich.edu/class/eecs627/tsmc180/sc_x_oa_utm
set init_lef_file        [list \
                        ${sc_dir}/sc_x.lef \
                        ${sc_dir}/sc_x_antenna.lef \
                    ]
set typ_lib_file    [list \
                        ${sc_dir}/typical.lib \
                    ]
# set init_lef_file "$TECH_PATH/lef/ibm13_8lm_2thick_tech.lef \
# 		   		   $TECH_PATH/lef/ibm13rvt_macros.lef \
# 				   $TECH_PATH/../io/lef/arti_cmos8rf_8lm_2thick_i.lef \
# 				   $LEF_DIR/reset_driver.lef \
# 				   $LEF_DIR/mult_block.lef \
# 				   $SRAM_DIR/SIGN_MEM/SIGN_MEM.vclef \
		   		#   "

set timing_case_analysis_for_icg_propagation false

# General technology dependent definitions. To be used in the scripts
set PROCESS_NODE 180

# Set mapfile for generating gds.
set map_dir     /afs/umich.edu/class/eecs627/tsmc180
set MAP_FILE "${map_dir}/tsmc18.map"
# set MAP_FILE "/afs/umich.edu/class/eecs627/w23/lab_resource/lab2_Innovus/apr/enc2gdsLM.map"

# Set Cells to be used
set TAP_CELL ""

# Filler Cells; Do not include an underscore at the end of $filler_prefix
set FILL_CELLS       [list FILL128 FILL64 FILL32 FILL16 FILL8 FILL4 FILL2 FILL1]
set filler_prefix       FILL
# set FILL_CELLS     "FILL1TR FILL2TR FILL4TR FILL8TR FILL16TR FILL32TR FILL64TR"

set FILL_CAP_CELLS ""

set CLOCK_INV_CELLS    ""

set CLOCK_BUF_CELLS    ""

# Don't Use Cells
set EXCLUDE_CELLS       [list DFFSRHQXL]
# set EXCLUDE_CELLS  "PCORNER PFILLH PFILLQ PFILL1 \
					FILL1TR FILL2TR FILL4TR FILL8TR FILL16TR FILL32TR FILL64TR"

# Antenna Cells
set ANTENNA_DIODES       [list ANTENNA]
# set ANTENNA_DIODES "ANTENNATR"


# Tie-Cells; Do not include an underscore at the end of $tie_prefix
set TIEHL_CELLS           [list TIEHI TIELO]
set tie_prefix          TIEHILO
set tie_max_distance    500
set tie_max_fanout      32
# set TIEHL_CELLS "TIELOTR TIEHITR"


#-----------------------TSMC 180 CLKs -----------------------------
# Clocks; By default, all clocks listed below are asynchronous to each other.
set clk_const_name "typConst"

                    #   clk_name        period  uncertainty transition  source
#set clk_list        [list \
#                        CLK             3333    0.3           2           CLK \
#                    ]
                    #   type    bottom_layer    top_layer
set clk_route_rule  [list \
                        leaf    METAL1          METAL4 \
                        trunk   METAL1          METAL4 \
                        top     METAL1          METAL4 \
                    ]

set CLOCK_BUF_CELLS    [list CLKBUFX1 CLKBUFX2 CLKBUFX3 CLKBUFX4 CLKBUFX8 CLKBUFX12 CLKBUFX16 CLKBUFX20]
set clk_dly_cells   [list DLY1X1 DLY2X1 DLY3X1 DLY4X1 CLKBUFX1 CLKBUFX2 CLKBUFX3 CLKBUFX4 CLKBUFX8 CLKBUFX12 CLKBUFX16 CLKBUFX20]
set CLOCK_INV_CELLS   [list CLKINVX1 CLKINVX2 CLKINVX3 CLKINVX4 CLKINVX8 CLKINVX12 CLKINVX16 CLKINVX20]

set clk_max_fanout  32

set clk_max_length  600 ;# The max routing length of each clock net
#--------------------------------------------------------------

##----------------------------------------------------------------------------
## General Global Variables
##----------------------------------------------------------------------------

# enable verbose script source
set enc_source_verbose 0    ;# (Integer, default=0, persistent)

##----------------------------------------------------------------------------
## Floorplan Global Variables
##----------------------------------------------------------------------------

# If this variable is set to 1, create rows based on default power domain's 
# site, not design's default site. 
set fpHonorDefaultPowerDomainSite 1 ;# (Integer, default=0, persistent)

##----------------------------------------------------------------------------
## Delay Calculation Global Variables
##----------------------------------------------------------------------------

# set threshold to apply the default delay
set delaycal_use_default_delay_limit 1000   ;# (Integer, default=1000, persistent)

# set default net delay. The software uses this default values for nets that
# exceeds N terminals. (N = # specified in 'delaycal_use_default_delay_limit')
# Delay calculation is performed for nets with fewer than N terminals.
set delaycal_default_net_delay 1000ps   ;# (String, default=1000ps, persistent)

# set default net load. You can use this global variable to specify the default
# net load value that is used for nets that exceed N terminals.
# (N = # specified in 'delaycal_use_default_delay_limit')
set delaycal_default_net_load 1pf ;# (String, default=0.5pf, persistent)

# set default input transition time and the ideal clock transition time for delay
# calculation. The software uses this default transition time for nets that exceed
# N terminals. (N = # specified in 'delaycal_use_default_delay_limit')
set delaycal_input_transition_delay 0ps ;# (String, default=0ps, persistent)

# Enables support of Liberty wire-load models and related SDC commands.
set delaycal_support_wire_load_model 0  ;# (Integer, default=0, persistent)

##----------------------------------------------------------------------------
## Timing Global Variables
##----------------------------------------------------------------------------

# Enables clocks to be created in propagated mode
set timing_create_clock_default_propagated 1    ;# (Boolean, default=0, persistent)

# Considers clock uncertainty when performing clock checks.
set timing_enable_uncertainty_for_clock_checks 1    ;# (Boolean, default=0, persistent)

# When set to true, considers clock uncertainty when performing minimum 
# pulse width checks
set timing_enable_uncertainty_for_pulsewidth_checks 1   ;# (Boolean, default=0, persistent)

# Specifies the type of slew propagation to use for generating extracted 
# timing model
set timing_extract_model_slew_propagation_mode path_based_slew   ;# (Enum, default=worst_slew, range={worst_slew path_based_slew}, persistent)

# Controls whether network latency of a reference clock is added or not 
# to the data arrival time on the port. When set to 'ideal', the 'set_input_delay' and the
# 'set_output_delay' constraints will not add the network latency of the reference clock 
# to the data arrival time on the port if the clock is in 'propagated' mode.
# When this global is set to 'always', network latency is added to the data arrival time
# on the port regardless of the clock propagation mode.
set timing_io_use_clock_network_latency ideal   ;# (Enum, default=ideal, range={always ideal}, persistent)

# Controls whether the report_timing reports are generated using the default 
# orextended report header
set timing_report_timing_header_detail_info extended ;# (Enum, default=default, range={default extended}, persistent)

# enables clocks to be given in -from/to options in report_timing command
set timing_report_enable_clock_object_in_from_to 1  ;# (Boolean, default=0, persistent)

# Controls whether report_timing reports the detailed clock latency path
set timing_report_launch_clock_path 1   ;# (Boolean, default=0, persistent)
