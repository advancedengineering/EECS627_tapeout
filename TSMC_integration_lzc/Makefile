STD_CELLS = /afs/umich.edu/class/eecs627/tsmc180/sc-x_2004q3v1/aci/sc/verilog/tsmc18_neg.v \
			/afs/umich.edu/class/eecs627/w23/groups/group3/TSMC_Controller/apr/controller.apr.v \
			/afs/umich.edu/class/eecs627/w23/groups/group3/TSMC_Shifter/apr/shifter.apr.v \
			/afs/umich.edu/class/eecs627/w23/groups/group3/TSMC_SA_array_part_grid/apr/SA_array_part.apr.v
#std cell need to be added for simulation

G3_PATH = /afs/umich.edu/class/eecs627/w23/groups/group3

SRAM_TOP = sram

SIM_FILES = ../verilog/standard.vh \
			../verilog/define.vh \
			../verilog/TOP.sv

SIM_SYN_FILES = ../verilog/standard.vh \
				../syn/data/TOP.syn.v \
				../../TSMC_SA_Array_part_grid/apr/SA_Array.syn.v

SIM_APR_FILES = ../verilog/standard.vh \
				../apr/data/TOP.apr.v \
				../../TSMC_SA_array_part_grid/apr/SA_Array.apr.v

VV         = vcs
VVOPTS     = -o $@ +v2k +vc -sverilog -timescale=1ns/1ps +vcs+lic+wait +multisource_int_delays                    \
	       	+neg_tchk +notimingcheck +incdir+$(VERIF) +plusarg_save +overlap +warn=noSDFCOM_UHICD,noSDFCOM_IWSBA,noSDFCOM_IANE,noSDFCOM_PONF -full64 -cc gcc +libext+.v+.vlib+.vh 

top_level	= TOP

ifdef WAVES
VVOPTS += +define+DUMP_VCD=1 +memcbk +vcs+dumparrays +sdfverbose
endif

ifdef GUI
VVOPTS += -gui
endif

all: clean sim lef run_syn sim_syn run_apr sim_apr

