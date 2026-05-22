# Valgrind Reference

## Overview

Valgrind is a dynamic binary instrumentation framework. Its primary tool, **Memcheck**, detects memory-management problems in x86/Linux programs. Unlike GCC Sanitizers (ASan/LSan/MSan/TSan/UBSan), Valgrind works on **unmodified binaries** — no recompilation with special flags is required, though `-g` is recommended for source-level stack traces.

Valgrind is an interpreter/JIT-based tool: it runs the program on a synthetic CPU, checking every memory access. This makes it significantly slower than hardware-assisted tools (10–50× slowdown), but it works on any ELF binary regardless of how it was compiled.

**Valgrind does not require libasan or any other sanitizer runtime.** The program is compiled normally with `-g` for best results.

---

## Compilation

No special flags required. Just use debug symbols:

```bash
gcc -g -O0 -o myprogram myprogram.c
```

| Flag | Purpose |
|------|---------|
| `-g` | Emit debug symbols (enables source line numbers in Valgrind output) |
| `-O0` | Disable optimizations (makes Valgrind output easier to interpret) |
| `-O2` | Generally fine; Valgrind handles it correctly |

> **Note:** Valgrind works on release builds too (`-O2 -g`). Avoid `-O3` with older Valgrind versions as it may produce spurious warnings.

---

## Basic Valgrind Command

```bash
valgrind [valgrind-options] ./myprogram [program-args]
```

### Essential Options

| Option | Description |
|--------|-------------|
| `--leak-check=full` | Detailed per-leak allocation stack trace |
| `--track-origins=yes` | Track where uninitialized values originate (needed for use-of-uninitialized-memory detection) |
| `--show-leak-kinds={definite,indirect,possible,none}` | Filter leak kinds shown |
| `--errors-for-leak-kinds={definite,indirect,possible,none}` | Treat specific leak kinds as errors (exit code 2) |
| `--error-limit=no` | Don't limit error output |
| `-v` | Verbose (show tool configuration) |
| `-q` | Quiet — suppress statistics summary |

### Recommended Baseline Command

```bash
valgrind --leak-check=full --track-origins=yes --error-limit=no ./myprogram
```

---

## Typical Output

### Example: Use-After-Free

```bash
$ gcc -g -o uaf uaf.c
$ valgrind --leak-check=full --track-origins=yes ./uaf
```

```
==12345== Invalid write of size 4
==12345==    at 0x401286: main (uaf.c:7)
==12345==  Address 0x4a66040 is 0 bytes inside a block of size 16 free'd
==12345==    at 0x4A2F0B3: free (vg_replace_malloc.c:...)
==12345==    by 0x401284: main (uaf.c:6)
```

### Example: Heap Buffer Overflow

```bash
$ gcc -g -o heap_overflow heap_overflow.c
$ valgrind --leak-check=full --track-origins=yes ./heap_overflow
```

```
==12346== Invalid write of size 4
==12346==    at 0x401286: main (heap_overflow.c:6)
==12346==  Address 0x4a66048 is 4 bytes after 16-byte region [0x4a66040,0x4a66050)
```

### Example: Memory Leak

```bash
$ gcc -g -o leak leak.c
$ valgrind --leak-check=full --track-origins=yes ./leak
```

```
==12347== 16 bytes in 1 blocks are definitely lost in loss record 1 of 1
==12347==    at 0x4A2F0B3: malloc (vg_replace_malloc.c:...)
==12347==    by 0x401286: main (leak.c:5)
```

### Summary Block (end of every run)

```
==12345== LEAK SUMMARY:
==12345==    definitely lost: 0 bytes in 0 blocks
==12345==    indirectly lost: 0 bytes in 0 blocks
==12345==      possibly lost: 0 bytes in 0 blocks
==12345==    still reachable: 0 bytes in 0 blocks
==12345==         suppressed: 0 bytes in 0 blocks

==12345== ERROR SUMMARY: 1 error from 1 context (but 0 unique contexts)
```

---

## Valgrind Tool Suite

| Tool | Purpose |
|------|---------|
| **memcheck** | Memory error detection (default) — use-after-free, invalid reads/writes, uninitialized values, leaks |
| **helgrind** | Thread error detection — data races, lock order violations |
| **drd** | Another thread checker, alternative to helgrind |
| **cachegrind** | Cache and branch prediction profiler |
| **callgrind** | Call-graph profiler |
| **massif** | Heap profiler (allocation profiling) |

Select a tool with `--tool=<name>`, e.g. `valgrind --tool=helgrind ./myprogram`.

---

## Common Valgrind Error Types

| Error Type | Meaning |
|------------|---------|
| `Invalid read` | Reading from an invalid memory address (freed, unallocated, out-of-bounds) |
| `Invalid write` | Writing to an invalid memory address |
| `Use of uninitialized memory` | Reading a variable before it was assigned (requires `--track-origins=yes`) |
| `Invalid free` | Double-free or free() on non-heap pointer |
| `Mismatched free/delete` | free() vs delete vs delete[] mismatch |
| `Memory leak` | Allocated memory never freed |

---

## Known Limitations

1. **Slow**: 10–50× performance overhead vs native execution. Not suitable for production or performance-critical paths.
2. **Does not detect stack buffer overflows in optimized code** (`-O1+`): Valgrind tracks each stack frame as a single "stack area." Out-of-bounds writes to a stack array may not be caught when the compiler reuses the stack space.
3. **Global buffer overflow not detected**: Overflows of global arrays (data/BSS segments) are not reported by Memcheck.
4. **Does not understand SIMD/vector instructions**: It runs scalar code correctly but treats vector operations conservatively.
5. **Binary-only instrumentation**: Valgrind instruments at the machine-code level, so it cannot provide the same source-level precision as ASan's `__asan` poison redzones.
6. **Not compatible with statically linked programs that use `vmalloc`** on some architectures.
7. **Exit code**: Valgrind returns exit code 1 on any error. Use `valgrind --error-exitcode=0` to suppress this.
8. **Suppressions**: Third-party library warnings can be suppressed with `--suppressions=file.supp`.