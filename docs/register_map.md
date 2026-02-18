# Elastic Buffer (EB) – Register Map

Assumptions:
- APB clock `pclk_i` is the same as `sys_clk_i` (or at least synchronous).
- EB configuration is programmed while `EB_CTRL.enable=0`, then enabled.

## Address Map (word offsets from `BASE_ADDR`)

| Offset | Name           | Access | Bits                 | Description |
|-------:|----------------|:------:|----------------------|-------------|
| 0x00   | EB_CTRL        |  R/W   | [0] enable           | 1=run, 0=reset/bypass (also resets counters/state) |
| 0x04   | EB_THRESH      |  R/W   | [5:0] cor_max        | High watermark (drop SKP when above) |
|        |                |        | [13:8] cor_min       | Low watermark (insert SKP when below) |
| 0x08   | EB_COR_SEQ1    |  R/W   | [19:0] seq1          | SKP ordered-set symbol pattern 1 |
| 0x0C   | EB_COR_SEQ2    |  R/W   | [19:0] seq2          | SKP ordered-set symbol pattern 2 |
| 0x10   | EB_RSVD0       |  Rsvd  | -                    | Reserved (was EB_COR_CFG) |
| 0x14   | EB_FILL_LEVEL  |  R/O   | [5:0] fill_level     | Current fill level (sys_clk domain view) |
| 0x18   | EB_SKP_ADD_CNT |  R/O   | [15:0] add_count     | Count of SKP insertions |
| 0x1C   | EB_SKP_RM_CNT  |  R/O   | [15:0] drop_count    | Count of SKP removals |
| 0x20   | EB_SKP_EVENT   |  R/O   | [0] add_seen         | 1 if a SKP insertion occurred since last read |
|        |                |        | [1] drop_seen        | 1 if a SKP removal occurred since last read |

Notes:
- `EB_SKP_EVENT` is **read-to-clear**.
- If both bits are 0: no SKP add/drop has occurred since the last read.
