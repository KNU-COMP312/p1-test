#!/bin/bash

# Check input argument
if [ -z "$1" ]; then
  echo "[USAGE] $0 [alarm|priority|mlfqs|all]"
  exit 1
fi
TARGET="$1"

# Check PINTOS_HOME is set
if [ -z "$PINTOS_HOME" ]; then
  echo "[ERROR] PINTOS_HOME is not set. Please set it before running this script."
  exit 1
fi

# Check if build directory exists
BUILD_PATH="$PINTOS_HOME/threads/build"
if [ ! -d "$BUILD_PATH" ]; then
  echo "[ERROR] Build directory does not exist: $BUILD_PATH"
  echo "Please run 'make' in $PINTOS_HOME/threads before running this test."
  exit 1
fi

# Automatically determine script path
SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_PATH" || exit 1

# Define test groups
TESTS_ALARM_CLOCK="alarm-single alarm-multiple alarm-simultaneous alarm-zero alarm-negative"
TESTS_PRIORITY_SCHED="alarm-priority priority-change priority-preempt priority-fifo priority-sema priority-condvar"
TESTS_MLFQS="mlfqs-load-1 mlfqs-load-60 mlfqs-load-avg mlfqs-recent-1 mlfqs-fair-2 mlfqs-fair-20 mlfqs-nice-2 mlfqs-nice-10 mlfqs-block"

# Choose test list
case "$TARGET" in
  alarm)
    TEST_LIST="$TESTS_ALARM_CLOCK"
    ;;
  priority)
    TEST_LIST="$TESTS_PRIORITY_SCHED"
    ;;
  mlfqs)
    TEST_LIST="$TESTS_MLFQS"
    ;;
  all)
    TEST_LIST="$TESTS_ALARM_CLOCK $TESTS_PRIORITY_SCHED $TESTS_MLFQS"
    ;;
  *)
    echo "[ERROR] Invalid target: $TARGET"
    echo "Available targets: alarm, priority, mlfqs, all"
    exit 1
    ;;
esac

# Result summary
PASS_LIST=()
FAIL_LIST=()

echo "[INFO] Running tests for '$TARGET'"

for t in $TEST_LIST; do
  echo "--------------------------------------------------"
  echo "[RUNNING] $t"
  bash check.sh "$t"
  if [ $? -eq 0 ]; then
    PASS_LIST+=("$t")
  else
    FAIL_LIST+=("$t")
  fi
done

# Summary
echo
echo "================== TEST SUMMARY =================="
echo "✅ PASSED (${#PASS_LIST[@]})"
for t in "${PASS_LIST[@]}"; do
  echo "  - $t"
done

echo
echo "❌ FAILED (${#FAIL_LIST[@]})"
for t in "${FAIL_LIST[@]}"; do
  echo "  - $t"
done
echo "=================================================="
