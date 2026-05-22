---
name: sanitize-tools
description: Detect memory safety issues, leaks, undefined behavior, and data races using LLVM/Clang sanitizers (ASan, LSan, MSan, UBSan, TSan). Activate when user mentions any sanitizer name, memory debug, memory leak, or address sanitizer.
metadata:
  emoji: "🔬"
  version: "0.1.0"
  author: "OpenClaw Agent"
  created: "2026-05-22"
---

# sanitize-tools Agent Skill

> Memory-safe debugging toolkit: AddressSanitizer (ASan), LeakSanitizer (LSan), UndefinedBehaviorSanitizer (UBSan), and ThreadSanitizer (TSan).

---

## Table of Contents

1. [Overview](#overview)
2. [AddressSanitizer (ASan)](#addresssanitizer-asan)
3. [LeakSanitizer (LSan)](#leaksanitizer-lsan)
4. [UndefinedBehaviorSanitizer (UBSan)](#undefinedbehaviorsanitizer-ubsan)
5. [ThreadSanitizer (TSan)](#threadsanitizer-tsan)
6. [MemorySanitizer (MSan)](#memorysanitizer-msan)
7. [Common Compiler Flags](#common-compiler-flags)
8. [Typical Output Examples](#typical-output-examples)
9. [Known Limitations](#known-limitations)
10. [References](#references)

---

## Overview

LLVM/Clang sanitizers are compile-time instrumentation tools that detect runtime bugs.

| Sanitizer | Detects | Compiler Flag |
|-----------|---------|---------------|
| AddressSanitizer (ASan) | Use-after-free, stack/heap buffer overflow, double-free | `-fsanitize=address` |
| LeakSanitizer (LSan) | Memory leaks (standalone or with ASan) | `-fsanitize=leak` |
| UndefinedBehaviorSanitizer (UBSan) | Undefined behavior (int overflow, null deref, etc.) | `-fsanitize=undefined` |
| ThreadSanitizer (TSan) | Data races in multi-threaded programs | `-fsanitize=thread` |
| MemorySanitizer (MSan) | Use of uninitialized memory (Clang-only) | `-fsanitize=memory` |

> **Note**: ASan and TSan are mutually exclusive — you cannot combine them in the same build.

---

## AddressSanitizer (ASan)

See [references/asan.md](references/asan.md) for full details.

### Quick Use

```bash
# Compile with ASan
gcc -fsanitize=address -g -O1 -o program program.c

# Run — reports memory errors at runtime
./program
```

### What ASan Detects

- Heap buffer overflow (read/write)
- Stack buffer overflow (read/write)
- Global buffer overflow (read/write)
- Use-after-free (dangling pointer dereference)
- Double-free
- Stack-use-after-return (requires `-O1` or higher, `-fno-stack-protector`)
- Initialization order bugs (with `-fsanitize-address-use-after-return`)

### ASan + GDB Debugging

```bash
# Compile with ASan and debug symbols
gcc -fsanitize=address -g -O1 -fno-stack-protector -o program program.c

# Attach GDB
gdb ./program
# (gdb) run
# When ASan triggers: (gdb) bt 10
```

---

## LeakSanitizer (LSan)

LSan is integrated into ASan builds (enabled by default). Standalone use is rare.

```bash
# LSan standalone (no ASan)
gcc -fsanitize=leak -g -O1 -o program program.c

# LSan is also included when using -fsanitize=address
gcc -fsanitize=address -g -O1 -o program program.c
# lsan_context will appear in the leak report
```

---

## UndefinedBehaviorSanitizer (UBSan)

```bash
# Compile with UBSan
gcc -fsanitize=undefined -g -O1 -o program program.c
./program
```

### Common UBSan Checks

| Check | Flag | Description |
|-------|------|-------------|
| All | `-fsanitize=undefined` | All undefined behavior checks |
| Integer overflow | `-fsanitize=signed-integer-overflow` | Signed integer overflow |
| Null dereference | `-fsanitize=null` | Null pointer dereference |
| Alignment | `-fsanitize=alignment` | Memory alignment violations |
| Shift overflow | `-fsanitize=shift` | Shift amount overflow |
| Unreachable | `-fsanitize=unreachable` | Executing unreachable code |
| vptr | `-fsanitize=vptr` | Invalid C++ object pointer casts |

### ASan + UBSan Combined

```bash
# Combined — but note: cannot combine with TSan
gcc -fsanitize=address,undefined -g -O1 -fno-common -o program program.c
```

---

## ThreadSanitizer (TSan)

> ⚠️ TSan is **mutually exclusive** with ASan. Cannot use both in same build.

```bash
# Compile with TSan (no ASan!)
gcc -fsanitize=thread -g -O1 -o program program.c
./program
```

### What TSan Detects

- Data races (two threads access same memory, at least one write)
- Use of unlocked mutexes
- Incorrect lock ordering
- Thread leaks

### TSan + GDB Debugging

```bash
# Compile with TSan
gcc -fsanitize=thread -g -O1 -o program program.c

# Run directly or attach GDB
gdb ./program
# (gdb) run
# When TSan reports: (gdb) bt 20
```

---

## Common Compiler Flags

| Flag | Purpose |
|------|---------|
| `-fsanitize=address` | Enable AddressSanitizer |
| `-fsanitize=leak` | Enable LeakSanitizer |
| `-fsanitize=undefined` | Enable UndefinedBehaviorSanitizer |
| `-fsanitize=thread` | Enable ThreadSanitizer (mutually exclusive with ASan) |
| `-g` | Debug symbols (required for readable stack traces) |
| `-O1` or higher | Optimization level (ASan needs at least `-O1`) |
| `-fno-stack-protector` | Disable stack canaries (for cleaner ASan stack traces) |
| `-fno-common` | Disable common symbol merging (avoids masking ASan reports) |
| `-fsanitize-address-use-after-return` | Detect stack-use-after-return (experimental) |

---

## Typical Output Examples

### ASan Output

```
==31854== ERROR: AddressSanitizer: heap-buffer-overflow on address 0x60200000003c
    #0 0x401286 in malloc_allocated_pages /src/libcollector/././util_linux.cpp:7
    #1 0x4013a2 in allocate_heap /src/libcollector/././util_linux.cpp:18
    #2 0x4014c7 in main /src/libcollector/./main.cpp:27
    #3 0x7feabc9d0822 in __libc_start_main ??:?
```

### UBSan Output

```
prog.cpp:3: runtime error: null pointer passed as argument 2, which is expected to be non-null
Aborted (core dumped)
```

### TSan Output

```
WARNING: ThreadSanitizer: data race on address 0x000000000003
    #0 write_func /src/race.cpp:12
    #1 thread_func /src/race.cpp:24
```

See [references/asan.md](references/asan.md) for full ASan output examples.

---

## Known Limitations

- ASan and TSan are **mutually exclusive**
- ASan has ~2x memory overhead and ~2x slowdown
- TSan has ~5-15x slowdown and significant memory overhead
- Custom allocators may conflict with ASan; use `LD_PRELOAD` instead
- ASan may not detect all forms of stack buffer overflow (use with `-fsanitize=stack`)
- LeakSanitizer in ASan builds reports reachable leaks by default in newer versions
- ASan suppressions (`suppressions` file) may hide real bugs
- UBSan `signed-integer-overflow` check may conflict with intentional wrap-around (use `-fwrapv`)

See [references/asan.md](references/asan.md) for full details.

---

## References

- [asan.md](references/asan.md) — AddressSanitizer full reference
- [lsan.md](references/lsan.md) — LeakSanitizer full reference
- [ubsan.md](references/ubsan.md) — UndefinedBehaviorSanitizer full reference
- [tsan.md](references/tsan.md) — ThreadSanitizer full reference
- [msan.md](references/msan.md) — MemorySanitizer full reference
- [LSan Documentation](https://clang.llvm.org/docs/LeakSanitizer.html)
- [MSan Documentation](https://clang.llvm.org/docs/MemorySanitizer.html)
- [UBSan Documentation](https://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html)
- [TSan Documentation](https://clang.llvm.org/docs/ThreadSanitizer.html)

---

## Quick Reference

| Sanitizer | Compile Command | Detects |
|-----------|----------------|---------|
| **ASan** | `gcc -fsanitize=address -g -O1 -o prog prog.c` | Use-after-free, heap/stack/global overflow, double-free |
| **LSan** | `gcc -fsanitize=leak -g -O1 -o prog prog.c` | Memory leaks (standalone) |
| **MSan** | `clang -fsanitize=memory -g -O1 -o prog prog.c` | Uninitialized memory reads (Clang-only) |
| **UBSan** | `gcc -fsanitize=undefined -g -O1 -o prog prog.c` | Null deref, int overflow, alignment, shift overflow |
| **TSan** | `gcc -fsanitize=thread -g -O1 -o prog prog.c` | Data races in multi-threaded programs |

### Combined Builds

```bash
# ASan + UBSan (cannot combine with TSan)
gcc -fsanitize=address,undefined -g -O1 -fno-common -o prog prog.c

# LSan with ASan (LSan is auto-enabled in ASan builds)
gcc -fsanitize=address -g -O1 -o prog prog.c
```