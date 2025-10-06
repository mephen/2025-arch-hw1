#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

typedef struct {
    uint16_t bits;
} bf16_t;

#define BF16_SIGN_MASK 0x8000U
#define BF16_EXP_MASK  0x7F80U
#define BF16_MANT_MASK 0x007FU
#define BF16_EXP_BIAS  127

#define BF16_NAN()  ((bf16_t) {.bits = 0x7FC0})
#define BF16_ZERO() ((bf16_t) {.bits = 0x0000})

static inline bool bf16_isnan(bf16_t a)
{
    return ((a.bits & BF16_EXP_MASK) == BF16_EXP_MASK) &&
           (a.bits & BF16_MANT_MASK);
}

static inline bool bf16_isinf(bf16_t a)
{
    return ((a.bits & BF16_EXP_MASK) == BF16_EXP_MASK) &&
           !(a.bits & BF16_MANT_MASK);
}

static inline bool bf16_iszero(bf16_t a)
{
    return !(a.bits & 0x7FFF);
}

static inline bf16_t f32_to_bf16(float val)
{
    uint32_t f32bits;
    memcpy(&f32bits, &val, sizeof(float));
    if (((f32bits >> 23) & 0xFF) == 0xFF)
        return (bf16_t) {.bits = (f32bits >> 16) & 0xFFFF};
    f32bits += ((f32bits >> 16) & 1) + 0x7FFF; // round-to-nearest-even
    return (bf16_t) {.bits = f32bits >> 16};
}

static inline float bf16_to_f32(bf16_t val)
{
    uint32_t f32bits = ((uint32_t) val.bits) << 16;
    float result;
    memcpy(&result, &f32bits, sizeof(float));
    return result;
}

// No guard/round/sticky bits, truncation rounding only
static inline bf16_t bf16_add(bf16_t a, bf16_t b)
{
    uint16_t sign_a = (a.bits >> 15) & 1;
    uint16_t sign_b = (b.bits >> 15) & 1;
    int16_t exp_a = ((a.bits >> 7) & 0xFF);
    int16_t exp_b = ((b.bits >> 7) & 0xFF);
    uint16_t mant_a = a.bits & 0x7F;
    uint16_t mant_b = b.bits & 0x7F;

    if (exp_a == 0xFF) {
        if (mant_a)
            return a; // a is NaN	
        if (exp_b == 0xFF)
            // if mant_b != 0 → b is NaN → return NaN
            // if mant_b == 0 → b is Inf
            //     if sign_a == sign_b → same sign infinities → return b
            //     if sign_a != sign_b → +Inf + -Inf → return NaN
            return (mant_b || sign_a == sign_b) ? b : BF16_NAN();
        return a; // a is Inf, b is finite or zero
    }
    if (exp_b == 0xFF)
        return b; // b is NaN or Inf
    if (!exp_a && !mant_a)
        return b;
    if (!exp_b && !mant_b)
        return a;
       
    // Restore the implicit leading 1
    if (exp_a)
        mant_a |= 0x80;
    if (exp_b)
        mant_b |= 0x80;

    // Align exponents and perform integer add/sub on 8-bit mantissas
    int16_t exp_diff = exp_a - exp_b;
    uint16_t result_sign;
    int16_t result_exp;
    uint32_t result_mant;

    if (exp_diff > 0) {        // exp_a > exp_b
        result_exp = exp_a;
        if (exp_diff > 8)      // If exponent gap > 8, b is negligible
            return a;
        mant_b >>= exp_diff;   // Right shift b mantissa for alignment
    } else if (exp_diff < 0) { // exp_a < exp_b
        result_exp = exp_b;
        if (exp_diff < -8)
            return b;
        mant_a >>= -exp_diff;
    } else {                   // Same exponent
        result_exp = exp_a;
    }

    // Same sign addition
    if (sign_a == sign_b) {
        result_sign = sign_a;
        result_mant = (uint32_t) mant_a + mant_b; // up to 9 bits (0..0x1FF)
				
        // Normalize if overflow (carry out to 9th bit)
        if (result_mant & 0x100) {
            result_mant >>= 1;
            if (++result_exp >= 0xFF)
                return (bf16_t) {.bits = (result_sign << 15) | 0x7F80};
        }
    } else { // Different signs → subtraction
        if (mant_a >= mant_b) {
            result_sign = sign_a;
            result_mant = mant_a - mant_b;
        } else {
            result_sign = sign_b;
            result_mant = mant_b - mant_a;
        }

        if (!result_mant)
            return BF16_ZERO();
        while (!(result_mant & 0x80)) { // Normalize: shift left until bit7 = 1
            result_mant <<= 1;
            if (--result_exp <= 0) 
                return BF16_ZERO(); // Skip subnormals (precision loss)
        }
    }

    return (bf16_t) {
        .bits = (result_sign << 15) | ((result_exp & 0xFF) << 7) |
                (result_mant & 0x7F),
    };
}

