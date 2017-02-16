


# Delete the 'cham' (chameleon) namespace
if {[namespace exists cham]} {
	catch {namespace delete cham}
}

# Mask error when pressing the alt button - could not find any other solution than to hijack this function
namespace eval tk {
   proc WinMenuKey {bla blubb} {
   }
}

namespace eval cham {
   set version 1.15
   set debug 0
   set major 0
   set minor 0
   set override_revision 0
   set gen_adr_dec 0
   set cc_adr_dec_type 0
   set cc_gen_lookup 0
   set cc_gen_pci_hex 0
   set cc_increment_minor 0
   set cc_manual_cfg 0
   set cc_cfg_file 0
   set cc_gen_offsets 0
   set chameleon_tool ""
   set excel_tool ""
   set cham_is_script 0
   set pkg_path $::quartus(quartus_rootpath)
   
   proc init_cham { } {
      package require inifile
      #set cham::debug 1;
      set cham::major [get_parameter -name major_revision];
      set cham::minor [get_parameter -name minor_revision];
      set cham::override_revision [get_parameter -name override_revision]
      set cham::gen_adr_dec [get_parameter -name gen_adr_dec]
      
      
      if {$cham::gen_adr_dec != 0 && $cham::gen_adr_dec != 1} {
         set cham::gen_adr_dec 0
      }
      
      if {$cham::override_revision != 0 && $cham::override_revision != 1} {
         set cham::override_revision 0
      }
      
      # Compilation configuration settings - generate variables used for dialog
      set cham::cc_adr_dec_type ""
      set cham::cc_gen_lookup 0
      set cham::cc_gen_pci_hex 0
      set cham::cc_increment_minor 1
      set cham::cc_manual_cfg 0
      set cham::cc_cfg_file 0
      set cham::cc_gen_offsets 0
      
      # Tools are saved in an ini file located inside the library directory
      # Open ini file
      set cham_ini [::ini::open [file join $cham::pkg_path "lib/cham" "chameleon.ini"] r] 
      if {[::ini::exists $cham_ini "Paths"]} {
         set ini_paths [::ini::get $cham_ini "Paths"]
         ::ini::close $cham_ini
      } else {
         set ini_paths ""
      }
      
      for {set i 0} {$i < [llength $ini_paths]} {incr i; incr i} {
         #puts "[lindex $ini_paths $i] [lindex $ini_paths [expr $i + 1]]"
         if {[lindex $ini_paths $i] == "is_script"} {
            set cham::cham_is_script  [lindex $ini_paths [expr $i + 1]]
         }
         if {[lindex $ini_paths $i] == "excel"} {
            set cham::excel_tool      [lindex $ini_paths [expr $i + 1]]
         }
         if {[lindex $ini_paths $i] == "cham"} {
            set cham::chameleon_tool  [lindex $ini_paths [expr $i + 1]]
         }
      }
      
   }
   
   proc dbg {dbg_msg} {
      if {$cham::debug == 1} {
         post_message -type info $dbg_msg
      }
   }
   
   proc get_chameleon_files { } {
      dbg "Started get_chameleon_files"
      set no_of_chams [get_parameter -name no_of_chams]
      set cham_list ""
      if {$no_of_chams > 0} {
         for { set i 0} {$i < $no_of_chams} {incr i} {
            lappend cham_list [get_parameter -name "chameleon_$i"]
         }
      }
      dbg "Current items in chameleon list $cham_list"
      return $cham_list
   }
   
   proc get_chameleon_option {id} {
      dbg "Started get_chameleon_option $id"
      set no_of_chams [get_parameter -name no_of_chams]
      set cham_list ""
      
      if {$no_of_chams > 0} {
         for { set i 0} {$i < $no_of_chams} {incr i} {
            dbg "chameleon_${id}_${i}"
            lappend cham_list [get_parameter -name "chameleon_${id}_${i}"]
         }
      }
      dbg "Current items in chameleon list $cham_list"
      return $cham_list
   }
   
   proc save_chameleon_file {filename} {
      dbg "Save_chameleon_file started"
      
   }
   
