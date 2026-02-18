module eb_assertions #(
    parameter DATA_WIDTH = 20
)(
    input logic                 sys_clk_i,
    input logic                 sys_arst_n_i,
    input  logic [DATA_WIDTH-1:0]   data_in_i,        // Raw/Aligned Data from PHY
    input  logic                    wr_data_vld_i,    // "Write Enable" from Aligner
    input logic [DATA_WIDTH-1:0] rd_data_out_o,
    input logic                 data_valid_out_o,
    input logic [5:0]           stat_fill_level_o,
    input logic [5:0]           cfg_cor_min_i,
    input logic [5:0]           cfg_cor_max_i
);

    import uvm_pkg::*;
    `include "uvm_macros.svh"


    // ---------------------------------------------------------------------
    // RESET CHECKS (immediate assertions)
    // ---------------------------------------------------------------------
    // Used Static Deferred Assertions it's equivalennt to 
    /*
    always_comb begin
        if (!sys_arst_n_i) begin
            assert #0 (rd_data_out_o == '0) else $error("EB_ASSERT_RST", $sformatf("rd_data_out_o=%0h expected 0 during reset", rd_data_out_o));
            assert #0 (data_valid_out_o == 1'b0) else $error("EB_ASSERT_RST", $sformatf("data_valid_out_o=%0b expected 0 during reset", data_valid_out_o));
            assert #0 (stat_fill_level_o == '0) else $error("EB_ASSERT_RST", $sformatf("stat_fill_level_o=%0d expected 0 during reset", stat_fill_level_o));
        end
    end
    */


    default clocking 
        cb1 @(posedge sys_clk_i);
    endclocking 



    function void err_report(string id  , string message);
        `uvm_error(id, message);
    endfunction

    a_rst_rd_data: assert #0 (!sys_arst_n_i ? rd_data_out_o == '0 : 1'b1)
        else err_report("EB_ASSERT_RST", $sformatf("rd_data_out_o=%0h expected 0 during reset", rd_data_out_o));

    a_rst_valid: assert #0 (!sys_arst_n_i -> data_valid_out_o == 1'b0)
        else err_report("EB_ASSERT_RST", $sformatf("data_valid_out_o=%0b expected 0 during reset", data_valid_out_o));

    a_rst_level: assert #0 (sys_arst_n_i || (stat_fill_level_o == '0))
        else err_report("EB_ASSERT_RST", $sformatf("stat_fill_level_o=%0d expected 0 during reset", stat_fill_level_o));

    bit aux_after_reset ;      // Flag to indicate if we've come out of reset
    always_comb  begin
        if (!sys_arst_n_i)
            aux_after_reset = 1'b1;
    end

    property valid_o_never_X; 
        @(posedge sys_clk_i) disable iff (!sys_arst_n_i || !aux_after_reset) 
            !($isunknown(data_valid_out_o));
    endproperty : valid_o_never_X

    property rd_data_out_o_never_X;
        @(posedge sys_clk_i) disable iff (!sys_arst_n_i || !aux_after_reset) 
            !($isunknown(rd_data_out_o));
    endproperty

    property stat_fill_level_o_never_X;
        @(posedge sys_clk_i) disable iff (!sys_arst_n_i || !aux_after_reset) 
            !($isunknown(stat_fill_level_o));
    endproperty


    // ---------------------------------------------------------------------
    // data_valid_o properties
    // data_valid_o should rise after cfg_clock_min writes
    // data_valid_o should stay High until a reset 
    int unsigned aux_cnt ; // Counter to track cycles after wr_data_vld_i 
    always_ff @(posedge sys_clk_i or negedge sys_arst_n_i) begin
        if (!sys_arst_n_i) begin
            aux_cnt = 0;
        end else begin
            if (($rose(wr_data_vld_i))) begin
                for (int i = 0; i < cfg_cor_min_i; i++) begin
                    ##1 aux_cnt ++ ;
                end
            end
        end
    end
    
    // After a rising edge on wr_data_vld_i wait for the 1st time cfg_cor_min_i cycles have passed followed by a high on data_valid_out_o
    property valid_o_rise;
        @(posedge sys_clk_i) disable iff (!sys_arst_n_i)
            $rose(wr_data_vld_i) |-> (aux_cnt == (cfg_cor_min_i))[->1] ##1 data_valid_out_o ;
    endproperty

    // data_valid_out_o should remain high until reset
    property valid_o_sticky_high;
        @(posedge sys_clk_i) disable iff (!sys_arst_n_i) 
            data_valid_out_o |=> $stable(data_valid_out_o);
    endproperty
    

    a_valid__o_rise: assert property (valid_o_rise)
        else `uvm_error("EB_ASSERT_VALID_O", $sformatf("data_valid_out_o=%0b does not match expected behavior based on wr_data_vld_i and cfg_cor_min_i", data_valid_out_o))

    a_valid_o_sticky: assert property (valid_o_sticky_high)
        else `uvm_error("EB_ASSERT_VALID_O_STICKY", $sformatf("data_valid_out_o=%0b expected to remain stable until reset", data_valid_out_o))

    a_valid_o_never_X : assert property (valid_o_never_X)
        else `uvm_error("EB_ASSERT_VALID_O_UNKNOWN", $sformatf("data_valid_out_o=%0b expected to never be unknown after a reset", data_valid_out_o))

    a_rd_data_out_o_never_X : assert property (rd_data_out_o_never_X)
        else `uvm_error("EB_ASSERT_RD_DATA_OUT_UNKNOWN", $sformatf("rd_data_out_o=%0b expected to never be unknown after a reset", rd_data_out_o))

    a_stat_fill_level_o_never_X : assert property (stat_fill_level_o_never_X)
        else `uvm_error("EB_ASSERT_STAT_FILL_LEVEL_UNKNOWN", $sformatf("stat_fill_level_o=%0b expected to never be unknown after a reset", stat_fill_level_o))

        
endmodule : eb_assertions