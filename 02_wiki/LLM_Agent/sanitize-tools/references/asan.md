# AddressSanitizer (ASan) — Full Reference

## Overview

AddressSanitizer (ASan) is a memory error detector for C/C++ programs. It uses shadow memory and instrumentation to detect out-of-bounds and use-after-free errors at runtime.

- **Compiler**: GCC ≥ 4.8 or Clang ≥ 3.1
- **Supported platforms**: Linux, macOS, FreeBSD
- **Overhead**: ~2x memory, ~2x slowdown
- **Requires**: `-O1` or higher for full accuracy

---

## Compilation

### Basic

```bash
gcc -fsanitize=address -g -O1 -o program program.c
g++ -fsanitize=address -g -O1 -o program program.cpp
```

### With CMake

```cmake
# CMakeLists.txt
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fsanitize=address -g -O1")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fsanitize=address -g -O1")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -fsanitize=address")
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -fsanitize=address")
```

### With Make

```bash
CFLAGS="-fsanitize=address -g -O1" make program
CXXFLAGS="-fsanitize=address -g -O1" make program
```

### Autotools

```bash
CC=gcc CFLAGS="-fsanitize=address -g -O1" LDFLAGS="-fsanitize=address" ./configure
make clean && make
```

---

## What ASan Detects

| Error Type | Description |
|-----------|-------------|
| **Heap buffer overflow** | Read/write past end of a heap allocation |
| **Stack buffer overflow** | Read/write past end of a stack-allocated array |
| **Global buffer overflow** | Read/write past end of a global variable |
| **Use-after-free** | Dereferencing a freed (dangling) pointer |
| **Double-free** | Calling `free()` twice on same pointer |
| **Stack-use-after-return** | Accessing a local variable after it goes out of scope |
| **Initialization order bugs** | Using global constructors before initialization |

---

## Typical ASan Output

### Heap Buffer Overflow

```
=================================================================
==12345== ERROR: AddressSanitizer: heap-buffer-overflow on address 0x60200000003c
0x60200000003c is located 4 bytes after 8-byte region [0x602000000038,0x602000000040)
allocated by thread T0 here:
    #0 0x4c2b8e in malloc /src/compiler-rt/lib/asan/asan_malloc_linux.cpp:69
    #1 0x4a43b7 in main /src/demo/main.cpp:6
    #2 0x7f5a6c9d1c82 in __libc_start_main ??:?

SUMMARY: AddressSanitizer: heap-buffer-overflow at 0x60200000003c
```

### Use-After-Free

```
=================================================================
==12345== ERROR: AddressSanitizer: use-after-free on address 0x60200000003c
0x60200000003c is located 4 bytes after 8-byte region [0x602000000038,0x602000000040)
allocated by thread T0 here:
    #0 0x4c2b8e in malloc /src/compiler-rt/lib/asan/asan_malloc_linux.cpp:69
    #1 0x4a43b7 in main /src/demo/main.cpp:6
    #2 0x7f5a6c9d1c82 in __libc_start_main ??:?

Freed by thread T0:
    #0 0x4c2b8e in free /src/compiler-rt/lib/asan/asan_malloc_linux.cpp:69
    #1 0x4a4407 in main /src/demo/main.cpp:10
    #2 0x7f5a6c9d1c82 in __libc_start_main ??:?

Previously allocated by thread T0:
    #0 0x4c2b8e in malloc /src/compiler-rt/lib/asan/asan_malloc_linux.cpp:69
    #1 0x4a43b7 in main /src/demo/main.cpp:6
    #2 0x7f5a6c9d1c82 in __libc_start_main ??:?

SUMMARY: AddressSanitizer: use-after-free at 0x60200000003c
```

### Stack Buffer Overflow

```
=================================================================
==12345== ERROR: AddressSanitizer: stack-buffer-overflow on address 0x7fff12345678
Write of size 4 at 0x7fff12345678 by thread T0:
    #0 0x4a44a7 in main /src/demo/main.cpp:12
    #1 0x7f5a6c9d1c82 in __libc_start_main ??:?

SUMMARY: AddressSanitizer: stack-buffer-overflow at 0x7fff12345678
```

### Stack-Use-After-Return

```
=================================================================
==12345== ERROR: AddressSanitizer: stack-use-after-return on address 0x7fff12345678
Write of size 4 at 0x7fff12345678 by thread T0:
    #0 0x4a44a7 in main /src/demo/main.cpp:12
    #1 0x7f5a6c9d1c82 in __libc_start_main ??:?

SUMMARY: AddressSanitizer: stack-use-after-return at 0x7fff12345678
```