   proc compile_all { } {
      # compile all files
      
      # check if chameleon path is ok
      if {![file exist $cham::chameleon_tool]} {
         setup_paths
         if {![file exist $cham::chameleon_tool]} {
            post_message -type error "Chameleon Tool Path incorrect - deinstall preflow script or set path correctly"
            return
         }
      }
      
      # Retrieve the number of available chameleon tables
      set no_of_chams [get_parameter -name no_of_chams]
      
      # throw error in case there is none
      if {$no_of_chams == 0 || $no_of_chams == ""} {
         post_message -type error "No chameleon tables defined in qsf file - please check the chameleon setup"
      } else {
         # Run compilation for each of the items
         for {set i 0} {$i < $no_of_chams} {incr i} {
            run_compile $i
         }
      }
      
      # in case compile_all has been called from within the gui, deselect the one time compile options
      if {[winfo exists .top] == 1} {
      	.top.revision_f.use_cb deselect
         .top.revision_f.gen_adr_dec_cb deselect
      }
   }
   
   proc compile { } {
      # compile current selection
      
      if {![file exist $cham::chameleon_tool]} {
         setup_paths
         if {![file exist $cham::chameleon_tool]} {
            post_message -type error "Chameleon Tool Path incorrect - deinstall preflow script or set path correctly"
            return
         }
      }
      
      set idx [.top.bot_but_f.tbl curselection]
      run_compile $idx
      
      .top.revision_f.use_cb deselect
      .top.revision_f.gen_adr_dec_cb deselect
      
   }
   
   
   proc run_compile {idx} {
      # run chameleon for file
      dbg "Start Compilation for $idx [lindex [get_chameleon_files] $idx]"
      
      # retrieve the options from the qsf
      set c_infile [lindex [get_chameleon_files] $idx]
      
      if {$cham::gen_adr_dec == 1} {
         set c_adr [lindex [get_chameleon_option "adt"] $idx]
      } else {
         set c_adr ""      
      }
      
      if {[lindex [get_chameleon_option "mc"] $idx] == 1} {
         set c_cfg "-x \"[lindex [get_chameleon_option "cfg"] $idx]\"" 
      } else {
         set c_cfg ""
      }
      
      if {[lindex [get_chameleon_option "im"] $idx] == 0} {
         set c_rev ""
      } else {
         if {$cham::override_revision == 1} {
            set c_rev [concat "-r" $cham::minor "-j" $cham::major]   
         } else {
            set c_rev "-s"
         }
      }
      
      if {[lindex [get_chameleon_option "gl"] $idx]} {
         set c_gl "-L"
      } else {
         set c_gl ""
      }
      
      dbg "Compiling c_infile"
      dbg "Address Decoder $c_adr"
      dbg "Generate Lut $c_gl"
      dbg "Config file $c_cfg"
      
      # generate command line for the chameleon tool
      if {$cham::cham_is_script == 1} {
         # retrieve path to script
         # Start up perl add include path
         regexp -- "(.*)\/.*\/.*\/.*\.pl" $cham::chameleon_tool mymatch path_to_perl
         set cham_line "perl -I $path_to_perl/16t000-/source -I $path_to_perl/16t001-/source $cham::chameleon_tool"
         #set cham_line "perl -I ../../16t000-/source $cham::chameleon_tool"
      } else {
         set cham_line "$cham::chameleon_tool"
      }
      
      # Generate address Decoder
      if {$cham::gen_adr_dec == 1 && [lindex [get_chameleon_option "adt"] $idx] != "none"} {
         # We need to generate an address Decoder
         set c_adr_t [lindex [get_chameleon_option "adt"] $idx]
         set c_adt "-a $c_adr_t"
      } else {
         set c_adt ""
      }
      
      set cham_line 
      set command_line [concat "$cham_line -d -i" $c_infile $c_rev $c_cfg $c_adt]
      post_message -type info "Starting up Chameleon tool"
      post_message -type info $command_line
      
      # run chameleon tool
      set err [catch {eval exec $command_line} status]
      
      #regexp -- "Warning .*" $status warning
      #dbg $warning
      set lines [split $status "\n"]
      if {$err == 1} {
         post_message -type error "Had errors during execution of Chameleon" -submsgs $lines
      } elseif {[regexp -- "^(\[0-9]+) Warnings" [lindex $lines end] mymatch warnings]} {
         post_message -type warning "Found $warnings Warnings during execution of Chameleon" -submsgs $lines
      } else {
         post_message -type info "Chameleon executed successfully" -submsgs $lines
      }
      
      #Parse output
      foreach line $lines {
         if {[regexp -- "(\[0-9]+) Minor Revision" $line mymatch min_rev]} {
            post_message -type info "New Minor Revision is $min_rev"
            set cham::minor $min_rev
            set_parameter -name minor_revision $min_rev
            }
         if {[regexp -- "(\[0-9]+) Major Revision" $line mymatch maj_rev ]} {
            post_message -type info "New Major Revision is $maj_rev"
            set cham::major $maj_rev
            set_parameter -name major_revision $maj_rev
            }
         if {[regexp -- "Conversion v (.*)" $line mymatch cham_version]} {
            if {$cham_version != $cham::version} {
               post_message -type critical_warning "Chameleon Version mismatch between TCL and Perl Script! This may lead to unpredicte3d behaviour, please update your tools." \
               -submsgs [list "TCL Tool Version $cham::version" "Perl Tool Version $cham_version"]
            }
         }
      }
      
      # activate override for further compilations
      if {[winfo exists .top] == 1} {
         .top.revision_f.use_cb select
      } else {
         set cham::override_revision 1
      }
         
   }
   
