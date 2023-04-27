
# sc_dir = /afs/eecs.umich.edu/kits/.contrib/tsmc_t018mm/arm_2010q1/sc_x_oa_utm
STD_CELLS = /afs/umich.edu/class/eecs627/tsmc180/sc-x_2004q3v1/aci/sc/verilog/tsmc18_neg.v
TESTBENCH = SA_tb2.sv
SIM_FILES = SA.sv PE.sv BitBrick_4bit.sv BitBrick.sv
SIM_SYNTH_FILES = ../syn/SA.syn.v
SIM_APR_FILES = ../apr/SA.apr.v

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

sim_synth:
	cd verilog; $(VV) $(VVOPTS) $(STD_CELLS) $(SIM_SYNTH_FILES) $(TESTBENCH); ./$@

sim_apr:
	cd verilog; $(VV) $(VVOPTS) +sdfverbose +define+APR=1 $(STD_CELLS) $(SIM_APR_FILES) $(TESTBENCH); ./$@
