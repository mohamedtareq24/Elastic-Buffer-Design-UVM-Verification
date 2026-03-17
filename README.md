# Design and Verification of an Elastic Buffer

## Project Title and Objective
Design and Verification of an Elastic Buffer

This repository implements a SystemVerilog elastic buffer for rate matching between independent clock domains, with support for APB-based configuration and SKP symbol insert/drop control relevant to **USB 3.0 Gen1** style data paths. The project includes both synthesizable RTL and a UVM verification environment used to validat buffering correctness, register programmability, and protocol-oriented traffic scenarios.

## Architecture and Block Diagrams
The Elastic Buffer consists of the following components:
- **Asynchronous FIFO**
- **SKP DROP LOGIC**
- **SKP INSERT LOGIC**
- **APB Wrapper**

### Block Diagram
![eb_block_diagram](docs/eb_design.jpg)
### Interfaces
- **APB Interface**: Used for configuration and control.
- **Read/Write Stream Interfaces**: Handle data input and output.

## Directory Structure
```
├── src/          # Synthesizable SystemVerilog source files
├── verf/         # Verification environment (UVM components, testbenches, etc.)
│   ├── apb_uvc/  # APB (Advanced Peripheral Bus) Universal Verification Component
│   ├── clk_uvc/  # Clock generation and synchronization component
│   ├── rd_uvc/   # Read stream data interface component
│   ├── wr_uvc/   # Write stream data interface component
│   ├── if/       # Interface definitions for all UVC components
│   ├── eb_env/   # Main Elastic Buffer verification environment
│   └── USB_3_GEN1_case.md  # USB 3.0 Gen1 use case documentation
├── scripts/      # TCL scripts and automation tools
├── docs/         # Documentation and diagrams
└── sim/          # Simulation files and results
```

### Verification Environment (verf/) Overview
![Verification_env](docs/eb_verification.jpg)

The verification environment is built from modular UVM components that coordinate to validate the Elastic Buffer design:

#### **Clock UVC** (`clk_uvc/`)
Generates multi-frequency clock signals to stress test clock domain crossing logic.
- **Key Features**: Configurable clock frequencies, and **Spread Spectrum Clock (SSC) generation** for USB 3.0 Gen1 compliance
- **Components**: Driver, monitor, sequencer, and coverage collector for comprehensive clock behavior validation

![Clock UVC Architecture](docs/usb_clock_uvc.png)

#### **APB UVC** (`apb_uvc/`)
Manages APB (Advanced Peripheral Bus) configuration and control transactions.
- **Key Features**: Full register model using **UVM RAL (Register Abstraction Layer)** with register verification framework (`reg_verifier_dir/`)
- **Components**: Driver, sequencer, monitor, and register model for register-level testing and coverage

#### **Write Stream UVC** (`wr_uvc/`)
Injects write data into the Elastic Buffer input interface.
- **Key Features**: Constrained-random and directed write sequence generation with configurble SKP injection & starving sequences

#### **Read Stream UVC** (`rd_uvc/`)
Monitors read data from the Elastic Buffer output interface.

#### **Elastic Buffer Environment** (`eb_env/`)
Integrates all UVCs and coordinates verification:
- **eb_env.sv**: Top-level environment orchestrating all UVC connections
- **eb_scoreboard.sv**: Self-checking component comparing expected vs. actual transactions
- **eb_coverage_collector.sv**: Aggregates functional and code coverage metrics
- **eb_test_lib.sv**: Test cases including `eb_usb_test`, `eb_counting_test`, `fifo_test`, `eb_wr_skp_test`, `eb_rd_skp_test`

#### **Regression Suite** (`eb_env/REGRESSION/`)
Automated testing and result aggregation framework:
- **run_regression.sh**: Executes all tests sequentially and logs results
- **Features**: Automatic test failure reporting, coverage merging, and result summary generation

## Tools Used
- **Simulation Tools**: Cadence xceilum, imc & regverifier 
- **Synthesis Tools**: Vivado 2023.1

## How to Run
### Simulation
1. Navigate to the `verf/eb_env/` directory.
2. Run the following command to execute the testbench:
   ```bash
   make sim
   ```
#### Regression
1. Navigate to the `verf/eb_env/REGRESSION/` directory.
2. source ./run_regression.sh

### Synthesis
1. Open Vivado and source the provided TCL script:
   ```tcl
   source scripts/vivado_zybo_z7_10_project.tcl
   ```

## Verification Strategy and Results

### Methodology
The verification environment employs a **UVM-based (Universal Verification Methodology)** approach coordinating five specialized UVCs:
- **Clock UVC**: Generates realistic clocks with SSC for multi-frequency CDC validation
- **APB UVC**: Configuration via register model with full RAL support
- **Write/Read Stream UVCs**: Data injection and extraction with backpressure scenarios
- **Scoreboard**: Self-checking mechanism flagging data corruption, dropped symbols, and protocol violations

### Running Verification
```bash
cd verf/eb_env
make sim TEST=eb_usb_test
```
Results and waveforms are available in `verf/eb_env/sim/` and coverage reports in `cov_work/`.
