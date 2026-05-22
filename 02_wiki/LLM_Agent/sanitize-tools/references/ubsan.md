# UndefinedBehaviorSanitizer (UBSan) Reference

## Overview

UBSan detects undefined behavior (UB) at runtime through compile-time instrumentation. It catches a wide range of issues: integer overflows, null dereferences, alignment violations, shift overflows, and more.

UBSan is included in `-fsanitize=undefined` or can be selectively enabled with individual check flags.

---

## Compile Options

```bash
# Full UBSan (all checks)
gcc -fsanitize=undefined -g -O1 -o program program.cpp

# Selective checks
gcc -fsanitize=null               # null pointer dereference
gcc -fsanitize=alignment          # alignment violations
gcc -fsanitize=shift              # shift overflows
gcc -fsanitize=signed-integer-overflow   # signed int overflow
gcc -fsanitize=unsigned-integer-overflow  # unsigned int overflow (C++20)
gcc -fsanitize=integer-divide-by-zero     # integer divide by zero
gcc -fsanitize=vptr               # invalid C++ object casts
gcc -fsanitize=unreachable        # unreachable code execution
gcc -fsanitize=return             # return without value
gcc -fsanitize=builtin           # unsafe use of compiler builtins

# Combine multiple
gcc -fsanitize=undefined,null,alignment -g -O1 -o program program.cpp

# With ASan (cannot combine with TSan)
gcc -fsanitize=address,undefined -g -O1 -fno-common -o program program.cpp
```

### Key Compiler Flags

| Flag | Purpose |
|------|---------|
| `-fsanitize=undefined` | Enable all undefined behavior checks |
| `-fno-sanitize-recover=all` | Abort on first error (default: continue) |
| `-fno-sanitize-recover=null` | Abort on null deref specifically |
| `-fsanitize-trap=<check>` | Trap instead of call (smaller binary) |
| `-fwrapv` | Treat signed integer overflow as wrapping (disables that check) |
| `-fno-strict-overflow` | Same as `-fwrapv` |

---

## Detects

- **Null pointer dereference** — reading/writing through null
- **Alignment violations** — accessing unaligned memory
- **Signed integer overflow** — e.g. `INT_MAX + 1`
- **Unsigned integer overflow** — (C++20, newer GCC/Clang)
- **Shift overflow** — shifting by negative or >= bit width
- **Integer divide by zero** — compile-time or runtime
- **Return without value** — function declared non-void but reaches end
- **Unreachable code** — code after `std::exit()`, `abort()`, etc.
- **Invalid C++ vptr** — bad dynamic_cast, bad virtual call on object
- **Invalid object pointer cast** — base→derived cast corruption

---

## Typical Output

### Null Dereference

```
prog.cpp:5: runtime error: null pointer passed as argument 2, which is expected to be non-null
/usr/include/stdio.h:80: note: strlen argument 2 is null
SUMMARY: UndefinedBehaviorSanitizer: undefined-behavior prog.cpp:5 in main()
Aborted (core dumped)
```

### Signed Integer Overflow

```
prog.cpp:10: runtime error: signed integer overflow: 2147483647 + 1 cannot be represented in type 'int'
prog.cpp:10: note: run with 'UBSAN_OPTIONS=print_stacktrace=1' to get more info
SUMMARY: UndefinedBehaviorSanitizer: undefined-behavior prog.cpp:10 in main()
Aborted (core dumped)
```

### Alignment

```
prog.cpp:15: runtime error: member access within misaligned address 0x7ffd12345678 for type 'struct S', which requires 8 byte alignment
prog.cpp:15: note: run with 'UBSAN_OPTIONS=print_stacktrace=1' to get more info
SUMMARY: UndefinedBehaviorSanitizer: undefined-behavior prog.cpp:15 in main()
Aborted (core dumped)
```

### Shift Overflow

```
prog.cpp:20: runtime error: shift exponent 40 is too large for 32-bit type 'int'
prog.cpp:20: note: run with 'UBSAN_OPTIONS=print_stacktrace=1' to get more info
SUMMARY: UndefinedBehaviorSanitizer: undefined-behavior prog.cpp:20 in main()
Aborted (core dumped)
```

---

## Environment Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `UBSAN_OPTIONS` | — | Colon-separated options |
| `print_stacktrace` | 0 | Print stack trace on error |
| `halt_on_error` | 0 | Abort after first error |
| `suppressions` | — | Path to suppression file |
| `symbolize` | 1 | Symbolize stack frames |

Example:
```bash
UBSAN_OPTIONS=print_stacktrace=1:halt_on_error=1 ./program
```

---

## Known Limitations

1. **Performance overhead**: ~2-3x slowdown when enabled
2. **Not a security tool**: UBSan detects bugs but does not prevent exploits
3. **`signed-integer-overflow` vs `-fwrapv`**: Code that intentionally wraps must use `-fwrapv` or the check will fire
4. **Cannot combine with TSan**: Like ASan, UBSan is incompatible with ThreadSanitizer in the same build
5. **`-fsanitize=undefined` includes `vptr`**: Requires RTTI (`-frtti`) enabled for C++; may cause issues with no-RTTI codebases
6. **No detection of uninitialized memory**: UBSan does not catch use of uninitialized values (use MSan for that)
7. **Compile-time overhead**: Instrumentation adds compile time, especially with `-fsanitize=undefined`
8. **Stack trace quality**: Without `-g` debug symbols, reports show hex addresses rather than source locations
9. **May not catch all UB**: Some undefined behavior is compiler-version-dependent; UBSan instruments what it can statically detect
10. **May cause false positives in third-party libraries**: Use suppression files (`suppressions=path`) to silence known-false positives