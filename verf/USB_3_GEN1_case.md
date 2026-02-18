---

## Environment Architecture

This UVM environment is designed to verify the Elastic Buffer (EB) IP in the context of USB 3.0 Gen 1 (5.0 Gbps) requirements. The environment includes:

- **Clock UVC**: Generates reference and drifted clocks, including SSC (Spread Spectrum Clocking) effects.
- **APB Interface**: For configuration and status monitoring.
- **Write UVC**: Stimulates the EB with USB 3.0-compliant data streams, including SKP symbol insertion.
- **Read UVC**: Monitors and checks the EB output, including SKP drop and data integrity.
- **Scoreboard**: Compares expected and actual EB behavior, including SKP handling and error detection.
- **Assertions**: Ensure protocol and design requirements are met (reset, valid, error, fill level, etc).

### Environment Block Diagram

![Environment Block Diagram](env_block_diagram.png)

*Figure: Insert your environment block diagram above (replace the filename as needed).*

---

## USB 3.0 Gen 1 Testcase Description

The USB 3.0 Gen 1 testcase validates the EB under realistic PHY conditions:

- **Clock Drift**: Simulates static and SSC-induced frequency variations.
- **SKP Handling**: Verifies correct insertion and removal of SKP symbols per USB 3.0 rules.
- **Data Integrity**: Ensures no data loss or corruption through the buffer.
- **Error Handling**: Checks EB response to overflow/underflow and error signaling.
- **Reset Behavior**: Confirms all registers and outputs reset correctly.
- **Coverage**: Ensures all protocol scenarios (SKP, error, fill, etc.) are exercised.

---

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

---

## Configuration Parameters (USB 3.0 Compliance)

- All configuration and status registers are accessible via the APB interface.
- SKP insertion/removal thresholds are programmable for compliance and stress testing.

---

## Scoreboard and Coverage

- The scoreboard checks for correct data, SKP, and error propagation.
- Coverage model ensures all USB 3.0 protocol scenarios are exercised.

---