static inline bf16_t bf16_sub(bf16_t a, bf16_t b)
{
    b.bits ^= BF16_SIGN_MASK; // Negate b
    return bf16_add(a, b);
}

static inline bf16_t bf16_mul(bf16_t a, bf16_t b)
{
    uint16_t sign_a = (a.bits >> 15) & 1;
    uint16_t sign_b = (b.bits >> 15) & 1;
    int16_t exp_a = ((a.bits >> 7) & 0xFF);
    int16_t exp_b = ((b.bits >> 7) & 0xFF);
    uint16_t mant_a = a.bits & 0x7F;
    uint16_t mant_b = b.bits & 0x7F;

    uint16_t result_sign = sign_a ^ sign_b;

    // Special cases
    if (exp_a == 0xFF) {
        if (mant_a) return a;              // a is NaN
        if (!exp_b && !mant_b) return BF16_NAN(); // Inf * 0 = NaN
        return (bf16_t) {.bits = (result_sign << 15) | 0x7F80}; // Inf * finite
    }
    if (exp_b == 0xFF) {
        if (mant_b) return b;
        if (!exp_a && !mant_a) return BF16_NAN();
        return (bf16_t) {.bits = (result_sign << 15) | 0x7F80};
    }
    if ((!exp_a && !mant_a) || (!exp_b && !mant_b))
        return (bf16_t) {.bits = result_sign << 15}; // ±0

    // Normalize mantissas
    int16_t exp_adjust = 0;
    if (!exp_a) {
        while (!(mant_a & 0x80)) {
            mant_a <<= 1;
            exp_adjust--;
        }
        exp_a = 1;
    } else
        mant_a |= 0x80;
    if (!exp_b) {
        while (!(mant_b & 0x80)) {
            mant_b <<= 1;
            exp_adjust--;
        }
        exp_b = 1;
    } else
        mant_b |= 0x80;

    uint32_t result_mant = (uint32_t) mant_a * mant_b;
    int32_t result_exp = (int32_t) exp_a + exp_b - BF16_EXP_BIAS + exp_adjust;

    // Normalize if result ≥ 2.0 (bit15 = 1)
    if (result_mant & 0x8000) {
        result_mant = (result_mant >> 8) & 0x7F;
        result_exp++;
    } else
        result_mant = (result_mant >> 7) & 0x7F;

    // Handle overflow & underflow
    if (result_exp >= 0xFF)
        return (bf16_t) {.bits = (result_sign << 15) | 0x7F80};
    if (result_exp <= 0) {
        if (result_exp < -6)
            return (bf16_t) {.bits = result_sign << 15};
        result_mant >>= (1 - result_exp);
        result_exp = 0;
    }

    return (bf16_t) {.bits = (result_sign << 15) | ((result_exp & 0xFF) << 7) |
                             (result_mant & 0x7F)};
}

