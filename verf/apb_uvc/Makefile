# Xcelium/XRUN Makefile for APB UVC environment

XRUN ?= /opt/rh/XCELIUM2009/tools/bin/xrun
REG_VERIFIER ?= reg_verifier

TOP      ?= apb_wrapper_tb_top
TEST     ?= apb_smoke_test
SEED     ?= 1

IPXACT_TOP    ?= ./eb_apb_registers_ipxact.xml
IPXACT_DUT    ?= elastic_buffer_apb_regs
REG_TOP_CLASS ?= apb_wrapper_regs_t
REG_OUT       ?= apb_wrapper_regs
REG_PKG       ?= apb_wrapper_reg_pkg

FILELIST ?= ./tb/run.f

# Output directories
RUN_DIR  ?= sim/$(TEST)
TEMP_DIR ?= $(HOME)/temp
COV_DIR  ?= $(TEMP_DIR)
LOG_ELAB ?= $(RUN_DIR)/xrun_elab.log
LOG_RUN  ?= $(RUN_DIR)/xrun.log
LOG_GUI  ?= $(RUN_DIR)/xrun_gui.log

XRUN_OPTS ?= \
    -64bit \
    -sv \
    -uvm \
    -access +rwc \
    +UVM_TESTNAME=$(TEST) \
    +UVM_VERBOSITY=UVM_MEDIUM \
    -svseed $(SEED) \
    -coverage U \
    -covoverwrite \
    -covworkdir $(COV_DIR) \
    -covtest $(TEST)

# Keep compiled libs per-run
XRUN_LIB_OPTS ?= -xmlibdirname $(RUN_DIR)/xcelium.d

# GUI options (SimVision)
XRUN_GUI_OPTS ?= \
    -gui \
    +UVM_TR_RECORD

.PHONY: help sim elab run gui clean distclean cov regmodel

help:
	@echo "Targets:"
	@echo "  make sim TEST=<uvm_test> SEED=<n>"
	@echo "  make regmodel  (Generates UVM RAL model from IP-XACT)"
	@echo "  make cov  (Opens coverage GUI)"
	@echo "  make clean"

regmodel:
	$(REG_VERIFIER) -domain uvmreg -top $(IPXACT_TOP) -dut_name $(IPXACT_DUT) -top_level_class_name $(REG_TOP_CLASS) -out_file $(REG_OUT) -cov -quicktest -pkg $(REG_PKG)

sim: $(RUN_DIR)
	-$(XRUN) -f $(FILELIST) -top $(TOP) $(XRUN_LIB_OPTS) $(XRUN_OPTS) -l $(LOG_RUN) || echo "xrun exited with an error. Check $(LOG_RUN) for details."
	@mkdir -p $(RUN_DIR)/cov_work
	@if [ -d $(TEMP_DIR) ]; then \
		mv -f $(TEMP_DIR)/* $(RUN_DIR)/cov_work; \
		echo "Coverage files moved to $(RUN_DIR)/cov_work"; \
	else \
		echo "Directory $(TEMP_DIR) does not exist"; \
	fi

# Split flow (optional)
elab: $(RUN_DIR)
	$(XRUN) -f $(FILELIST) -top $(TOP) $(XRUN_LIB_OPTS) $(XRUN_OPTS) -l $(LOG_ELAB) -elaborate

run:
	-$(XRUN) -f $(FILELIST) -top $(TOP) $(XRUN_LIB_OPTS) $(XRUN_OPTS) -l $(LOG_RUN) || echo "xrun exited with an error. Check $(LOG_RUN) for details."
	@mkdir -p $(RUN_DIR)/cov_work
	@if [ -d $(TEMP_DIR) ]; then \
		mv -f $(TEMP_DIR)/* $(RUN_DIR)/cov_work; \
		echo "Coverage files moved to $(RUN_DIR)/cov_work"; \
	else \
		echo "Directory $(TEMP_DIR) does not exist"; \
	fi

gui: $(RUN_DIR)
	$(XRUN) -f $(FILELIST) -top $(TOP) $(XRUN_LIB_OPTS) $(XRUN_OPTS) $(XRUN_GUI_OPTS) -l $(LOG_GUI)

# Open Integrated Metrics Center (IMC) for coverage analysis
cov:
	imc -load ./$(RUN_DIR)/cov_work/

$(RUN_DIR):
	@mkdir -p $(RUN_DIR)

clean:
	@rm -rf sim xcelium.d INCA_libs waves.shm *.log *.key $(TEMP_DIR)
