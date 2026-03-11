module apb_wrapper_tb_top;
    import uvm_pkg::*;
    import apb_pkg::*;
    `include "uvm_macros.svh"

    // Clock and reset signals
    logic clk;
    logic resetn;

    // APB interface instantiation
    apb_if apb_if_i(.pclk(clk), .preset_n(resetn));

    logic [5:0]  stat_fill_level;
    logic [15:0] stat_cnt_add;
    logic [15:0] stat_cnt_drop;
    logic        skp_add_evt_pulse;
    logic        skp_drop_evt_pulse;
    logic [2:0]  err_status;

    logic [5:0]  cfg_cor_max;
    logic [5:0]  cfg_cor_min;
    logic [19:0] cfg_cor_seq_val_1;
    logic [19:0] cfg_cor_seq_val_2;

    apb_wrapper #(
        .DATA_WIDTH(32),
        .ADDR_WIDTH(32),
        .BASE_ADDR(32'hA000_0000)
    ) dut (
        // APB Interface
        .pclk_i        (apb_if_i.pclk),
        .preset_n_i    (apb_if_i.preset_n),
        .psel_i        (apb_if_i.psel),
        .penable_i     (apb_if_i.penable),
        .pready_o      (apb_if_i.pready),
        .pwrite_i      (apb_if_i.pwrite),
        .pwdata_i      (apb_if_i.pwdata),
        .paddr_i       (apb_if_i.paddr),
        .prdata_o      (apb_if_i.prdata),
        
        // Configuration Outputs
        .cfg_cor_max_o        (cfg_cor_max),
        .cfg_cor_min_o        (cfg_cor_min),
        .cfg_cor_seq_val_1_o  (cfg_cor_seq_val_1),
        .cfg_cor_seq_val_2_o  (cfg_cor_seq_val_2),
        
        // Status Inputs
        .stat_fill_level_i    (stat_fill_level),
        .stat_cnt_add_i       (stat_cnt_add),
        .stat_cnt_drop_i      (stat_cnt_drop),
        .skp_add_evt_pulse_i  (skp_add_evt_pulse),
        .skp_drop_evt_pulse_i (skp_drop_evt_pulse),
        .err_status_i         (err_status)
    );

    // Clock generation - 100MHz (10ns period)
    initial begin
        clk = 0;
        forever #5ns clk = ~clk;
    end


    // Simulate elastic buffer status signals
    initial begin
        stat_fill_level    = 6'd0;
        stat_cnt_add       = 16'd0;
        stat_cnt_drop      = 16'd0;
        skp_add_evt_pulse  = 1'b0;
        skp_drop_evt_pulse = 1'b0;
        err_status         = 3'd0; 
        resetn = 0;
        #50ns;
        resetn = 1;
        `uvm_info("TB_TOP", "Reset deasserted", UVM_LOW)
    end

    initial begin
        uvm_config_db#(virtual apb_if)::set(null, "uvm_test_top.env.apb_agt", "vif", apb_if_i);
        run_test();
    end

endmodule
