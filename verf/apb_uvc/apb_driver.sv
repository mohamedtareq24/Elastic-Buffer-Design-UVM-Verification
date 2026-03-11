class apb_driver extends uvm_driver#(apb_tr);
    `uvm_component_utils(apb_driver)
    
    virtual apb_if vif;
    apb_tr req;

    function new(string name = "apb_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("APB_DRV", "Virtual interface not found")
        end
    endfunction


    virtual task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(req);
            send_to_dut(req);
            `uvm_info(get_type_name(), $sformatf("Sent APB Transaction %s", req.stringify()), UVM_LOW)
            seq_item_port.item_done();
        end
    endtask

    // Drive transaction on APB bus
    task send_to_dut(apb_tr tr);
        // Setup phase
        @(posedge vif.pclk);
        vif.psel   = 1;
        vif.pwrite = tr.wr_en;
        vif.paddr  = tr.addr;
        vif.pwdata = tr.data;
        vif.penable = 0;
        
        // Access phase  
        @(posedge vif.pclk);
        vif.penable = 1;

        wait (vif.pready == 1);
        @(posedge vif.pclk);
        vif.psel    = 0;
        vif.penable = 0;
    endtask

endclass