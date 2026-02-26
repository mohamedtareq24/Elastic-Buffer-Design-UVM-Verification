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
      if (i == num_transactions - 1) begin
        `uvm_info("WRSEQ", $sformatf("Last Transactionin the sequence %s", get_type_name()), UVM_LOW)
      end
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

// wr_skp_packet_seq
// -----------------
// Single packet: 1 SKP symbol, random-length data, 1 SKP symbol
// pkt_size controls the number of data symbols between SKP bookends
class wr_skp_packet_seq extends wr_seq_base;
  `uvm_object_utils(wr_skp_packet_seq)

  rand int unsigned pkt_size;
  constraint pkt_size_range { soft pkt_size > 0; pkt_size <= 525; }

  function new(string name = "wr_skp_packet_seq");
    super.new(name);
  endfunction
  
  virtual task body();
    // Initial SKP symbol
    `uvm_do_with(req, {req.is_skp == 1'b1;})

    // Packet with random-length data
    repeat (pkt_size) begin
      `uvm_do_with(req, {req.is_skp == 1'b0;})
    end

    // Trailing SKP symbol
    `uvm_do_with(req, {req.is_skp == 1'b1;})
  endtask
  
endclass


// class wr_usb_seq_base extends wr_seq_base;
//   `uvm_object_utils(wr_usb_seq_base)

//   int unsigned skp_period        = 354;
//   int unsigned i                 = 0;

//   function new(string name = "wr_usb_seq_base");
//     super.new(name);
//   endfunction

//   virtual task body();
//     usb_wr_item tr;

//     forever begin
//       tr = usb_wr_item::type_id::create($sformatf("tr_%0d", i));
//       i++;
//       start_item(tr);

//       if ((skp_period != 0) && ((i % skp_period) == 0) && (i != 0)) begin
//         assert(tr.randomize() with {
//           is_skp == 1'b1;
//         }) else `uvm_error("RAND_FAIL", "Failed to randomize wr_item");

//       end else begin
//         assert(tr.randomize() with {is_skp == 1'b0;})
//         else `uvm_error("RAND_FAIL", "Failed to randomize wr_item") ;
//       end

//       finish_item(tr);
//     end
//   endtask

// endclass

// wr_random_skp_seq
// ---------------
// Shedules random SKP ordered sets within the write transaction stream based on a specified distribution.
//Resulting random data payload lengths 
class wr_random_skp_seq extends wr_seq_base;
  `uvm_object_utils(wr_random_skp_seq)
  usb_wr_item usb_tr;

  function new(string name = "wr_random_skp_seq");
    super.new(name);
  endfunction

  virtual function randomize_item();
    assert( tr.randomize()) 
    else `uvm_error("RAND_FAIL", "Failed to randomize usb_wr_item");
  endfunction
endclass

// wr_skp_drop_seq
// ---------------
  // Fill the Buffer above the config max thershold
  // Use random skips to trigger drops
class wr_skp_drop_seq extends wr_seq_base;
  `uvm_object_utils(wr_skp_drop_seq)
  wr_skp_packet_seq random_skp_seq;
  wr_counting_seq   counting_seq;

  function new(string name = "wr_skp_drop_seq");
    super.new(name);
  endfunction
  virtual task body ();
    `uvm_do_with(counting_seq , {counting_seq.num_transactions == 100 ;})
    `uvm_do(random_skp_seq)
    `uvm_info("WRSEQ", $sformatf("Draining........."), UVM_LOW)
  #100ns; // Allow time for scoreboard to process transactions before ending the sequence
  endtask

endclass


// Sends packed transactions with random SKP distribution to test the write controller's handling of SKP drops when the buffer is above the max threshold. 
// Each packet is bookended by SKP symbols
class wr_skp_multi_packet_seq extends wr_seq_base;
  `uvm_object_utils(wr_skp_multi_packet_seq)
  rand wr_skp_packet_seq   skp_packet_seq;
  rand wr_counting_seq     counting_seq;
  rand int unsigned        num_packets = 1000; // number of packets to send
  constraint num_packets_range { num_packets > 0; num_packets <= 5000; }
  
  function new(string name = "wr_skp_multi_packet_seq");
    super.new(name);
  endfunction
  virtual task body ();
    `uvm_do_with(counting_seq , {counting_seq.num_transactions == 10 ;})
    // Send multiple packets; each wr_skp_packet_seq run randomizes its own pkt_size
    repeat(num_packets) begin
      `uvm_do_with(skp_packet_seq , {skp_packet_seq.pkt_size inside {[100:525]};})
    end
    `uvm_info("WRSEQ", $sformatf("Draining........."), UVM_LOW)
    #100ns; // Allow time for scoreboard to process transactions before ending the sequence
  endtask

endclass



// class wr_usb_seq_counting extends wr_usb_seq_base;
//   /*
//     wr_usb_seq_counting
//     ---------------------
//     A USB write sequence that generates counting data payloads
//     with periodic SKP ordered sets.
//   */
//   `uvm_object_utils(wr_usb_seq_counting)

//   function new(string name = "wr_usb_seq_counting");
//     super.new(name);
//   endfunction
  
//   virtual task body ();
//   int unsigned j = 0; // keep a running count of payload symbols
//   usb_wr_item tr;
//     forever begin
//       tr = usb_wr_item::type_id::create($sformatf("tr_%0d", i));
//       i++;
//       start_item(tr);

//       if ((skp_period != 0) && ((i % skp_period) == 0) && (i != 0)) begin
//         assert(tr.randomize() with {
//           is_skp == 1'b1;
//         //  data  inside {skp_val_1, skp_val_2};
//         }) else `uvm_error("RAND_FAIL", "Failed to randomize wr_item");

//       end else begin
//         assert(tr.randomize() with {is_skp == 1'b0;
//           data   == (i);
//         })
//         else `uvm_error("RAND_FAIL", "Failed to randomize wr_item") ;
//       end

//       finish_item(tr);
//     end
//   endtask
// endclass