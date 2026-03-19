module apb_wrapper #(parameter DATA_WIDTH = 32 , ADDR_WIDTH = 32 , BASE_ADDR = 32'hA000_0000)(
        // APB Interface
        input   logic                       pclk_i        ,
        input   logic                       preset_n_i    ,
        input   logic                       psel_i        ,
        input   logic                       penable_i     ,
        output  logic                       pready_o      ,
        input   logic                       pwrite_i      ,
        input   logic   [DATA_WIDTH-1:0]    pwdata_i      ,
        input   logic   [ADDR_WIDTH-1:0]    paddr_i       ,
        output  logic   [DATA_WIDTH-1:0]    prdata_o      ,

        // Configuration Outputs (to Elastic Buffer)
        output  logic   [5:0]               cfg_cor_max_o,
        output  logic   [5:0]               cfg_cor_min_o,
        output  logic   [19:0]              cfg_cor_seq_val_1_o,
        output  logic   [19:0]              cfg_cor_seq_val_2_o,

        // Status Inputs (from Elastic Buffer)
        input   logic   [5:0]               stat_fill_level_i,
        input   logic   [15:0]              stat_cnt_add_i,
        input   logic   [15:0]              stat_cnt_drop_i,
        input   logic                       skp_add_evt_pulse_i,
        input   logic                       skp_drop_evt_pulse_i,
        input   logic   [2:0]               err_status_i
    );

    // ---------------------------------------------------------------------
    // Minimal Register Map (word offsets from BASE_ADDR)
    // 0x00 EB_CTRL        [0] enable
    // 0x04 EB_COR_CFG_MAX [5:0] threshold for skp drops
    // 0x08 EB_COR_CFG_MIN [5:0] threshold for skp inserstions
    // 0x0C EB_COR_SEQ1    [19:0] // SKP sequence values for error correction 
    // 0x10 EB_COR_SEQ2    [19:0] // SKP sequence values for error correction
    
    // 0x14 EB_FILL_LEVEL  [5:0]    (RO)
    // 0x18 EB_SKP_ADD_CNT [15:0]   (RO)
    // 0x1C EB_SKP_RM_CNT  [15:0]   (RO)
    // 0x20 EB_SKP_EVENT   [1:0]    (RO)
    // 0x24 EB_ERR_STATUS  [2:0]    (RO)
    // ---------------------------------------------------------------------

    localparam int unsigned REG_EB_CTRL        = 0;
    localparam int unsigned REG_EB_COR_CFG_MAX = 1;
    localparam int unsigned REG_EB_COR_CFG_MIN = 2;
    localparam int unsigned REG_EB_COR_SEQ1    = 3;
    localparam int unsigned REG_EB_COR_SEQ2    = 4;

    localparam int unsigned REG_EB_FILL_LEVEL  = 5;
    localparam int unsigned REG_EB_SKP_ADD_CNT = 6;
    localparam int unsigned REG_EB_SKP_RM_CNT  = 7;
    localparam int unsigned REG_EB_SKP_EVENT   = 8;
    localparam int unsigned REG_EB_ERR_STATUS  = 9;

    logic [DATA_WIDTH-1:0] reg_eb_ctrl;
    logic [DATA_WIDTH-1:0] reg_eb_cor_cfg_max;
    logic [DATA_WIDTH-1:0] reg_eb_cor_cfg_min;

    logic [DATA_WIDTH-1:0] reg_eb_cor_seq1;
    logic [DATA_WIDTH-1:0] reg_eb_cor_seq2;
    logic [DATA_WIDTH-1:0] reg_eb_skp_event;
    logic [DATA_WIDTH-1:0] reg_eb_err_status;

    logic [5:0]            stat_fill_level_q;
    logic [15:0]           stat_cnt_add_q;
    logic [15:0]           stat_cnt_drop_q;
    logic                  skp_add_evt_pulse_q;
    logic                  skp_drop_evt_pulse_q;
    logic [2:0]            err_status_q;

    logic [ADDR_WIDTH-1:0] addr_offs;
    logic [7:0]            addr_word;

    assign addr_offs = paddr_i - BASE_ADDR;
    assign addr_word = addr_offs[9:2]; // word aligned (enough for this map)

    always_ff @( posedge pclk_i or negedge preset_n_i)
    begin
        if (!preset_n_i)
            pready_o <=  0 ;
        else 
            pready_o <=  1 ;
    end

    always_ff @(posedge pclk_i or negedge preset_n_i)
    begin
        if (!preset_n_i) begin
            prdata_o            <= '0;
            reg_eb_ctrl         <= '0;
            reg_eb_cor_cfg_max  <= '0;
            reg_eb_cor_cfg_min  <= '0;
            reg_eb_cor_seq1     <= '0;
            reg_eb_cor_seq2     <= '0;
            reg_eb_skp_event    <= '0;
            reg_eb_err_status   <= '0;
            stat_fill_level_q   <= '0;
            stat_cnt_add_q      <= '0;
            stat_cnt_drop_q     <= '0;
            skp_add_evt_pulse_q <= 1'b0;
            skp_drop_evt_pulse_q<= 1'b0;
            err_status_q        <= '0;
        end 
        else begin
            // Sample status inputs once per APB clock.
            stat_fill_level_q    <= stat_fill_level_i;
            stat_cnt_add_q       <= stat_cnt_add_i;
            stat_cnt_drop_q      <= stat_cnt_drop_i;
            skp_add_evt_pulse_q  <= skp_add_evt_pulse_i;
            skp_drop_evt_pulse_q <= skp_drop_evt_pulse_i;
            err_status_q         <= err_status_i;

            if (psel_i && penable_i && !pwrite_i) begin
                case (addr_word)
                    REG_EB_CTRL:        prdata_o <= reg_eb_ctrl;
                    REG_EB_COR_CFG_MAX: prdata_o <= reg_eb_cor_cfg_max;
                    REG_EB_COR_CFG_MIN: prdata_o <= reg_eb_cor_cfg_min;
                    REG_EB_COR_SEQ1:    prdata_o <= reg_eb_cor_seq1;
                    REG_EB_COR_SEQ2:    prdata_o <= reg_eb_cor_seq2;
                    REG_EB_FILL_LEVEL:  prdata_o <= {{(DATA_WIDTH-6){1'b0}}, stat_fill_level_q};
                    REG_EB_SKP_ADD_CNT: prdata_o <= {{(DATA_WIDTH-16){1'b0}}, stat_cnt_add_q};
                    REG_EB_SKP_RM_CNT:  prdata_o <= {{(DATA_WIDTH-16){1'b0}}, stat_cnt_drop_q};
                    REG_EB_SKP_EVENT:   prdata_o <= {{(DATA_WIDTH-2){1'b0}}, skp_add_evt_pulse_q, skp_drop_evt_pulse_q};
                    REG_EB_ERR_STATUS:  prdata_o <= {{(DATA_WIDTH-3){1'b0}}, err_status_q};
                    default:            prdata_o <= '0;
                endcase
            end
            else if (psel_i && penable_i && pwrite_i) begin
                case (addr_word)
                    REG_EB_CTRL:     reg_eb_ctrl     <= pwdata_i;
                    REG_EB_COR_CFG_MAX: reg_eb_cor_cfg_max <= pwdata_i;
                    REG_EB_COR_CFG_MIN: reg_eb_cor_cfg_min <= pwdata_i;
                    REG_EB_COR_SEQ1: reg_eb_cor_seq1 <= pwdata_i;
                    REG_EB_COR_SEQ2: reg_eb_cor_seq2 <= pwdata_i;
                    default: /* no-op */;
                endcase
            end
        end
    end

    // Drive configuration outputs from registers
    assign cfg_cor_max_o       = reg_eb_cor_cfg_max[5:0];
    assign cfg_cor_min_o       = reg_eb_cor_cfg_min[5:0];
    assign cfg_cor_seq_val_1_o = reg_eb_cor_seq1[19:0];
    assign cfg_cor_seq_val_2_o = reg_eb_cor_seq2[19:0];

endmodule