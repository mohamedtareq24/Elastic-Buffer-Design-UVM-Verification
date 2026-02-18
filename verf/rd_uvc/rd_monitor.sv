`ifndef RD_MONITOR_SV
`define RD_MONITOR_SV 

class rd_monitor extends uvm_component;
  `uvm_component_utils(rd_monitor)

  virtual rd_stream_if #(20) vif;
  uvm_analysis_port #(rd_mon_tr) ap;

  function new(string name = "rd_monitor", uvm_component parent = null);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual rd_stream_if #(20))::get(this, "", "vif", vif)) begin
        `uvm_fatal("NOVIF", {"virtual rd_stream_if must be set for: ", get_full_name(), ".vif"})
    end
  endfunction

  virtual task run_phase(uvm_phase phase);
    rd_mon_tr tr;
    wait (vif.arst_n === 1'b1);

    forever begin
      @(posedge vif.clk);
      if ((vif.vld === 1'b1)) begin
        tr = rd_mon_tr::type_id::create("tr");
        tr.data = vif.data_out;
        ap.write(tr);
      end
    end
  endtask

endclass

`endif
