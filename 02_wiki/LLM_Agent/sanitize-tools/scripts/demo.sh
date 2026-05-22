#!/bin/bash
# =============================================================================
# Valgrind Bug Detection Demo
# =============================================================================
# This script demonstrates how Valgrind detects three classic memory bugs:
#   1. use-after-free      — dereferencing a pointer after free()
#   2. heap-buffer-overflow — writing past the end of a heap allocation
#   3. memory leak          — allocated memory never freed
#
# Run:  bash scripts/demo.sh
# Requires: valgrind >= 3.23.0  (no special compiler flags needed)
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
    arr[0] = 42;   // Valgrind: Invalid write after free
    return 0;
}
EOF
cat "$BUILD_DIR/uaf.c"

info "Compile: gcc -g -o uaf _build/uaf.c"
info "Run:     valgrind --leak-check=full --track-origins=yes ./uaf"

gcc -g -o "$BUILD_DIR/uaf" "$BUILD_DIR/uaf.c"
echo "--- Valgrind output below ---"
valgrind --leak-check=full --track-origins=yes "$BUILD_DIR/uaf" 2>&1 || true
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
    arr[4] = 123;  // Valgrind: write past the end of heap allocation
    free(arr);
    return 0;
}
EOF
cat "$BUILD_DIR/heap_overflow.c"

info "Compile: gcc -g -o heap_overflow _build/heap_overflow.c"
info "Run:     valgrind --leak-check=full --track-origins=yes ./heap_overflow"

gcc -g -o "$BUILD_DIR/heap_overflow" "$BUILD_DIR/heap_overflow.c"
echo "--- Valgrind output below ---"
valgrind --leak-check=full --track-origins=yes "$BUILD_DIR/heap_overflow" 2>&1 || true
echo ""

# =============================================================================
# BUG #3 — Memory Leak
# =============================================================================
info "=== BUG #3: Memory Leak ==="
info "Source: _build/leak.c"
cat > "$BUILD_DIR/leak.c" << 'EOF'
#include <stdio.h>
#include <stdlib.h>

int main() {
    int *arr = malloc(4 * sizeof(int));  // allocated but never freed
    arr[0] = 1;
    arr[1] = 2;
    // leak: arr is never freed
    return 0;
}
EOF
cat "$BUILD_DIR/leak.c"

info "Compile: gcc -g -o leak _build/leak.c"
info "Run:     valgrind --leak-check=full --track-origins=yes ./leak"

gcc -g -o "$BUILD_DIR/leak" "$BUILD_DIR/leak.c"
echo "--- Valgrind output below ---"
valgrind --leak-check=full --track-origins=yes "$BUILD_DIR/leak" 2>&1 || true
echo ""

# =============================================================================
# Summary
# =============================================================================
info "=== Summary ==="
info "All three bugs detected with Valgrind — no special compiler flags needed."
info ""
info "  Bug                       | How to Trigger                 | Valgrind Error Type     "
info "  --------------------------|--------------------------------|-------------------------"
info "  Use-after-free            | free() then write              | Invalid write / read     "
info "  Heap buffer overflow     | Write past end of malloc       | Invalid write            "
info "  Memory leak              | malloc() without free()        | definitely lost          "
info ""
info "Key:  --leak-check=full     (enable detailed leak reporting)"
info "      --track-origins=yes  (show where uninitialized values came from)"
info "      -g                   (debug symbols for source-level stack traces)"