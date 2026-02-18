module apb_wrapper #(parameter DATA_WIDTH = 32 , ADDR_WIDTH = 32 , BASE_ADDR = 32'hA000_0000)(
        input   logic       pclk_i        ,
        input   logic       preset_n_i    ,
        input   logic       psel_i        ,
        input   logic       penable_i     ,
        output  logic       pready_o      ,
        input   logic       pwrite_i      ,

        input   logic   [DATA_WIDTH-1:0]    pwdata_i      ,
        input   logic   [ADDR_WIDTH-1:0]    paddr_i       ,
        output  logic   [DATA_WIDTH-1:0]    prdata_o      ,

        // Elastic Buffer Ports
        input   logic                       cdr_clk_i,
        input   logic                       sys_clk_i,
        input   logic                       sys_arst_n_i,
        input   logic   [19:0]              data_in_i,
        input   logic                       wr_data_vld_i,
        input   logic                       rd_data_rdy_i,
        output  logic   [19:0]              data_out_o,
        output  logic                       data_valid_out_o
    );

    // ---------------------------------------------------------------------
    // Minimal Register Map (word offsets from BASE_ADDR)
    // 0x00 EB_CTRL        [0] enable
    // 0x04 EB_THRESH      [5:0] cor_max, [13:8] cor_min
    // 0x08 EB_COR_SEQ1    [19:0]
    // 0x0C EB_COR_SEQ2    [19:0]
    // 0x10 EB_RSVD0       reserved (was EB_COR_CFG)
    // 0x14 EB_FILL_LEVEL  [5:0] (RO)
    // 0x18 EB_SKP_ADD_CNT [15:0] (RO)
    // 0x1C EB_SKP_RM_CNT  [15:0] (RO)
    // 0x20 EB_SKP_EVENT   [1:0] (RO, read-to-clear)
    // ---------------------------------------------------------------------

    localparam int unsigned REG_EB_CTRL        = 0;
    localparam int unsigned REG_EB_THRESH      = 1;
    localparam int unsigned REG_EB_COR_SEQ1    = 2;
    localparam int unsigned REG_EB_COR_SEQ2    = 3;
    localparam int unsigned REG_EB_RSVD0       = 4;
    localparam int unsigned REG_EB_FILL_LEVEL  = 5;
    localparam int unsigned REG_EB_SKP_ADD_CNT = 6;
    localparam int unsigned REG_EB_SKP_RM_CNT  = 7;
    localparam int unsigned REG_EB_SKP_EVENT   = 8;

    logic [DATA_WIDTH-1:0] reg_eb_ctrl;
    logic [DATA_WIDTH-1:0] reg_eb_thresh;
    logic [DATA_WIDTH-1:0] reg_eb_cor_seq1;
    logic [DATA_WIDTH-1:0] reg_eb_cor_seq2;
    logic [DATA_WIDTH-1:0] reg_eb_skp_event;

    logic [5:0]  stat_fill_level;
    logic [15:0] stat_cnt_add;
    logic [15:0] stat_cnt_drop;

    logic skp_add_evt_pulse;
    logic skp_drop_evt_pulse;

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
            prdata_o       <= '0;
            reg_eb_ctrl    <= '0;
            reg_eb_thresh  <= '0;
            reg_eb_cor_seq1<= '0;
            reg_eb_cor_seq2<= '0;
            reg_eb_skp_event <= '0;
        end else begin
            // Latch SKP events for SW (cleared on disable and read)
            if (!reg_eb_ctrl[0]) begin
                reg_eb_skp_event <= '0;
            end else begin
                if (skp_add_evt_pulse)  reg_eb_skp_event[0] <= 1'b1;
                if (skp_drop_evt_pulse) reg_eb_skp_event[1] <= 1'b1;
            end

            // Default read data
            if (psel_i && penable_i && !pwrite_i) begin
                unique case (addr_word)
                    REG_EB_CTRL:        prdata_o <= reg_eb_ctrl;
                    REG_EB_THRESH:      prdata_o <= reg_eb_thresh;
                    REG_EB_COR_SEQ1:    prdata_o <= reg_eb_cor_seq1;
                    REG_EB_COR_SEQ2:    prdata_o <= reg_eb_cor_seq2;
                    REG_EB_RSVD0:       prdata_o <= '0;
                    REG_EB_FILL_LEVEL:  prdata_o <= {{(DATA_WIDTH-6){1'b0}}, stat_fill_level};
                    REG_EB_SKP_ADD_CNT: prdata_o <= {{(DATA_WIDTH-16){1'b0}}, stat_cnt_add};
                    REG_EB_SKP_RM_CNT:  prdata_o <= {{(DATA_WIDTH-16){1'b0}}, stat_cnt_drop};
                    REG_EB_SKP_EVENT:   prdata_o <= reg_eb_skp_event;
                    default:            prdata_o <= '0;
                endcase

                // Read-to-clear for event register
                if (addr_word == REG_EB_SKP_EVENT) begin
                    reg_eb_skp_event <= '0;
                end
            end

            // Writes in APB access phase
            if (psel_i && penable_i && pwrite_i) begin
                unique case (addr_word)
                    REG_EB_CTRL:     reg_eb_ctrl     <= pwdata_i;
                    REG_EB_THRESH:   reg_eb_thresh   <= pwdata_i;
                    REG_EB_COR_SEQ1: reg_eb_cor_seq1 <= pwdata_i;
                    REG_EB_COR_SEQ2: reg_eb_cor_seq2 <= pwdata_i;
                    default: /* no-op */;
                endcase
            end
        end
    end

    elastic_buffer #(
        .DATA_WIDTH(20),
        .FIFO_DEPTH(32)
    ) elastic_buffer_inst (
        .cdr_clk_i(cdr_clk_i),
        .sys_clk_i(sys_clk_i),
        .sys_arst_n_i(sys_arst_n_i),
        .data_in_i(data_in_i),
        .wr_data_vld_i(wr_data_vld_i),
        .wr_data_rdy_o(),
        .rd_data_rdy_i(rd_data_rdy_i),
        .rd_data_out_o(data_out_o),
        .data_valid_out_o(data_valid_out_o),

        .cfg_cor_max_i(reg_eb_thresh[5:0]),
        .cfg_cor_min_i(reg_eb_thresh[13:8]),
        .cfg_cor_seq_val_1_i(reg_eb_cor_seq1[19:0]),
        .cfg_cor_seq_val_2_i(reg_eb_cor_seq2[19:0]),
        .cfg_eb_enable_i(reg_eb_ctrl[0]),

        .stat_fill_level_o(stat_fill_level),
        .stat_cnt_add_o(stat_cnt_add),
        .stat_cnt_drop_o(stat_cnt_drop),
        .skp_add_evt_pulse_o(skp_add_evt_pulse),
        .skp_drop_evt_pulse_o(skp_drop_evt_pulse)
    );
endmodule