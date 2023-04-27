STD_CELLS = /afs/umich.edu/class/eecs627/tsmc180/sc-x_2004q3v1/aci/sc/verilog/tsmc18_neg.v 
TESTBENCH = verilog/TOP_tb.sv
G3_PATH = /afs/umich.edu/class/eecs627/w23/groups/group3
# ../TOP/verilog/define.vh
# ../SA_array/verilog/SA_Array.sv
SIM_FILES = ../TOP/verilog/define.vh ../SA_array/verilog/rr_arbiter.sv  ../SA_array/verilog/FIFO.sv ../SA_array_2/verilog/SA_array_part.sv ../SA_array_2/verilog/write_back_part.sv ../pooling/verilog/pooling.sv \
			../controller/verilog/controller.sv ../controller/verilog/counter1.sv ../controller/verilog/counter2.sv ../controller/verilog/counter3.sv ../controller/verilog/demux.sv ../controller/verilog/shifter.sv ../controller/verilog/shifter_reg.sv ../controller/verilog/shifter_reg_4bits.sv\
			../SA/verilog/SA.sv ../SA/verilog/PE.sv ../SA/verilog/BitBrick_4bit.sv ../SA/verilog/BitBrick.sv $(G3_PATH)/TSMC_SRAM/sram_apr17/compout/views/sram/Typical/sram.v
SIM_SYNTH_FILES = ../TOP/verilog/define.vh
SIM_APR_FILES = /afs/umich.edu/class/eecs627/w23/groups/group3/TOP/verilog/define.vh ../TSMC_Controller/apr/controller.apr.v ../TSMC_Shifter/apr/shifter.apr.v \
				../TSMC_write_back/apr/write_back_part.apr.v ../TSMC_SA_array_part_tgc_grid_sqh/apr/SA_array_part.apr.v $(G3_PATH)/TSMC_SRAM/sram_apr17/compout/views/sram/Typical/sram.v
VV         = vcs
VVOPTS     = +v2k +vc -sverilog -timescale=1ns/1ps +vcs+lic+wait +multisource_int_delays  +lint=TFIPC-L                   \
	       	+neg_tchk +incdir+$(VERIF) +plusarg_save +overlap +warn=noSDFCOM_UHICD,noSDFCOM_IWSBA,noSDFCOM_IANE,noSDFCOM_PONF -full64 -cc gcc +libext+.v+.vlib+.vh 

ifdef WAVES
VVOPTS += +define+DUMP_VCD=1 +memcbk +vcs+dumparrays +sdfverbose
endif

ifdef GUI
VVOPTS += -gui
endif

all: clean c_compile sim synth sim_synth sim_apr

clean:
	rm -f ucli.key
	rm -f sim
	rm -f sim_synth
	rm -fr sim.daidir
	rm -fr sim_synth.daidir
	rm -rf *.log
	rm -fr csrc
	rm -rf -r syn/dwsvf_*
	rm -f syn/mult.syn.v
	rm -f syn/output.txt
	rm -f syn/*.{log,sdf,rpt,svf}
	rm -f inter.*
	rm -f *afs*
	rm -f novas.*
	rm -rf sim*
	rm -f *.txt
	rm -rf sim_apr
	rm -rf sdf/*.sdf

c_compile:
	cd goldenbrick; gcc -Wall -ggdb -o goldenbrick goldenbrick.c
	cd goldenbrick; ./goldenbrick > goldenbrick.txt

sim: clean
	$(VV) -o $@  $(VVOPTS) -debug_access+all $(SIM_FILES) $(TESTBENCH) -kdb -R -gui
# $(VV) -o $@  $(VVOPTS) -debug_access+all $(SIM_FILES) $(TESTBENCH); ./$@

dve:	$(SIM_FILES)  $(TESTBENCH)
#	$(VV) $(VVOPTS) -lncurses $(SIM_FILES) $(TESTBENCH) -debug_access+all -kdb -o verilog/$@ -R -gui
	$(VV) $(VVOPTS) -lncurses $^ -debug_access+all -kdb -o $@ -R -gui

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

copy_from_apr:
	cp $(G3_PATH)/TSMC_SA_array_part_tgc_grid_sqh/apr/SA_array_part.apr.sdf $(G3_PATH)/TOP/sdf
	cp $(G3_PATH)/TSMC_write_back/apr/write_back_part.apr.sdf $(G3_PATH)/TOP/sdf
	cp $(G3_PATH)/TSMC_Controller/apr/controller.apr.sdf $(G3_PATH)/TOP/sdf
	cp $(G3_PATH)/TSMC_Shifter/apr/shifter.apr.sdf $(G3_PATH)/TOP/sdf
#	cp $(G3_PATH)/TSMC_SRAM/dual_port_tgc/compout/views/asssrsgss2p1024x16cm16/Typical/sram.lib $(G3_PATH)/TOP/sdf

sim_apr: clean copy_from_apr
	$(VV) $(VVOPTS) +sdfverbose -debug_access+all +define+APR=1 $(STD_CELLS) $(SIM_APR_FILES) $(TESTBENCH) -kdb -R -gui
#	-o $@ ; ./$@