static inline bf16_t bf16_div(bf16_t a, bf16_t b)
{
    uint16_t sign_a = (a.bits >> 15) & 1;
    uint16_t sign_b = (b.bits >> 15) & 1;
    int16_t exp_a = ((a.bits >> 7) & 0xFF);
    int16_t exp_b = ((b.bits >> 7) & 0xFF);
    uint16_t mant_a = a.bits & 0x7F;
    uint16_t mant_b = b.bits & 0x7F;

    uint16_t result_sign = sign_a ^ sign_b;

    // Handle special cases
    if (exp_b == 0xFF) {
        if (mant_b) return b;
        if (exp_a == 0xFF && !mant_a) return BF16_NAN(); // Inf/Inf
        return (bf16_t) {.bits = result_sign << 15}; // finite / Inf = 0
    }
    if (!exp_b && !mant_b) {
        if (!exp_a && !mant_a) return BF16_NAN(); // 0/0
        return (bf16_t) {.bits = (result_sign << 15) | 0x7F80}; // /0 = Inf
    }
    if (exp_a == 0xFF) {
        if (mant_a) return a;
        return (bf16_t) {.bits = (result_sign << 15) | 0x7F80};
    }
    if (!exp_a && !mant_a)
        return (bf16_t) {.bits = result_sign << 15};

    if (exp_a) mant_a |= 0x80;
    if (exp_b) mant_b |= 0x80;

    uint32_t dividend = (uint32_t) mant_a << 15;
    uint32_t divisor = mant_b;
    uint32_t quotient = 0;

    // Integer division (bitwise long division)
    for (int i = 0; i < 16; i++) {
        quotient <<= 1;
        if (dividend >= (divisor << (15 - i))) {
            dividend -= (divisor << (15 - i));
            quotient |= 1;
        }
    }

    int32_t result_exp = (int32_t) exp_a - exp_b + BF16_EXP_BIAS;
    if (!exp_a) result_exp--;
    if (!exp_b) result_exp++;

    if (quotient & 0x8000)
        quotient >>= 8;
    else {
        while (!(quotient & 0x8000) && result_exp > 1) {
            quotient <<= 1;
            result_exp--;
        }
        quotient >>= 8;
    }
    quotient &= 0x7F;

    if (result_exp >= 0xFF)
        return (bf16_t) {.bits = (result_sign << 15) | 0x7F80};
    if (result_exp <= 0)
        return (bf16_t) {.bits = result_sign << 15};
    return (bf16_t) {.bits = (result_sign << 15) | ((result_exp & 0xFF) << 7) |
                             (quotient & 0x7F)};
}

static inline bf16_t bf16_sqrt(bf16_t a)
{
    uint16_t sign = (a.bits >> 15) & 1;
    int16_t exp = ((a.bits >> 7) & 0xFF);
    uint16_t mant = a.bits & 0x7F;

    // Handle special cases
    if (exp == 0xFF) {
        if (mant) return a;  // NaN propagation
        if (sign) return BF16_NAN(); // sqrt(-Inf) = NaN
        return a;            // sqrt(+Inf) = +Inf
    }

    // sqrt(0) = 0
    if (!exp && !mant)
        return BF16_ZERO();

    // sqrt of negative number
    if (sign)
        return BF16_NAN();

    // Flush denormals to zero
    if (!exp)
        return BF16_ZERO();

    // new_exp = (old_exp - bias) / 2 + bias
    int32_t e = exp - BF16_EXP_BIAS;
    int32_t new_exp;
    
    uint32_t m = 0x80 | mant;  // Restore implicit 1
    
    if (e & 1) {
        m <<= 1;
        new_exp = ((e - 1) >> 1) + BF16_EXP_BIAS;
    } else {
        new_exp = (e >> 1) + BF16_EXP_BIAS;
    }
    
    uint32_t low = 90;
    uint32_t high = 256;
    uint32_t result = 128;
    
    // Binary search for sqrt(m)
    while (low <= high) {
        uint32_t mid = (low + high) >> 1;
        uint32_t sq = (mid * mid) / 128;
        
        if (sq <= m) {
            result = mid;
            low = mid + 1;
        } else {
            high = mid - 1;
        }
    }
    
    // Normalize to [128, 256)
    if (result >= 256) {
        result >>= 1;
        new_exp++;
    } else if (result < 128) {
        while (result < 128 && new_exp > 1) {
            result <<= 1;
            new_exp--;
        }
    }
    
    uint16_t new_mant = result & 0x7F;
    
    if (new_exp >= 0xFF)
        return (bf16_t) {.bits = 0x7F80};
    if (new_exp <= 0)
        return BF16_ZERO();
    
    return (bf16_t) {.bits = ((new_exp & 0xFF) << 7) | new_mant};
}

int test(){
    int ret = 1;
    
    float in1 = 1.5f;
    float in2 = 2.5f;
    float in3 = 4.0f;
    float out;
    
    bf16_t a = f32_to_bf16(in1);
    bf16_t b = f32_to_bf16(in2);
    out = bf16_to_f32(bf16_add(a, b));
    printf("a = %f, b = %f, a+b = %f\n", in1, in2, out);
    if(out != in1 + in2) ret = 0;

    out = bf16_to_f32(bf16_mul(a, b));
    printf("a = %f, b = %f, a*b = %f\n", in1, in2, out);
    if(out != in1 * in2) ret = 0;

    bf16_t c = f32_to_bf16(in3);
    out = bf16_to_f32(bf16_sqrt(c));
    printf("c = %f, sqrt(c) = %f\n", in3, out);
    if(out != 2.0f) ret = 0;

    return ret;
}

int main()
{
    if(test())
        printf("All tests passed.\n");
    else
        printf("Some tests failed.\n");
    return 0;
}