   proc setup_paths { } {
      # Create window to setup the paths
      toplevel .sp
      #wm geometry .cc 300x200+5+40
      
      wm iconbitmap .sp [file join $cham::pkg_path "lib/cham/cham.ico"]
      wm title .sp "Tool Paths"
      
      image create photo excl -file [file join $cham::pkg_path "lib/cham/exclamation_mark.gif"]
      image create photo ques -file [file join $cham::pkg_path "lib/cham/question-mark.gif"]
      image create photo ok   -file [file join $cham::pkg_path "lib/cham/ok.gif"]
      
      label .sp.cham_l -text "Chameleon Tool"
      checkbutton  .sp.cham_as_perl_cb -text "Use Script" -variable cham::cham_is_script
      
      label .sp.cham_i -image ques
      
      entry .sp.cham_e -textvariable cham::chameleon_tool -width 40
      button .sp.cham_b -text " .. " -command "cham::set_cham_file"
      
      label .sp.excel_l -text "Excel"
      
      label .sp.excel_i -image ques
      
      entry .sp.excel_e -textvariable cham::excel_tool -width 40
      button .sp.excel_b -text " .. " -command "cham::set_excel_file"
      button .sp.ok_b -text "Exit" -command "cham::cancel_sp"
      
      # Now grid it
      grid .sp.cham_l            -row 1 -column 2 -padx 0 -pady 5 -sticky w
      grid .sp.cham_i            -row 2 -column 1 -padx 5 -pady 5 -sticky w
      grid .sp.cham_e            -row 2 -column 2 -padx 5 -pady 5 -sticky w
      grid .sp.cham_b            -row 2 -column 3 -padx 5 -pady 5 -sticky w
      grid .sp.cham_as_perl_cb   -row 3 -column 2 -padx 0 -pady 5 -sticky w
      
      grid .sp.excel_l           -row 4 -column 2 -padx 0 -pady 5 -sticky w
      
      grid .sp.excel_i           -row 5 -column 1 -padx 5 -pady 5 -sticky w
      grid .sp.excel_e           -row 5 -column 2 -padx 5 -pady 5 -sticky w
      grid .sp.excel_b           -row 5 -column 3 -padx 5 -pady 5 -sticky w
      grid .sp.ok_b              -row 6 -column 2 -padx 5 -pady 5 -sticky w -columnspan 2
      
      update_sp_img
      
      # In case debugging is active, offer perl script option
      wm geometry .sp ""
      wm protocol .sp WM_DELETE_WINDOW {cham::cancel_sp}
      tkwait window .sp
      
   }
   
   proc set_cham_file { } {
      set cham::chameleon_tool [tk_getOpenFile -initialdir . -filetypes {{"Chameleon Script" "pl"} {"Chameleon Executable" "exe"} {"All" "*"} }]
      #puts $cham::chameleon_tool
      if {[regexp -nocase -- "chameleon_v2\.pl" $cham::chameleon_tool]} {
         # We have the script
         # puts "Detected Perl"
         set cham::cham_is_script 1
      } else {
         # puts "Didnt detect a perl"
         set cham::cham_is_script 0
      }
      if {$cham::chameleon_tool != ""} {
         set cham_ini [::ini::open [file join $cham::pkg_path "lib/cham" "chameleon.ini"] r+] 
         ::ini::set $cham_ini "Paths" "cham" "$cham::chameleon_tool"
         ::ini::set $cham_ini "Paths" "is_script" "$cham::cham_is_script"
         ::ini::commit $cham_ini
         ::ini::close $cham_ini
         }
      update_sp_img
   }
   
