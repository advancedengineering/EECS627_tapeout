##############################################################################
# Makefile FOR INNOVUS 18.10
##############################################################################

top_level   = SA_array_part

############################
## Directories
############################
sc_dir = /afs/umich.edu/class/eecs627/tsmc180/sc_x_oa_utm

############################
## File Names
############################
cdl_file     = $(top_level).cdl
ckt_file     = $(top_level).ckt
apr_v        = $(top_level).apr.v
apr_pg_v     = $(top_level).apr.pg.v
apr_sim_v    = $(top_level).apr.sim.v
apr_sdf      = $(top_level).apr.sdf

############################
## User-Defined Variables
############################

############################
## v2lvs Settings
############################
cdl_v2lvs_lsr = -lsr $(sc_dir)/sc_x.cdl
cdl_v2lvs_s   = -s $(sc_dir)/sc_x.cdl
ckt_v2lvs_lsr = -lsr $(sc_dir)/sc_x.ckt
ckt_v2lvs_s   = -s $(sc_dir)/sc_x.ckt

############################
## Makefile Recipes
############################
FINAL_MSG =	"**** [Makefile]: End of Makefile ****"

apr:
	@ echo "**** [Makefile] Deleting previous log files... "
	@ rm -rf innovus.* anaMsvClk.* $(top_level).log* $(top_level).cmd* *.rcdb.d *.old .*_diode.list* .*.fp .*.fp.spr *Analysis.txt *Analysis_early_*.rpt *Analysis_late_*.rpt
	@ echo "**** [Makefile] Starting Innovus... "
	@ innovus -init apr.tcl | tee apr.log

check:
	@ echo " "
	@ echo "**** [Makefile] Checking $(top_level) Setup Time Report... "
	@ echo " "
	@ if zgrep -q "VIOLATED" timingReports/$(top_level)_postRoute_all.tarpt.gz; \
	   then zgrep "VIOLATED" timingReports/$(top_level)_postRoute_all.tarpt.gz; \
	        echo ""; \
	        zgrep -m 1 "Slack Time" timingReports/$(top_level)_postRoute_all.tarpt.gz; \
	        echo ""; \
       else echo "      PASS!"; fi
	@ echo " "
	@ echo "**** [Makefile] Checking $(top_level) Hold Time Report... "
	@ echo " "
	@ if zgrep -q "VIOLATED" timingReports/$(top_level)_postRoute_all_hold.tarpt.gz; \
	   then zgrep "VIOLATED" timingReports/$(top_level)_postRoute_all_hold.tarpt.gz; \
	        echo ""; \
	        zgrep -m 1 "Slack Time" timingReports/$(top_level)_postRoute_all_hold.tarpt.gz; \
	        echo ""; \
       else echo "      PASS!"; fi
	@ echo " "
	@ echo "**** [Makefile] Timing Check Done... "
	@ echo " "

#cdl: pre_v2lvs v2lvs final_msg
spice: pre_v2lvs v2lvs final_msg

pre_v2lvs:
	@ echo " "
	@ echo "**** [Makefile] Preparing stuffs for v2lvs... "
	@ echo " "

v2lvs:
	@ echo " "
	@ echo "**** [Makefile] Starting v2lvs... "
	@ echo " "
	v2lvs -a \<\> -i -v ./$(apr_pg_v) $(cdl_v2lvs_lsr) $(cdl_v2lvs_s) -o $(cdl_file) -sn 
	v2lvs -a \<\> -i -v ./$(apr_pg_v) $(ckt_v2lvs_lsr) $(ckt_v2lvs_s) -o $(ckt_file) -sn 
	
final_msg:
	@ echo " "
	@ echo $(FINAL_MSG)
	@ echo " "

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

.PHONY: apr check cdl pre_v2lvs v2lvs post_v2lvs final_msg clean
