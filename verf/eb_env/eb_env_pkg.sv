package eb_env_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"


  import clk_pkg::*;
  import wr_pkg::*;
  import rd_pkg::*;
  import eb_common_pkg::*;  // SKP_VAL_1, SKP_VAL_2

  `include "eb_cfg.sv"
  `include "eb_scoreboard.sv"
  `include "eb_coverage_collector.sv"
  `include "eb_env.sv"
  `include "eb_test_lib.sv"


endpackage : eb_env_pkg
