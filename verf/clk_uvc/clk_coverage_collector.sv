class clk_coverage_collector extends uvm_subscriber #(clk_mon_tr);
    `uvm_component_utils(clk_coverage_collector)
    clk_mon_tr tr;    
    // what does the spec say about the clock period values ?
    // USB 3.0 -> 4ns +/- 300ppm & +5000 ppm max for SSC
    covergroup clk_period_cg ;
        sys_period_cp: coverpoint tr.sys_period{
            bins max_bin     = {4020, 4021};
            bins min_bin     = {3999};
            bins others_bin  = default;
            illegal_bins out_of_range = {[0 : 3998] , [4022 : $]};
        }
        
        cdr_period_cp: coverpoint tr.cdr_period{
            bins max_bin     = {4020 , 4021};
            bins min_bin     = {3999};
            bins others_bin  = default;
            illegal_bins out_of_range = {[0 : 3998] , [4022 : $]} ;
        }

        cross sys_period_cp, cdr_period_cp {
            bins sys_max_cdr_min = binsof (sys_period_cp.max_bin) && binsof (cdr_period_cp.min_bin);
            bins sys_min_cdr_max = binsof (sys_period_cp.min_bin) && binsof (cdr_period_cp.max_bin);
            bins sys_max_cdr_max = binsof (sys_period_cp.max_bin) && binsof (cdr_period_cp.max_bin);
            bins sys_min_cdr_min = binsof (sys_period_cp.min_bin) && binsof (cdr_period_cp.min_bin);
        } 
    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        clk_period_cg = new();
    endfunction

    virtual function void write(clk_mon_tr t);
        tr = new t;
        `uvm_info("CLK_COV_COLLECTOR", $sformatf("Received clk_mon_tr: sys_period=%0d cdr_period=%0d", tr.sys_period, tr.cdr_period), UVM_HIGH)
        clk_period_cg.sample();
    endfunction


endclass