---

## ASan with GDB

```bash
# Compile with debug info
gcc -fsanitize=address -g -O1 -fno-stack-protector -o program program.c

# Attach GDB
gdb ./program
# (gdb) set environment ASAN_OPTIONS=abort_on_error=1
# (gdb) run
# When ASan triggers, type:
(gdb) bt            # backtrace
(gdb) bt 20         # limit to 20 frames
(gdb) frame N       # switch to frame N
(gdb) print var     # print variable
(gdb) info registers
```

### Useful GDB Commands for ASan

```
(gdb) set print array-indexers on
(gdb) set print frame-arguments all
(gdb) set scheduler-locking step   # freeze other threads
(gdb) thread apply all bt         # all threads backtrace
```

---

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `ASAN_OPTIONS` | — | Colon-separated options |
| `ASAN_SYMBOLIZER_PATH` | (auto) | Path to `llvm-symbolizer` |
| `ASAN_OPTIONS=abort_on_error=1` | 0 | Abort instead of exit |
| `ASAN_OPTIONS=detect_leaks=1` | 1 | Enable LeakSanitizer |
| `ASAN_OPTIONS=halt_on_error=1` | 0 | Stop on first error |
| `ASAN_OPTIONS=print_stats=1` | 0 | Print memory stats on exit |
| `ASAN_OPTIONS=log_path=FILE` | stderr | Log to file |
| `ASAN_OPTIONS=symbolize=1` | 1 | Use symbolizer |
| `ASAN_OPTIONS=suppressions=SUPPRESSIONS` | — | Suppressions file |

### Suppressions File

```
# suppressions.txt
# Format: type:binary:function
# Example:
leak:$global_lib.*
leak:libc.so.*
```

```bash
ASAN_OPTIONS=suppressions=suppressions.txt ./program
```

---

## Common Compilation Issues

### "ASan runtime does not support this OS"

```
This sanitizer does not support the current OS
```

Upgrade your compiler or use a supported platform.

### No debug symbols in stack trace

Install `llvm-symbolizer` or set `ASAN_SYMBOLIZER_PATH`:

```bash
ASAN_SYMBOLIZER_PATH=$(which llvm-symbolizer) ./program
```

Or install `binutils` (provides `addr2line` fallback):

```bash
export ASAN_OPTIONS=symbolize=1
```

### Custom allocators

ASan instruments `malloc`/`free`. Custom allocators may bypass ASan. Use:

```bash
# Preload ASan's allocator
LD_PRELOAD=/path/to/libasan.so.0 ./program
```

---

## Known Limitations

1. **Mutual exclusivity with TSan**: ASan and TSan cannot be used together.
2. **Memory overhead**: ~2x memory usage. May cause OOM on memory-constrained systems.
3. **Slowdown**: ~2x runtime slowdown. Not suitable for production builds.
4. **Custom allocators**: ASan may miss bugs in code using custom memory allocators that bypass `malloc`/`free`.
5. **Stack buffer overflow detection**: ASan may not catch all stack overflows. Consider `-fsanitize=stack` for experimental stack overflow detection.
6. **LeakSanitizer in ASan builds**: By default, LSan runs as part of ASan and reports reachable leaks. Use `ASAN_OPTIONS=detect_leaks=0` to disable.
7. **Container environments**: In some container/pids namespaces, ASan's thread creation may conflict. Use `--cap-add=SYS_PTRACE` or run outside the container.
8. **suppressions file**: Can hide real bugs if patterns are too broad.
9. **Stack-use-after-return**: Requires `-O1` or higher and no stack protector. May give false negatives with `-O0`.
10. **ARM/32-bit platforms**: Limited support; some ASan features may be unavailable.

---

## Minimal Example Program

```c
// demo_asan.c — Compile with: gcc -fsanitize=address -g -O1 -o demo demo_asan.c

#include <stdio.h>
#include <stdlib.h>

int main() {
    int *arr = malloc(4 * sizeof(int));  // ASan will catch overflow past 4 ints

    // Heap buffer overflow
    arr[4] = 42;  // ERROR: heap-buffer-overflow

    free(arr);

    // Use-after-free
    arr[0] = 100;  // ERROR: use-after-free

    return 0;
}
```

```bash
gcc -fsanitize=address -g -O1 -o demo demo_asan.c
./demo
# => ASan will report the errors above
```