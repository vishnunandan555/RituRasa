#!/usr/bin/env bash
set -e

# Colors for terminal output
BOLD="\033[1m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[1;33m"
CYAN="\033[0;36m"
RED="\033[0;31m"
NC="\033[0m"

echo -e "${CYAN}${BOLD}⚡ RituRasa Fast Unified Test Runner${NC}"
echo -e "${BLUE}Running all 45+ tests across all 12 modules in a single VM...${NC}\n"

START_TIME=$(date +%s%N)

MODE="fast"
EXTRA_ARGS=()

for arg in "$@"; do
  case $arg in
    --ci|--check)
      MODE="ci"
      ;;
    --coverage)
      EXTRA_ARGS+=("--coverage")
      ;;
    --help|-h)
      echo "Usage: ./run_tests.sh [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  (no args)     Run all tests in a single blazing-fast process (~2s)"
      echo "  --ci, --check Run static analyzer first, then all tests"
      echo "  --coverage    Run all tests and generate coverage report"
      echo "  -h, --help    Show this help message"
      exit 0
      ;;
    *)
      EXTRA_ARGS+=("$arg")
      ;;
  esac
done

if [ "$MODE" = "ci" ]; then
  echo -e "${YELLOW}🔍 Step 1/2: Running flutter analyze...${NC}"
  flutter analyze
  echo -e "${GREEN}✓ Analysis passed cleanly!${NC}\n"
  echo -e "${YELLOW}🧪 Step 2/2: Running unified test suite...${NC}"
fi

# Run the master aggregator suite
flutter test test/all_tests_test.dart "${EXTRA_ARGS[@]}"

END_TIME=$(date +%s%N)
ELAPSED_MS=$(( (END_TIME - START_TIME) / 1000000 ))
ELAPSED_SEC=$(awk "BEGIN {printf \"%.2f\", ${ELAPSED_MS}/1000}")

echo ""
echo -e "${GREEN}${BOLD}✓ All tests passed in ${ELAPSED_SEC}s!${NC} 🚀"
