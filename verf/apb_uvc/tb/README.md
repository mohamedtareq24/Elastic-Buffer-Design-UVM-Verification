# APB Wrapper Testbench

This directory contains the UVM testbench for verifying the APB wrapper module.

## Overview

The APB wrapper provides an APB (Advanced Peripheral Bus) interface to configure and monitor the Elastic Buffer. This testbench verifies:
- APB read/write transactions
- Register access (configuration and status)
- Protocol compliance
- Register functionality

### Environment Topology
```
UVM_INFO @ 0: reporter [UVMTOP] UVM testbench topology:
--------------------------------------------------------------
Name                       Type                    Size  Value
--------------------------------------------------------------
uvm_test_top               apb_smoke_test          -     @2660
  env                      apb_wrapper_env         -     @2721
    apb_agt                apb_agent               -     @2766
      driver               apb_driver              -     @2867
        rsp_port           uvm_analysis_port       -     @2967
        seq_item_port      uvm_seq_item_pull_port  -     @2916
      monitor              apb_monitor             -     @3582
        ap                 uvm_analysis_port       -     @3687
      sequencer            apb_sequencer           -     @2946
        rsp_export         uvm_analysis_export     -     @3055
        seq_item_export    uvm_seq_item_pull_imp   -     @3603
        arbitration_queue  array                   0     -    
        lock_queue         array                   0     -    
        num_last_reqs      integral                32    'd1  
        num_last_rsps      integral                32    'd1  
    apb_ap                 uvm_analysis_port       -     @2814
--------------------------------------------------------------
```
```

## Register Map

The APB wrapper implements the following registers at base address `0xA000_0000`:

| Offset | Name             | Access | Description                    |
|--------|------------------|--------|--------------------------------|
| 0x00   | EB_CTRL          | RW     | Enable control [0]             |
| 0x04   | EB_COR_CFG_MAX   | RW     | Max threshold [5:0]            |
| 0x08   | EB_COR_CFG_MIN   | RW     | Min threshold [5:0]            |
| 0x0C   | EB_COR_SEQ1      | RW     | Correction sequence 1 [19:0]   |
| 0x10   | EB_COR_SEQ2      | RW     | Correction sequence 2 [19:0]   |
| 0x14   | EB_FILL_LEVEL    | RO     | Current fill level [5:0]       |
| 0x18   | EB_SKP_ADD_CNT   | RO     | SKP add counter [15:0]         |
| 0x1C   | EB_SKP_RM_CNT    | RO     | SKP remove counter [15:0]      |
| 0x20   | EB_SKP_EVENT     | RO     | SKP event flags [1:0]          |
| 0x24   | EB_ERR_STATUS    | RO     | Error status [2:0]             |


## Running Tests