   proc set_excel_file { } {
      set cham::excel_tool [tk_getOpenFile -initialdir . -filetypes {{"Excel Executable" "exe"}}]
      if {$cham::excel_tool != ""} {
         set cham_ini [::ini::open [file join $cham::pkg_path "lib/cham" "chameleon.ini"] r+] 
         ::ini::set $cham_ini "Paths" "excel" "$cham::excel_tool"
         ::ini::commit $cham_ini
         ::ini::close $cham_ini
         }
      update_sp_img
   }
   
   proc update_sp_img { } {
      # check if chameleon exists
      if {$cham::chameleon_tool == ""} {
         .sp.cham_i configure -image ques
      } elseif {[file exist $cham::chameleon_tool]} {
         .sp.cham_i configure -image ok
      } else {
         .sp.cham_i configure -image excl   
      }
      
      # check if excel exists
      if {$cham::excel_tool == ""} {
         .sp.excel_i configure -image ques
      } elseif {[file exist $cham::excel_tool]} {
         .sp.excel_i configure -image ok
      } else {
         .sp.excel_i configure -image excl   
      }
   }
   
   
   
   proc cancel_sp { } {
      destroy .sp
      }
   
   
    # get relative path to target file from current file
    # arguments are file names, not directory names (not checked)
    proc relTo {targetfile currentpath} {
     if {$targetfile != ""} {
        set cc [file split [file normalize $currentpath]]
        set tt [file split [file normalize $targetfile]]
        if {![string equal [lindex $cc 0] [lindex $tt 0]]} {
            # not on *n*x then
            return -code error "$targetfile not on same volume as $currentpath"
        }
        while {[string equal [lindex $cc 0] [lindex $tt 0]] && [llength $cc] > 0} {
            # discard matching components from the front
            set cc [lreplace $cc 0 0]
            set tt [lreplace $tt 0 0]
        }
        set prefix ""
        if {[llength $cc] == 0} {
            # just the file name, so targetfile is lower down (or in same place)
            set prefix "."
        }
        # step up the tree
        for {set i 0} {$i < [llength $cc]} {incr i} {
            append prefix " .."
        }
        # stick it all together (the eval is to flatten the targetfile list)
        return [eval file join $prefix $tt]
     }
     return ""
   }
   
   proc populate_list { } {
      # clear list
      
      # fill list with the items
      set temp_list [get_chameleon_files]
      set item_no 1
      foreach list_item [get_chameleon_files] {
         dbg "add list_item to table";
         .top.bot_but_f.tbl insert end [list "$item_no" "$list_item"]
         incr item_no
      }
      
      if {$item_no > 1} {
         dbg "Enable compile all button"
         .top.bot_but_f.compile_f.compile_all_b configure -state active
      }
      
   }
   