clean:
	rm -rf vsim/ucli.key
	rm -rf vsim/sim
	rm -rf vsim/sim_syn
	rm -rf vsim/sim_apr
	rm -rf vsim/sim.daidir
	rm -rf vsim/sim_syn.daidir
	rm -rf vsim/sim_apr.daidir
	rm -rf vsim/*.log
	rm -rf vsim/csrc
	rm -rf vsim/sdfAnnotateInfo
	rm -rf -r syn/dwsvf_*
	rm -rf syn/output.txt
	rm -rf syn/alib*
	rm -rf syn/*.svf
	rm -rf syn/*.log
	rm -rf apr/output.txt
	rm -rf apr/innovus.*
	rm -rf apr/*.lef
	rm -rf apr/*.rpt*
	rm -rf apr/*Analysis.txt
	rm -rf apr/rc_model.bin
	rm -rf apr/*.pgnets
	rm -rf apr/powerAnalysis.*
	rm -rf apr/vectorprofile.*
	rm -rf apr/voltus*
	rm -rf apr/*.ptiavg
	rm -rf apr/*.spef*
	rm -rf apr/*.gz
	rm -rf apr/*log
	rm -rf apr/pm.ob
	rm -f lib/*.db
	rm -f lib/*.lib
	rm -f lib/*.txt
	rm -f lef/*.lef

sim:
	cd vsim; $(VV) $(VVOPTS) $(STD_CELLS) $(SIM_FILES) $(TESTBENCH); ./$@
	cp vsim/signatures.txt vsim/signatures_behavioral.txt


models:
	cd lib; pt_shell -f reset_driver.lib.tcl | tee reset_driver.log
	cd lib; pt_shell -f SRAM_template.lib.tcl | tee SRAM_template.log

copy_from_apr:
	cp $(G3_PATH)/TSMC_SA_array_part_lzc/apr/SA_array_part.lib $(G3_PATH)/TSMC_integration_lzc/lib
	cp $(G3_PATH)/TSMC_write_back/apr/write_back_part.lib $(G3_PATH)/TSMC_integration_lzc/lib
	cp $(G3_PATH)/TSMC_Controller/apr/controller.lib $(G3_PATH)/TSMC_integration_lzc/lib
	cp $(G3_PATH)/TSMC_Shifter/apr/shifter.lib $(G3_PATH)/TSMC_integration_lzc/lib
	cp $(G3_PATH)/TSMC_SRAM/sram_apr17/compout/views/$(SRAM_TOP)/Typical/$(SRAM_TOP).lib $(G3_PATH)/TSMC_integration_lzc/lib/sram.lib
	cp $(G3_PATH)/virtuoso_example/digital/Ring/apr/Ring.lib $(G3_PATH)/TSMC_integration_lzc/lib

	cp $(G3_PATH)/TSMC_SA_array_part_lzc/apr/SA_array_part.lef $(G3_PATH)/TSMC_integration_lzc/lef
	cp $(G3_PATH)/TSMC_write_back/apr/write_back_part.lef $(G3_PATH)/TSMC_integration_lzc/lef
	cp $(G3_PATH)/TSMC_Controller/apr/controller.lef $(G3_PATH)/TSMC_integration_lzc/lef
	cp $(G3_PATH)/TSMC_Shifter/apr/shifter.lef $(G3_PATH)/TSMC_integration_lzc/lef
	cp $(G3_PATH)/TSMC_SRAM/sram_apr17/compout/views/$(SRAM_TOP)/$(SRAM_TOP).plef $(G3_PATH)/TSMC_integration_lzc/lef/sram.plef
	cp $(G3_PATH)/virtuoso_example/digital/Ring/apr/Ring.lef $(G3_PATH)/TSMC_integration_lzc/lef

run_syn: copy_from_apr
	cd lib; lc_shell -f LIBtoDB.tcl | tee LIBtoDB_rpt.txt
	cd syn; dc_shell -tcl_mode -xg_mode -f TOP.syn.tcl | tee output.txt

sim_syn:
	cd vsim; $(VV) $(VVOPTS) +define+SYN=1 $(STD_CELLS) $(SIM_SYN_FILES) $(TESTBENCH); ./$@
	cp vsim/signatures.txt vsim/signatures_syn.txt
	diff vsim/signatures_behavioral.txt vsim/signatures_syn.txt | tee vsim/diff_syn.txt

run_apr:
	cd apr; innovus -init apr_main.tcl | tee output.txt 

sim_apr:
	cd vsim; $(VV) $(VVOPTS) +sdfverbose +define+APR=1 $(STD_CELLS) $(SIM_APR_FILES) $(TESTBENCH); ./$@
	cp vsim/signatures.txt vsim/signatures_apr.txt
	diff vsim/signatures_behavioral.txt vsim/signatures_apr.txt | tee vsim/diff_structural.txt

power_apr:
	cd apr; innovus -init apr_power_est.tcl 

check:
	@ echo " "
	@ echo "**** [Makefile] Checking $(top_level) Setup Time Report... "
	@ echo " "
	@ if zgrep -q "VIOLATED" apr/timingReports/$(top_level)_postRoute_all.tarpt.gz; \
	   then zgrep "VIOLATED" apr/timingReports/$(top_level)_postRoute_all.tarpt.gz; \
	        echo ""; \
	        zgrep -m 1 "Slack Time" apr/timingReports/$(top_level)_postRoute_all.tarpt.gz; \
	        echo ""; \
       else echo "      PASS!"; fi
	@ echo " "
	@ echo "**** [Makefile] Checking $(top_level) Hold Time Report... "
	@ echo " "
	@ if zgrep -q "VIOLATED" apr/timingReports/$(top_level)_postRoute_all_hold.tarpt.gz; \
	   then zgrep "VIOLATED" apr/timingReports/$(top_level)_postRoute_all_hold.tarpt.gz; \
	        echo ""; \
	        zgrep -m 1 "Slack Time" apr/timingReports/$(top_level)_postRoute_all_hold.tarpt.gz; \
	        echo ""; \
       else echo "      PASS!"; fi
	@ echo " "
	@ echo "**** [Makefile] Timing Check Done... "
	@ echo " "

cp_cdl: 
	cp $(G3_PATH)/TSMC_SA_array_part_lzc/apr/SA_array_part.cdl $(G3_PATH)/TSMC_integration_lzc/v2lvs
	cp $(G3_PATH)/TSMC_write_back/apr/write_back_part.cdl $(G3_PATH)/TSMC_integration_lzc/v2lvs
	cp $(G3_PATH)/TSMC_Controller/apr/controller.cdl $(G3_PATH)/TSMC_integration_lzc/v2lvs
	cp $(G3_PATH)/TSMC_Shifter/apr/shifter.cdl $(G3_PATH)/TSMC_integration_lzc/v2lvs
	cp $(G3_PATH)/virtuoso_example/digital/Ring/apr/Ring.cdl $(G3_PATH)/TSMC_integration_lzc/v2lvs

	cp $(G3_PATH)/TSMC_SA_array_part_lzc/apr/SA_array_part.apr.pg.v $(G3_PATH)/TSMC_integration_lzc/v2lvs
	cp $(G3_PATH)/TSMC_write_back/apr/write_back_part.apr.pg.v $(G3_PATH)/TSMC_integration_lzc/v2lvs
	cp $(G3_PATH)/TSMC_Controller/apr/controller.apr.pg.v $(G3_PATH)/TSMC_integration_lzc/v2lvs
	cp $(G3_PATH)/TSMC_Shifter/apr/shifter.apr.pg.v $(G3_PATH)/TSMC_integration_lzc/v2lvs
	cp $(G3_PATH)/virtuoso_example/digital/Ring/apr/Ring.apr.pg.v $(G3_PATH)/TSMC_integration_lzc/v2lvs