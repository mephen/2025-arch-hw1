	.file	"HW1ProbC.c"
	.option pic
	.attribute arch, "rv64i2p1_m2p0_a2p1_f2p2_d2p2_c2p0_zicsr2p0_zifencei2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
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
	addi	sp,sp,-48
	.cfi_def_cfa_offset 48
	fsd	fs0,24(sp)
	fsd	fs1,16(sp)
	fsd	fs2,8(sp)
	.cfi_offset 40, -24
	.cfi_offset 41, -32
	.cfi_offset 50, -40
	fld	fs1,.LC2,a5
	fld	fs2,.LC1,a5
	fld	fs0,.LC0,a5
	fmv.x.d	a4,fs0
	fmv.x.d	a3,fs2
	fmv.x.d	a2,fs1
	lla	a1,.LC3
	li	a0,2
	sd	ra,40(sp)
	sd	s0,32(sp)
	.cfi_offset 1, -8
	.cfi_offset 8, -16
	call	__printf_chk@plt
	fmv.x.d	a3,fs2
	fmv.x.d	a2,fs1
	ld	a4,.LC4
	lla	a1,.LC5
	li	a0,2
	call	__printf_chk@plt
	li	a4,128
	li	a0,256
	li	a1,90
	li	a6,128
.L4:
	addw	a5,a0,a1
	srliw	a3,a5,1
	mulw	a2,a3,a3
	srliw	a5,a5,1
	srliw	a2,a2,7
	bgtu	a2,a6,.L2
	addiw	a1,a3,1
	mv	a4,a5
	bgeu	a0,a1,.L4
.L16:
	li	a5,255
	bgtu	a4,a5,.L14
	li	a5,127
	li	s0,16384
	bgtu	a4,a5,.L6
	li	a3,128
	li	a2,127
	li	a1,1
	j	.L8
.L7:
	beq	a3,a1,.L15
.L8:
	slliw	a4,a4,1
	addiw	a3,a3,-1
	bleu	a4,a2,.L7
	slliw	s0,a3,7
	slli	s0,s0,48
	srli	s0,s0,48
	j	.L6
.L2:
	addiw	a0,a3,-1
	bgeu	a0,a1,.L4
	j	.L16
.L14:
	li	s0,16384
	srliw	a4,a4,1
	addi	s0,s0,128
.L6:
	andi	a4,a4,127
	or	s0,s0,a4
	slliw	s0,s0,16
	fmv.s.x	fa5,s0
	fmv.x.d	a2,fs0
	lla	a1,.LC6
	fcvt.d.s	fa5,fa5
	li	a0,2
	fmv.x.d	a3,fa5
	call	__printf_chk@plt
	fmv.s.x	fa4,s0
	ld	ra,40(sp)
	.cfi_remember_state
	.cfi_restore 1
	ld	s0,32(sp)
	.cfi_restore 8
	flw	fa5,.LC7,a5
	fld	fs0,24(sp)
	.cfi_restore 40
	fld	fs1,16(sp)
	.cfi_restore 41
	fld	fs2,8(sp)
	.cfi_restore 50
	feq.s	a0,fa5,fa4
	addi	sp,sp,48
	.cfi_def_cfa_offset 0
	jr	ra
.L15:
	.cfi_restore_state
	li	s0,128
	j	.L6
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
	addi	sp,sp,-16
	.cfi_def_cfa_offset 16
	sd	ra,8(sp)
	.cfi_offset 1, -8
	call	test
	beq	a0,zero,.L18
	lla	a0,.LC8
	call	puts@plt
.L19:
	ld	ra,8(sp)
	.cfi_remember_state
	.cfi_restore 1
	li	a0,0
	addi	sp,sp,16
	.cfi_def_cfa_offset 0
	jr	ra
.L18:
	.cfi_restore_state
	lla	a0,.LC9
	call	puts@plt
	j	.L19
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