# After Flow Script - tell the script engine that a successful flow has been executed

project_open [lindex $quartus(args) 1]
set_parameter -name "incremented" -remove
export_assignments
project_close