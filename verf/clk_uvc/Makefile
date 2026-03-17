# Xcelium/XRUN Makefile for EB UVM environment

XRUN ?= /opt/rh/XCELIUM2009/tools/bin/xrun

TOP      ?= clk_tb_top
TEST     ?= clk_test
SEED     ?= 1

FILELIST ?= ./tb/run.f

# Output Directories
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
	-covtest $(TEST) \

# Keep compiled libs per-run
XRUN_LIB_OPTS ?= -xmlibdirname $(RUN_DIR)/xcelium.d

# GUI options (SimVision)
XRUN_GUI_OPTS ?= \
    -gui \
    +UVM_TR_RECORD

.PHONY: help sim elab run gui clean distclean cov run_with_cov

help:
	@echo "Targets:"
	@echo "  make sim TEST=<uvm_test> SEED=<n>"
	@echo "  make cov  (Opens coverage GUI)"
	@echo "  make clean"


sim: $(RUN_DIR)
	-$(XRUN) -f $(FILELIST) -top $(TOP) $(XRUN_LIB_OPTS) $(XRUN_OPTS) -l $(LOG_RUN) || echo "xrun exited with an error. Check $(LOG_RUN) for details."
	@mkdir -p $(RUN_DIR)/cov_work
	@if [ -d $(TEMP_DIR) ]; then \
		mv -f  $(TEMP_DIR)/* $(RUN_DIR)/cov_work; \
		echo "Coverage files moved to $(RUN_DIR)/"; \
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
		mv -f  $(TEMP_DIR)/* $(RUN_DIR)/cov_work; \
		echo "Coverage files moved to $(RUN_DIR)/"; \
	else \
		echo "Directory $(TEMP_DIR) does not exist"; \
	fi

gui: $(RUN_DIR)
	$(XRUN) -f $(FILELIST) -top $(TOP) $(XRUN_LIB_OPTS) $(XRUN_OPTS) $(XRUN_GUI_OPTS) -l $(LOG_GUI)

# NEW TARGET: Open Integrated Metrics Center (IMC) for Coverage Analysis
cov:
	imc -load  ./sim/usb_clk_test/cov_work/

$(RUN_DIR):
	@mkdir -p $(RUN_DIR)

clean:
	@rm -rf sim

distclean: clean
	@rm -rf xcelium.d INCA_libs waves.shm *.log *.key $(TEMP_DIR)