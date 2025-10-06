    .text
_start:
    jal     ra, main           # jump to main
halt:
    li      a7, 10
    ecall                      # if main returns, exit
clz_branchless:             # uint32_t clz_branchless(uint32_t x)
    li      t0, 32          # n = 32
    mv      t1, a0          # t1 = x
    srli    t2, t1, 16      # y = x >> 16
    sltu    t3, x0, t2      # b = (y!=0) ? 1 : 0
    slli    t4, t3, 4       # s = b*16
    srl     t1, t1, t4      # x >>= s
    sub     t0, t0, t4      # n -= s
    srli    t2, t1, 8
    sltu    t3, x0, t2
    slli    t4, t3, 3       # s = b*8
    srl     t1, t1, t4
    sub     t0, t0, t4
    srli    t2, t1, 4
    sltu    t3, x0, t2
    slli    t4, t3, 2       # s = b*4
    srl     t1, t1, t4
    sub     t0, t0, t4
    srli    t2, t1, 2
    sltu    t3, x0, t2
    slli    t4, t3, 1       # s = b*2
    srl     t1, t1, t4
    sub     t0, t0, t4
    srli    t2, t1, 1
    sltu    t3, x0, t2      # b = (x>>1)!=0
    mv      t4, t3          # s = b*1
    srl     t1, t1, t4
    sub     t0, t0, t4
    sub     a0, t0, t1      # return n - x
    ret
uf8_decode:                 # uint32_t uf8_decode(uint8_t fl)
    andi t0, a0, 0x0F        # m = fl & 0x0f
    srli t1, a0, 4           # e = fl >> 4
    li   t2, 1
    sll  t2, t2, t1
    addi t2, t2, -1
    slli t2, t2, 4           # offset = ((1<<e)-1) << 4
    sll  t0, t0, t1
    add  a0, t0, t2          # fl = (m << e) + offset
    ret
uf8_encode: # uint8_t uf8_encode(uint32_t value)
    addi    sp, sp, -16
    sw      ra, 12(sp)               # store ra (because we call clz_branchless)
    sw      s0, 8(sp)                # store callee-saved s0 (exponent)
    sw      s1, 4(sp)                # store callee-saved s1 (overflow)
    sltiu   t0, a0, 16     # if (value < 16) return value;
    beqz    t0, enCode_normalVal          # if (!(value<16)), goto enCode_normalVal
    j       enCode_ret                    # goto enCode_ret
enCode_normalVal:
    mv      t5, a0                   # v = value
    jal     ra, clz_branchless                  # lz = clz_branchless(value)
    li      t0, 31                   
    sub     t1, t0, a0               # msb = 31 - lz
    mv      a0, t5                   # value = v
    li      s0, 0                    # exponent = 0
    li      s1, 0                    # overflow = 0
    sltiu   t2, t1, 5                # if (msb >= 5) { exponent = msb - 4; if (exponent>15) exponent=15; }
    bnez    t2, enCode_find_up       
    addi    s0, t1, -4               
    sltiu   t3, s0, 16
    bnez    t3, enCode_initGuess_overflow_ok   # if (exponent < 16) goto enCode_initGuess_overflow_ok;
    li      s0, 15                   # exponent = 15;
enCode_initGuess_overflow_ok: # overflow = ((1<<e)-1)*16
    li      s1, 0                    # overflow = 0;
    li      t4, 0                    # e = 0;
enCode_overflow_loop:
    bge     t4, s0, enCode_adjust_down  # if (e >= exponent) goto enCode_adjust_down;
    slli    s1, s1, 1
    addi    s1, s1, 16
    addi    t4, t4, 1                   # overflow = (overflow<<1) + 16; e++;
    j       enCode_overflow_loop
enCode_adjust_down:
    beqz    s0, enCode_find_up       # if (exponent==0) goto enCode_find_up;
    sltu    t4, a0, s1               
    beqz    t4, enCode_find_up       # if (value >= overflow) goto enCode_find_up;
    addi    s1, s1, -16              
    srli    s1, s1, 1                # overflow = (overflow - 16) >> 1;
    addi    s0, s0, -1               # exponent--;
    j       enCode_adjust_down
enCode_find_up:
    li      t4, 15                   # upper limit 15
enCode_up_loop:
    bge     s0, t4, enCode_up_done   # if (exponent >= 15) break;
    slli    t1, s1, 1
    addi    t1, t1, 16               # next_overflow = (overflow << 1) + 16;
    sltu    t2, a0, t1               
    bnez    t2, enCode_up_done       # if (value < next_overflow), goto enCode_up_done;
    mv      s1, t1                   # overflow = next_overflow;
    addi    s0, s0, 1                # exponent++;
    j       enCode_up_loop
enCode_up_done:
    sub     t0, a0, s1               # num = value - overflow;
    srl     t0, t0, s0               # mantissa = num >> exponent;
    slli    t1, s0, 4
    andi    t0, t0, 0x0F             # mantissa &= 0x0F;
    or      a0, t1, t0               # a0 = (exponent<<4) | mantissa;
    andi    a0, a0, 0xFF             # mask return value to 8 bits
