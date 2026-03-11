class apb_base_test extends uvm_test;
    `uvm_component_utils(apb_base_test)
    apb_wrapper_env env;
    apb_base_seq apb_seq;
    function new(string name = "apb_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = apb_wrapper_env::type_id::create("env", this);
        apb_seq = apb_base_seq::type_id::create("apb_seq");
    endfunction
    
    virtual function void end_of_elaboration_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Printing Test Topology...", UVM_LOW)
        uvm_top.print_topology(); 
    endfunction

    
    virtual task configure_phase(uvm_phase phase);
        phase.raise_objection(this);
        // Start configuration sequence
        apb_seq.randomize();
        apb_seq.start(env.apb_agt.sequencer);
        phase.drop_objection(this);
    endtask

    
endclass

class apb_smoke_test extends apb_base_test;
    `uvm_component_utils(apb_smoke_test)

    function new(string name = "apb_smoke_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        set_type_override_by_type(apb_base_seq::get_type(), apb_config_seq::get_type());
        super.build_phase(phase);
    endfunction
    

endclass