
# sc_dir = /afs/eecs.umich.edu/kits/.contrib/tsmc_t018mm/arm_2010q1/sc_x_oa_utm
STD_CELLS = /afs/umich.edu/class/eecs627/tsmc180/sc-x_2004q3v1/aci/sc/verilog/tsmc18_neg.v
TESTBENCH = controller_tb.sv
# SIM_FILES = controller.sv
SIM_FILES = /afs/umich.edu/class/eecs627/w23/groups/group3/TOP/verilog/define.vh /afs/umich.edu/class/eecs627/w23/groups/group3/controller/verilog/counter1.sv \
                  /afs/umich.edu/class/eecs627/w23/groups/group3/controller/verilog/counter2.sv /afs/umich.edu/class/eecs627/w23/groups/group3/controller/verilog/demux.sv \
                  /afs/umich.edu/class/eecs627/w23/groups/group3/controller/verilog/controller.sv \
                  /afs/umich.edu/class/eecs627/w23/groups/group3/controller/verilog/shifter_reg.sv /afs/umich.edu/class/eecs627/w23/groups/group3/controller/verilog/shifter_reg_4bits.sv 
SIM_SYNTH_FILES = ../syn/controller.syn.v
SIM_APR_FILES = ../apr/controller.apr.v

VV		   = vcs
VVOPTS     = -o $@ +v2k +vc -sverilog -timescale=1ns/1ps +vcs+lic+wait +multisource_int_delays                    \
	       	+neg_tchk +incdir+$(VERIF) +plusarg_save +overlap +warn=noSDFCOM_UHICD,noSDFCOM_IWSBA,noSDFCOM_IANE,noSDFCOM_PONF -full64 -cc gcc +libext+.v+.vlib+.vh 

all: clean syn apr

clean:
	cd syn; make clean
	cd apr; make clean

syn:
	cd syn; make 

apr:
	cd apr; make

sim:
	cd verilog; $(VV) $(VVOPTS) $(SIM_FILES) $(TESTBENCH); ./$@

dve:
	cd verilog; $(VV) $(VVOPTS) $(STD_CELLS) $(SIM_FILES)  $(TESTBENCH) -lncurses $^ -debug_access+all -kdb -o $@ -R -gui

dve_synth:	
	cd verilog; $(VV) $(VVOPTS) $(STD_CELLS) $(SIM_SYNTH_FILES)  $(TESTBENCH) -lncurses $^ -debug_access+all -kdb -o $@ -R -gui

dve_apr:	
	cd verilog; $(VV) $(VVOPTS) $(STD_CELLS) $(SIM_APR_FILES)  $(TESTBENCH) -lncurses $^ -debug_access+all -kdb -o $@ -R -gui

sim_synth:
	cd verilog; $(VV) $(VVOPTS) $(STD_CELLS) $(SIM_SYNTH_FILES) $(TESTBENCH); ./$@

sim_apr:
	cd verilog; $(VV) $(VVOPTS) +sdfverbose +define+APR=1 $(STD_CELLS) $(SIM_APR_FILES) $(TESTBENCH); ./$@

power_est:
	cd apr; innovus -init apr_power_est.tcl 


.PHONY: syn