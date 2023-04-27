# Version:1.0 MMMC View Definition File
# Do Not Remove Above Line
set QTM_DIR     $CURRENT_PATH/../lib
set QRC_PATH	/afs/umich.edu/class/eecs627/w23/resources

set cap_dir     /afs/umich.edu/class/eecs627/tsmc180/captable/1_2
set max_captable_file   [list   ${cap_dir}/TSMC180_6m_4x1n8k_cworst.CapTbl]
set typ_captable_file   [list   ${cap_dir}/TSMC180_6m_4x1n8k_typical.CapTbl]
set min_captable_file   [list   ${cap_dir}/TSMC180_6m_4x1n8k_cbest.CapTbl]
# Create RC Corners
# note: Captable is used by above 32nm nodes and QRC tech by below 32nm nodes
create_rc_corner -name typRC -cap_table ${typ_captable_file}
create_rc_corner -name maxRC -cap_table ${max_captable_file}
create_rc_corner -name minRC -cap_table ${min_captable_file}
# create_rc_corner -name rc-typ \
#         -T {25} -preRoute_res {1.0} -preRoute_cap {1.0} \
#         -preRoute_clkres {0.0} -preRoute_clkcap {0.0} \
#         -postRoute_res {1.0} -postRoute_cap {1.0} \
#         -postRoute_xcap {1.0} -postRoute_clkres {0.0} -postRoute_clkcap {0.0} \
#         -qx_tech_file "$QRC_PATH/cmos8rf_8LM_62_SigCmax.tch" 

# create_rc_corner -name rc-best \
#         -T {25} -preRoute_res {1.0} -preRoute_cap {1.0} \
#         -preRoute_clkres {0.0} -preRoute_clkcap {0.0} \
#         -postRoute_res {1.0} -postRoute_cap {1.0} \
#         -postRoute_xcap {1.0} -postRoute_clkres {0.0} -postRoute_clkcap {0.0} \
#         -qx_tech_file "$QRC_PATH/cmos8rf_8LM_62_SigCmax.tch" 

# create_rc_corner -name rc-worst \
#         -T {25} -preRoute_res {1.0} -preRoute_cap {1.0} \
#         -preRoute_clkres {0.0} -preRoute_clkcap {0.0} \
#         -postRoute_res {1.0} -postRoute_cap {1.0} \
#         -postRoute_xcap {1.0} -postRoute_clkres {0.0} -postRoute_clkcap {0.0} \
#         -qx_tech_file "$QRC_PATH/cmos8rf_8LM_62_SigCmax.tch" 

# Create Libraries
create_library_set -name typLib -timing $typ_lib_file
# create_library_set -name typLib    -timing $typ_lib_file
# create_library_set -name typLibSvt -timing $typ_svt_lib_file
# create_library_set -name typLibHvt -timing $typ_hvt_lib_file

# create_library_set -name typLibs -timing "\
# 		$TECH_PATH/synopsys/typical.lib\
# 		$TECH_PATH/../io/synopsys/arti_ibm13io_syn_tt.lib\
# 		$QTM_DIR/reset_driver.lib\
# 		$QTM_DIR/mult_block.lib\
# 		$SRAM_DIR/SIGN_MEM/SIGN_MEM_tt_1p2v_25c_syn.lib\
# 		"

# create_library_set -name bestLibs -timing "\
# 		$TECH_PATH/synopsys/typical.lib\
# 		$TECH_PATH/../io/synopsys/arti_ibm13io_syn_tt.lib\
# 		$QTM_DIR/reset_driver.lib\
# 		$QTM_DIR/mult_block.lib\
# 		$SRAM_DIR/SIGN_MEM/SIGN_MEM_tt_1p2v_25c_syn.lib\
# 		"

# create_library_set -name worstLibs -timing "\
# 		$TECH_PATH/synopsys/typical.lib\
# 		$TECH_PATH/../io/synopsys/arti_ibm13io_syn_tt.lib\
# 		$QTM_DIR/reset_driver.lib\
# 		$QTM_DIR/mult_block.lib\
# 		$SRAM_DIR/SIGN_MEM/SIGN_MEM_tt_1p2v_25c_syn.lib\
# 		"

# Create Constraint Mode with sdc file
create_constraint_mode -name typConst -sdc_files $SDC_FILE
# create_constraint_mode -name typConstraintMode -sdc_files $SDC_FILE

# Create Delay Corners
create_delay_corner -name typDelay -library_set typLib -opcond_library typical -opcond typical 
create_delay_corner -name maxDelay -library_set typLib -rc_corner maxRC
create_delay_corner -name minDelay -library_set typLib -rc_corner minRC
# create_delay_corner -name typDelay -library_set {typLibs} -rc_corner {rc-typ}
# create_delay_corner -name bestDelay -library_set {bestLibs} -rc_corner {rc-typ}
# create_delay_corner -name worstDelay -library_set {worstLibs} -rc_corner {rc-typ}

# Create Analysis Views
create_analysis_view -name typAnalysis -constraint_mode typConst -delay_corner typDelay
create_analysis_view -name maxAnalysis -constraint_mode typConst -delay_corner maxDelay
create_analysis_view -name minAnalysis -constraint_mode typConst -delay_corner minDelay
# create_analysis_view -name typAnalysis -constraint_mode {typConstraintMode} -delay_corner {typDelay}
# create_analysis_view -name holdAnalysis -constraint_mode {typConstraintMode} -delay_corner {bestDelay}
# create_analysis_view -name setupAnalysis -constraint_mode {typConstraintMode} -delay_corner {worstDelay}

# Set Analysis Views
set_analysis_view -setup maxAnalysis -hold minAnalysis
set_analysis_view -setup {typAnalysis} -hold {typAnalysis}

# set_analysis_view -setup {setupAnalysis} -hold {holdAnalysis}

