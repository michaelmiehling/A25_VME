#------------------------------------------------------------------------------
# File          : gen_ip_cores.tcl
# Author        : Grzegorz Daniluk <greg.daniluk@cern.ch>
# Organization  : CERN
# Created       : 2017-04-27
#------------------------------------------------------------------------------
# Based on GSI work for bel-projects and White Rabbit project
#------------------------------------------------------------------------------
#
# Copyright (c) 2017, CERN
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#------------------------------------------------------------------------------


# Load Quartus II Tcl Project package
package require ::quartus::project

# Borrowed and adjusted from GSI bel-projects
proc qmegawiz {files} {
  set dir [file dirname [info script]]
  post_message "Testing for megawizard regeneration in $dir:$files"

  set device  [ get_global_assignment -name DEVICE ]
  set family  [ get_global_assignment -name FAMILY ]

  foreach i $files {
    if {![file exists "$dir/$i.qip"] || [file mtime "$dir/$i.txt"] > [file mtime "$dir/$i.qip"]} {
      post_message -type info "Regenerating $i using qmegawiz"
      file delete "$dir/$i.qip"
      file copy -force "$dir/$i.txt" "$dir/$i.vhd"

      set sf [open "| qmegawiz -silent \"-defaultfamily:$family\" \"-defaultdevice:$device\" \"$dir/$i.vhd\" 2>@stderr" r]
      while {[gets $sf line] >= 0} { post_message -type info "$line" }
      if {[catch {close $sf} err]} {
	post_message -type error "Executing qmegawiz: $err"
	exit 1
      }
      if {![file exists "$dir/$i.qip"]} {
	post_message -type error "Executing qmegawiz: did not create $dir/$i.qip!"
	exit 1
      }

      file mtime "$dir/$i.qip" [file mtime "$dir/$i.vhd"]
    }
      set_global_assignment -name QIP_FILE "$dir/$i.qip"
  }
}

# SCRIPT EXECUTION STARTS HERE
post_message "Executing A25 pre-flow script"

set project_name "A25_top"

set make_assignments 0

# Make sure that the right project is open
if {[is_project_open]} {
    if {[string compare $quartus(project) $project_name]} {
	project_close
	project_open -force $project_name
    }
} else {
    project_open -force $project_name
}

source ../16z091-01_src/Source/x4/x4.tcl
source ../Source/pll_pcie/gen_pll_pcie.tcl
source ../16z126-01_src/Source/z126_01_pasmi/gen_m25p32.tcl
source ../16z126-01_src/Source/z126_01_ru/gen_ru.tcl

# Commit assignments
export_assignments

# SCRIPT EXECUTION ENDS HERE
post_message "A25 pre-flow script execution complete"
