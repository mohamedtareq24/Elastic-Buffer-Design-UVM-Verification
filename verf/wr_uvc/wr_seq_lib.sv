// wr_base_seq
// -------------
// Base sequence for generating write transactions. Generates random data payloads with no SKP ordered sets.
class wr_seq_base extends uvm_sequence#(wr_item);

  `uvm_object_utils(wr_seq_base)
  rand int unsigned num_transactions = 100;
  wr_item tr;
  function new(string name = "wr_seq_base");
    super.new(name);  
  endfunction
  
  virtual task pre_body();
    `uvm_info("WRSEQ", $sformatf("Starting %s", get_type_name()), UVM_LOW)
  endtask

  virtual task body();
    for (int unsigned i = 0 ; i < num_transactions; i++) begin
      tr = wr_item::type_id::create($sformatf("tr_%0d", i));
      start_item(tr);
      randomize_item();
      finish_item(tr);
    end
  endtask

  virtual function randomize_item();
    assert( tr.randomize() with {
      is_skp == 1'b0;
    }) else `uvm_error("RAND_FAIL", "Failed to randomize wr_item");
  endfunction

endclass 

class wr_counting_seq extends wr_seq_base;
  `uvm_object_utils(wr_counting_seq)
  int unsigned tr_number = 0;
  function new(string name = "wr_counting_seq");
    super.new(name);
  endfunction
  
  virtual function randomize_item();
    assert( tr.randomize() with {
      is_skp == 1'b0;
      data   == (tr_number); 
    }) else `uvm_error("RAND_FAIL", "Failed to randomize wr_item");
    tr_number++;
  endfunction
endclass

class wr_usb_seq_base extends wr_seq_base;
  `uvm_object_utils(wr_usb_seq_base)

  int unsigned skp_period        = 354;
  int unsigned i                 = 0;

  function new(string name = "wr_usb_seq_base");
    super.new(name);
  endfunction

  virtual task body();
    usb_wr_item tr;

    forever begin
      tr = usb_wr_item::type_id::create($sformatf("tr_%0d", i));
      i++;
      start_item(tr);

      if ((skp_period != 0) && ((i % skp_period) == 0) && (i != 0)) begin
        assert(tr.randomize() with {
          is_skp == 1'b1;
        }) else `uvm_error("RAND_FAIL", "Failed to randomize wr_item");

      end else begin
        assert(tr.randomize() with {is_skp == 1'b0;})
        else `uvm_error("RAND_FAIL", "Failed to randomize wr_item") ;
      end

      finish_item(tr);
    end
  endtask

endclass

// wr_random_skp_seq
// ---------------
// Shedules random SKP ordered sets within the write transaction stream based on a specified distribution.
//Resulting random data payload lengths 
class wr_random_skp_seq extends wr_seq_base;
  `uvm_object_utils(wr_random_skp_seq)
  usb_wr_item usb_tr;
  rand int skp_percentage = 10;
  constraint skp_percentage_range {skp_percentage >= 0; skp_percentage <= 10;}

  function new(string name = "wr_random_skp_seq");
    super.new(name);
  endfunction

  virtual function randomize_item();
    assert( tr.randomize() with {is_skp dist {0 := 100 - skp_percentage, 1 := skp_percentage};} ) 
    else `uvm_error("RAND_FAIL", "Failed to randomize usb_wr_item");
  endfunction
endclass

// wr_skp_drop_seq
// ---------------
  // Fill the Buffer above the config max thershold
  // Use random skips to trigger drops
class wr_skp_drop_seq extends wr_usb_seq_base;
  `uvm_object_utils(wr_skp_drop_seq)
  wr_random_skp_seq random_skp_seq;
  wr_counting_seq   counting_seq;
  rand int          skp_percentage = 1;

  function new(string name = "wr_skp_drop_seq");
    super.new(name);
  endfunction
  virtual task body ();
    `uvm_do_with(counting_seq , {counting_seq.num_transactions == 100 ;})
    `uvm_do_with(random_skp_seq, {
      random_skp_seq.num_transactions == 10000 ;
      random_skp_seq.skp_percentage == local::skp_percentage;
      })
  endtask
endclass

// wr_skp_insert_seq
// ---------------
  // Use random skips to trigger insertions
class wr_skp_insert_seq extends wr_usb_seq_base;
  `uvm_object_utils(wr_skp_insert_seq)
  wr_random_skp_seq random_skp_seq;
  wr_counting_seq   counting_seq;
  rand int          skp_percentage = 1;

  function new(string name = "wr_skp_insert_seq");
    super.new(name);
  endfunction
  virtual task body ();
    `uvm_do_with(counting_seq , {counting_seq.num_transactions == 10 ;})
    `uvm_do_with(random_skp_seq, {
      random_skp_seq.num_transactions == 10000 ;
      random_skp_seq.skp_percentage == local::skp_percentage;
      })
  endtask
endclass


class wr_usb_seq_counting extends wr_usb_seq_base;
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
  usb_wr_item tr;
    forever begin
      tr = usb_wr_item::type_id::create($sformatf("tr_%0d", i));
      i++;
      start_item(tr);

      if ((skp_period != 0) && ((i % skp_period) == 0) && (i != 0)) begin
        assert(tr.randomize() with {
          is_skp == 1'b1;
        //  data  inside {skp_val_1, skp_val_2};
        }) else `uvm_error("RAND_FAIL", "Failed to randomize wr_item");

      end else begin
        assert(tr.randomize() with {is_skp == 1'b0;
          data   == (i);
        })
        else `uvm_error("RAND_FAIL", "Failed to randomize wr_item") ;
      end

      finish_item(tr);
    end
  endtask
endclass
