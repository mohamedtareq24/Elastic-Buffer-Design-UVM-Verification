***

## Environment Architecture

This UVM environment is designed to verify the Elastic Buffer (EB) IP in the context of USB 3.0 Gen 1 (5.0 Gbps) requirements. The environment includes:

- **Clock UVC**: Generates reference and drifted clocks, including SSC (Spread Spectrum Clocking) effects.
- **APB Interface**: For configuration and status monitoring.
- **Write UVC**: Stimulates the EB with USB 3.0-compliant data streams, including SKP symbol insertion.
- **Read UVC**: Monitors and checks the EB output, including SKP drop and data integrity.
- **Scoreboard**: Compares expected and actual EB behavior, including SKP handling and error detection.
- **Assertions**: Ensure protocol and design requirements are met (reset, valid, error, fill level, etc).

### Environment Block Diagram

![alt text](..\docs\env_bd.png)

*Figure: Insert your environment block diagram above (replace the filename as needed).*

***

## USB 3.0 Gen 1 Testcase Description

The USB 3.0 Gen 1 testcase validates the EB under realistic PHY conditions:

- **Clock Drift**: Simulates static and SSC-induced frequency variations.
- **SKP Handling**: Verifies correct insertion and removal of SKP symbols per USB 3.0 rules.
- **Data Integrity**: Ensures no data loss or corruption through the buffer.
- **Error Handling**: Checks EB response to overflow/underflow and error signaling.
- **Reset Behavior**: Confirms all registers and outputs reset correctly.
- **Coverage**: Ensures all protocol scenarios (SKP, error, fill, etc.) are exercised.

***

## Key Parameters

| Parameter         | Value/Description                                  |
|------------------|----------------------------------------------------|
| Data Path Width  | 20 bits                                            |
| Nominal Frequency| 250 MHz                                            |
| Clock Period     | 4.0 ns                                             |
| Static Tolerance | ±300 ppm (±1.2 ps per cycle)                       |
| SSC Profile      | Triangular, 33 kHz, 0 to -5000 ppm (0 to +20 ps)   |
| SKP Insertion    | Controlled by `cfg_cor_seq_val_1`, `cfg_cor_seq_val_2`, `cfg_cor_min` |
| SKP Drop         | Controlled by `cfg_cor_max`                        |
| Reset Polarity   | Active low (`sys_arst_n`)                          |

***

## Configuration Parameters (USB 3.0 Compliance)
- All configuration and status registers are accessible via the APB interface.
- SKP insertion/removal thresholds are programmable for compliance and stress testing.

***

## Scoreboard and Coverage

- The scoreboard checks for correct data, SKP, and error propagation.
- Coverage model ensures all USB 3.0 protocol scenarios are exercised.

---
### UVM Environment Topology 
```
UVM_INFO @ 0: reporter [UVMTOP] UVM testbench topology:
------------------------------------------------------------------------
Name                       Type                        Size  Value
------------------------------------------------------------------------
uvm_test_top               fifo_test                   -     @2800
  env                      eb_env                      -     @2866
    clk_ag                 clk_agent                   -     @2925
      agent_ap             uvm_analysis_port           -     @4682
      coverage_collector   clk_coverage_collector      -     @4583
        analysis_imp       uvm_analysis_imp            -     @4633
      driver               clk_driver                  -     @4374
        rsp_port           uvm_analysis_port           -     @4473
        seq_item_port      uvm_seq_item_pull_port      -     @4424
      monitor              clk_monitor                 -     @4453
        ap                 uvm_analysis_port           -     @4552
      sequencer            clk_sequencer               -     @3735
        rsp_export         uvm_analysis_export         -     @3793
        seq_item_export    uvm_seq_item_pull_imp       -     @4343
        arbitration_queue  array                       0     -
        lock_queue         array                       0     -
        num_last_reqs      integral                    32    'd1
        num_last_rsps      integral                    32    'd1
    coverage_collector     eb_coverage_collector       -     @3551
      rd_mon_imp           uvm_analysis_imp_rd_mon     -     @3651
      wr_mon_imp           uvm_analysis_imp_wr_mon     -     @3700
    rd_ag                  rd_agent                    -     @2985
      monitor              rd_monitor                  -     @4749
        ap                 uvm_analysis_port           -     @4796
      is_active            uvm_active_passive_enum     1     UVM_PASSIVE
    scoreboard             eb_scoreboard               -     @3015
      rd_fifo              uvm_tlm_analysis_fifo #(T)  -     @3324
        analysis_export    uvm_analysis_imp            -     @3572
        get_ap             uvm_analysis_port           -     @3522
        get_peek_export    uvm_get_peek_imp            -     @3424
        put_ap             uvm_analysis_port           -     @3473
        put_export         uvm_put_imp                 -     @3373
      wr_fifo              uvm_tlm_analysis_fifo #(T)  -     @3014
        analysis_export    uvm_analysis_imp            -     @3294
        get_ap             uvm_analysis_port           -     @3244
        get_peek_export    uvm_get_peek_imp            -     @3146
        put_ap             uvm_analysis_port           -     @3195
        put_export         uvm_put_imp                 -     @3095
    wr_ag                  wr_agent                    -     @2955
      driver               wr_driver                   -     @5556
        rsp_port           uvm_analysis_port           -     @5655
        seq_item_port      uvm_seq_item_pull_port      -     @5606
      monitor              wr_monitor                  -     @4845
        ap                 uvm_analysis_port           -     @4894
      sequencer            wr_sequencer                -     @4874
        rsp_export         uvm_analysis_export         -     @4981
        seq_item_export    uvm_seq_item_pull_imp       -     @5525
        arbitration_queue  array                       0     -
        lock_queue         array                       0     -
        num_last_reqs      integral                    32    'd1
        num_last_rsps      integral                    32    'd1
------------------------------------------------------------------------
```