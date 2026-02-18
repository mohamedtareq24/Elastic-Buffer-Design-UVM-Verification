import uvm_pkg::*;
import wr_pkg::*;
`include "uvm_macros.svh"

class wr_uvc_test extends uvm_test;
    `uvm_component_utils(wr_uvc_test)

    wr_agent  agent;
    wr_base_seq seq;
    function new(string name = "wr_uvc_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        set_type_override_by_type(wr_base_seq::get_type(), wr_usb_seq::get_type());
        super.build_phase(phase);
        agent =wr_agent::type_id::create("agent", this);
        seq = wr_base_seq::type_id::create("seq");
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        seq.start(agent.sequencer);

        phase.drop_objection(this);
    endtask

endclass