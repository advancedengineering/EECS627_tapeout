STD_CELLS = /afs/umich.edu/class/eecs627/ibm13/artisan/2005q3v1/aci/sc-x/verilog/ibm13_neg.sv
TESTBENCH = verilog/controller_tb.sv 
SIM_FILES = ../TOP/verilog/define.vh \
			verilog/controller.sv verilog/counter1.sv verilog/counter2.sv verilog/counter3.sv verilog/demux.sv verilog/shifter.sv verilog/shifter_reg.sv verilog/shifter_reg_4bits.sv
SIM_SYNTH_FILES = standard.vh ../syn/SA.syn.sv

VV         = vcs
VVOPTS     = +v2k +vc -sverilog -timescale=1ns/1ps +vcs+lic+wait +multisource_int_delays  +lint=TFIPC-L                   \
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

sim: clean
	$(VV) -o $@  $(VVOPTS) -debug_access+all $(SIM_FILES) $(TESTBENCH) -kdb -R -gui

dve:	$(SIM_FILES)  $(TESTBENCH)
#	$(VV) $(VVOPTS) -lncurses $(SIM_FILES) $(TESTBENCH) -debug_access+all -kdb -o verilog/$@ -R -gui
	$(VV) $(VVOPTS) -lncurses $^ -debug_access+all -kdb -o verilog/$@ -R -gui

synth:
	cd syn; dc_shell -tcl_mode -xg_mode -f mult_8bit.syn.tcl | tee output.txt 

sim_synth:
	cp goldenbrick/goldenbrick.txt verilog/goldenbrick.txt
	cd verilog; $(VV) $(VVOPTS) $(STD_CELLS) $(SIM_SYNTH_FILES) $(TESTBENCH); ./$@
	diff verilog/goldenbrick.txt verilog/testbench.txt | tee verilog/diff_structural.txt
	cp verilog/testbench.txt verilog/testbench_structural.txt

run_apr:
	cd apr; mv BitBrick_8bit.apr.tcl viewDefinition.tcl BitBrick.globals BitBrick_8bit.io ../; rm -rf ./*; cd ..; mv BitBrick_8bit.apr.tcl viewDefinition.tcl BitBrick.globals BitBrick_8bit.io apr/
	cd apr; innovus -init BitBrick_8bit.apr.tcl | tee output.txt 

# sim_apr:
# 	cd verilog; $(VV) $(VVOPTS) +sdfverbose +define+APR=1 $(STD_CELLS) $(SIM_APR_FILES) $(TESTBENCH); ./$@
# 	cp verilog/signatures.txt verilog/signatures_apr.txt
# 	diff verilog/signatures_behavioral.txt verilog/signatures_apr.txt | tee verilog/diff_structural.txt
