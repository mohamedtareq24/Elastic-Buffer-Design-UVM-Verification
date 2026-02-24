module eb_tb_top;
  timeunit 1ns;
  timeprecision 1ps;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import clk_pkg::*;
  import wr_pkg::*;
  import rd_pkg::*;
  import eb_env_pkg::*;

  // Interfaces
  clk_if clk_vif();
  wr_stream_if#(20) wr_vif(.clk(clk_vif.cdr_clk), .arst_n(clk_vif.sys_arst_n));
  rd_stream_if#(20) rd_vif(.clk(clk_vif.sys_clk), .arst_n(clk_vif.sys_arst_n));

  // Testbench configuration object (used by scoreboard, sequences, etc.).
  eb_cfg cfg;

  // Simple static config for now (APB agent can override later)

  localparam logic [5:0]  COR_MAX = 6'd8;
  localparam logic [5:0]  COR_MIN = 6'd8;
  localparam logic [19:0] SKP1    = eb_common_pkg::USB_SKP_VAL_1;
  localparam logic [19:0] SKP2    = eb_common_pkg::USB_SKP_VAL_2;

  // DUT
  // ---
  // For now, we configure the DUT via static ports.
  // Later, will replace these with an APB agent + apb_wrapper + (optional)
  // UVM RAL so tests program registers like a real system.

  elastic_buffer #(
    .DATA_WIDTH(20),
    .FIFO_DEPTH(16)
  ) dut (
    .cdr_clk_i(clk_vif.cdr_clk),
    .sys_clk_i(clk_vif.sys_clk),
    .sys_arst_n_i(clk_vif.sys_arst_n),

    .data_in_i(wr_vif.data_in),
    .wr_data_vld_i(wr_vif.vld),

    .rd_data_out_o(rd_vif.data_out),
    .data_valid_out_o(rd_vif.vld),

    .cfg_cor_max_i(COR_MAX),
    .cfg_cor_min_i(COR_MIN),
    .cfg_cor_seq_val_1_i(SKP1),
    .cfg_cor_seq_val_2_i(SKP2),

    .stat_fill_level_o(),
    .stat_cnt_add_o(),
    .stat_cnt_drop_o(),
    .skp_add_evt_pulse_o(),
    .skp_drop_evt_pulse_o()
  );

  initial begin
    cfg = eb_cfg::type_id::create("cfg");

    // Keep scoreboard SKP filtering aligned with DUT SKP configuration.
    cfg.skp_val_1 = SKP1;
    cfg.skp_val_2 = SKP2;
    cfg.cor_min = COR_MIN;
    cfg.cor_max = COR_MAX;

  
    uvm_config_db#(virtual clk_if)::set(null, "uvm_test_top.env.clk_ag.*", "vif", clk_vif);
    uvm_config_db#(virtual wr_stream_if#(20))::set(null, "uvm_test_top.env.wr_ag.*", "vif", wr_vif);
    uvm_config_db#(virtual rd_stream_if#(20))::set(null, "uvm_test_top.env.rd_ag.*", "vif", rd_vif);
    uvm_config_db#(eb_cfg)::set(null, "uvm_test_top.env.*", "cfg", cfg);
  
    run_test();
  end

  // =========================================================================
  // ASSERTIONS BINDING
  // =========================================================================
  bind dut eb_assertions #(
    .DATA_WIDTH(20)
  ) u_eb_assertions (
    .sys_clk_i(dut.sys_clk_i),
    .sys_arst_n_i(dut.sys_arst_n_i),
    .data_in_i(dut.data_in_i),
    .wr_data_vld_i(dut.wr_data_vld_i),
    .rd_data_out_o(dut.rd_data_out_o),
    .data_valid_out_o(dut.data_valid_out_o),
    .stat_fill_level_o(dut.stat_fill_level_o),
    .cfg_cor_min_i(dut.cfg_cor_min_i),
    .cfg_cor_max_i(dut.cfg_cor_max_i)
  );

endmodule
