
# Elastic Buffer (EB) Design Overview

## Design Summary
The Elastic Buffer (EB) is a rate-matching FIFO designed for high-speed serial interfaces. It compensates for frequency offsets ($\pm$ ppm drift and Spread Spectrum Clocking) between the Recovered Clock Domain (Write Side) and the Local System Clock Domain (Read Side).The design ensures continuous data flow by dynamically inserting or deleting "Skip Markers" (padding symbols) based on buffer occupancy, preventing data loss (overflow) or data corruption (underflow) without interrupting the data stream.

---

### **Key Features**

**Clock Tolerance Compensation (CTC):**
* **Skip Deletion (Overflow Protection):** Drops a Skip Marker when the FIFO level exceeds the `cfg_high_watermark`.
* **Skip Insertion (Underflow Protection):** Replays a Skip Marker when the FIFO level falls below the `cfg_low_watermark`.
* **Atomic Handling:** Performs insertions and deletions on the full datapath width to maintain protocol compliance and running disparity.


**Streaming Data Interface (Push Model):**
* **No Backpressure:** The buffer continuously accepts data from the source and pushes data to the sink without pausing.
* **Startup Synchronization:** Output valid (`vld_o`) is asserted only after the buffer reaches the **Half-Full** threshold to ensure maximum drift margin.


**Error Handling & Status:**
* **Overflow Error:** Triggered if valid data arrives when the FIFO is full.
* **Underflow Error:** Triggered if the stream is active but the FIFO is empty.


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

