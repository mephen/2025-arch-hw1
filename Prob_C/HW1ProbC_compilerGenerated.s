	.file	"HW1ProbC.c"
	.option pic
	.attribute arch, "rv64i2p1_m2p0_a2p1_f2p2_d2p2_c2p0_zicsr2p0_zifencei2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
# GNU C17 (Ubuntu 13.3.0-6ubuntu2~24.04) version 13.3.0 (riscv64-linux-gnu)
#	compiled by GNU C version 13.3.0, GMP version 6.3.0, MPFR version 4.2.1, MPC version 1.3.1, isl version isl-0.26-GMP

# GGC heuristics: --param ggc-min-expand=100 --param ggc-min-heapsize=131072
# options passed: -mabi=lp64d -misa-spec=20191213 -march=rv64imafdc_zicsr_zifencei -O2 -fstack-protector-strong
	.text
	.section	.rodata.str1.8,"aMS",@progbits,1
	.align	3
.LC3:
	.string	"a = %f, b = %f, a+b = %f\n"
	.align	3
.LC5:
	.string	"a = %f, b = %f, a*b = %f\n"
	.align	3
.LC6:
	.string	"c = %f, sqrt(c) = %f\n"
	.text
	.align	1
	.globl	test
	.type	test, @function
test:
.LFB47:
	.cfi_startproc
	addi	sp,sp,-48	#,,
	.cfi_def_cfa_offset 48
	fsd	fs0,24(sp)	#,
	fsd	fs1,16(sp)	#,
	fsd	fs2,8(sp)	#,
	.cfi_offset 40, -24
	.cfi_offset 41, -32
	.cfi_offset 50, -40
# /usr/riscv64-linux-gnu/include/bits/stdio2.h:86:   return __printf_chk (__USE_FORTIFY_LEVEL - 1, __fmt, __va_arg_pack ());
	fld	fs1,.LC2,a5	# tmp158,, tmp211
	fld	fs2,.LC1,a5	# tmp156,, tmp210
	fld	fs0,.LC0,a5	# tmp206,, tmp209
	fmv.x.d	a4,fs0	#, tmp206
	fmv.x.d	a3,fs2	#, tmp156
	fmv.x.d	a2,fs1	#, tmp158
	lla	a1,.LC3	#,
	li	a0,2		#,
# HW1ProbC.c:359: int test(){
	sd	ra,40(sp)	#,
	sd	s0,32(sp)	#,
	.cfi_offset 1, -8
	.cfi_offset 8, -16
# /usr/riscv64-linux-gnu/include/bits/stdio2.h:86:   return __printf_chk (__USE_FORTIFY_LEVEL - 1, __fmt, __va_arg_pack ());
	call	__printf_chk@plt	#
	fmv.x.d	a3,fs2	#, tmp156
	fmv.x.d	a2,fs1	#, tmp158
	ld	a4,.LC4		#,
	lla	a1,.LC5	#,
	li	a0,2		#,
	call	__printf_chk@plt	#
# HW1ProbC.c:323:     uint32_t result = 128;
	li	a4,128		# result,
# HW1ProbC.c:322:     uint32_t high = 256;
	li	a0,256		# high,
# HW1ProbC.c:321:     uint32_t low = 90;
	li	a1,90		# low,
# HW1ProbC.c:330:         if (sq <= m) {
	li	a6,128		# tmp171,
.L4:
# HW1ProbC.c:327:         uint32_t mid = (low + high) >> 1;
	addw	a5,a0,a1	# low, tmp166, high
# HW1ProbC.c:327:         uint32_t mid = (low + high) >> 1;
	srliw	a3,a5,1	#, tmp167, tmp166
# HW1ProbC.c:328:         uint32_t sq = (mid * mid) / 128;
	mulw	a2,a3,a3	# tmp168, tmp167, tmp167
# HW1ProbC.c:327:         uint32_t mid = (low + high) >> 1;
	srliw	a5,a5,1	# mid, tmp166,
# HW1ProbC.c:330:         if (sq <= m) {
	srliw	a2,a2,7	# sq, tmp168,
	bgtu	a2,a6,.L2	#, sq, tmp171,
# HW1ProbC.c:332:             low = mid + 1;
	addiw	a1,a3,1	#, low, tmp167
# HW1ProbC.c:331:             result = mid;
	mv	a4,a5	# result, mid
# HW1ProbC.c:326:     while (low <= high) {
	bgeu	a0,a1,.L4	#, high, low,
.L16:
# HW1ProbC.c:339:     if (result >= 256) {
	li	a5,255		# tmp177,
	bgtu	a4,a5,.L14	#, result, tmp177,
# HW1ProbC.c:342:     } else if (result < 128) {
	li	a5,127		# tmp180,
	li	s0,16384		# _153,
	bgtu	a4,a5,.L6	#, result, tmp180,
	li	a3,128		# new_exp,
# HW1ProbC.c:343:         while (result < 128 && new_exp > 1) {
	li	a2,127		# tmp184,
# HW1ProbC.c:343:         while (result < 128 && new_exp > 1) {
	li	a1,1		# tmp207,
	j	.L8		#
.L7:
	beq	a3,a1,.L15	#, new_exp, tmp207,
