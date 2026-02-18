`ifndef RD_AGENT_SV
`define RD_AGENT_SV

class rd_agent extends uvm_agent;
  uvm_active_passive_enum is_active = UVM_PASSIVE;
  
  `uvm_component_utils_begin(rd_agent)
    `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
  `uvm_component_utils_end  

  rd_monitor   monitor;

  function new(string name = "rd_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    monitor = rd_monitor::type_id::create("monitor", this);
  endfunction


endclass

`endif
