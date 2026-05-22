#!/bin/bash
# =============================================================================
# ASan Bug Detection Demo
# =============================================================================
# This script demonstrates how ASan detects three classic memory bugs:
#   1. use-after-free      — dereferencing a pointer after free()
#   2. heap-buffer-overflow — writing past the end of a heap allocation
#   3. stack-buffer-overflow — writing past the end of a stack array
#
# Run:  bash scripts/demo.sh
# Requires: GCC ≥ 4.8 or Clang ≥ 3.1 with ASan runtime installed
#           On many distros:  dnf install libasan  or  apt install libasan6
# =============================================================================

DEMO_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$DEMO_DIR/_build"
mkdir -p "$BUILD_DIR"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${YELLOW}[INFO]${NC} $1"; }
ok()   { echo -e "${GREEN}[ OK ]${NC} $1"; }
err()  { echo -e "${RED}[FAIL]${NC} $1"; }

# Check compiler
if ! gcc -fsanitize=address -g -O1 -o /dev/null -x c - <<< 'int main(){}' 2>/dev/null; then
  info "ASan is not available in this environment (libasan runtime not linked)."
  info "The source files below are written to _build/ — copy to a machine with ASan installed."
  echo ""
fi

# =============================================================================
# BUG #1 — Use-After-Free
# =============================================================================
info "=== BUG #1: Use-After-Free ==="
info "Source: _build/uaf.c"
cat > "$BUILD_DIR/uaf.c" << 'EOF'
#include <stdio.h>
#include <stdlib.h>

int main() {
    int *arr = malloc(4 * sizeof(int));
    free(arr);
    arr[0] = 42;   // ASan: use-after-free
    return 0;
}
EOF
cat "$BUILD_DIR/uaf.c"

info "Compile: gcc -fsanitize=address -g -O1 -o uaf _build/uaf.c"
info "Run:     ./uaf"

if gcc -fsanitize=address -g -O1 -o "$BUILD_DIR/uaf" "$BUILD_DIR/uaf.c" 2>/dev/null; then
  echo "--- Actual ASan output below ---"
  "$BUILD_DIR/uaf" 2>&1 || true
else
  echo "--- Simulated ASan output ---"
  echo '================================================================='
  echo '==12345== ERROR: AddressSanitizer: use-after-free on address 0x602000000038'
  echo '0x602000000038 is located 0 bytes inside [0x602000000038,0x602000000048)'
  echo 'allocated by thread T0 here:'
  echo '    #0 0x4c2b8e in __interceptor_malloc'
  echo '    #1 0x401286 in main _build/uaf.c:5'
  echo 'Freed by thread T0:'
  echo '    #0 0x4012a7 in main _build/uaf.c:6'
  echo 'SUMMARY: AddressSanitizer: use-after-free'
fi
echo ""

# =============================================================================
# BUG #2 — Heap Buffer Overflow
# =============================================================================
info "=== BUG #2: Heap Buffer Overflow ==="
info "Source: _build/heap_overflow.c"
cat > "$BUILD_DIR/heap_overflow.c" << 'EOF'
#include <stdio.h>
#include <stdlib.h>

int main() {
    int *arr = malloc(4 * sizeof(int));  // 4 ints = 16 bytes
    arr[4] = 123;  // ASan: heap-buffer-overflow (index 4 is the 5th int, past the end)
    free(arr);
    return 0;
}
EOF
cat "$BUILD_DIR/heap_overflow.c"

info "Compile: gcc -fsanitize=address -g -O1 -o heap_overflow _build/heap_overflow.c"
info "Run:     ./heap_overflow"

if gcc -fsanitize=address -g -O1 -o "$BUILD_DIR/heap_overflow" "$BUILD_DIR/heap_overflow.c" 2>/dev/null; then
  echo "--- Actual ASan output below ---"
  "$BUILD_DIR/heap_overflow" 2>&1 || true
else
  echo "--- Simulated ASan output ---"
  echo '================================================================='
  echo '==12346== ERROR: AddressSanitizer: heap-buffer-overflow on address 0x602000000048'
  echo '0x602000000048 is located 4 bytes after 16-byte region [0x602000000040,0x602000000050)'
  echo 'allocated by thread T0 here:'
  echo '    #0 0x4c2b8e in __interceptor_malloc'
  echo '    #1 0x401286 in main _build/heap_overflow.c:5'
  echo 'SUMMARY: AddressSanitizer: heap-buffer-overflow'
fi
echo ""

# =============================================================================
# BUG #3 — Stack Buffer Overflow
# =============================================================================
info "=== BUG #3: Stack Buffer Overflow ==="
info "Source: _build/stack_overflow.c"
cat > "$BUILD_DIR/stack_overflow.c" << 'EOF'
#include <stdio.h>

int main() {
    int arr[4];    // 4 ints on the stack  [arr[0]..arr[3]]
    arr[4] = 999;  // ASan: stack-buffer-overflow (arr[4] is past the end)
    return 0;
}
EOF
cat "$BUILD_DIR/stack_overflow.c"

info "Compile: gcc -fsanitize=address -g -O1 -o stack_overflow _build/stack_overflow.c"
info "Run:     ./stack_overflow"

if gcc -fsanitize=address -g -O1 -o "$BUILD_DIR/stack_overflow" "$BUILD_DIR/stack_overflow.c" 2>/dev/null; then
  echo "--- Actual ASan output below ---"
  "$BUILD_DIR/stack_overflow" 2>&1 || true
else
  echo "--- Simulated ASan output ---"
  echo '================================================================='
  echo '==12347== ERROR: AddressSanitizer: stack-buffer-overflow on address 0x7fff12345678'
  echo 'WRITE of size 4 at 0x7fff12345678 by thread T0:'
  echo '    #0 0x401286 in main _build/stack_overflow.c:6'
  echo 'SUMMARY: AddressSanitizer: stack-buffer-overflow'
fi
echo ""

# =============================================================================
# Summary
# =============================================================================
info "=== Summary ==="
info "All three bugs detected with the same compile flag: -fsanitize=address"
info ""
info "  Bug                       | Flag                          | ASan Error Type          "
info "  --------------------------|-------------------------------|-------------------------"
info "  Use-after-free            | -fsanitize=address -g -O1     | AddressSanitizer: use-after-free       "
info "  Heap buffer overflow      | -fsanitize=address -g -O1     | AddressSanitizer: heap-buffer-overflow  "
info "  Stack buffer overflow     | -fsanitize=address -g -O1     | AddressSanitizer: stack-buffer-overflow "
info ""
info "Key:  -g   (debug symbols for source-level stack traces)"
info "      -O1  (ASan requires at least -O1 for full accuracy)"