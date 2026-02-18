
`timescale 1ps  / 1fs
package clk_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  `include "clk_transaction.sv"
  `include "clk_mon_tr.sv"
  `include "clk_sequencer.sv"
  `include "clk_coverage_collector.sv"
  `include "clk_driver.sv"
  `include "clk_monitor.sv"
  `include "clk_agent.sv"
  `include "clk_seq_lib.sv"


endpackage : clk_pkg
