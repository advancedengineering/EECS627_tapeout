######################################
# message suppression
######################################
setmessagelimit 100
# implf-119 : a layer already defined, the content other than the antenna data will be ignored.
suppressmessage implf-119
# implf-58 : a layer already defined, the content other than the density and antenna data will be ignored.
suppressmessage implf-58
# implf-61 : a macro already defined, the content other than the density and antenna data will be ignored.
suppressmessage implf-61
# implf-200 : no antennagatearea (ignored for outputs)
suppressmessage implf-200
# implf-201 : no antennadiffarea (ignored for outputs)
suppressmessage implf-201
# imppp-557 : a single-layer viarule generate for turn-vias is obsolete and ignored
suppressmessage imppp-557
# techlib-436 : attribute 'max_fanout' on 'output/input' pin 'x' of cell 'xxx' is not defined in the library.
suppressmessage techlib-436
# additional: /afs/eecs.umich.edu/vlsida/users/junghol/stimote/digital/apr/220613_digital/hvgm.tcl
