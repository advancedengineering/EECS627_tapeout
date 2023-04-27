set G3_PATH  /afs/umich.edu/class/eecs627/w23/groups/group3
#lc_shell
# read_lib ./SA_Array_max.lib
# write_lib SA_Array_max -format db -output SA_Array_max.db
# read_lib ./SA_Array_min.lib
# write_lib SA_Array_min -format db -output SA_Array_min.db
# read_lib ./SA_array_part.lib
read_lib $G3_PATH/TSMC_integration/lib/SA_array_part.lib
write_lib SA_array_part -format db -output SA_array_part.db

read_lib $G3_PATH/TSMC_integration/lib/write_back_part.lib
write_lib write_back_part -format db -output write_back_part.db

# read_lib ./controller_max.lib
# write_lib controller_max -format db -output controller_max.db
# read_lib ./controller_min.lib
# write_lib controller_min -format db -output controller_min.db
# read_lib ./controller.lib
read_lib $G3_PATH/TSMC_integration/lib/controller.lib
write_lib controller -format db -output controller.db

# read_lib ./shifter.lib
# write_lib shifter_max -format db -output shifter_max.db
# read_lib ./shifter_min.lib
# write_lib shifter_min -format db -output shifter_min.db
# read_lib ./shifter.lib
read_lib $G3_PATH/TSMC_integration/lib/shifter.lib
write_lib shifter -format db -output shifter.db

read_lib $G3_PATH/TSMC_integration/lib/sram.lib
#write_lib sram -format db -output sram.db
write_lib sram_lib -format db -output sram.db

read_lib $G3_PATH/TSMC_integration/lib/Ring.lib
write_lib Ring -format db -output Ring.db

quit
