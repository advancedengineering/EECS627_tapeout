# common.tcl setup library files

# 0.13um IBM Artisan Library
# Set library paths

set search_path [list "." \
                     "/afs/umich.edu/class/eecs627/tsmc180/sc_x_oa_utm" \
                     "./../lib" \
                    ]

set link_library "* typical.db dw_foundation.sldb"
set target_library "typical.db"

# set_dont_use any *XL* cell
set_dont_use { typical/*XL }

