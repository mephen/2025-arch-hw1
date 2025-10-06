#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

typedef uint8_t uf8;

static inline unsigned clz(uint32_t x) //count leading zeros
{
    //假設一開始有 32 個 leading zeros, 每次測試一半（binary search 的思路）
    int n = 32, c = 16;
    do {
        uint32_t y = x >> c; //把數字右移 c 位
        if (y) {    //檢查高位是否有非零 bit，y!=0 代表最高位落在中線左邊
            n -= c; //至少有 c bit 不是 leading zero
            x = y;  //縮小範圍繼續檢查
        }
        c >>= 1;    //c 除以 2，繼續二分搜尋
    } while (c);
    return n - x;   //最後一輪 x 會縮到 1，n-x 最大 31 (最高位在 bit 0) 最小 0 (最高位在 bit 31)
}

/* Decode uf8 to uint32_t */
uint32_t uf8_decode(uf8 fl)
{
    uint32_t mantissa = fl & 0x0f;
    uint8_t exponent = fl >> 4;
    uint32_t offset = (0x7FFF >> (15 - exponent)) << 4; //(2^e - 1)*16
    return (mantissa << exponent) + offset; //m*2^e + (2^e - 1)*16
}

/* Encode uint32_t to uf8 */
uf8 uf8_encode(uint32_t value)
{
    /* Use CLZ for fast exponent calculation */
    if (value < 16)
        return value;

    /* Find appropriate exponent using CLZ hint */
    int lz = clz(value);
    int msb = 31 - lz;

    /* Start from a good initial guess */
    uint8_t exponent = 0;
    uint32_t overflow = 0;

    if (msb >= 5) {
        exponent = msb - 4; // 經驗公式：exponent ≈ msb - 4
        if (exponent > 15)
            exponent = 15;

        /* Calculate overflow for estimated exponent */
        for (uint8_t e = 0; e < exponent; e++) //overflow是offset，求(2^e - 1)*16
            overflow = (overflow << 1) + 16; 

        /* Adjust if estimate was off：向下修正 (如果估計太大)*/
        while (exponent > 0 && value < overflow) {
            overflow = (overflow - 16) >> 1;
            exponent--;
        }
    }

    /* Find exact exponent：向上修正 (如果估計太小) */
    while (exponent < 15) {
        uint32_t next_overflow = (overflow << 1) + 16;
        if (value < next_overflow)
            break;
        overflow = next_overflow;
        exponent++;
    }

    uint8_t mantissa = (value - overflow) >> exponent;//(value - offset(e))/(2^e)
    return (exponent << 4) | mantissa;
}

/* Test encode/decode round-trip */
static bool test(void)
{
    int32_t previous_value = -1;
    bool passed = true;

    for (int i = 0; i < 256; i++) {
        printf("test data: %d\n",i);
        
        uint8_t fl = i;
        int32_t value = uf8_decode(fl);
        uint8_t fl2 = uf8_encode(value);
        
        if (fl != fl2) {
            printf("%02x: produces value %d but encodes back to %02x\n", fl,
                   value, fl2);
            passed = false;
        }

        if (value <= previous_value) {
            printf("%02x: value %d <= previous_value %d\n", fl, value,
                   previous_value);
            passed = false;
        }

        previous_value = value;
    }

    return passed;
}

int main(void)
{
    if (test()) {
        printf("All tests passed.\n");
        return 0;
    }
    return 1;
}