.L8:
# HW1ProbC.c:344:             result <<= 1;
	slliw	a4,a4,1	#,, result
# HW1ProbC.c:345:             new_exp--;
	addiw	a3,a3,-1	#,, new_exp
# HW1ProbC.c:343:         while (result < 128 && new_exp > 1) {
	bleu	a4,a2,.L7	#, result, tmp184,
	slliw	s0,a3,7	#, tmp186, tmp182
	slli	s0,s0,48	#, _153, tmp186
	srli	s0,s0,48	#, _153, _153
	j	.L6		#
.L2:
# HW1ProbC.c:334:             high = mid - 1;
	addiw	a0,a3,-1	#, high, tmp167
# HW1ProbC.c:326:     while (low <= high) {
	bgeu	a0,a1,.L4	#, high, low,
	j	.L16		#
.L14:
	li	s0,16384		# _153,
# HW1ProbC.c:340:         result >>= 1;
	srliw	a4,a4,1	# result, result,
	addi	s0,s0,128	#, _153, _153
.L6:
# HW1ProbC.c:349:     uint16_t new_mant = result & 0x7F;
	andi	a4,a4,127	#, tmp190, result
# HW1ProbC.c:47:     uint32_t f32bits = ((uint32_t) val.bits) << 16;
	or	s0,s0,a4	# tmp190, tmp193, _153
# HW1ProbC.c:47:     uint32_t f32bits = ((uint32_t) val.bits) << 16;
	slliw	s0,s0,16	#, tmp194, tmp193
# /usr/riscv64-linux-gnu/include/bits/stdio2.h:86:   return __printf_chk (__USE_FORTIFY_LEVEL - 1, __fmt, __va_arg_pack ());
	fmv.s.x	fa5,s0	# tmp215, tmp194
	fmv.x.d	a2,fs0	#, tmp206
	lla	a1,.LC6	#,
	fcvt.d.s	fa5,fa5	# tmp214, tmp215
	li	a0,2		#,
	fmv.x.d	a3,fa5	#, tmp214
	call	__printf_chk@plt	#
# HW1ProbC.c:383: }
	fmv.s.x	fa4,s0	# tmp216, tmp194
	ld	ra,40(sp)		#,
	.cfi_remember_state
	.cfi_restore 1
	ld	s0,32(sp)		#,
	.cfi_restore 8
# HW1ProbC.c:380:     if(out != 2.0f) ret = 0;
	flw	fa5,.LC7,a5	# tmp200,, tmp213
# HW1ProbC.c:383: }
	fld	fs0,24(sp)	#,
	.cfi_restore 40
	fld	fs1,16(sp)	#,
	.cfi_restore 41
	fld	fs2,8(sp)	#,
	.cfi_restore 50
	feq.s	a0,fa5,fa4	#,, tmp200, tmp216
	addi	sp,sp,48	#,,
	.cfi_def_cfa_offset 0
	jr	ra		#
.L15:
	.cfi_restore_state
	li	s0,128		# _153,
	j	.L6		#
	.cfi_endproc
.LFE47:
	.size	test, .-test
	.section	.rodata.str1.8
	.align	3
.LC8:
	.string	"All tests passed."
	.align	3
.LC9:
	.string	"Some tests failed."
	.section	.text.startup,"ax",@progbits
	.align	1
	.globl	main
	.type	main, @function
main:
.LFB48:
	.cfi_startproc
	addi	sp,sp,-16	#,,
	.cfi_def_cfa_offset 16
	sd	ra,8(sp)	#,
	.cfi_offset 1, -8
# HW1ProbC.c:387:     if(test())
	call	test		#
# HW1ProbC.c:387:     if(test())
	beq	a0,zero,.L18	#, tmp138,,
# /usr/riscv64-linux-gnu/include/bits/stdio2.h:86:   return __printf_chk (__USE_FORTIFY_LEVEL - 1, __fmt, __va_arg_pack ());
	lla	a0,.LC8	#,
	call	puts@plt	#
.L19:
# HW1ProbC.c:392: }
	ld	ra,8(sp)		#,
	.cfi_remember_state
	.cfi_restore 1
	li	a0,0		#,
	addi	sp,sp,16	#,,
	.cfi_def_cfa_offset 0
	jr	ra		#
.L18:
	.cfi_restore_state
# /usr/riscv64-linux-gnu/include/bits/stdio2.h:86:   return __printf_chk (__USE_FORTIFY_LEVEL - 1, __fmt, __va_arg_pack ());
	lla	a0,.LC9	#,
	call	puts@plt	#
	j	.L19		#
	.cfi_endproc
.LFE48:
	.size	main, .-main
	.section	.rodata.cst8,"aM",@progbits,8
	.align	3
.LC0:
	.word	0
	.word	1074790400
	.align	3
.LC1:
	.word	0
	.word	1074003968
	.align	3
.LC2:
	.word	0
	.word	1073217536
	.align	3
.LC4:
	.word	0
	.word	1074659328
	.section	.rodata.cst4,"aM",@progbits,4
	.align	2
.LC7:
	.word	1073741824
	.ident	"GCC: (Ubuntu 13.3.0-6ubuntu2~24.04) 13.3.0"
	.section	.note.GNU-stack,"",@progbits
