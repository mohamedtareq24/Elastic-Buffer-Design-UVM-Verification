# Create a persistent Vivado project for Avnet Ultra96 V2 and run synthesis
#
# Usage (from repo root):
#   vivado -mode batch -nolog -nojournal -source scripts/vivado_u96_project.tcl
#
# Optional args:
#   -tclargs <top>
#   Example: vivado -mode batch -source scripts/vivado_u96_project.tcl -tclargs eb_top
#
# Outputs:
#   syn/vivado_u96/eb_u96.xpr
#   syn/vivado_u96/post_synth_utilization.rpt
#   syn/vivado_u96/post_synth_timing_summary.rpt

proc _arg_or_default {idx default} {
  if {[llength $::argv] > $idx} {
    return [lindex $::argv $idx]
  }
  return $default
}

set script_dir [file dirname [info script]]
set repo_root  [file normalize [file join $script_dir ".."]]
set out_dir    [file normalize [file join $repo_root "syn" "vivado_u96"]]

file mkdir $out_dir

set proj_name "eb_u96"
set part      "xczu3eg-sbva484-1-e"
set top       [_arg_or_default 0 "eb_top"]

puts "INFO: repo_root=$repo_root"
puts "INFO: out_dir=$out_dir"
puts "INFO: part=$part"
puts "INFO: top=$top"

# Create/open project
create_project -force $proj_name $out_dir -part $part

# Add sources
set src_dir [file join $repo_root "src"]
set rtl_files [list \
  [file join $src_dir "elastic_buffer.sv"] \
  [file join $src_dir "apb_wrapper.sv"] \
  [file join $src_dir "eb_top.sv"] \
]

foreach f $rtl_files {
  if {![file exists $f]} {
    puts "ERROR: missing RTL file: $f"
    exit 2
  }
}

add_files -fileset sources_1 -norecurse $rtl_files

# Add Ultra96 timing constraints
set xdc_file [file join $repo_root "syn" "vivado_u96" "eb_top_u96.xdc"]
if {[file exists $xdc_file]} {
  add_files -fileset constrs_1 -norecurse $xdc_file
} else {
  puts "WARNING: XDC file not found: $xdc_file"
}

# Include dirs for `include "*.svh" usage
set_property include_dirs [list $src_dir] [get_filesets sources_1]

# Set top and compile order
set_property top $top [get_filesets sources_1]
update_compile_order -fileset sources_1

# Run synthesis
launch_runs synth_1 -jobs 4
wait_on_run synth_1

# Post-synth reports
open_run synth_1
report_utilization -file [file join $out_dir "post_synth_utilization.rpt"]
report_timing_summary -file [file join $out_dir "post_synth_timing_summary.rpt"]

puts "INFO: Vivado Ultra96 project + synth completed. See $out_dir"
