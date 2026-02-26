#!/bin/bash

################################################################################
# EB Regression Test Script
# 
# Description:
#   Runs all elastic buffer UVM tests sequentially with real-time failure 
#   reporting. Supports future parallelization (up to 5 tests in parallel).
#
# Usage:
#   ./run_regression.sh [--parallel] [--seed SEED]
#
# Options:
#   --parallel      Run up to 5 tests in parallel (future feature)
#   --seed SEED     Random seed for all tests (default: 1)
#
# Logs:
#   All test logs go to: sim/<test_name>/xrun.log
#   Regression summary: regression_summary.log
#
################################################################################

set -o pipefail

# ============================================================================
# Environment Setup
# ============================================================================
# Source IC command if available (Cadence environment setup)
if command -v IC &> /dev/null; then
    echo "Loading Cadence environment (IC)..."
    IC
elif [ -f ~/.bashrc ]; then
    source ~/.bashrc
    if command -v IC &> /dev/null; then
        echo "Loading Cadence environment (IC)..."
        IC
    fi
fi

# ============================================================================
# Configuration
# ============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"
XRUN=${XRUN:-/opt/rh/XCELIUM2009/tools/bin/xrun}
TOP="eb_tb_top"
FILELIST="${PARENT_DIR}/filelist.f"
SEED=1
PARALLEL=0
MAX_PARALLEL_JOBS=5

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Array of all tests to run
declare -a TESTS=(
    "fifo_test"
    "eb_counting_test"
    "eb_wr_skp_test"
    "eb_rd_skp_test"
    "eb_usb_test"
)

# ============================================================================
# Functions
# ============================================================================

# Print header with formatting
print_header() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║             EB REGRESSION TEST SUITE                                   ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Print section separator
print_section() {
    local title="$1"
    echo -e "${CYAN}─────────────────────────────────────────────────────────────────────────${NC}"
    echo -e "${CYAN}${title}${NC}"
    echo -e "${CYAN}─────────────────────────────────────────────────────────────────────────${NC}"
}

# Print test start
print_test_start() {
    local test_name="$1"
    local test_num="$2"
    local total_tests="$3"
    echo -e "${YELLOW}[${test_num}/${total_tests}]${NC} Starting test: ${CYAN}${test_name}${NC}"
}

# Print test pass
print_test_pass() {
    local test_name="$1"
    echo -e "  ${GREEN}✓ PASS${NC}  ${test_name}"
}

# Print test fail with critical reporting
print_test_fail() {
    local test_name="$1"
    local log_file="$2"
    echo -e "  ${RED}✗ FAIL${NC}  ${test_name}"
    echo -e "    ${RED}└─ Log: ${log_file}${NC}"
}

# Check if test passed by examining log file
check_test_passed() {
    local log_file="$1"
    local test_name="$2"
    
    if [ ! -f "$log_file" ]; then
        return 1
    fi
    
    # Check for UVM TEST PASSED message (standard UVM success indicator)
    if grep -q "UVM_\(TEST\|ERROR\).*PASSED" "$log_file" || grep -q "Simulation finished successfully" "$log_file"; then
        # Make sure there are no UVM_FATAL/UVM_ERROR messages
        if grep -q "^.*UVM_\(FATAL\|ERROR\)" "$log_file"; then
            return 1
        fi
        return 0
    fi
    
    # Alternative check: if xrun completed without critical errors
    if grep -qE "Unmatched|Fatal|Error|failed" "$log_file" | grep -iv "warning"; then
        return 1
    fi
    
    return 0
}

# Run a single test
run_test() {
    local test_name="$1"
    local seed="$2"
    local test_num="$3"
    local total_tests="$4"
    
    local run_dir="${PARENT_DIR}/sim/${test_name}"
    local log_elab="${run_dir}/xrun_elab.log"
    local log_run="${run_dir}/xrun.log"
    
    print_test_start "$test_name" "$test_num" "$total_tests"
    
    # Create run directory
    mkdir -p "$run_dir"
    
    # Prepare xrun options
    local xrun_opts="-64bit -sv -uvm -access +rwc +UVM_TESTNAME=${test_name} +UVM_VERBOSITY=UVM_MEDIUM -svseed ${seed} -coverage all -covoverwrite -covworkdir ${HOME}/temp -covtest ${test_name}"
    local xrun_lib_opts="-xmlibdirname ${run_dir}/xcelium.d"
    
    # Run compilation, elaboration, and simulation
    if ${XRUN} -f "$FILELIST" -top "$TOP" $xrun_lib_opts $xrun_opts -l "$log_elab" -elaborate > /dev/null 2>&1 && \
       ${XRUN} $xrun_lib_opts $xrun_opts -l "$log_run" -R > /dev/null 2>&1; then
        
        # Check the log for actual success
        if check_test_passed "$log_run" "$test_name"; then
            print_test_pass "$test_name"
            return 0
        else
            print_test_fail "$test_name" "$log_run"
            return 1
        fi
    else
        print_test_fail "$test_name" "$log_run"
        return 1
    fi
}