enCode_ret:
    lw      ra, 12(sp)               # restore ra
    lw      s0, 8(sp)                # restore s0
    lw      s1, 4(sp)                # restore s1
    addi    sp, sp, 16               # deallocate stack frame
    ret                              # return
test: # static bool test(void)
    addi    sp, sp, -40            
    sw      ra, 36(sp)             # save return address
    sw      s0, 32(sp)             # save s0 (previous_value)
    sw      s1, 28(sp)             # save s1 (passed)
    sw      s2, 24(sp)             # save s2 (i)
    sw      s3, 20(sp)             # save s3 (value)
    sw      t0, 16(sp)
    sw      t1, 12(sp)
    sw      t2, 8(sp)
    sw      t3, 4(sp)
    li      s0, -1                 # previous_value = -1
    li      s1, 1                  # passed = true
    li      s2, 0                  # i = 0
t_loop:
    li      t3, 256                # loop upper bound = 256
    bge     s2, t3, t_done         # if (i >= 256) break
    la      a0, msg_test           # "test data: "
    li      a7, 4                  # syscall: print string
    ecall                          # perform syscall
    mv      a0, s2                 # a0 = i
    li      a7, 1                  # syscall: print integer
    ecall                          # perform syscall
    la      a0, msg_nl             # "\n"
    li      a7, 4                  # syscall: print string
    ecall                          # perform syscall
    mv      a0, s2                 # a0 = fl = i
    jal     ra, uf8_decode         # call uf8_decode(fl)
    mv      s3, a0                 # value = return
    mv      a0, s3                 # a0 = value
    jal     ra, uf8_encode         # call uf8_encode(value)
    mv      t1, a0                 # fl2 = return
    bne     s2, t1, t_fail_flag    # if (fl != fl2) goto t_fail_flag
    slt     t2, s0, s3
    bnez    t2, t_set_prev         # if (value <= previous_value) report non-increasing
t_bad_inc:
    la      a0, msg_noninc_a       # print prefix for non-increasing message
    li      a7, 4
    ecall
    mv      a0, s2                 # print fl (as integer)
    li      a7, 1
    ecall
    la      a0, msg_noninc_b       # print " value "
    li      a7, 4
    ecall
    mv      a0, s3                 # print value
    li      a7, 1
    ecall
    la      a0, msg_noninc_c       # print " <= previous_value "
    li      a7, 4
    ecall
    mv      a0, s0                 # print previous_value
    li      a7, 1
    ecall
    la      a0, msg_nl             # newline
    li      a7, 4
    ecall
    li      s1, 0                  # passed = false
    j       t_set_prev             # proceed to update previous_value
t_fail_flag:
    la      a0, msg_mismatch_a     # print mismatch prefix
    li      a7, 4
    ecall
    mv      a0, s2                 # print fl
    li      a7, 1
    ecall
    la      a0, msg_mismatch_b     # print ": produces value "
    li      a7, 4
    ecall
    mv      a0, s3                 # print value
    li      a7, 1
    ecall
    la      a0, msg_mismatch_c     # print " but encodes back to "
    li      a7, 4
    ecall
    mv      a0, t1                 # print fl2
    li      a7, 1
    ecall
    la      a0, msg_nl             # newline
    li      a7, 4
    ecall
    li      s1, 0                  # passed = false
t_set_prev:
    mv      s0, s3                 # previous_value = value
    addi    s2, s2, 1              # i++
    j       t_loop                 # next iteration
t_done:
    mv      a0, s1                 # return value = passed
    lw      ra, 36(sp)             # restore ra
    lw      s0, 32(sp)             # restore s0
    lw      s1, 28(sp)             # restore s1
    lw      s2, 24(sp)             # restore s2
    lw      s3, 20(sp)             # restore s3
    lw      t0, 16(sp)             # restore t0
    lw      t1, 12(sp)             # restore t1
    lw      t2, 8(sp)              # restore t2
    lw      t3, 4(sp)              # restore t3
    addi    sp, sp, 40             # pop stack frame
    ret                            # return to caller
main:
    addi    sp, sp, -16
    sw      ra, 12(sp)
    jal     ra, test
    beqz    a0, print_fail
    la      a0, msg_ok              # print "All tests passed.\n"
    li      a7, 4
    ecall
    j       main_exit
print_fail:
    la      a0, msg_fail
    li      a7, 4
    ecall
main_exit:
    li      a7, 10
    ecall
# data section
    .data
    .align 4
msg_ok:         .asciz "All tests passed.\n"
msg_fail:       .asciz "Failed.\n"
msg_test:       .asciz "test data: "
msg_nl:         .asciz "\n"
msg_mismatch_a: .asciz "mismatch: fl= "
msg_mismatch_b: .asciz " value= "
msg_mismatch_c: .asciz " fl2= "
msg_noninc_a:   .asciz "non-increasing: fl= "
msg_noninc_b:   .asciz " value= "
msg_noninc_c:   .asciz " prev= "