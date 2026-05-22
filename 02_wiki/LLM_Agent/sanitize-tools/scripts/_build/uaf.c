#include <stdio.h>
#include <stdlib.h>

int main() {
    int *arr = malloc(4 * sizeof(int));
    free(arr);
    arr[0] = 42;   // ASan: use-after-free
    return 0;
}
