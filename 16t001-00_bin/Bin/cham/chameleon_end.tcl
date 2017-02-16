# After Flow Script

project_open [lindex $quartus(args) 1]
set_parameter -name "incremented" -remove
export_assignments
project_close