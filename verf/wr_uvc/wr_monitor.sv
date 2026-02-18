`ifndef WR_MONITOR_SV
`define WR_MONITOR_SV

class wr_monitor extends uvm_component;
  `uvm_component_utils(wr_monitor)

  virtual wr_stream_if#(20) vif;
  uvm_analysis_port#(wr_item) ap;

  function new(string name = "wr_monitor", uvm_component parent = null);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual wr_stream_if#(20))::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", {"virtual wr_stream_if must be set for: ", get_full_name(), ".vif"})
    end
  endfunction

  virtual task run_phase(uvm_phase phase);
    wr_item tr;
    @(negedge vif.arst_n);

    forever begin
      @(posedge vif.clk);
      if (vif.vld === 1'b1) begin
        tr = wr_item::type_id::create("tr");
        tr.data = vif.data_in;
        tr.is_skp = 1'b0;
        ap.write(tr);
      end
    end
  endtask

endclass

`endif
