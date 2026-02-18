`ifndef WR_BASE_SEQ_SV
`define WR_BASE_SEQ_SV

class wr_base_seq extends uvm_sequence#(wr_item);
  `uvm_object_utils(wr_base_seq)

  function new(string name = "wr_base_seq");
    super.new(name);  
  endfunction
  
  virtual task pre_body();
    `uvm_info("WRSEQ", $sformatf("Starting %s", get_type_name()), UVM_LOW)
  endtask

  virtual task body();
    wr_item tr;
    forever begin
      tr = wr_item::type_id::create($sformatf("tr"));
      start_item(tr);
      assert(tr.randomize() with {is_skp == 1'b0;})
      else `uvm_error("RAND_FAIL", "Failed to randomize wr_item");

      finish_item(tr);
    end
  endtask
endclass 

class wr_counting_seq extends wr_base_seq;
  `uvm_object_utils(wr_counting_seq)
  function new(string name = "wr_counting_seq");
    super.new(name);
  endfunction
  virtual task body ();
    int unsigned i = 0; // keep a running count of payload symbols
    forever begin
          wr_item tr;
          i++;
          tr = wr_item::type_id::create($sformatf("tr_%0d", i));
          start_item(tr);
          assert(tr.randomize() with {
              is_skp  == 1'b0;
              data    == (i % 4096);
          }) else `uvm_error("RAND_FAIL", "Failed to randomize wr_item") ;
          finish_item(tr);
      end
  endtask
endclass

class wr_usb_seq extends wr_base_seq;
  `uvm_object_utils(wr_usb_seq)

  int unsigned skp_period        = 354;
  int unsigned i                 = 0;

  bit [19:0]   skp_val_1         = {10'b1100000110, 10'b0011111001};  // K28.1 & K28.1
  bit [19:0]   skp_val_2         = {10'b0011111001, 10'b1100000110};  // K28.1 & K28.1  

  function new(string name = "wr_usb_seq");
    super.new(name);
  endfunction

  virtual task body();
    wr_item tr;

    forever begin
      tr = wr_item::type_id::create($sformatf("tr_%0d", i));
      i++;
      start_item(tr);

      if ((skp_period != 0) && ((i % skp_period) == 0) && (i != 0)) begin
        assert(tr.randomize() with {
          is_skp == 1'b1;
          data  inside {skp_val_1, skp_val_2};
        }) else `uvm_error("RAND_FAIL", "Failed to randomize wr_item");

      end else begin
        assert(tr.randomize() with {is_skp == 1'b0;})
        else `uvm_error("RAND_FAIL", "Failed to randomize wr_item") ;
      end

      finish_item(tr);
    end
  endtask

endclass


class wr_usb_seq_counting extends wr_usb_seq;
  /*
    wr_usb_seq_counting
    ---------------------
    A USB write sequence that generates counting data payloads
    with periodic SKP ordered sets.
  */
  `uvm_object_utils(wr_usb_seq_counting)

  function new(string name = "wr_usb_seq_counting");
    super.new(name);
  endfunction
  
  virtual task body ();
  int unsigned j = 0; // keep a running count of payload symbols
  forever begin
        wr_item tr;
        j++;
        tr = wr_item::type_id::create($sformatf("tr_%0d", j));
        start_item(tr);
        assert(tr.randomize() with {
            is_skp  == ((j % skp_period) == 0);
            data    == (j % 32);
        }) else `uvm_error("RAND_FAIL", "Failed to randomize wr_item") ;
        
        if (tr.is_skp) begin
            `uvm_info("WRSEQ", $sformatf("Generated SKP symbol: 0x%05h @ time %0t", tr.data, $time), UVM_LOW)
        end
        finish_item(tr);
    end
  endtask
endclass


`endif
