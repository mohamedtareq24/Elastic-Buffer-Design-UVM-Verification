package wr_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import eb_common_pkg::*;  // SKP_VAL_1, SKP_VAL_2

  `include "wr_item.sv"
  `include "wr_sequencer.sv"
  `include "wr_driver.sv"
  `include "wr_monitor.sv"
  `include "wr_agent.sv"
  `include "wr_seq_lib.sv"

endpackage : wr_pkg
