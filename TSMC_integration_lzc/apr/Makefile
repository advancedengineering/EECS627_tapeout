##############################################################################
# Makefile FOR INNOVUS 18.10
##############################################################################

top_level   = TOP

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
	rm -rf .cadence .t* timingReports *.rcdb.d *.v innovus.* *.sdf *.bk CTS_*.txt cts.rguide *.rpt *.trace *.def *.old *.lef *.gds *.spf *.spef *.dc.outbound.* clkNetList.* implicitIsoShifterRules.cpf orig*.route origScaleFactor.tcl *_diode.list* *.apr.sdf.orig *.mac.ckt *.cdl.orig v2lvs.log db .nano_eco_diode* scripts/ccopt* *.cdl *.ckt *.log *Analysis* *.lib *.cmd* *.log*

.PHONY: apr check cdl pre_v2lvs v2lvs post_v2lvs final_msg clean
