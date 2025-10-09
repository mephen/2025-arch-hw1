#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>

/* -------------------- CLZ Optimized Version -------------------- */
/* Use __builtin_clz to find the most significant 1 bit */
bool isPowerOfTwo_clz(uint32_t n) {
    if (n == 0) return false;
    int msb_pos = 31 - __builtin_clz(n);   // position of highest 1 bit
    return n == (1u << msb_pos);           // must equal 1 << position
}

/* -------------------- Test Driver -------------------- */
int main(void) {
    uint32_t test_vals[] = {1, 16, 3};
    int num_tests = sizeof(test_vals) / sizeof(test_vals[0]);

    for (int i = 0; i < num_tests; i++) {
        uint32_t n = test_vals[i];
        bool ret = isPowerOfTwo_clz(n);
        printf("%s\n", ret ? "true" : "false");
    }
    return 0;
}
