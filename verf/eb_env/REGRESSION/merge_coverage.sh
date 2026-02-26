#!/bin/bash

################################################################################
# EB Coverage Merge Script
#
# Description:
#   Copies coverage data from ~/temp to cov_work directory and merges
#   all test coverage data into a single total_coverage report
#
# Usage:
#   ./merge_coverage.sh
#
# Output:
#   - cov_work/        - Coverage data directory
#   - total_coverage   - Merged coverage database
#   - coverage_merge.log - Merge operation log
#
################################################################################

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"
TEMP_COV="${HOME}/temp"
SCOPE_DIR="${TEMP_COV}/scope"
COV_WORK_DIR="${PARENT_DIR}/cov_work"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║             EB COVERAGE MERGE TOOL                                      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if coverage data exists in temp
if [ ! -d "$SCOPE_DIR" ]; then
    echo -e "${RED}✗ Error: Coverage scope directory not found at ${SCOPE_DIR}${NC}"
    echo ""
    echo "Make sure you have run the regression tests first:"
    echo "  ./run_regression.sh"
    echo ""
    exit 1
fi

# Check for coverage files
COV_FILES=$(find "$SCOPE_DIR" -name "*.ucm" -o -type d 2>/dev/null | wc -l)
if [ "$COV_FILES" -eq 0 ]; then
    echo -e "${YELLOW}⚠  Warning: No coverage files found in ${SCOPE_DIR}${NC}"
    echo ""
fi

check_test_passed() {
    local log_file="$1"
    if [ ! -f "$log_file" ]; then
        return 1
    fi

    if grep -q "UVM_\(TEST\|ERROR\).*PASSED" "$log_file" || grep -q "Simulation finished successfully" "$log_file"; then
        if grep -q "^.*UVM_\(FATAL\|ERROR\)" "$log_file"; then
            return 1
        fi
        return 0
    fi

    if grep -qE "Unmatched|Fatal|Error|failed" "$log_file" | grep -iv "warning"; then
        return 1
    fi

    return 0
}

echo -e "${CYAN}─────────────────────────────────────────────────────────────────────────${NC}"
echo -e "${CYAN}COVERAGE DATA PREPARATION${NC}"
echo -e "${CYAN}─────────────────────────────────────────────────────────────────────────${NC}"

merge_targets=()
passed_tests=()

if [ -d "${PARENT_DIR}/sim" ]; then
    for log_file in "${PARENT_DIR}"/sim/*/xrun.log; do
        test_dir=$(basename "$(dirname "$log_file")")
        if check_test_passed "$log_file"; then
            passed_tests+=("$test_dir")
        fi
    done
fi

if [ ${#passed_tests[@]} -eq 0 ]; then
    echo -e "${YELLOW}⚠  Warning: No passed tests detected in ${PARENT_DIR}/sim${NC}"
fi

shopt -s nullglob
for test_name in "${passed_tests[@]}"; do
    for run_path in ${SCOPE_DIR}/${test_name}*; do
        if [ -e "$run_path" ]; then
            merge_targets+=("$run_path")
        fi
    done
done
shopt -u nullglob

if [ ${#merge_targets[@]} -eq 0 ]; then
    echo -e "${RED}✗ Error: No matching coverage runs found for passed tests${NC}"
    exit 1
fi

# Create cov_work directory
echo -e "Creating coverage directory: ${CYAN}${COV_WORK_DIR}${NC}"
mkdir -p "$COV_WORK_DIR"

echo ""

# Check if imc command is available
if ! command -v imc &> /dev/null; then
    echo -e "${RED}✗ Error: imc command not found${NC}"
    echo ""
    echo "Make sure the Cadence environment is loaded:"
    echo "  IC"
    echo "  or"
    echo "  source /opt/rh/XCELIUM2009/setup.sh"
    echo ""
    echo -e "${YELLOW}Coverage data has been copied to: ${COV_WORK_DIR}${NC}"
    exit 1
fi

echo -e "${CYAN}─────────────────────────────────────────────────────────────────────────${NC}"
echo -e "${CYAN}COVERAGE MERGE${NC}"
echo -e "${CYAN}─────────────────────────────────────────────────────────────────────────${NC}"

# Change to cov_work directory for merging
cd "$COV_WORK_DIR" || exit 1

echo -e "Working directory: ${CYAN}$(pwd)${NC}"
echo -e "Command: ${CYAN}imc -execcmd \"merge ${TEMP_COV}/scope/* -out all\"${NC}"
echo ""

# Run the merge command
LOG_FILE="${PARENT_DIR}/coverage_merge.log"

echo "Running coverage merge..."
if imc -execcmd "merge ${merge_targets[*]} -out all" > "$LOG_FILE" 2>&1; then
    echo -e "${GREEN}✓ Coverage merge completed successfully!${NC}"
    echo ""
    echo -e "${CYAN}Output Files:${NC}"
    echo -e "  Coverage database: ${GREEN}${COV_WORK_DIR}/all${NC}"
    echo -e "  Merge log:         ${CYAN}${LOG_FILE}${NC}"
    echo ""
    
    # Check if output was created
    if [ -d "all" ] || [ -f "all" ]; then
        echo -e "${GREEN}✓${NC} Merged coverage database created"
        
        # Show size if possible
        SIZE=$(du -sh all 2>/dev/null | cut -f1)
        if [ -n "$SIZE" ]; then
            echo -e "  Size: ${CYAN}${SIZE}${NC}"
        fi
    fi

    if [ -d "$TEMP_COV" ]; then
        if [ -d "${COV_WORK_DIR}/temp" ]; then
            mv "${COV_WORK_DIR}/temp" "${COV_WORK_DIR}/temp_backup_$(date +%Y%m%d_%H%M%S)" 2>/dev/null
        fi
        mv "$TEMP_COV" "${COV_WORK_DIR}/temp" 2>/dev/null
    fi
    
    echo ""
    echo -e "${CYAN}Next Steps:${NC}"
    echo "  1. View coverage report:"
    echo "     cd ${COV_WORK_DIR}"
    echo "     imc -load all"
    echo ""
    echo "  2. Generate HTML report:"
    echo "     imc -load all -execcmd \"report -html -out coverage_report\""
    echo ""
    
    cd "$SCRIPT_DIR"
    exit 0
else
    echo -e "${RED}✗ Coverage merge failed${NC}"
    echo ""
    echo -e "Check the log file for details:"
    echo -e "  ${CYAN}${LOG_FILE}${NC}"
    echo ""
    echo "Last 20 lines of log:"
    echo -e "${YELLOW}────────────────────────────────────────────────────────────────${NC}"
    tail -20 "$LOG_FILE" 2>/dev/null || echo "Could not read log file"
    echo -e "${YELLOW}────────────────────────────────────────────────────────────────${NC}"
    echo ""
    
    cd "$SCRIPT_DIR"
    exit 1
fi
