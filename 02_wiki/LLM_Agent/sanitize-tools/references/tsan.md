# ThreadSanitizer (TSan) Reference

## Overview

TSan detects data races and other thread-safety issues in multi-threaded C/C++ programs. It instruments memory accesses and monitors lock/unlock operations to identify when two threads access the same memory location without proper synchronization.

TSan is mutually exclusive with ASan — they cannot be combined in the same build.

---

## Compile Options

```bash
# Basic TSan build
gcc -fsanitize=thread -g -O1 -o program program.cpp

# TSan with explicit debug info
clang -fsanitize=thread -g -O1 -o program program.cpp

# TSan suppresses (optional)
gcc -fsanitize=thread -g -O1 -fsanitize-ignorelist=tsan_ignore.txt -o program program.cpp
```

### Key Compiler Flags

| Flag | Purpose |
|------|---------|
| `-fsanitize=thread` | Enable ThreadSanitizer |
| `-g` | Debug symbols (required for source-level stack traces) |
| `-O1` or higher | Optimization (TSan requires at least `-O1`) |
| `-fsanitize-ignorelist=<file>` | Suppress specific functions/locations |
| `-fPIC` | Recommended for shared libraries |
| `-pie` | Position-independent executable (recommended) |

### What TSan Detects

- **Data races** — two threads access same variable, at least one write, no lock protecting
- **Use of unlocked mutex** — locking a mutex that is not held
- **Incorrect lock ordering** — potential deadlock from lock ordering violation
- **Thread leaks** — threads not joined/finished before main exits
- **Incorrect destruction order** — synchronization issues in destructor

---

## Typical Output

### Data Race — Basic

```bash
$ cat race.cpp
#include <pthread.h>

int counter = 0;

void* thread_func(void* arg) {
    for (int i = 0; i < 1000000; ++i) {
        counter++;  // data race: both threads write counter without sync
    }
    return nullptr;
}

int main() {
    pthread_t t1, t2;
    pthread_create(&t1, nullptr, thread_func, nullptr);
    pthread_create(&t2, nullptr, thread_func, nullptr);
    pthread_join(t1, nullptr);
    pthread_join(t2, nullptr);
    return 0;
}

$ gcc -fsanitize=thread -g -O1 -pthread -o race race.cpp
$ ./race
```

Output:
```
==================
WARNING: ThreadSanitizer: data race on address 0x000000000003 at 0x000000401a80 by thread T2:
  #0 counter++ race.cpp:9
  #1 thread_func race.cpp:6

Previous write of size 4 at 0x000000000003 by thread T1:
  #0 counter++ race.cpp:9
  #1 thread_func race.cpp:6

Location: counter 0x000000000003
==================
Thread T1 (0x7f9abc001640) created by main thread at:
  #0 pthread_create
  #1 main race.cpp:11

Thread T2 (0x7f9ab8001820) created by main thread at:
  #0 pthread_create
  #1 main race.cpp:12
==================
```

### Data Race — Struct Member

```bash
$ cat race_struct.cpp
#include <pthread.h>
#include <vector>

struct Node {
    int value;
    Node* next;
};

Node* head = nullptr;

void push(int v) {
    Node* n = new Node{v, head};
    head = n;  // race if two threads push simultaneously
}

void* worker(void*) {
    for (int i = 0; i < 1000; ++i) push(i);
    return nullptr;
}

int main() {
    pthread_t t[4];
    for (int i = 0; i < 4; ++i) pthread_create(&t[i], nullptr, worker, nullptr);
    for (int i = 0; i < 4; ++i) pthread_join(t[i], nullptr);
    return 0;
}

$ gcc -fsanitize=thread -g -O1 -pthread -o race_struct race_struct.cpp
$ ./race_struct
```

Output:
```
WARNING: ThreadSanitizer: data race on address 0x00d000000054 at 0x000000401d60 by thread T2:
  #0 push race_struct.cpp:10
  #1 worker race_struct.cpp:19

Previous write of size 8 at 0x00d000000054 by thread T1:
  #0 push race_struct.cpp:10
  #1 worker race_struct.cpp:19

Location: head 0x00d000000054
```

### Use of Unlocked Mutex

```
WARNING: ThreadSanitizer: lock ordering bug:
  Thread T1: mutex M1 -> M2
  Thread T2: mutex M2 -> M1
  This creates a potential deadlock cycle:
    T1@M1 -> T1@M2 -> T2@M2 -> T2@M1
```

### Thread Leak

```
WARNING: ThreadSanitizer: thread leak (2 threads)
  Thread T1 (id=0x7fabc001640) created at:
    #0 pthread_create @ main.cpp:20
  Thread T2 (id=0x7fab8001820) created at:
    #0 pthread_create @ main.cpp:21
```

---

## Environment Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `TSAN_OPTIONS` | — | Colon-separated options |
| `halt_on_error` | 0 | Abort after first error |
| `report_atomics` | 1 | Report atomic operation issues |
| `suppressions` | — | Path to suppression file |
| `ignore_prev_trace` | 0 | Ignore previous trace in dual-source reports |
| `stack_trace_at` | — | Report when specific function is on stack |
| `symbolize` | 1 | Symbolize stack frames |

Example:
```bash
TSAN_OPTIONS=halt_on_error=1:print_stacktrace=1 ./program
```

---

## Known Limitations

1. **Mutually exclusive with ASan**: Cannot use `-fsanitize=address` and `-fsanitize=thread` in the same build. Choose one.
2. **High overhead**: ~5-15x slowdown and significant memory overhead. Not suitable for production.
3. **Does not detect deadlocks**: TSan detects race conditions but cannot detect deadlock loops (circular wait). Use ThreadSanitizer's `detect_deadlocks=1` option or other tools.
4. **Requires proper threading primitives**: Code using low-level atomics or custom synchronization may need `-fsanitize=thread -fsanitize-ignorelist=` for known-safe patterns.
5. **Thread-safe function interception**: TSan intercepts pthread operations; some third-party threading libraries may not be fully intercepted, leading to false negatives.
6. **No detection of logical races**: Only memory-access races are detected; a logically incorrect but race-free program passes TSan.
7. **Compile-time memory**: Very large programs may exhaust memory during compilation with TSan instrumentation.
8. **Debug symbols required**: Without `-g`, stack traces show only hex addresses; always compile with debug info.
9. **Signal handlers**: Data races in signal handlers may not be reliably detected.
10. **Custom allocators**: Programs using custom thread-local allocators may have false positives; use suppression files to filter known-safe patterns.