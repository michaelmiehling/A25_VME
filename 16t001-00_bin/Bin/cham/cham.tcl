package require cham

if {$argc == 0} {
   ::cham::chameleon
} else {
   ::cham::chameleon_preflow [lindex $quartus(args) 1]
}