   proc delete_item { } {
      # check which item is selected in table
      dbg "Remove item [.top.bot_but_f.tbl curselection] from chameleon excel list" 
      
      set idx [.top.bot_but_f.tbl curselection]
      .top.bot_but_f.tbl delete 0 [.top.bot_but_f.tbl size]
      # create list and save it
      set temp_list [get_chameleon_files]
      
      # Need to save compile options as well
      set adt_list [get_chameleon_option "adt"]
      set im_list [get_chameleon_option "im"]
      set gl_list [get_chameleon_option "gl"]
      set mc_list [get_chameleon_option "mc"]
      set cfg_list [get_chameleon_option "cfg"]
      
      dbg "Old List: $temp_list"
            
      # remove item from list
      set temp_list [lreplace $temp_list $idx $idx]
      set adt_list  [lreplace $adt_list $idx $idx]
      set im_list   [lreplace $im_list $idx $idx]
      set gl_list   [lreplace $gl_list $idx $idx]
      set mc_list   [lreplace $mc_list $idx $idx]
      set cfg_list  [lreplace $cfg_list $idx $idx]
      
      dbg "New List: $temp_list"
      
      # remove parameters from qsf
      remove_all_parameters -name chameleon_*
      remove_all_parameters -name no_of_chams
      
      # save the rest of the items back into qsf
      set_parameter -name no_of_chams [llength $temp_list]
      set i 0
      foreach item $temp_list {
         set_parameter -name "chameleon_$i" "$item"
         incr i
      }
      set i 0
      foreach item $adt_list {
         set_parameter -name "chameleon_adt_$i" "$item"
         incr i
      }
      set i 0
      foreach item $im_list {
         set_parameter -name "chameleon_im_$i" "$item"  
         incr i
      }
      set i 0
      foreach item $gl_list {
         set_parameter -name "chameleon_gl_$i" "$item"  
         incr i
      }
      set i 0
      foreach item $mc_list {
         set_parameter -name "chameleon_mc_$i" "$item"  
         incr i
      }
      set i 0
      foreach item $cfg_list {
         set_parameter -name "chameleon_cfg_$i" "$item"  
         incr i
      }
      populate_list
      .top.bot_but_f.compile_f.compile_b configure -state disabled
      .top.bot_but_f.add_del_f.del_b configure -state disabled
      .top.bot_but_f.compile_f.configure_b configure -state disabled
      .top.bot_but_f.compile_f.edit_b configure -state disabled
   }
   
   
   proc add_item { } {
      dbg "add_item fired"
      
      # Open File Dialog in current window
      set new_cham_file [relTo [tk_getOpenFile -initialdir . -initialfile chameleon_v2.xls -filetypes {{"Excel File" "xls"}}] [pwd]]
      # check if file has been selected
      dbg "Selected $new_cham_file as new file"
            
      # Check if file is already present
      if {[lsearch [get_chameleon_files] $new_cham_file] == -1 && $new_cham_file != ""} {
         dbg "File is a new file, add it to list and save as parameter"
         # Add file to list
         
         set no_of_chams [get_parameter -name no_of_chams]
         if {$no_of_chams == ""} {
            set no_of_chams 0
            }
            
         incr no_of_chams
         set_parameter -name no_of_chams $no_of_chams
         
         .top.bot_but_f.tbl insert end [list "$no_of_chams" "$new_cham_file"]
         
         set no_of_chams [expr $no_of_chams - 1]
         set_parameter -name [subst "chameleon_$no_of_chams"] "$new_cham_file"
         set_parameter -name [subst "chameleon_adt_$no_of_chams"] "none"
         set_parameter -name [subst "chameleon_im_$no_of_chams"] "1"
         set_parameter -name [subst "chameleon_gl_$no_of_chams"] "0"
         set_parameter -name [subst "chameleon_mc_$no_of_chams"] "0"
         set_parameter -name [subst "chameleon_cfg_$no_of_chams"] "none"
         
         
      }
      # ignore file if already present
   }
   
   proc exit_gui { } {
      dbg "exit_gui fired"
      
      if {[winfo exists .sp] == 1} {
         destroy .sp
      }
      
      if {[winfo exists .cc] == 1} {
         destroy .cc
      }
      
      destroy .top
      # close the Tk Window
      
   }
   
   proc save_and_exit_cc { } {
      # Exit configuration Dialog
      dbg "Save configured variables and close window"
      set idx [.top.bot_but_f.tbl curselection]
      
      # Save variables
      set_parameter -name "chameleon_adt_$idx" $cham::cc_adr_dec_type
      set_parameter -name "chameleon_im_$idx"  $cham::cc_increment_minor
      set_parameter -name "chameleon_gl_$idx"  $cham::cc_gen_lookup
      set_parameter -name "chameleon_mc_$idx"  $cham::cc_manual_cfg
      set_parameter -name "chameleon_cfg_$idx" $cham::cc_cfg_file
      
      export_assignments
            
      # close Window
      destroy .cc
   }
   
   proc install_cham { } {
      # Set chameleon as preflow script      
      post_message -type info "Installing chameleon script as preflow and postflow script"
      set_global_assignment -name PRE_FLOW_SCRIPT_FILE "quartus_sh:cham.tcl"
      set_global_assignment -name POST_FLOW_SCRIPT_FILE "quartus_sh:cham_end.tcl"
      # Copy preflow and postflow scripts to synthesis folder
      post_message -type info "Copy Preflow and Postflow script to synthesis folder"
      file copy -force [file join $cham::pkg_path "lib/cham" "cham.tcl"] .
      file copy -force [file join $cham::pkg_path "lib/cham" "cham_end.tcl"] .
   }
   
   proc cancel_cc { } {
      dbg "Abort CC and exit dialog"
      destroy .cc
   }
   
   proc set_cfg_file { } {
      set cham::cc_cfg_file [relTo [tk_getOpenFile -initialdir . -initialfile device_config.xml -filetypes {{"Device Configuration File" "xml"}}] [pwd]]
   }
   
   proc manual_cfg_switched { } {
      set cfg_state "disabled"
      
      if {$cham::cc_manual_cfg == 1} {
         set cfg_state "active"
      }
      .cc.cfg_f.cfg_file_b configure -state $cfg_state
      
      if {$cham::cc_manual_cfg == 1} {
         set cfg_state "normal"
      }
      .cc.cfg_f.cfg_file_e configure -state $cfg_state
   }
   
