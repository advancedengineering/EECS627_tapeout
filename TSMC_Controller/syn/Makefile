
all: clean syn

clean:
	rm -rf dwsvf_*
	rm -f *.syn.v
	rm -f output.txt
	rm -f *.{log,sdf,rpt,svf,sdc}

syn:
	dc_shell -tcl_mode -xg_mode -f controller.syn.tcl | tee output.txt



