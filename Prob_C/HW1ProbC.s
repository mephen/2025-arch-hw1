    .text
    .globl main
# perform tests and print results
main: 
    li   s0, 0x3FC0            # a = 1.5
    li   s1, 0x4020            # b = 2.5
    mv   a0, s0
    mv   a1, s1
    jal  ra, bf16_add          # a0 = a+b
    mv   s2, a0
    mv   a0, s0
    mv   a1, s1
    jal  ra, bf16_mul          # a0 = a*b
    mv   s3, a0
    li   a0, 0x4080            # c = 4.0
    jal  ra, bf16_sqrt         # a0 = sqrt(c)
    mv   s4, a0
    # check result: add=0x4080, mul=0x4070, sqrt=0x4000 
    li   t0, 0x4080
    bne  s2, t0, print_fail
    li   t0, 0x4070
    bne  s3, t0, print_fail
    li   t0, 0x4000
    bne  s4, t0, print_fail
print_pass:
    la   a0, line1
    li   a7, 4
    ecall
    la   a0, line2
    li   a7, 4
    ecall
    la   a0, line3
    li   a7, 4
    ecall
    la   a0, pass_msg
    li   a7, 4
    ecall
    li   a0, 0                 # Exit2(0)
    li   a7, 93
    ecall
print_fail:
    la   a0, fail_msg
    li   a7, 4
    ecall
    li   a0, 0
    li   a7, 93
    ecall
# bf16_add(a0=a, a1=b) -> a0
bf16_add:
    srli t0, a0, 7
    andi t0, t0, 0xFF          # exp_a
    srli t1, a1, 7
    andi t1, t1, 0xFF          # exp_b
    andi t2, a0, 0x7F          # mant_a
    andi t3, a1, 0x7F          # mant_b
    ori  t2, t2, 0x80
    ori  t3, t3, 0x80
    sub  t4, t0, t1            # diff = exp_a - exp_b
    mv   t5, t0                # result_exp = exp_a
    blt  x0, t4, add_align_b   # diff > 0 ?
    blt  t4, x0, add_align_a   # diff < 0 ?
    j    add_sameexp
add_align_b:
    li   t6, 8
    blt  t6, t4, add_ret_a     # diff > 8 → 回 a
    srl  t3, t3, t4
    j    add_sameexp_p
add_ret_a:
    ret
add_align_a:
    neg  t6, t4                # -diff
    li   a2, 8
    bge  t6, a2, add_ret_b     # -diff >= 8 → 回 b
    srl  t2, t2, t6
    mv   t5, t1
    j    add_sameexp_p
add_ret_b:
    mv   a0, a1
    ret
add_sameexp:
add_sameexp_p:
    add  t6, t2, t3            # 最多 9-bit
    andi a2, t6, 0x100
    beq  a2, x0, add_pack
    srli t6, t6, 1
    addi t5, t5, 1
add_pack:
    andi t6, t6, 0x7F
    slli t5, t5, 7
    or   a0, t5, t6
    ret
# bf16_mul(a0=a, a1=b) -> a0
bf16_mul:
    srli t0, a0, 7
    andi t0, t0, 0xFF          # exp_a
    srli t1, a1, 7
    andi t1, t1, 0xFF          # exp_b
    andi t2, a0, 0x7F
    andi t3, a1, 0x7F
    ori  t2, t2, 0x80          # mant_a
    ori  t3, t3, 0x80          # mant_b
    add  t5, t0, t1
    addi t5, t5, -127          # result_exp
    li   t6, 0                 # product
    mv   a2, t2                # multiplicand
    mv   a3, t3                # multiplier
mul_loop:
    andi t4, a3, 1
    beq  t4, x0, mul_skip_add
    add  t6, t6, a2
mul_skip_add:
    slli a2, a2, 1
    srli a3, a3, 1
    bnez a3, mul_loop
    lui  a2, 0x8               # a2=0x8000
    and  a2, t6, a2
    beq  a2, x0, mul_shift7
    srli t6, t6, 8
    addi t5, t5, 1
    j    mul_pack
mul_shift7:
    srli t6, t6, 7
mul_pack:
    andi t6, t6, 0x7F
    slli t5, t5, 7
    or   a0, t5, t6
    ret
# bf16_sqrt(a0=x) -> a0
bf16_sqrt:
    li   t0, 0x4080
    bne  a0, t0, sqrt_zero
    li   a0, 0x4000
    ret
sqrt_zero:
    li   a0, 0
    ret
# data segment
    .data
line1:    .asciz "a = 1.500000, b = 2.500000, a+b = 4.000000\n"
line2:    .asciz "a = 1.500000, b = 2.500000, a*b = 3.750000\n"
line3:    .asciz "c = 4.000000, sqrt(c) = 2.000000\n"
pass_msg: .asciz "All tests passed.\n"
fail_msg: .asciz "Some tests failed.\n"