   proc configure_cham { } {
      # Retrieve the currently selected item from table
      set idx [.top.bot_but_f.tbl curselection]
      
      # get current compilation configuration from file
      set cham::cc_adr_dec_type [get_parameter -name "chameleon_adt_$idx"]
      if {$cham::cc_adr_dec_type != "pci" && $cham::cc_adr_dec_type != "pcie" && $cham::cc_adr_dec_type != "wb"} {
         set cham::cc_adr_dec_type "none"
      }
      
      set cham::cc_increment_minor [get_parameter -name "chameleon_im_$idx"]
      if {$cham::cc_increment_minor != 0} {
         set cham::cc_increment_minor 1
      }
      
      set cham::cc_gen_lookup [get_parameter -name "chameleon_gl_$idx"]
      if {$cham::cc_gen_lookup != 1} {
         set cham::cc_gen_lookup 0
      }
      
      set cham::cc_manual_cfg [get_parameter -name "chameleon_mc_$idx"]
      if {$cham::cc_manual_cfg != 1} {
         set cham::cc_manual_cfg 0
      }
      
      # Create New Window
      toplevel .cc
      #wm geometry .cc 300x200+5+40
      wm protocol .cc WM_DELETE_WINDOW {cham::cancel_cc}
      wm iconbitmap .cc [file join $cham::pkg_path "lib/cham/cham.ico"]
      wm title .cc "Compilation Settings"
      
      label .cc.title -text [lindex [get_chameleon_files] $idx]
      label .cc.gen_adr_dec_l -text "Address Decoder"
      radiobutton .cc.adr_dec_none_rd -text "None" -variable cham::cc_adr_dec_type -value "none"
      radiobutton .cc.adr_dec_pci_rd -text "PCI" -variable cham::cc_adr_dec_type -value "pci"
      radiobutton .cc.adr_dec_pcie_rd -text "PCIe" -variable cham::cc_adr_dec_type -value "pcie"
      radiobutton .cc.adr_dec_wb_rd -text "WB" -variable cham::cc_adr_dec_type -value "wb"
      
      checkbutton .cc.incr_min_cb -text "Increment minor revision" -variable cham::cc_increment_minor
      checkbutton .cc.gen_lookup_cb -text "Generate Lookuptable instead of hex file" -variable cham::cc_gen_lookup
      checkbutton .cc.manual_cfg_cb -text "Use local device configuration" -variable cham::cc_manual_cfg -command {cham::manual_cfg_switched}
      
      frame .cc.cfg_f
      entry .cc.cfg_f.cfg_file_e -width 40 -textvariable cham::cc_cfg_file -state disabled
      button .cc.cfg_f.cfg_file_b -text ".." -command "cham::set_cfg_file" -state disabled
      
      button .cc.exit_b -text "Save" -command cham::save_and_exit_cc
      button .cc.cancel_b -text "Cancel" -command cham::cancel_cc
      
      manual_cfg_switched
      
      # Grid the stuff
      
      grid .cc.title -row 1 -column 1 -columnspan 5 -pady 5 -padx 10
      grid .cc.gen_adr_dec_l -row 2 -column 1 -columnspan 4 -sticky w
      grid .cc.adr_dec_none_rd -row 3 -column 1 
      grid .cc.adr_dec_pci_rd  -row 3 -column 2 
      grid .cc.adr_dec_pcie_rd -row 3 -column 3 
      grid .cc.adr_dec_wb_rd   -row 3 -column 4 
      
      grid .cc.incr_min_cb     -row 4 -column 1 -columnspan 4 -sticky w -pady 5 -padx 5
      grid .cc.gen_lookup_cb   -row 5 -column 1 -columnspan 4 -sticky w -pady 5 -padx 5
      grid .cc.manual_cfg_cb   -row 6 -column 1 -columnspan 4 -sticky w -pady 2 -padx 5
      grid .cc.cfg_f.cfg_file_e      -row 1 -column 1 -sticky w
      grid .cc.cfg_f.cfg_file_b      -row 1 -column 2
      grid .cc.cfg_f           -row 7 -column 1 -columnspan 5 -padx 5
      
      grid .cc.cancel_b        -row 8 -column 1 -columnspan 2 -pady 2 -sticky e
      grid .cc.exit_b          -row 8 -column 3 -columnspan 2 -pady 2 -sticky w
      
      
      set cham::cc_cfg_file [get_parameter -name "chameleon_cfg_$idx"]
      
      
      # Wait for this window to finish
      # Make window Modal (no other window of this program can be worked with
      #grab .cc
      wm transient .cc .top
      wm geometry .cc ""
      #raise .cc
      tkwait window .cc
      destroy .cc
      
   }
   
