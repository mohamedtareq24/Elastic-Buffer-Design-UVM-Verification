`timescale 1ns/1ps

module elastic_buffer #(
    parameter DATA_WIDTH = 20,   // 2 Symbols (20-bit encoded) for 250 MHz USB 3.0
    parameter FIFO_DEPTH = 16    // Depth of the internal RAM
  )(
    // =========================================================================
    // 1. CLOCKING & RESET (The Domains)
    // =========================================================================
    // Write Domain (Recovered Clock from CDR)
    input  logic                    cdr_clk_i,

    // Read Domain (System/PCLK)
    input  logic                    sys_clk_i,
    input  logic                    sys_arst_n_i,

    // =========================================================================
    // 2. DATA PATH (The Stream)
    // =========================================================================
    // Input (Write Side)
    input  logic [DATA_WIDTH-1:0]   data_in_i,        // Raw/Aligned Data from PHY
    input  logic                    wr_data_vld_i,    // "Write Enable" from Aligner

    output logic [DATA_WIDTH-1:0]   rd_data_out_o,       // Corrected Data Stream
    output logic                    data_valid_out_o,

    // =========================================================================
    // 3. CSR INPUTS 
    // =========================================================================

    input  logic [5:0]              cfg_cor_max_i,    // High Watermark (Trigger Drop)
    input  logic [5:0]              cfg_cor_min_i,    // Low Watermark (Trigger Insert)
  
    // 2 possible correction sequences for diparity 
    input  logic [19:0]             cfg_cor_seq_val_1_i, // Holds bytes for Seq 1,2
    input  logic [19:0]             cfg_cor_seq_val_2_i, // Holds bytes for Seq 1,2

    // input  logic                    cfg_eb_enable_i,   // 1 = Run, 0 = Reset/Bypass

    // =========================================================================
    // 4. STATUS OUTPUTS (To BUF STAT Register)
    // =========================================================================
    output logic [5:0]              stat_fill_level_o,      // Current Level (sys_clk domain view)

    // Correction counters (Performance Counters)
    output logic [15:0]             stat_cnt_add_o,         // Count of SKPs inserted
    output logic [15:0]             stat_cnt_drop_o,        // Count of SKPs dropped

    // 1-cycle event pulses in sys_clk domain (for APB wrapper to latch)
    output logic                    skp_add_evt_pulse_o,
    output logic                    skp_drop_evt_pulse_o,

    output logic [2:0]              err_status_o          // 000 = OK, 001 = OVERFLOW, 010 = UNDERFLOW 
  );

  // =========================================================================
  // FUNCTIONS: Gray code conversion
  // =========================================================================
  
  // Binary to Gray (single XOR)
  function automatic logic [$clog2(FIFO_DEPTH):0] bin2gray(
    input logic [$clog2(FIFO_DEPTH):0] bin
  );
    return bin ^ (bin >> 1);
  endfunction
  
  // Gray to Binary (XOR cascade from MSB to LSB)
  function automatic logic [$clog2(FIFO_DEPTH):0] gray2bin(
    input logic [$clog2(FIFO_DEPTH):0] gray
  );
    logic [$clog2(FIFO_DEPTH):0] bin;
    bin[$clog2(FIFO_DEPTH)] = gray[$clog2(FIFO_DEPTH)];
    for (int i = $clog2(FIFO_DEPTH)-1; i >= 0; i--)
      bin[i] = bin[i+1] ^ gray[i];
    return bin;
  endfunction

  // Inferred memory (simple dual-clock FIFO-style RAM)
  logic [DATA_WIDTH-1:0] fifo_mem [0:FIFO_DEPTH-1];

  // =========================================================================
  // POINTERS: Binary internally, Gray only for CDC
  // =========================================================================
  
  // Write domain (cdr_clk) - BINARY
  logic [$clog2(FIFO_DEPTH):0]    wr_ptr_bin;
  logic [$clog2(FIFO_DEPTH):0]    wr_ptr_gray;
  
  // Read domain (sys_clk) - BINARY
  logic [$clog2(FIFO_DEPTH):0]    rd_ptr_bin;
  logic [$clog2(FIFO_DEPTH):0]    rd_ptr_gray;
  // Internal Signals
  logic [DATA_WIDTH-1:0]          wr_data;
  logic                           wr_en;

  // CDC synchronized pointers (Gray after sync, then converted to binary)
  logic [$clog2(FIFO_DEPTH):0]    wr_ptr_gray_d, wr_ptr_gray_dd;  // wr sys CDC
  logic [$clog2(FIFO_DEPTH):0]    rd_ptr_gray_d, rd_ptr_gray_dd;  // rd cdr CDC
  
  // Binary versions of synced pointers (for fill level calc)
  logic [$clog2(FIFO_DEPTH):0]    wr_ptr_in_sys;  // wr_ptr seen in sys domain
  logic [$clog2(FIFO_DEPTH):0]    rd_ptr_in_cdr;  // rd_ptr seen in cdr domain

  logic                           rd_en;
  logic [DATA_WIDTH-1:0]          rd_data_reg;    // Registered read data (CDC safe)
  logic [$clog2(FIFO_DEPTH):0]    rd_fill_level;

  logic [$clog2(FIFO_DEPTH):0]     wr_fill_level;
  logic [$clog2(FIFO_DEPTH):0]     rd_fill_level_comb;

  logic drop_evt_tgl_cdr;
  logic drop_evt_tgl_sys_d, drop_evt_tgl_sys_dd;

  
  assign wr_ptr_gray = bin2gray(wr_ptr_bin);
  assign rd_ptr_gray = bin2gray(rd_ptr_bin); 
  // Fill level calculations
  assign wr_fill_level = wr_ptr_bin - rd_ptr_in_cdr;
  assign rd_fill_level_comb = wr_ptr_in_sys - rd_ptr_bin;

  // =========================================================================
  // WRITE CONTROLLER (cdr_clk domain)
  // =========================================================================
  always_ff @(posedge cdr_clk_i or negedge sys_arst_n_i) begin
    if (!sys_arst_n_i) begin
      wr_en            <= 1'b0;
      wr_ptr_bin       <= '0;
      wr_data          <= '0;
      drop_evt_tgl_cdr <= 1'b0;
    end
    else if (wr_data_vld_i) begin
      if ((data_in_i == cfg_cor_seq_val_1_i || data_in_i == cfg_cor_seq_val_2_i) &&
          (wr_fill_level > cfg_cor_max_i)) begin
        // DROP SKP: buffer is getting full
        wr_en            <= 1'b0;
        drop_evt_tgl_cdr <= ~drop_evt_tgl_cdr; 
      end
      else begin
        // Normal write
        wr_en      <= 1'b1;
        wr_ptr_bin <= wr_ptr_bin + 1'b1; 
        wr_data    <= data_in_i;
      end
    end
    else begin
      wr_en <= 1'b0;
    end
  end

  // Memory write port (CDR clock domain)
  always_ff @(posedge cdr_clk_i) begin
    if (wr_en) begin
      fifo_mem[wr_ptr_bin[$clog2(FIFO_DEPTH)-1:0]] <= wr_data;
    end
  end

  // Memory read port (CDR clock domain) - registered for CDC safety
  always_ff @(posedge cdr_clk_i) begin
    if (rd_en)
      rd_data_reg <= fifo_mem[rd_ptr_in_cdr[$clog2(FIFO_DEPTH)-1:0]];
  end

  // =========================================================================
  // CDC: Write pointer → Read domain (cdr → sys)
  // =========================================================================
  always_ff @(posedge sys_clk_i or negedge sys_arst_n_i) begin
    if (!sys_arst_n_i) begin
      wr_ptr_gray_d  <= '0;
      wr_ptr_gray_dd <= '0;
      wr_ptr_in_sys  <= '0;
    end
    else begin
      wr_ptr_gray_d  <= wr_ptr_gray;
      wr_ptr_gray_dd <= wr_ptr_gray_d;
      wr_ptr_in_sys  <= gray2bin(wr_ptr_gray_dd);  // Convert ONCE after CDC
    end
  end

  // =========================================================================
  // CDC: Read pointer → Write domain (sys → cdr)
  // =========================================================================
  always_ff @(posedge cdr_clk_i or negedge sys_arst_n_i) begin
    if (!sys_arst_n_i) begin
      rd_ptr_gray_d  <= '0;
      rd_ptr_gray_dd <= '0;
      rd_ptr_in_cdr  <= '0;
    end
    else begin
      rd_ptr_gray_d  <= rd_ptr_gray;
      rd_ptr_gray_dd <= rd_ptr_gray_d;
      rd_ptr_in_cdr  <= gray2bin(rd_ptr_gray_dd);  // Convert ONCE after CDC
    end
  end

  // =========================================================================
  // READ CONTROLLER (sys_clk domain)
  // =========================================================================
  
  // Registered copy of read data for SKP detection (CDC safe - uses synced pointer)
  logic [DATA_WIDTH-1:0] rd_data_for_skp_check;
  
  always_ff @(posedge sys_clk_i or negedge sys_arst_n_i) begin
    if (!sys_arst_n_i)
      rd_data_for_skp_check <= '0;
    else
      rd_data_for_skp_check <= fifo_mem[rd_ptr_bin[$clog2(FIFO_DEPTH)-1:0]];
  end

  always_ff @(posedge sys_clk_i or negedge sys_arst_n_i) begin
    if (!sys_arst_n_i) begin
      rd_en               <= 1'b0;
      rd_ptr_bin          <= '0;
      rd_fill_level       <= '0;
      data_valid_out_o    <= 1'b0;
      rd_data_out_o       <= '0;
      stat_cnt_add_o      <= '0;
      skp_add_evt_pulse_o <= 1'b0;
    end
    else begin
      // Update fill level
      rd_fill_level <= rd_fill_level_comb;
      
      // Sticky valid: once buffer reaches threshold, stay valid until reset
      data_valid_out_o <= data_valid_out_o | (rd_fill_level_comb >= cfg_cor_min_i);
      
      // Default: no SKP add event
      skp_add_evt_pulse_o <= 1'b0;
      
      // If FIFO is empty, do not advance read pointer
      if (rd_fill_level_comb == '0) begin
        rd_en         <= 1'b0;
      end
      // Check if current read data is SKP and buffer is getting empty
      else if ((rd_data_for_skp_check == cfg_cor_seq_val_1_i || 
                rd_data_for_skp_check == cfg_cor_seq_val_2_i) &&
              (rd_fill_level_comb < cfg_cor_min_i)) begin
        // ADD SKP: stall read pointer, output the SKP (generate extra)
        rd_en               <= 1'b0;
        rd_data_out_o       <= rd_data_for_skp_check;
        stat_cnt_add_o      <= stat_cnt_add_o + 16'd1;
        skp_add_evt_pulse_o <= 1'b1;
      end
      else begin
        // Normal read
        rd_en         <= 1'b1;
        rd_ptr_bin    <= rd_ptr_bin + 1'b1;  // Simple binary increment
        rd_data_out_o <= rd_data_for_skp_check;
      end
    end
  end

  // Fill level output
  assign stat_fill_level_o = rd_fill_level;
  
  // Error status (placeholder for now)
  assign err_status_o = 3'b000;

  // Drop counter + drop event pulse (sys_clk domain)
  always_ff @(posedge sys_clk_i or negedge sys_arst_n_i) begin
    if (!sys_arst_n_i) begin
      drop_evt_tgl_sys_d    <= 1'b0;
      drop_evt_tgl_sys_dd   <= 1'b0;
      stat_cnt_drop_o       <= 16'd0;
      skp_drop_evt_pulse_o  <= 1'b0;
    end else begin
      drop_evt_tgl_sys_d    <= drop_evt_tgl_cdr;
      drop_evt_tgl_sys_dd   <= drop_evt_tgl_sys_d;
      skp_drop_evt_pulse_o  <= (drop_evt_tgl_sys_d ^ drop_evt_tgl_sys_dd);
      if (drop_evt_tgl_sys_d ^ drop_evt_tgl_sys_dd) begin
        stat_cnt_drop_o <= stat_cnt_drop_o + 16'd1;
      end
    end
  end

endmodule
