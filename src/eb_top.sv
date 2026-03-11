module eb_top #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter BASE_ADDR = 32'hA000_0000
)(
    // APB Interface
    // input   logic                       pclk_i        ,
    // input   logic                       preset_n_i    ,
    input   logic                       psel_i        ,
    input   logic                       penable_i     ,
    output  logic                       pready_o      ,
    input   logic                       pwrite_i      ,
    input   logic   [DATA_WIDTH-1:0]    pwdata_i      ,
    input   logic   [ADDR_WIDTH-1:0]    paddr_i       ,
    output  logic   [DATA_WIDTH-1:0]    prdata_o      ,

    // CDR Clock Domain
    input   logic                       cdr_clk_i,

    // System Clock Domain
    input   logic                       sys_clk_i,
    input   logic                       sys_arst_n_i,

    // Data Input (Write Path)
    input   logic   [19:0]              data_in_i,
    input   logic                       wr_data_vld_i,

    // Data Output (Read Path)
    output  logic   [19:0]              data_out_o,
    output  logic                       data_valid_out_o,

    // Sideband Signals
    output  logic                       skp_add_evt_pulse_o,
    output  logic                       skp_drop_evt_pulse_o,
    output  logic   [2:0]               err_status_o
);

    // Internal signals connecting APB Wrapper to Elastic Buffer
    logic [5:0]   cfg_cor_max;
    logic [5:0]   cfg_cor_min;
    logic [19:0]  cfg_cor_seq_val_1;
    logic [19:0]  cfg_cor_seq_val_2;
    
    logic [5:0]   stat_fill_level;
    logic [15:0]  stat_cnt_add;
    logic [15:0]  stat_cnt_drop;
    logic         skp_add_evt_pulse;
    logic         skp_drop_evt_pulse;
    logic [2:0]   err_status;

    // Instantiate APB Wrapper (standalone register interface)
    apb_wrapper #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .BASE_ADDR(BASE_ADDR)
    ) apb_wrapper_inst (
        // APB Interface
        .pclk_i(sys_clk_i),
        .preset_n_i(sys_arst_n_i),
        .psel_i(psel_i),
        .penable_i(penable_i),
        .pready_o(pready_o),
        .pwrite_i(pwrite_i),
        .pwdata_i(pwdata_i),
        .paddr_i(paddr_i),
        .prdata_o(prdata_o),

        // Configuration Outputs (to Elastic Buffer)
        .cfg_cor_max_o(cfg_cor_max),
        .cfg_cor_min_o(cfg_cor_min),
        .cfg_cor_seq_val_1_o(cfg_cor_seq_val_1),
        .cfg_cor_seq_val_2_o(cfg_cor_seq_val_2),

        // Status Inputs (from Elastic Buffer)
        .stat_fill_level_i(stat_fill_level),
        .stat_cnt_add_i(stat_cnt_add),
        .stat_cnt_drop_i(stat_cnt_drop),
        .skp_add_evt_pulse_i(skp_add_evt_pulse_o),
        .skp_drop_evt_pulse_i(skp_drop_evt_pulse_o),
        .err_status_i(err_status_o)
    );

    // Instantiate Elastic Buffer
    elastic_buffer #(
        .DATA_WIDTH(20),
        .FIFO_DEPTH(32)
    ) elastic_buffer_inst (
        // Clocking & Reset
        .cdr_clk_i(cdr_clk_i),
        .sys_clk_i(sys_clk_i),
        .sys_arst_n_i(sys_arst_n_i),

        // Data Path
        .data_in_i(data_in_i),
        .wr_data_vld_i(wr_data_vld_i),
        .rd_data_out_o(data_out_o),
        .data_valid_out_o(data_valid_out_o),

        // Configuration from APB Wrapper
        .cfg_cor_max_i(cfg_cor_max),
        .cfg_cor_min_i(cfg_cor_min),
        .cfg_cor_seq_val_1_i(cfg_cor_seq_val_1),
        .cfg_cor_seq_val_2_i(cfg_cor_seq_val_2),

        // Status to APB Wrapper
        .stat_fill_level_o(stat_fill_level),
        .stat_cnt_add_o(stat_cnt_add),
        .stat_cnt_drop_o(stat_cnt_drop),
        .skp_add_evt_pulse_o(skp_add_evt_pulse_o),
        .skp_drop_evt_pulse_o(skp_drop_evt_pulse_o),
        .err_status_o(err_status_o)
    );

endmodule
