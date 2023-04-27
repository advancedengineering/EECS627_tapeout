# Multi-CPU
set root_dir    ..
set net_dir     ${root_dir}/verilog
set syn_dir     ${root_dir}/syn
set apr_dir     ${root_dir}/apr
set script_dir  ${apr_dir}/scripts
set my_toplevel $DESIGN_NAME

set num_cpu [exec getconf _NPROCESSORS_ONLN]

# Process Node
set process_node 180

# Power Nets            net_name    voltage
set vdd_nets        [list \
                        VDD         1.8 \
                    ]
# Ground Nets            net_name    voltage
set gnd_nets        [list \
                        VSS       0 \
                    ]

# Verilog Files
set verilog_file    [list  \
                        ${syn_dir}/${my_toplevel}.syn.v \
                    ]

# LEF Files
set lef_file        [list \
                        ${sc_dir}/sc_x.lef \
                        ${sc_dir}/sc_x_antenna.lef \
                    ]

# LIB Files
set typ_lib_file    [list \
                        ${sc_dir}/typical.lib \
                    ]

# Cab Tables
set max_captable_file   [list   ${cap_dir}/TSMC180_6m_4x1n8k_cworst.CapTbl]
set typ_captable_file   [list   ${cap_dir}/TSMC180_6m_4x1n8k_typical.CapTbl]
set min_captable_file   [list   ${cap_dir}/TSMC180_6m_4x1n8k_cbest.CapTbl]

# Antenna Cells
set antenna_cells       [list ANTENNA]

# Tie-Cells; Do not include an underscore at the end of $tie_prefix
set tie_cells           [list TIEHI TIELO]
set tie_prefix          TIEHILO
set tie_max_distance    500
set tie_max_fanout      32

# Filler Cells; Do not include an underscore at the end of $filler_prefix
set filler_cells        [list FILL128 FILL64 FILL32 FILL16 FILL8 FILL4 FILL2 FILL1]
set filler_prefix       FILL

# Don't Use Cells
set dontuse_cells       [list DFFSRHQXL]

# Clocks; By default, all clocks listed below are asynchronous to each other.
set clk_const_name "typConst"

                    #   clk_name        period  uncertainty transition  source
#set clk_list        [list \
#                        CLK             3333    0.3           2           CLK \
#                    ]
                    #   type    bottom_layer    top_layer
set clk_route_rule  [list \
                        leaf    METAL1          METAL6 \
                        trunk   METAL1          METAL6 \
                        top     METAL1          METAL6 \
                    ]

set clk_buf_cells   [list CLKBUFX1 CLKBUFX2 CLKBUFX3 CLKBUFX4 CLKBUFX8 CLKBUFX12 CLKBUFX16 CLKBUFX20]
set clk_dly_cells   [list DLY1X1 DLY2X1 DLY3X1 DLY4X1 CLKBUFX1 CLKBUFX2 CLKBUFX3 CLKBUFX4 CLKBUFX8 CLKBUFX12 CLKBUFX16 CLKBUFX20]
set clk_inv_cells   [list CLKINVX1 CLKINVX2 CLKINVX3 CLKINVX4 CLKINVX8 CLKINVX12 CLKINVX16 CLKINVX20]

set clk_max_fanout  32

set clk_max_length  600 ;# The max routing length of each clock net

# IO Files
set io_file         "${script_dir}/apr.io"

# SDC File
set sdc_file        "${syn_dir}/${my_toplevel}.syn.sdc"

# CPF File
set cpf_file        ""

# Clock Tree Specification File
set ccopt_file      "${script_dir}/ccopt.spec"

# Map File used for stream-out
set map_file        "${map_dir}/tsmc18.map"


##############################################################################
# POST-PROCESSING
##############################################################################
set vdd_names [list ]
set gnd_names [list ]
foreach {my_vdd_name my_vdd_val} ${vdd_nets} { set vdd_names [concat ${vdd_names} ${my_vdd_name}] }
foreach {my_gnd_name my_gnd_val} ${gnd_nets} { set gnd_names [concat ${gnd_names} ${my_gnd_name}] }

##############################################################################
# TCL Globals
#-----------------------------------------------------------------------------
#   For more information, run 'find_global' in Innovus
##############################################################################

##----------------------------------------------------------------------------
## Import and Export Global Variables
##----------------------------------------------------------------------------

# Specify the defOut hierarchy delimiter.
set defHierChar {/}     ;# (String, default="", persistent)

# Specifies the source of the design netlist. You can specify either "Verilog" or "OA".
set init_design_netlisttype {Verilog}    ;# (String, default=Verilog, persistent)

# Path to MMMC View Definition file.
set init_mmmc_file "${script_dir}/viewDefinition.tcl"    ;# (String, default="", persistent)

# Path to I/O Constraint file.
set init_io_file "" ;# (String, default="", persistent)

# List of Verilog netlist files to be read.
set init_verilog ${verilog_file}    ;# (String, default="", persistent)

# List of LEF files to be read. Mutually exclusive with init_oa_ref_lib.
set init_lef_file ${lef_file}

# List of global Power nets.
set init_pwr_net ${vdd_names}    ;# (String, default="", persistent)

# List of global Ground nets.
set init_gnd_net ${gnd_names}    ;# (String, default="", persistent)

# Name of top module (used when reading Verilog netlist information only).
set init_top_cell ${my_toplevel}

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


