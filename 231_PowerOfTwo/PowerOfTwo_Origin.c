#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>

/* -------------------- Naive Loop Version -------------------- */
/* Divide by 2 until n == 1; if any remainder appears, return false */
bool isPowerOfTwo_naive(uint32_t n) {
    if (n == 0) return false;
    while (n % 2 == 0)
        n /= 2;
    return n == 1;
}

/* -------------------- Test Driver -------------------- */
int main(void) {
    uint32_t test_vals[] = {1, 16, 3};
    int num_tests = sizeof(test_vals) / sizeof(test_vals[0]);

    for (int i = 0; i < num_tests; i++) {
        uint32_t n = test_vals[i];
        bool ret = isPowerOfTwo_naive(n);
        printf("%s\n", ret ? "true" : "false");
    }
    return 0;
}
