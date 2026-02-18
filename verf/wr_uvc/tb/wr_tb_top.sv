module wr_tb_top ();

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    // Virtual interface
    logic clk;
    logic arst_n;
    wr_stream_if#(20) wr_vif(.clk(clk), .arst_n(arst_n));
    
    // UVM components
    wr_uvc_test  test;

    always #10 clk = ~clk; // 50 MHz clock    
    initial begin
        uvm_config_db#(virtual wr_stream_if#(20))::set(null, "*.agent.driver", "vif", wr_vif);
        uvm_config_db#(virtual wr_stream_if#(20))::set(null, "*.agent.monitor", "vif", wr_vif);

        // Run the UVM test
        arst_n = 0;
        clk = 0;
        #50;
        arst_n = 1;
    end 

    initial begin
        run_test();
    end

endmodule