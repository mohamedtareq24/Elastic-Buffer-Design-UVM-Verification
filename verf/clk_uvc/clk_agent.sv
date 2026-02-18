`ifndef CLK_AGENT_SV
`define CLK_AGENT_SV

class clk_agent extends uvm_agent;
  `uvm_component_utils(clk_agent)

  uvm_active_passive_enum is_active = UVM_ACTIVE;

  clk_sequencer     sequencer;
  clk_driver        driver;
  clk_monitor       monitor;
  clk_coverage_collector coverage_collector;
  uvm_analysis_port#(clk_mon_tr) agent_ap;

  function new(string name = "clk_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(uvm_active_passive_enum)::get(this, "", "is_active", is_active)) begin
      is_active = UVM_ACTIVE;
    end

    if (is_active == UVM_ACTIVE) begin
      sequencer = clk_sequencer::type_id::create("sequencer", this);
      driver    = clk_driver::type_id::create("driver", this);
    end
    monitor   = clk_monitor::type_id::create("monitor", this);
    coverage_collector = clk_coverage_collector::type_id::create("coverage_collector", this);
    agent_ap = new("agent_ap", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (is_active == UVM_ACTIVE) begin
      // Standard UVM connection: driver pulls items from sequencer.
      driver.seq_item_port.connect(sequencer.seq_item_export);
      monitor.ap.connect(coverage_collector.analysis_export);
      monitor.ap.connect(agent_ap);
    end
  endfunction

endclass

`endif
