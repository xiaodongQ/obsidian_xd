# MemorySanitizer (MSan) Reference

## Overview

MemorySanitizer (MSan) detects use of uninitialized memory at runtime. It instruments memory reads to ensure all loads originate from initialized memory, catching bugs where variables are read before being written to.

- **Compiler**: Clang ≥ 3.1 (MSan is **Clang-only**, not available in GCC)
- **Supported platforms**: Linux, macOS (Clang-based)
- **Overhead**: ~2x memory, ~2-3x slowdown
- **Requires**: `-O1` or higher; **cannot be combined with ASan or TSan**

---

## Compile Options

### Basic MSan Build

```bash
# MSan requires Clang (not GCC)
clang -fsanitize=memory -g -O1 -o program program.cpp

# With MSan origin tracking (more detail, higher overhead)
clang -fsanitize=memory -g -O1 -fsanitize-memory-track-origins -o program program.cpp
```

### Key Compiler Flags

| Flag | Purpose |
|------|---------|
| `-fsanitize=memory` | Enable MemorySanitizer |
| `-fsanitize-memory-track-origins` | Track origin of uninitialized values (more detail) |
| `-fsanitize-memory-track-origins=2` | Extended origin tracking |
| `-fno-sanitize-recover=memory` | Abort on first error |
| `-fno-init-memory` | Assume memory is uninitialized (stricter) |

### What MSan Detects

- **Use of uninitialized memory** — reading a variable before it is assigned
- **Branching on uninitialized values** — `if (x)` where `x` is uninitialized
- **Uninitialized struct fields** — reading a struct member never written to
- **Uninitialized array elements** — accessing beyond written indices

---

## Typical MSan Output

### Use of Uninitialized Variable

```bash
$ cat msan_uninit.cpp
#include <stdio.h>

int main() {
    int x;
    printf("%d\n", x);  // x is uninitialized
    return 0;
}

$ clang -fsanitize=memory -g -O1 -o msan_uninit msan_uninit.cpp
$ ./msan_uninit
```

Output:
```
==34567== MemorySanitizer: use-of-uninitialized-memory
    #0 0x4a43b7 in main msan_uninit.cpp:6
    #1 0x7f5a6c9d1c82 in __libc_start_main ??:?

SUMMARY: MemorySanitizer: use-of-uninitialized-memory of 4 byte(s)
```

### Use of Uninitialized Variable with Origins

```bash
$ clang -fsanitize=memory -g -O1 -fsanitize-memory-track-origins -o msan_uninit msan_uninit.cpp
$ ./msan_uninit
```

Output:
```
==34567== MemorySanitizer: use-of-uninitialized-value
    #0 0x4a43b7 in main msan_uninit.cpp:6
    #1 0x7f5a6c9d1c82 in __libc_start_main ??:?

Uninitialized value was created by an allocation of 'x' in the stack frame of function 'main'
    #0 0x4a43b7 in main msan_uninit.cpp:5

SUMMARY: MemorySanitizer: use-of-uninitialized-value of 4 byte(s)
```

### Uninitialized Array Element

```bash
$ cat msan_array.cpp
#include <stdio.h>
#include <string.h>

int main() {
    int arr[10];
    // arr[0..9] are all uninitialized
    memset(arr, 0, sizeof(arr));
    // Now all initialized — but what about before?
    printf("%d\n", arr[5]);  // uninitialized before memset
    return 0;
}

$ clang -fsanitize=memory -g -O1 -o msan_array msan_array.cpp
$ ./msan_array
```

Output:
```
==34568== MemorySanitizer: use-of-uninitialized-memory
    #0 0x4a43b7 in main msan_array.cpp:8
    #1 0x7f5a6c9d1c82 in __libc_start_main ??:?

SUMMARY: MemorySanitizer: use-of-uninitialized-memory of 4 byte(s)
```

### Branching on Uninitialized Value

```bash
$ cat msan_branch.cpp
#include <stdio.h>

int main() {
    int condition;
    if (condition) {
        printf("true\n");
    } else {
        printf("false\n");
    }
    return 0;
}

$ clang -fsanitize=memory -g -O1 -o msan_branch msan_branch.cpp
$ ./msan_branch
```

Output:
```
==34569== MemorySanitizer: use-of-uninitialized-value
    #0 0x4a43b7 in main msan_branch.cpp:6
    #1 0x7f5a6c9d1c82 in __libc_start_main ??:?

SUMMARY: MemorySanitizer: use-of-uninitialized-value of 4 byte(s)
```

---

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `MSAN_OPTIONS` | — | Colon-separated options |
| `halt_on_error` | 0 | Abort after first error |
| `track_origins` | 0 | Set to 1 or 2 for origin tracking |
| `print_stats` | 0 | Print memory statistics on exit |
| `log_path` | stderr | Log to file |
| `suppressions` | — | Path to suppression file |
| `symbolize` | 1 | Symbolize stack frames |

Example:
```bash
MSAN_OPTIONS=halt_on_error=1:track_origins=2:symbolize=1 ./program
```

---

## Known Limitations

1. **Clang-only**: MSan is not available in GCC. You must use Clang (`clang` not `gcc`) to compile with `-fsanitize=memory`.
2. **Incompatible with ASan and TSan**: MSan cannot be combined with AddressSanitizer or ThreadSanitizer in the same build. Use one sanitizer at a time.
3. **Cannot link with unrebuilt libraries**: All code must be compiled with MSan. Libraries pre-built without MSan will inject uninitialized memory markers, causing false positives.
4. **High memory overhead**: ~2x memory overhead due to shadow memory tracking of initialization state for every byte.
5. **Slowdown**: ~2-3x runtime slowdown. Not suitable for production builds.
6. **Origin tracking overhead**: `-fsanitize-memory-track-origins` adds significant overhead; use only when needed for debugging.
7. **Platform limitations**: MSan is primarily available on Linux and macOS with Clang. Some features may not work on all architectures.
8. **Custom allocators**: Programs using custom allocators that bypass `malloc`/`free` will cause false positives or miss real uninitialized reads.
9. **Bit-level uninitialized detection**: MSan tracks initialization at the byte level. A partially initialized value (e.g., first byte of an int written, rest uninitialized) may not trigger on every access pattern.
10. **No recovery mode**: Unlike ASan, MSan does not have a `continue` mode after error detection in most configurations; configure `halt_on_error` explicitly for behavior control.
11. **Static initialization**: Global/static variables with constructors may be reported as uninitialized if MSan cannot track the constructor's side effects correctly.