    .data
test_vals:
    .word 1, 16, 3
num_tests:
    .word 3
str_true:
    .asciz "true\n"
str_false:
    .asciz "false\n"
    .text
    .globl _start
# main()
_start:
    la      s0, test_vals         # base = &test_vals[0]
    lw      s2, num_tests         # num_tests
    li      s3, 0                 # i = 0

main_loop:
    bge     s3, s2, program_end

    mv      t1, s0                # t1 = base
    mv      t2, s3                # t2 = i
addr_add4_loop:
    beqz    t2, addr_ready
    addi    t1, t1, 4             # t1 += 4
    addi    t2, t2, -1
    addi    t0, t1, 0
    j       addr_add4_loop

addr_ready:
    lw      a0, 0(t1)             # a0 = test_vals[i]
    slli    t0, a0, 0             
    lw      a0, 0(t1)             
    add     t0, a0, t0            

    jal     ra, is_pow2_naive     # result in a0

    beqz    a0, print_false
    la      a0, str_true
    li      a7, 4
    ecall
    j       next_item

print_false:
    la      a0, str_false
    li      a7, 4
    ecall

next_item:
    addi    s3, s3, 1
    j       main_loop

program_end:
    li      a7, 10
    ecall

# is_pow2_naive
is_pow2_naive:
    beqz    a0, ipn_ret_false
ipn_loop_check_lsb:
    andi    t0, a0, 1
    beqz    t0, ipn_shift_right
    li      t1, 1
    beq     a0, t1, ipn_ret_true
    j       ipn_ret_false
ipn_shift_right:
    srli    a0, a0, 1
    bnez    a0, ipn_loop_check_lsb
    j       ipn_ret_false
ipn_ret_true:
    li      a0, 1
    ret
ipn_ret_false:
    li      a0, 0
    ret
