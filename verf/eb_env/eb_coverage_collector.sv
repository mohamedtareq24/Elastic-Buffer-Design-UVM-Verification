`uvm_analysis_imp_decl(_rd_mon)     
`uvm_analysis_imp_decl(_wr_mon)     
// decl macros for every monitor that will write to this coverage collector
class eb_coverage_collector extends uvm_component;
    import eb_common_pkg::*;
    `uvm_component_utils(eb_coverage_collector)
    wr_item     wr_tr;
    rd_mon_tr   rd_tr;

    uvm_analysis_imp_rd_mon #(rd_mon_tr , eb_coverage_collector) rd_mon_imp;
    uvm_analysis_imp_wr_mon #(wr_item   , eb_coverage_collector) wr_mon_imp;  

    covergroup wr_cg;
        wr_data_cp: coverpoint wr_tr.data {
            bins max_bin     = {20'hFFFFF};
            bins min_bin     = {20'h00000};
            bins skp1_bin    = USB_SKP_VAL_1;
            bins skp2_bin    = USB_SKP_VAL_2;
            bins others = default;
        }
    endgroup

    covergroup rd_cg;
        rd_data_cp: coverpoint rd_tr.data {
            bins max_bin     = {20'hFFFFF};
            bins min_bin     = {20'h00000};
            bins skp1_bin    = USB_SKP_VAL_1;
            bins skp2_bin    = USB_SKP_VAL_2;
            bins others = default;
        }
    endgroup


    function new(string name, uvm_component parent);
        super.new(name, parent);

        wr_cg = new();
        rd_cg = new();
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        rd_mon_imp = new("rd_mon_imp", this);
        wr_mon_imp = new("wr_mon_imp", this);
    endfunction

    virtual function write_rd_mon (rd_mon_tr t);
        rd_tr = t;
        rd_cg.sample();
    endfunction

    virtual function write_wr_mon (wr_item t);
        wr_tr = t;
        if (wr_tr.data === USB_SKP_VAL_1 || wr_tr.data === USB_SKP_VAL_2) begin
            `uvm_info(get_type_name(), $sformatf("SKP value observed: 0x%h", wr_tr.data), UVM_LOW)
        end
        wr_cg.sample();
    endfunction


endclass