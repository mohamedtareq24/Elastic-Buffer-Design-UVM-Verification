# Elastic Buffer (EB) Design Overview

## Design Summary
The Elastic Buffer (EB) is a rate-matching FIFO designed for high-speed serial interfaces. It compensates for frequency offsets ($\pm$ ppm drift and Spread Spectrum Clocking) between the Recovered Clock Domain (Write Side) and the Local System Clock Domain (Read Side).The design ensures continuous data flow by dynamically inserting or deleting "Skip Markers" (padding symbols) based on buffer occupancy, preventing data loss (overflow) or data corruption (underflow) without interrupting the data stream.

---




### **Elastic Buffer V1.0 Features**
#### **Clock Tolerance Compensation (CTC):**
**SKP Drop:**
- The EB shall drop SKP symbols indicated by `cfg_cor_seq_val_1` and `cfg_cor_seq_val_2` if the FIFO's fill level is greater than `cfg_cor_max`.

**SKP Insertion:**
- The EB shall insert SKP symbols indicated by `cfg_cor_seq_val_1` and `cfg_cor_seq_val_2` if the fill level is lower than `cfg_cor_min`, while maintaining synchronized running disparities.

**No Backpressure:**
- The EB shall not apply any backpressure on the write side and handle continuous data flow.

**Valid Data:**
- The EB shall assert `vld_o` upon reaching the fill level greater than `cfg_cor_min` once and for all until a reset.

**Error Data:**
- The FIFO shall indicate `ErrorState` if the FIFO is full and valid data is present.
- The FIFO shall indicate `ErrorState` if the FIFO is empty.

**FIFO Memory:**
- All memory locations can be written to and read from.

**FIFO Reset:**
- On the negative edge of `sys_arst_n`, all registers shall take reset values.

**SKP Add Event:**
- On SKP addition, the `skp_add_ev_o` shall be asserted for one cycle.

**SKP Drop Event:**
- On SKP drop, `skp_drop_ev_o` shall be asserted for one cycle.

**FIFO Fill Level:**
- The `stat_fill_level_o` shall always convey FIFO occupancy.

## Register Space

| Register Name         | Description                                                                                   |
|----------------------|-----------------------------------------------------------------------------------------------|
| cfg_cor_seq_val_1    | SKP symbol injection control value 1                                                          |
| cfg_cor_seq_val_2    | SKP symbol injection control value 2                                                          |
| cfg_cor_min          | Minimum FIFO fill level for SKP insertion                                                     |
| cfg_cor_max          | Maximum FIFO fill level for SKP drop                                                          |
| stat_fill_level_o    | Current FIFO occupancy                                                                        |
| skp_add_ev_o         | SKP addition event indicator                                                                  |
| skp_drop_ev_o        | SKP drop event indicator                                                                      |
| ErrorState           | FIFO error state indicator                                                                    |

---

