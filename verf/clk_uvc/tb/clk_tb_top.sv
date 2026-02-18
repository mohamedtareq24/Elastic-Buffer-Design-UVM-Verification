module clk_tb_top;
  timeunit 1ns;
  timeprecision 1ps;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import clk_pkg::*;

  clk_if clk_vif();

  initial begin
    // Provide the clock/reset interface to clk_agent (driver + monitor both need it).
    uvm_config_db#(virtual clk_if)::set(null, "*.agent.*", "vif", clk_vif);
    run_test();
  end

endmodule
