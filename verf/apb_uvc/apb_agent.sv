// APB Agent
// This agent contains the driver, monitor, and sequencer
// It encapsulates the APB interface and transaction-level functionality
class apb_agent extends uvm_agent;
    `uvm_component_utils(apb_agent)
    
    apb_driver     driver;
    apb_sequencer  sequencer;
    apb_monitor    monitor;
    
    virtual apb_if vif;

    function new(string name = "apb_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Get virtual interface from config database
        if (!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("APB_AGENT", "Virtual interface not found in config db")
        end
        
        // Set interface in config db for driver and monitor
        uvm_config_db#(virtual apb_if)::set(this, "driver", "vif", vif);
        uvm_config_db#(virtual apb_if)::set(this, "monitor", "vif", vif);
        
        // Create driver, sequencer, and monitor
        driver    = apb_driver::type_id::create("driver", this);
        sequencer = apb_sequencer::type_id::create("sequencer", this);
        monitor   = apb_monitor::type_id::create("monitor", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        // Connect driver to sequencer for transaction transfer
        driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction

endclass
