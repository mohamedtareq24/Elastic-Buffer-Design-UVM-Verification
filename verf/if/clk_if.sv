

interface clk_if;
  timeunit 1ns;
  timeprecision 1ps;

  logic cdr_clk;
  logic sys_clk;
  logic sys_arst_n;

  // Measured values (written by clk_monitor)
  time sys_period_meas;
  time cdr_period_meas;

  // Simple reset helper (async active-low)
  task automatic apply_reset(int unsigned delay = 10);
    sys_arst_n = 1'b1;
    #(delay);
    sys_arst_n = 1'b0;
    #(delay);
    sys_arst_n = 1'b1;
  endtask

endinterface
