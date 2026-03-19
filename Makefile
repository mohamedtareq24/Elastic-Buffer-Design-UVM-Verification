VIVADO ?= vivado
XRUN ?= /opt/rh/XCELIUM2009/tools/bin/xrun

TEST ?= eb_usb_test
SEED ?= 1

SYNTH_TOP ?= eb_top
CHECK_TOP ?= elastic_buffer
FPGA_PART ?= xc7z010clg400-1
U96_PART  ?= xczu3eg-sbva484-1-e

EB_ENV_DIR := verf/eb_env
REGRESSION_DIR := $(EB_ENV_DIR)/REGRESSION
VIVADO_PROJECT_TCL     := scripts/vivado_zybo_z7_10_project.tcl
VIVADO_U96_PROJECT_TCL := scripts/vivado_u96_project.tcl
VIVADO_CHECK_TCL       := scripts/vivado_check.tcl

.PHONY: help sim gui regression regression_gui imc_load synth synth_u96 vivado_check vivado_check_u96 clean

help:
	@echo "Elastic Buffer project Makefile"
	@echo ""
	@echo "Verification targets:"
	@echo "  make sim TEST=<uvm_test> SEED=<n>"
	@echo "  make gui TEST=<uvm_test> SEED=<n>"
	@echo "  make regression SEED=<n>"
	@echo "  make regression_gui SEED=<n>"
	@echo "  make imc_load"
	@echo ""
	@echo "Synthesis/check targets (Zybo Z7-10):"
	@echo "  make synth SYNTH_TOP=<top_module>"
	@echo "  make vivado_check CHECK_TOP=<top_module> FPGA_PART=<part>"
	@echo ""
	@echo "Synthesis/check targets (Avnet Ultra96 V2 - UltraScale+):"
	@echo "  make synth_u96 SYNTH_TOP=<top_module>"
	@echo "  make vivado_check_u96 CHECK_TOP=<top_module>"
	@echo ""
	@echo "Variables (override as needed):"
	@echo "  XRUN=$(XRUN)"
	@echo "  TEST=$(TEST)"
	@echo "  SEED=$(SEED)"
	@echo "  SYNTH_TOP=$(SYNTH_TOP)"
	@echo "  CHECK_TOP=$(CHECK_TOP)"
	@echo "  FPGA_PART=$(FPGA_PART)"
	@echo "  U96_PART=$(U96_PART)"

sim:
	$(MAKE) -C $(EB_ENV_DIR) sim XRUN=$(XRUN) TEST=$(TEST) SEED=$(SEED)

gui:
	$(MAKE) -C $(EB_ENV_DIR) gui XRUN=$(XRUN) TEST=$(TEST) SEED=$(SEED)

regression:
	$(MAKE) -C $(REGRESSION_DIR) regression XRUN=$(XRUN) SEED=$(SEED)

regression_gui:
	$(MAKE) -C $(REGRESSION_DIR) regression_gui XRUN=$(XRUN) SEED=$(SEED)

imc_load:
	$(MAKE) -C $(REGRESSION_DIR) imc_load

synth:
	$(VIVADO) -mode batch -nolog -nojournal -source $(VIVADO_PROJECT_TCL) -tclargs $(SYNTH_TOP)

vivado_check:
	$(VIVADO) -mode batch -nolog -nojournal -source $(VIVADO_CHECK_TCL) -tclargs $(CHECK_TOP) $(FPGA_PART)

synth_u96:
	$(VIVADO) -mode batch -nolog -nojournal -source $(VIVADO_U96_PROJECT_TCL) -tclargs $(SYNTH_TOP)

vivado_check_u96:
	$(VIVADO) -mode batch -nolog -nojournal -source $(VIVADO_CHECK_TCL) -tclargs $(CHECK_TOP) $(U96_PART)

clean:
	$(MAKE) -C $(EB_ENV_DIR) clean
	rm -rf *.log *.jou *.str