#!/bin/bash

# Check PINTOS_HOME is set
if [ -z "$PINTOS_HOME" ]; then
  echo "[ERROR] PINTOS_HOME is not set. Please set it before running this script."
  exit 1
fi

# Add Pintos utils to PATH
export PATH=$PATH:$PINTOS_HOME/utils
BUILD_PATH="$PINTOS_HOME/threads/build"
TEST_PREFIX="tests/threads"

# Test Lists
TESTS_ALARM_CLOCK="alarm-single alarm-multiple alarm-simultaneous alarm-zero alarm-negative"
TESTS_PRIORITY_SCHED="alarm-priority priority-change priority-preempt priority-fifo priority-sema priority-condvar"
TESTS_MLFQS="mlfqs-load-1 mlfqs-load-60 mlfqs-load-avg mlfqs-recent-1 mlfqs-fair-2 mlfqs-fair-20 mlfqs-nice-2 mlfqs-nice-10 mlfqs-block"

ALL_TESTS="$TESTS_ALARM_CLOCK $TESTS_PRIORITY_SCHED $TESTS_MLFQS"

# Check if test name is provided
if [ -z "$1" ]; then
  echo "[USAGE] $0 <test-name>"
  echo "Example: $0 alarm-single"
  exit 1
fi

TARGET="$1"

# Validate test name
if ! echo "$ALL_TESTS" | grep -qw "$TARGET"; then
  echo "[ERROR] Invalid test name: '$TARGET'"
  echo "Valid test names are:"
  for test in $ALL_TESTS; do
    echo "  - $test"
  done
  exit 1
fi

# Check if build directory exists
if [ ! -d "$BUILD_PATH" ]; then
  echo "[ERROR] Build directory does not exist: $BUILD_PATH"
  echo "Please run 'make' in $PINTOS_HOME/threads before running this test."
  exit 1
fi

cd "$BUILD_PATH" || exit 1

# Check if kernel is built
KERNEL_BIN="$BUILD_PATH/kernel.bin"
if [ ! -f "$KERNEL_BIN" ]; then
  echo "[ERROR] Pintos kernel not built."
  echo "Please run 'make' in $PINTOS_HOME/threads before running this test."
  exit 1
fi

# Define paths
RESULT_PATH="${TEST_PREFIX}/${TARGET}.result"
OUTPUT_PATH="${TEST_PREFIX}/${TARGET}.output"
ERROR_PATH="${TEST_PREFIX}/${TARGET}.errors"

# Clean old result files
rm -f "${RESULT_PATH}" "${OUTPUT_PATH}" "${ERROR_PATH}"

# Run the test
make "${RESULT_PATH}"
MAKE_STATUS=$?
if [ $MAKE_STATUS -ne 0 ]; then
  echo "[ERROR] make failed for test: $TARGET"
  exit 1
fi
echo ""

# Read result
TEST_RESULT="$(cat ${RESULT_PATH} 2>/dev/null)"
if [[ "$TEST_RESULT" == "PASS" ]]; then
  echo "PASS: ${TARGET}"
  exit 0
else
  echo "FAIL: ${TARGET}"
  echo ""

  # Output log
  if [ -f "$OUTPUT_PATH" ]; then
    echo "------ ${OUTPUT_PATH} ------"
    strings "$OUTPUT_PATH"
  else
    echo "(No output file)"
  fi
  echo ""

  # Error log (only show if non-empty)
  if [ -s "$ERROR_PATH" ]; then
    echo "------ ${ERROR_PATH} ------"
    cat "$ERROR_PATH"
  else
    echo "(No error file)"
  fi

  exit 1
fi

