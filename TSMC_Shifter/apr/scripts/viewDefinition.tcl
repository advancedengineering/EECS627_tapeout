# Version:1.0 MMMC View Definition File
# Do Not Remove Above Line

##############################################################################
# TCL SCRIPT FOR INNOVUS 15.21 (c7T_DECODER)
# viewDefinition.tcl
#-----------------------------------------------------------------------------
#   <Note> 
#       - "Using CapTable or QRC Techfiles" and "Using Library Operating Conditions" 
#         are mutually exclusive. You must entirely comment out one of the sections.
#       - Captable is used by above 32nm nodes and QRC tech by below 32nm nodes
#-----------------------------------------------------------------------------
#  < UPDATE HISTORY >
#   Nov 05 2018 -   First commit for RSRAM7Tv775s8kBx32m2Nov2018
#-----------------------------------------------------------------------------
#  < AUTHOR > 
#   Yejoong Kim (yejoong@umich.edu)
##############################################################################

##############################################################################
# Using CapTable or QRC Techfiles
##############################################################################
create_rc_corner -name typRC -cap_table ${typ_captable_file}
create_rc_corner -name maxRC -cap_table ${max_captable_file}
create_rc_corner -name minRC -cap_table ${min_captable_file}

create_library_set -name typLib -timing ${typ_lib_file}

create_constraint_mode -name typConst -sdc_files $sdc_file

create_delay_corner -name maxDelay -library_set typLib -rc_corner maxRC
create_delay_corner -name minDelay -library_set typLib -rc_corner minRC

create_analysis_view -name maxAnalysis -constraint_mode typConst -delay_corner maxDelay
create_analysis_view -name minAnalysis -constraint_mode typConst -delay_corner minDelay

set_analysis_view -setup maxAnalysis -hold minAnalysis


#############################################################################
# Using Library Operating Conditions
#############################################################################
create_library_set -name typLib    -timing $typ_lib_file
#create_library_set -name typLibSvt -timing $typ_svt_lib_file
#create_library_set -name typLibHvt -timing $typ_hvt_lib_file

create_constraint_mode -name typConst \
    -sdc_files $sdc_file

create_delay_corner -name typDelay \
    -library_set typLib \
    -opcond_library typical \
    -opcond typical \

create_analysis_view -name typAnalysis \
    -constraint_mode typConst \
    -delay_corner typDelay

set_analysis_view \
    -setup {typAnalysis} \
    -hold {typAnalysis}