# Run tests sequentially (current mode)
run_tests_sequential() {
    local total_tests=${#TESTS[@]}
    local passed=0
    local failed=0
    local failed_tests=()
    local passed_tests=()
    
    print_section "SEQUENTIAL TEST EXECUTION"
    echo "Total tests: $total_tests"
    echo "Seed: $SEED"
    echo ""
    
    for ((i=0; i<total_tests; i++)); do
        local test_name="${TESTS[$i]}"
        if run_test "$test_name" "$SEED" $((i+1)) "$total_tests"; then
            ((passed++))
            passed_tests+=("$test_name")
        else
            ((failed++))
            failed_tests+=("$test_name")
        fi
        echo ""
    done
    
    return_passed=$passed
    return_failed=$failed
    return_failed_tests=("${failed_tests[@]}")
    return_passed_tests=("${passed_tests[@]}")
}

# Run tests in parallel (future feature - stubbed)
run_tests_parallel() {
    echo -e "${YELLOW}⚠  Parallel mode is a future feature${NC}"
    echo "    Currently running in sequential mode"
    echo ""
    run_tests_sequential
}

# Print final summary
print_summary() {
    local passed=$1
    local failed=$2
    
    print_section "REGRESSION SUMMARY"
    
    local total=$((passed + failed))
    local pass_rate=0
    
    if [ $total -gt 0 ]; then
        pass_rate=$((100 * passed / total))
    fi
    
    echo -e "Total Tests:   ${CYAN}${total}${NC}"
    echo -e "Passed:        ${GREEN}${passed}${NC}"
    echo -e "Failed:        ${RED}${failed}${NC}"
    echo -e "Pass Rate:     ${CYAN}${pass_rate}%${NC}"
    echo ""
    
    if [ $failed -gt 0 ]; then
        echo -e "${RED}Failed Tests:${NC}"
        for test in "${return_failed_tests[@]}"; do
            echo -e "  ${RED}• ${test}${NC}"
        done
        echo ""
    fi
    
    # Print log directory info
    echo -e "${CYAN}Log Directory:${NC} ${PARENT_DIR}/sim/"
    echo ""
}

# Merge coverage data from all tests
merge_coverage() {
    print_section "COVERAGE MERGE"
    
    local temp_cov="${HOME}/temp"
    local scope_dir="${temp_cov}/scope"
    local cov_work_dir="${PARENT_DIR}/cov_work"
    local passed_tests=("${return_passed_tests[@]}")
    local merge_targets=()
    
    # Check if coverage data exists
    if [ ! -d "$scope_dir" ]; then
        echo -e "${YELLOW}⚠  No coverage scope found at ${scope_dir}${NC}"
        return 1
    fi

    if [ ${#passed_tests[@]} -eq 0 ]; then
        echo -e "${YELLOW}⚠  No passed tests to merge${NC}"
        return 1
    fi

    shopt -s nullglob
    for test_name in "${passed_tests[@]}"; do
        for run_path in ${scope_dir}/${test_name}*; do
            if [ -e "$run_path" ]; then
                merge_targets+=("$run_path")
            fi
        done
    done
    shopt -u nullglob

    if [ ${#merge_targets[@]} -eq 0 ]; then
        echo -e "${YELLOW}⚠  No matching coverage runs found for passed tests${NC}"
        return 1
    fi
    
    # Create cov_work directory
    echo -e "Creating coverage directory: ${CYAN}${cov_work_dir}${NC}"
    mkdir -p "$cov_work_dir"
    
    # Change to cov_work directory for merging
    cd "$cov_work_dir" || return 1
    
    # Check if imc command is available
    if ! command -v imc &> /dev/null; then
        echo -e "${YELLOW}⚠  imc command not found, skipping coverage merge${NC}"
        echo -e "   Coverage data saved in: ${cov_work_dir}"
        cd "$SCRIPT_DIR"
        return 1
    fi
    
    # Merge coverage data
    echo -e "Merging coverage data..."
    echo -e "${CYAN}Running: imc -execcmd \"merge ${temp_cov}/scope/* -out all\"${NC}"
    
    if imc -execcmd "merge ${merge_targets[*]} -out all" > "${SCRIPT_DIR}/coverage_merge.log" 2>&1; then
        echo -e "${GREEN}✓${NC} Coverage merged successfully"
        echo -e "   Output: ${CYAN}all${NC}"
        echo -e "   Log: ${CYAN}${SCRIPT_DIR}/coverage_merge.log${NC}"

        if [ -d "$temp_cov" ]; then
            if [ -d "${cov_work_dir}/temp" ]; then
                mv "${cov_work_dir}/temp" "${cov_work_dir}/temp_backup_$(date +%Y%m%d_%H%M%S)" 2>/dev/null
            fi
            mv "$temp_cov" "${cov_work_dir}/temp" 2>/dev/null
        fi
    else
        echo -e "${RED}✗${NC} Coverage merge failed"
        echo -e "   Check log: ${CYAN}${SCRIPT_DIR}/coverage_merge.log${NC}"
    fi
    
    # Return to script directory
    cd "$SCRIPT_DIR"
    echo ""
}

# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --parallel)
                PARALLEL=1
                shift
                ;;
            --seed)
                SEED="$2"
                shift 2
                ;;
            --help)
                echo "Usage: $0 [--parallel] [--seed SEED]"
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                exit 1
                ;;
        esac
    done
}

# ============================================================================
# Main Script
# ============================================================================

main() {
    parse_arguments "$@"
    
    print_header
    
    # Check if xrun exists
    if ! command -v $XRUN &> /dev/null; then
        echo -e "${RED}Error: xrun not found at $XRUN${NC}"
        exit 1
    fi
    
    # Check if filelist exists
    if [ ! -f "$FILELIST" ]; then
        echo -e "${RED}Error: Filelist not found at $FILELIST${NC}"
        exit 1
    fi
    
    # Run tests
    if [ $PARALLEL -eq 1 ]; then
        run_tests_parallel
    else
        run_tests_sequential
    fi
    
    # Print summary
    print_summary "$return_passed" "$return_failed"
    
    # Merge coverage data from all tests
    merge_coverage
    
    # Exit with appropriate code
    if [ "$return_failed" -gt 0 ]; then
        exit 1
    else
        exit 0
    fi
}

# Run main function
main "$@"
