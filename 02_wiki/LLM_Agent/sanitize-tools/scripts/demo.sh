#!/bin/bash
# =============================================================================
# GCC AddressSanitizer (ASan) Bug Detection Demo
# =============================================================================
# This script demonstrates how GCC + libasan detect three classic memory bugs:
#   1. use-after-free      — dereferencing a pointer after free()
#   2. heap-buffer-overflow — writing past the end of a heap allocation
#   3. stack-buffer-overflow — writing past the end of a stack array
#
# Run:  bash scripts/demo.sh
# Requires: gcc with -fsanitize=address and libasan runtime
#   (e.g.  gcc >= 10  +  libasan.so  on PATH)
# Compile:  gcc -fsanitize=address -g -O1 -o <prog> <src>.c
# Run:       ./<prog>
# =============================================================================

DEMO_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$DEMO_DIR/_build"
mkdir -p "$BUILD_DIR"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "${YELLOW}[INFO]${NC} $1"; }
ok()    { echo -e "${GREEN}[ OK ]${NC} $1"; }
err()   { echo -e "${RED}[FAIL]${NC} $1"; }
label() { echo -e "${CYAN}==== $1 ====${NC}"; }

# =============================================================================
# Helper: compile + run, capture ASan output
# =============================================================================
run_asan_test() {
    local label="$1"
    local src="$2"
    local bin="$3"

    label "$label"
    echo -e "\n[Source] $src"
    cat "$src"

    echo ""
    info "Compile: gcc -fsanitize=address -g -O1 -o $(basename "$bin") $(basename "$src")"
    gcc -fsanitize=address -g -O1 -o "$bin" "$src" 2>&1 && {
        echo ""
        info "Run: ./$(basename "$bin")"
        echo "--- ASan output below ---"
        "$bin" 2>&1 || true
        echo ""
    } || {
        err "Compilation failed"
        echo ""
    }
}

# =============================================================================
# BUG #1 — Use-After-Free
# =============================================================================
cat > "$BUILD_DIR/uaf.c" << 'EOF'
#include <stdio.h>
#include <stdlib.h>

int main() {
    int *arr = malloc(4 * sizeof(int));  // allocate 4 ints on heap
    free(arr);                            // free the heap memory
    arr[0] = 42;                          // WRITE through dangling pointer
    return 0;
}
EOF
run_asan_test "BUG #1: Use-After-Free" "$BUILD_DIR/uaf.c" "$BUILD_DIR/uaf"

# =============================================================================
# BUG #2 — Heap Buffer Overflow
# =============================================================================
cat > "$BUILD_DIR/heap_overflow.c" << 'EOF'
#include <stdio.h>
#include <stdlib.h>

int main() {
    int *arr = malloc(4 * sizeof(int));  // 4 ints = 16 bytes, indices 0-3 valid
    arr[4] = 123;                        // WRITE at index 4 → past the allocation
    free(arr);
    return 0;
}
EOF
run_asan_test "BUG #2: Heap Buffer Overflow" "$BUILD_DIR/heap_overflow.c" "$BUILD_DIR/heap_overflow"

# =============================================================================
# BUG #3 — Stack Buffer Overflow
# =============================================================================
cat > "$BUILD_DIR/stack_overflow.c" << 'EOF'
#include <stdio.h>

int main() {
    char buf[8];     // stack array of 8 bytes, indices 0-7 valid
    buf[8] = 'X';   // WRITE at index 8 → past the stack frame
    buf[9] = 'Y';
    buf[10] = 'Z';
    return 0;
}
EOF
run_asan_test "BUG #3: Stack Buffer Overflow" "$BUILD_DIR/stack_overflow.c" "$BUILD_DIR/stack_overflow"

# =============================================================================
# Summary
# =============================================================================
label "Summary"
echo "All three bugs detected with GCC -fsanitize=address — no extra tools needed."
echo ""
echo "  Bug                       | Trigger                      | ASan Error Type               "
echo "  --------------------------|------------------------------|-------------------------------"
echo "  Use-after-free            | free() then write           | heap-use-after-free            "
echo "  Heap buffer overflow      | Write past end of malloc    | heap-buffer-overflow           "
echo "  Stack buffer overflow     | Write past end of stack arr | stack-buffer-overflow          "
echo ""
echo "Key flags:"
echo "  -fsanitize=address   enable AddressSanitizer (ASan)"
echo "  -g                   include debug symbols for source-level stack traces"
echo "  -O1                  recommended (ASan works at -O0 too, but -O1 is faster)"
echo "  LD_PRELOAD=...       (not needed when libasan is in default library path)"