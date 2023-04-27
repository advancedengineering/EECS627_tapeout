STD_CELLS = /afs/umich.edu/class/eecs627/ibm13/artisan/2005q3v1/aci/sc-x/verilog/ibm13_neg.v
TESTBENCH = PE_tb.sv
SIM_FILES = PE.sv BitBrick_4bit.sv BitBrick.sv SA.sv
SIM_SYNTH_FILES = ../syn/PE.syn.v

VV         = vcs
VVOPTS     = -o $@ +v2k +vc -sverilog -timescale=1ns/1ps +vcs+lic+wait +multisource_int_delays                    \
	       	+neg_tchk +incdir+$(VERIF) +plusarg_save +overlap +warn=noSDFCOM_UHICD,noSDFCOM_IWSBA,noSDFCOM_IANE,noSDFCOM_PONF -full64 -cc gcc +libext+.v+.vlib+.vh 

ifdef WAVES
VVOPTS += +define+DUMP_VCD=1 +memcbk +vcs+dumparrays +sdfverbose
endif

ifdef GUI
VVOPTS += -gui
endif

all: clean c_compile sim synth sim_synth

clean:
	rm -f verilog/ucli.key
	rm -f verilog/sim
	rm -f verilog/sim_synth
	rm -fr verilog/sim.daidir
	rm -fr verilog/sim_synth.daidir
	rm -f verilog/*.log
	rm -fr verilog/csrc
	rm -f verilog/goldenbrick.txt
	rm -f verilog/testbench.txt
	rm -f verilog/testbench_functional.txt
	rm -f verilog/testbench_structural.txt
	rm -f verilog/diff_functional.txt
	rm -f verilog/diff_structural.txt
	rm -f goldenbrick/goldenbrick
	rm -f goldenbrick/goldenbrick.txt
	rm -f -r syn/dwsvf_*
	rm -f syn/mult.syn.v
	rm -f syn/output.txt
	rm -f syn/*.{log,sdf,rpt,svf}

c_compile:
	cd goldenbrick; gcc -Wall -ggdb -o goldenbrick goldenbrick.c
	cd goldenbrick; ./goldenbrick > goldenbrick.txt

sim:
	#cp goldenbrick/goldenbrick.txt verilog/goldenbrick.txt
	cd verilog; $(VV) $(VVOPTS) $(SIM_FILES) $(TESTBENCH); ./$@
	#diff verilog/goldenbrick.txt verilog/testbench.txt | tee verilog/diff_functional.txt
	#cp verilog/testbench.txt verilog/testbench_functional.txt

synth:
	cd syn; dc_shell -tcl_mode -xg_mode -f SA.syn.tcl | tee output.txt 

sim_synth:
	#cp goldenbrick/goldenbrick.txt verilog/goldenbrick.txt
	cd verilog; $(VV) $(VVOPTS) $(STD_CELLS) $(SIM_SYNTH_FILES) $(TESTBENCH); ./$@
	#diff verilog/goldenbrick.txt verilog/testbench.txt | tee verilog/diff_structural.txt
	#cp verilog/testbench.txt verilog/testbench_structural.txt

run_apr:
	cd apr; mv BitBrick_8bit.apr.tcl viewDefinition.tcl BitBrick.globals BitBrick_8bit.io ../; rm -rf ./*; cd ..; mv BitBrick_8bit.apr.tcl viewDefinition.tcl BitBrick.globals BitBrick_8bit.io apr/
	cd apr; innovus -init BitBrick_8bit.apr.tcl | tee output.txt 

# sim_apr:
# 	cd verilog; $(VV) $(VVOPTS) +sdfverbose +define+APR=1 $(STD_CELLS) $(SIM_APR_FILES) $(TESTBENCH); ./$@
# 	cp verilog/signatures.txt verilog/signatures_apr.txt
# 	diff verilog/signatures_behavioral.txt verilog/signatures_apr.txt | tee verilog/diff_structural.txt
