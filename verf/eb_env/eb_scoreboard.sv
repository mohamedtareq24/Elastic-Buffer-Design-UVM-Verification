`ifndef EB_SCOREBOARD_SV
`define EB_SCOREBOARD_SV

class eb_scoreboard extends uvm_component;
  `uvm_component_utils(eb_scoreboard)

  eb_cfg cfg;
  int num_tr;
  uvm_tlm_analysis_fifo#(wr_item)  wr_fifo;
  uvm_tlm_analysis_fifo#(rd_mon_tr) rd_fifo;

  bit [19:0] expected_payload_q[$];
  int unsigned num_mismatches;
  int unsigned num_matches;
  int unsigned skp_count_seen_wr;
  int unsigned skp_count_seen_rd;



  function new(string name = "eb_scoreboard", uvm_component parent = null);
    super.new(name, parent);
    wr_fifo = new("wr_fifo", this);
    rd_fifo = new("rd_fifo", this);
    skp_count_seen_wr = 0;
    skp_count_seen_rd = 0;
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(eb_cfg)::get(this, "", "cfg", cfg)) begin
      cfg = eb_cfg::type_id::create("cfg");
    end
  endfunction

  function automatic bit is_skp(bit [19:0] data);
    return (data === USB_SKP_VAL_1) || (data === USB_SKP_VAL_2);
  endfunction

  task automatic collect_wr();
    wr_item tr;
    forever begin
      wr_fifo.get(tr);
      if (is_skp(tr.data)) begin
        skp_count_seen_wr++;
        `uvm_info("EBSB", $sformatf("SKP observed on write: 'h%05h", tr.data), UVM_HIGH)
      end
      else begin
        expected_payload_q.push_back(tr.data);
        `uvm_info("EBSB", $sformatf("Data added to expected payload queue: 'h%05h. Size is %0d." , tr.data, expected_payload_q.size()), UVM_HIGH )
      end
    end
  endtask

  function bit [19:0] genrate_ref_rd();
    bit [19:0] ref_rd_data ;
    
    if (is_skp(expected_payload_q[0])) begin
      if (expected_payload_q.size() <= cfg.cor_min ) begin
          ref_rd_data = expected_payload_q[0];
        end
    end
    else
    begin
      ref_rd_data = expected_payload_q.pop_front();
    end
    return ref_rd_data;
  endfunction

  task automatic check_rd();
    rd_mon_tr tr;
    bit [19:0] ref_rd_data;
    forever begin
      rd_fifo.get(tr);
      num_tr++;
      if (is_skp(tr.data)) begin
        skp_count_seen_rd++;
        `uvm_info("EBSB", $sformatf("SKP observed on read: 'h%05h", tr.data), UVM_HIGH)
        continue; // Don't compare SKP values, as they may be inserted by the DUT
      end
      else
        ref_rd_data = genrate_ref_rd();
      if (expected_payload_q.size() == 0) begin
        `uvm_error("EBSB", $sformatf("Unexpected payload on output: 'h%05h", tr.data))
      end

      if (tr.data !== ref_rd_data) begin
        `uvm_error("EBSB", $sformatf("Payload mismatch. exp='h%05h got='h%05h", ref_rd_data, tr.data))
        num_mismatches++;
      end
      else begin
        `uvm_info("EBSB", $sformatf("Payload match: 'h%05h", tr.data), UVM_HIGH)
        num_matches++;
      end
    end
  endtask

  virtual task run_phase(uvm_phase phase);
    fork
      collect_wr();
      check_rd();
    join
  endtask

  virtual function void report_phase(uvm_phase phase);
    `uvm_info("EBSB", $sformatf("Total transactions processed: %0d", num_tr), UVM_LOW)
    `uvm_info("EBSB", $sformatf("Total mismatches detected: %0d", num_mismatches), UVM_LOW)
    `uvm_info("EBSB", $sformatf("Total matches detected: %0d", num_matches), UVM_LOW)
    `uvm_info("EBSB", $sformatf("Total SKPs seen on write side: %0d", skp_count_seen_wr), UVM_LOW)
    `uvm_info("EBSB", $sformatf("Total SKPs seen on read side: %0d", skp_count_seen_rd), UVM_LOW)
    `uvm_info("EBSB", $sformatf("Percentage of SKPs in the stream : %0.2f%%", (skp_count_seen_wr*100.0)/num_tr), UVM_LOW)
  endfunction
endclass

`endif
