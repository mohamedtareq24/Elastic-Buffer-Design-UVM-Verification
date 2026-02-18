`ifndef WR_AGENT_SV
`define WR_AGENT_SV

class wr_agent extends uvm_agent;
  `uvm_component_utils(wr_agent)

  uvm_active_passive_enum is_active = UVM_ACTIVE;

  wr_sequencer sequencer;
  wr_driver    driver;
  wr_monitor   monitor;

  function new(string name = "wr_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(uvm_active_passive_enum)::get(this, "", "is_active", is_active)) begin
      is_active = UVM_ACTIVE;
    end

    monitor = wr_monitor::type_id::create("monitor", this);

    if (is_active == UVM_ACTIVE) begin
      sequencer = wr_sequencer::type_id::create("sequencer", this);
      driver    = wr_driver   ::type_id::create("driver", this);
    end
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (is_active == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
  endfunction

endclass

`endif