   proc item_select { } {
      .top.bot_but_f.add_del_f.del_b configure -state active
      .top.bot_but_f.compile_f.compile_b configure -state active
      .top.bot_but_f.compile_f.configure_b configure -state active
      .top.bot_but_f.compile_f.edit_b configure -state active
   }
   
   proc edit { } {
      # Fire up Excel
      set idx [.top.bot_but_f.tbl curselection]
      set filename [lindex [get_chameleon_files] $idx]
      
      if {![file exist $cham::excel_tool]} {
         setup_paths
         if {![file exist $cham::excel_tool]} {
            post_message -type error "Excel Path incorrect - set path correctly to edit an Excel File"
            return
         }
      }
      
      exec "$cham::excel_tool" /r $filename &
   }
   
   proc create_gui_setup {win} {
      dbg "Starting up create_gui_setup"
      
      frame $win.revision_f -relief groove -borderwidth 2 
      label $win.revision_f.major_l -text "Major Revision"
      entry $win.revision_f.major_e -width 4 -textvariable cham::major
      label $win.revision_f.minor_l -text "Minor Revision"
      entry $win.revision_f.minor_e -width 4 -textvariable cham::minor
      checkbutton $win.revision_f.use_cb -text "Override revision in Excel file during next compile" -variable cham::override_revision
      checkbutton $win.revision_f.gen_adr_dec_cb -text "Generate address decoder on next compile" -variable cham::gen_adr_dec
      label $win.spacer -text " " -width 30
      
      frame $win.bot_but_f -relief groove -borderwidth 2
      
      tablelist::tablelist $win.bot_but_f.tbl -columns {0 "#" 0 "Chameleon File"} -stretch all -background white -width 80 -height 5 \
         -selectmode single -selecttype row
      
      
      
      
      
      frame $win.bot_but_f.add_del_f
      button $win.bot_but_f.add_del_f.add_b -text " + " -command "cham::add_item"
      button $win.bot_but_f.add_del_f.del_b -text " - " -command "cham::delete_item" -state disabled
      
      frame  $win.ei_f
      button $win.ei_f.exit_b -text "          Exit          " -command "cham::exit_gui"
      button $win.ei_f.install_b -text "      Install      " -command "cham::install_cham"
      
      image create photo img1 -file [file join $cham::pkg_path "lib/cham/cham.gif"] -width 100
      label $win.chameleon -image img1
      
      frame $win.bot_but_f.compile_f
      button $win.bot_but_f.compile_f.compile_all_b -text "Compile All" -command "cham::compile_all" -state disabled
      button $win.bot_but_f.compile_f.compile_b -text "Compile" -command "cham::compile" -state disabled
      button $win.bot_but_f.compile_f.configure_b -text "Configure..." -command "cham::configure_cham" -state disabled
      button $win.bot_but_f.compile_f.edit_b -text "Edit" -command "cham::edit" -state disabled
      
      bind $win.bot_but_f.tbl <<TablelistSelect>> cham::item_select
      
      
      
      # Display items      
      grid $win.chameleon -row 1 -column 1 -sticky ew -padx 0 -pady 0 -rowspan 2
      grid $win.ei_f.exit_b -row 1 -column 2 -sticky ne -padx 5 -pady 10
      grid $win.ei_f.install_b -row 1 -column 1 -sticky ne -padx 5 -pady 10
      grid $win.ei_f -row 1 -column 2 -sticky e -padx 40
      grid $win.revision_f.major_l -row 1 -column 2 -sticky ew -padx 5 -pady 5
      grid $win.revision_f.major_e -row 1 -column 3 -sticky ew -padx 5 -pady 5
      grid $win.revision_f.minor_l -row 1 -column 4 -padx 5 -pady 5
      grid $win.revision_f.minor_e -row 1 -column 5 -padx 5 -pady 5
      grid $win.revision_f.use_cb  -row 3 -column 2 -sticky w -padx 5 -columnspan 4
      grid $win.revision_f.gen_adr_dec_cb  -row 4 -column 2 -sticky w -padx 5  -pady 5 -columnspan 4
      grid $win.revision_f -row 2 -column 2 -sticky se -padx 2 -pady 10 
            
      grid $win.bot_but_f.add_del_f.add_b -row 1 -column 1 -pady 5                  
      grid $win.bot_but_f.add_del_f.del_b -row 1 -column 2 -pady 5
      grid $win.bot_but_f.add_del_f -row 2 -column 2 -sticky e -padx 6
      
      grid $win.bot_but_f.compile_f.compile_all_b -row 1 -column 1 -pady 5 -padx 5
      grid $win.bot_but_f.compile_f.compile_b     -row 1 -column 2 -pady 5 -padx 5
      grid $win.bot_but_f.compile_f.configure_b   -row 1 -column 3 -pady 5 -padx 5
      grid $win.bot_but_f.compile_f.edit_b        -row 1 -column 4 -pady 5 -padx 5
      grid $win.bot_but_f.compile_f -row 2 -column 1 -sticky w -padx 6
      grid $win.bot_but_f.tbl -row 1 -column 1 -sticky ew -padx 5 -pady 5 -columnspan 2
      grid $win.bot_but_f -row 3 -column 1  -padx 2 -pady 2 -columnspan 2
            
      populate_list
      
      option add *tearOff 0
      
      menu $win.menubar
      $win configure -menu $win.menubar
      
      menu $win.menubar.setup
      $win.menubar add cascade -menu $win.menubar.setup -label "File"
      $win.menubar.setup add command -label "Save Assignments" -command {export_assignments}
      $win.menubar.setup add separator
      $win.menubar.setup add command -label "Setup Paths..." -command "cham::setup_paths"
      $win.menubar.setup add separator
      $win.menubar.setup add command -label "Save & Exit" -command "cham::exit_gui"
      
      menu $win.menubar.info
      $win.menubar add cascade -menu $win.menubar.info -label "Help"
      $win.menubar.info add command -label "Open MEN Wiki" -command {set rc [catch {exec $env(COMSPEC) /c start "http://192.168.1.9/menwiki/Chameleon_Version_2" &} emsg]}
      $win.menubar.info add separator
      $win.menubar.info add command -label "About" -command {tk_messageBox -message "Chameleon Tcl Version $cham::version" -title "About"}
      
      wm iconbitmap $win [file join $cham::pkg_path "lib/cham/cham.ico"]
      wm title $win "Chameleon Setup"
      wm geometry $win ""
      
   }
   
      
   proc chameleon { } {
   
      # check if project exsist
      if {$::quartus(project) == ""} {
         post_message -type error "No active Project - open a project to run chameleon tool"
         return
      }
      
      init_tk
      package require Tk
      package require tablelist
      
       if {[winfo exists .top] == 1} {
      	dbg "Deleting the old top-level window"
      	destroy .top 
      }
      
      init_cham
      
      # Delete the top-level window
      # (in quartus_stp this command cannot be called until after
      #  the call to init_tk)
     
      # Assume script is run for the first time in case no arguments are given
      set top [toplevel .top]
      
      
      # CHeck if chameleon tool exists
      #if {![file exist $cham::chameleon_tool]} {
      #   setup_paths
      #}
      
      create_gui_setup $top
      
      dbg "Size without menubar [wm geometry .top]"
      
      # Size should be +20 in height - current height output is 300, set is 320
      wm geometry .top "502x320+200+200"
      dbg "Size after manual adjustment [wm geometry .top]"
      
      tkwait window $top
      
      # Copy Variables and settings into qsf file
      if {$cham::major != ""} {
         set_parameter -name major_revision $cham::major
      }
      if {$cham::minor != ""} {
         set_parameter -name minor_revision $cham::minor
      }
      set_parameter -name override_revision $cham::override_revision
      
      export_assignments
      
   }
   
   proc chameleon_preflow {project_name} {
      #post_message "ARGS [lindex $quartus(args) 0] [lindex $quartus(args) 1]"
      project_open $project_name
      init_cham
      package require Tk
      init_tk
      if {[winfo exists .top] == 1} {
      	dbg "Deleting the old top-level window"
      	destroy .top 
      }
      if {[winfo exists .] == 1} {
      	dbg "Withdraw the top-level window as we use .sp"
      	wm withdraw . 
      }
      if {[get_parameter -name "incremented"] != 1} {
         # Check if a successful compile has been run since last incrementation. If no, do not increment again
         cham::compile_all
         set_parameter -name "incremented" 1
      } else {
         post_message "No successful compile since last increment. Chameleon tool is not used. Start manually if necessary"
      }
      project_close
   }
   
   namespace export chameleon_preflow chameleon
   
}

package provide cham $cham::version

