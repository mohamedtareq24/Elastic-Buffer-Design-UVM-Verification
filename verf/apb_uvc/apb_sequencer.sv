// APB Sequencer
// This sequencer generates APB transactions and sends them to the driver
class apb_sequencer extends uvm_sequencer#(apb_tr);
    `uvm_component_utils(apb_sequencer)

    function new(string name = "apb_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction

endclass
