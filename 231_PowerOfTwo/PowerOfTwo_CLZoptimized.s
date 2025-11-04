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
# _start
_start:
    la      s0, test_vals      # s0 = ptr
    lw      s2, num_tests      # s2 = remaining
    la      s4, str_true       # s4 = "true\n"
    la      s5, str_false      # s5 = "false\n"
    li      a7, 4              # print string
main_loop:
    beqz    s2, program_end
    lw      a0, 0(s0)          # a0 = n
    jal     ra, is_power_of_two_clz
    beqz    a0, do_print_false
    mv      a0, s4
    ecall
    j       next_item
do_print_false:
    mv      a0, s5
    ecall
next_item:
    addi    s0, s0, 4
    addi    s2, s2, -1
    j       main_loop
program_end:
    li      a7, 10
    ecall
# is_power_of_two_clz
is_power_of_two_clz:
    beqz    a0, isp_false      # n==0 → false
    mv      t0, a0             # t0 = origin
    li      t1, 0              # t1 = clz count
    mv      t2, a0             # t2 = working x
    # chk 16
    srli    t3, t2, 16
    bnez    t3, clz_c8
    addi    t1, t1, 16
    slli    t2, t2, 16
clz_c8:
    srli    t3, t2, 24
    bnez    t3, clz_c4
    addi    t1, t1, 8
    slli    t2, t2, 8
clz_c4:
    srli    t3, t2, 28
    bnez    t3, clz_c2
    addi    t1, t1, 4
    slli    t2, t2, 4
clz_c2:
    srli    t3, t2, 30
    bnez    t3, clz_c1
    addi    t1, t1, 2
    slli    t2, t2, 2
clz_c1:
    srli    t3, t2, 31
    bnez    t3, clz_cdone
    addi    t1, t1, 1
clz_cdone:
    li      t4, 31
    sub     t4, t4, t1         # t4 = msb_pos
    li      t3, 1
    sll     t3, t3, t4         # t3 = 1 << msb_pos
    beq     t0, t3, isp_true
isp_false:
    li      a0, 0
    ret
isp_true:
    li      a0, 1
    ret
