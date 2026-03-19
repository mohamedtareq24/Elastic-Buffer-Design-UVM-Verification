# Vivado batch check for RTL compile + latch inference
# Usage (from repo root):
#   <vivado.exe> -mode batch -nolog -nojournal -source scripts/vivado_check.tcl -tclargs <top> <part>
# Example:
#   "D:/VIVADO/Vivado/2018.2/bin/unwrapped/win64.o/vivado.exe" -mode batch -nolog -nojournal -source scripts/vivado_check.tcl -tclargs elastic_buffer xc7z010clg400-1

proc _arg_or_default {idx default} {
  if {[llength $::argv] > $idx} {
    return [lindex $::argv $idx]
  }
  return $default
}

set top  [_arg_or_default 0 "elastic_buffer"]
# NOTE: You can change this part to match your FPGA. It's used by create_project/synth_design.
# Zybo Z7-10 default: Zynq-7010.
set part [_arg_or_default 1 "xc7z010clg400-1"]

set script_dir [file dirname [info script]]
set repo_root  [file normalize [file join $script_dir ".."]]

puts "INFO: repo_root=$repo_root"
puts "INFO: top=$top"
puts "INFO: part=$part"

# Create an in-memory project so Vivado has a context for compile order and synthesis.
create_project -in_memory -part $part

# Read RTL (project/fileset style)
# Vivado option support differs across versions; the most compatible approach is:
# - create a project
# - add_files into sources_1
# - set include directories via fileset properties
set src_dir [file join $repo_root "src"]
set inc_dirs [list $src_dir]

set rtl_files [list \
  [file join $src_dir "elastic_buffer.sv"] \
]

foreach f $rtl_files {
  if {![file exists $f]} {
    puts "ERROR: missing RTL file: $f"
    exit 2
  }
}

add_files -fileset sources_1 -norecurse $rtl_files

set xdc_file [file join $repo_root "syn" "vivado_zybo_z7_10" "eb_top_simple.xdc"]
if {![file exists $xdc_file]} {
  set xdc_file [file join $repo_root "constraints" "eb_top_simple.xdc"]
}
if {[file exists $xdc_file]} {
  read_xdc $xdc_file
} else {
  puts "WARNING: XDC file not found: $xdc_file"
}

# Make `include "..." work by telling Vivado where to search.
# Property name is stable for Vivado projects.
set_property include_dirs $inc_dirs [get_filesets sources_1]

update_compile_order -fileset sources_1

# Run out-of-context synthesis.
# This is where latch inference warnings would show up.
set synth_ok 1
if {[catch {
  synth_design -mode out_of_context -top $top -part $part
} err]} {
  puts "ERROR: synth_design failed: $err"
  set synth_ok 0
}

# Basic reports (useful to confirm synth ran)
if {$synth_ok} {
  report_utilization -file [file join $repo_root "syn" "vivado_utilization.rpt"]
  report_timing_summary -file [file join $repo_root "syn" "vivado_timing.rpt"]
  puts "INFO: Vivado check completed OK"
  exit 0
} else {
  exit 1
}
