class apb_wrapper_env extends uvm_env;
    `uvm_component_utils(apb_wrapper_env)
    
    apb_agent apb_agt;
    
    uvm_analysis_port#(apb_tr) apb_ap;
    
    function new(string name = "apb_wrapper_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Create APB agent
        apb_agt = apb_agent::type_id::create("apb_agt", this);
        
        // Create analysis port
        apb_ap = new("apb_ap", this);
        
        `uvm_info("APB_WRAPPER_ENV", "Build phase complete", UVM_MEDIUM)
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        // Connect monitor to environment analysis port
        apb_agt.monitor.ap.connect(apb_ap);
        
        `uvm_info("APB_WRAPPER_ENV", "Connect phase complete", UVM_MEDIUM)
    endfunction

    virtual function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        `uvm_info("APB_WRAPPER_ENV", "Environment topology:", UVM_LOW)
        this.print();
    endfunction

endclass
