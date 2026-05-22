# LeakSanitizer (LSan) Reference

## Overview

LeakSanitizer (LSan) detects memory leaks at runtime. It is integrated into ASan builds by default and can also be used standalone with `-fsanitize=leak`. LSan instruments memory allocation and free operations, tracking reachable vs. leaked memory.

- **Compiler**: GCC ≥ 4.8 or Clang ≥ 3.1 (embedded in ASan for GCC ≥ 4.6)
- **Supported platforms**: Linux, macOS, FreeBSD (standalone not available on all platforms)
- **Overhead**: ~2x memory (alongside ASan), standalone ~1.5x
- **Requires**: `-O1` or higher

---

## Compile Options

### Standalone LSan

```bash
# LSan standalone (no ASan)
gcc -fsanitize=leak -g -O1 -o program program.c
g++ -fsanitize=leak -g -O1 -o program program.cpp
```

### LSan as Part of ASan

```bash
# LSan is enabled by default in ASan builds
gcc -fsanitize=address -g -O1 -o program program.c
# LSan runs automatically at program exit
```

### With CMake

```cmake
# For ASan+LSan (default)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fsanitize=address -g -O1")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fsanitize=address -g -O1")

# For standalone LSan
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fsanitize=leak -g -O1")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fsanitize=leak -g -O1")
```

---

## What LSan Detects

| Error Type | Description |
|-----------|-------------|
| **Direct leak** | Allocated memory, no pointer held, not freed |
| **Indirect leak** | Memory reachable only via pointers in other leaked objects |
| **Reachable leak** | Pointer still held but not explicitly freed (reported separately) |

---

## Typical LSan Output

### Direct Leak

```bash
$ cat leak.cpp
#include <stdlib.h>

int main() {
    int* p = malloc(sizeof(int) * 100);
    // forgot to free(p);
    return 0;
}

$ g++ -fsanitize=leak -g -O1 -o leak leak.cpp
$ ./leak
```

Output:
```
=================================================================
==23456== LeakSanitizer: memory leak detection ON
==23456== Direct leak of 400 byte(s) in 1 object(s) allocated from:
    #0 0x4c2b8e in __interceptor_malloc /src/compiler-rt/lib/asan/asan_malloc_linux.cpp:69
    #1 0x4a43b7 in main /src/demo/leak.cpp:5
    #2 0x7f5a6c9d1c82 in __libc_start_main ??:?

SUMMARY: LeakSanitizer: memory leak of 400 byte(s) in 1 object(s) from:
  main @ leak.cpp:5
```

### Indirect Leak (linked list)

```bash
$ cat leak_list.cpp
#include <stdlib.h>

struct Node {
    int value;
    Node* next;
};

int main() {
    Node* head = new Node{1, nullptr};
    head->next = new Node{2, nullptr};
    // forgot to delete any nodes
    return 0;
}

$ g++ -fsanitize=leak -g -O1 -o leak_list leak_list.cpp
$ ./leak_list
```

Output:
```
=================================================================
==23457== LeakSanitizer: memory leak detection ON
==23457== Indirect leak of 32 byte(s) in 2 object(s) allocated from:
    #0 0x4c2b8e in __interceptor_malloc /src/compiler-rt/lib/asan/asan_malloc_linux.cpp:69
    #1 0x4a43b7 in main /src/demo/leak_list.cpp:11
    #2 0x7f5a6c9d1c82 in __libc_start_main ??:?

SUMMARY: LeakSanitizer: memory leak of 32 byte(s) in 2 object(s) from:
  main @ leak_list.cpp:11
```

### ASan+LSan Combined Output

```bash
$ g++ -fsanitize=address -g -O1 -o demo demo.cpp
$ ./demo
```

Output (at program exit):
```
=================================================================
==12345== ERROR: AddressSanitizer: heap-buffer-overflow on address 0x60200000003c
    #0 0x401286 in malloc /src/libcollector/././util_linux.cpp:7
    ...
=================================================================
==12345== LeakSanitizer: memory leak detection ON
==12345== Direct leak of 1024 byte(s) in 1 object(s) allocated from:
    #0 0x4c2b8e in malloc /src/libcollector/././util_linux.cpp:18
    #1 0x4013a2 in allocate_heap /src/libcollector/././util_linux.cpp:18
    #2 0x4014c7 in main /src/libcollector/./main.cpp:27
```

---

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `ASAN_OPTIONS` | — | Used when LSan is part of ASan |
| `LSAN_OPTIONS` | — | Standalone LSan options |
| `detect_leaks` | 1 | Enable leak detection (set to 0 to disable) |
| `halt_on_error` | 0 | Abort after first leak report |
| `log_path` | stderr | Log output to file |
| `suppressions` | — | Path to suppression file |
| `print_leak_stats` | 0 | Print detailed leak statistics |
| `strict_chain` | 1 | Follow all reachable pointers |
| `report_thread_leaks` | 1 | Report leaks from unjoined threads |
| ` Symbolize` | 1 | Symbolize stack frames |

### Suppressions File

```
# lsan_suppressions.txt
# Format: type:binary:function
leak:$global_lib.*
leak:libstdc++.*
leak: libc.so.*
```

```bash
LSAN_OPTIONS=suppressions=lsan_suppressions.txt ./program
# Or for ASan+LSan:
ASAN_OPTIONS=suppressions=lsan_suppressions.txt ./program
```

### Common Options

```bash
# Disable LSan (in ASan build)
ASAN_OPTIONS=detect_leaks=0 ./program

# Abort on first leak
LSAN_OPTIONS=halt_on_error=1 ./program

# Suppress specific leaks
LSAN_OPTIONS=suppressions=suppressions.txt ./program
```

---

## Known Limitations

1. **Standalone LSan platform support**: Standalone `-fsanitize=leak` is not available on all platforms (e.g., some older glibc). ASan-integrated LSan works everywhere ASan works.
2. **Reachable vs. leaked**: By default, LSan reports both direct leaks and "reachable" memory (pointers still held). Use `ASAN_OPTIONS=detect_leaks=1` and adjust thresholds to avoid noise from cached objects.
3. **Mutually exclusive with TSan**: Like ASan, LSan cannot be combined with ThreadSanitizer.
4. **False positives from caching/reuse**: Libraries that cache allocations for reuse may trigger LSan; use suppressions files for known-safe patterns.
5. **Custom allocators**: LSan tracks `malloc`/`free` and global operator new/delete. Custom allocators may bypass detection; use `LD_PRELOAD` with the ASan runtime.
6. **Memory overhead**: LSan adds ~2x memory overhead when combined with ASan; standalone LSan has lower overhead.
7. **Exit-time scanning**: LSan performs leak detection at program exit. For long-running programs, use `LSAN_OPTIONS=atexit=0` and call `lsan_do_leak_check()` manually.
8. **Leaks in static destructors**: Memory allocated in static destructors may be reported as leaked; use `-fsanitize=leak` with `__attribute__((destructor))` awareness or suppressions.
9. **Debugger interference**: Attaching GDB at specific breakpoints may interfere with LSan's leak checking timing; consider using `ASAN_OPTIONS=detect_leaks=0` during interactive debugging.
10. ** ARM/32-bit**: Limited platform support; some features may be unavailable on 32-bit ARM.