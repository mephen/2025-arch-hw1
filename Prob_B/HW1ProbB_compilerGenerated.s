	.file	"HW1.c"
	.option pic
	.attribute arch, "rv64i2p1_m2p0_a2p1_f2p2_d2p2_c2p0_zicsr2p0_zifencei2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.align	1
	.type	uf8_encode.part.0, @function
uf8_encode.part.0:
.LFB44:
	.cfi_startproc
	mv	a3,a0
	li	a4,5
	li	a5,16
	li	a1,32
.L3:
	srlw	a2,a3,a5
	addiw	a4,a4,-1
	beq	a2,zero,.L2
	subw	a1,a1,a5
	mv	a3,a2
.L2:
	srai	a5,a5,1
	bne	a4,zero,.L3
	subw	a3,a3,a1
	addiw	a3,a3,31
	li	a5,4
	ble	a3,a5,.L14
	andi	a3,a3,0xff
	addiw	a2,a3,-4
	andi	a2,a2,0xff
	li	a1,15
	andi	a5,a2,0xff
	bgtu	a2,a1,.L30
	li	a1,4
	beq	a3,a1,.L15
.L34:
	li	a3,0
.L7:
	addiw	a3,a3,1
	slliw	a4,a4,1
	andi	a3,a3,0xff
	addiw	a4,a4,16
	bgtu	a5,a3,.L7
	bgtu	a4,a0,.L10
	j	.L8
.L31:
	bleu	a4,a0,.L6
.L10:
	addiw	a5,a5,-1
	addiw	a4,a4,-16
	andi	a5,a5,0xff
	srliw	a4,a4,1
	bne	a5,zero,.L31
.L6:
	slliw	a3,a4,1
	addiw	a3,a3,16
	j	.L4
.L14:
	li	a3,16
	li	a5,0
.L4:
	li	a2,15
	bgeu	a0,a3,.L12
	j	.L32
.L13:
	bltu	a0,a4,.L33
	mv	a3,a4
.L12:
	addiw	a5,a5,1
	slliw	a4,a3,1
	andi	a5,a5,0xff
	addiw	a4,a4,16
	bne	a5,a2,.L13
.L28:
	li	a2,-16
	li	a5,15
.L11:
	subw	a0,a0,a3
	srlw	a5,a0,a5
	or	a0,a2,a5
	andi	a0,a0,0xff
	ret
.L30:
	li	a1,4
	li	a5,15
	bne	a3,a1,.L34
	j	.L15
.L33:
	slliw	a2,a5,4
	subw	a0,a0,a3
	sext.w	a5,a5
	slliw	a2,a2,24
	sraiw	a2,a2,24
	srlw	a5,a0,a5
	or	a0,a2,a5
	andi	a0,a0,0xff
	ret
.L15:
	li	a5,0
	j	.L6
.L8:
	li	a3,14
	bleu	a2,a3,.L6
	mv	a3,a4
	j	.L28
.L32:
	slliw	a2,a5,4
	slliw	a2,a2,24
	sext.w	a5,a5
	sraiw	a2,a2,24
	mv	a3,a4
	j	.L11
	.cfi_endproc
.LFE44:
	.size	uf8_encode.part.0, .-uf8_encode.part.0
	.align	1
	.globl	uf8_decode
	.type	uf8_decode, @function
uf8_decode:
.LFB40:
	.cfi_startproc
	srli	a5,a0,4
	li	a4,15
	subw	a4,a4,a5
	mv	a3,a5
	li	a5,32768
	addiw	a5,a5,-1
	sraw	a5,a5,a4
	andi	a0,a0,15
	slliw	a5,a5,4
	sllw	a0,a0,a3
	addw	a0,a5,a0
	ret
	.cfi_endproc
.LFE40:
	.size	uf8_decode, .-uf8_decode
	.align	1
	.globl	uf8_encode
	.type	uf8_encode, @function
uf8_encode:
.LFB41:
	.cfi_startproc
	li	a4,15
	bleu	a0,a4,.L40
	tail	uf8_encode.part.0
.L40:
	andi	a0,a0,0xff
	ret
	.cfi_endproc
.LFE41:
	.size	uf8_encode, .-uf8_encode
	.section	.rodata.str1.8,"aMS",@progbits,1
	.align	3
.LC0:
	.string	"test data: %d\n"
	.align	3
.LC1:
	.string	"%02x: produces value %d but encodes back to %02x\n"
	.align	3
.LC2:
	.string	"%02x: value %d <= previous_value %d\n"
	.align	3
.LC3:
	.string	"All tests passed."
	.section	.text.startup,"ax",@progbits
	.align	1
	.globl	main
	.type	main, @function
main:
.LFB43:
	.cfi_startproc
	addi	sp,sp,-112
	.cfi_def_cfa_offset 112
	sd	s0,96(sp)
	.cfi_offset 8, -16
	li	s0,32768
	sd	s1,88(sp)
	sd	s2,80(sp)
	sd	s3,72(sp)
	sd	s4,64(sp)
	sd	s5,56(sp)
	sd	s6,48(sp)
	sd	s7,40(sp)
	sd	s8,32(sp)
	sd	s9,24(sp)
	sd	ra,104(sp)
	sd	s10,16(sp)
	sd	s11,8(sp)
	.cfi_offset 9, -24
	.cfi_offset 18, -32
	.cfi_offset 19, -40
	.cfi_offset 20, -48
	.cfi_offset 21, -56
	.cfi_offset 22, -64
	.cfi_offset 23, -72
	.cfi_offset 24, -80
	.cfi_offset 25, -88
	.cfi_offset 1, -8
	.cfi_offset 26, -96
	.cfi_offset 27, -104
	li	s6,1
	li	s8,-1
	li	s9,0
	lla	s5,.LC0
	li	s4,15
	addiw	s0,s0,-1
	li	s3,15
	lla	s2,.LC1
	lla	s7,.LC2
	li	s1,256
.L46:
	mv	a2,s9
	mv	a1,s5
	li	a0,2
	call	__printf_chk@plt
	andi	s11,s9,0xff
	srliw	a5,s11,4
	subw	a5,s4,a5
	sraw	a5,s0,a5
	srli	a3,s11,4
	andi	a4,s11,15
	slliw	a5,a5,4
	sllw	a4,a4,a3
	mv	s10,s8
	addw	s8,a5,a4
	mv	a0,s8
	andi	a5,s8,0xff
	bleu	s8,s3,.L43
	call	uf8_encode.part.0
	mv	a5,a0
.L43:
	sext.w	a4,a5
	mv	a3,s8
	mv	a2,s9
	mv	a1,s2
	li	a0,2
	beq	a5,s11,.L44
	call	__printf_chk@plt
	li	s6,0
.L44:
	bge	s10,s8,.L52
.L45:
	addiw	s9,s9,1
	bne	s9,s1,.L46
	li	a0,1
	bne	s6,zero,.L53
.L47:
	ld	ra,104(sp)
	.cfi_remember_state
	.cfi_restore 1
	ld	s0,96(sp)
	.cfi_restore 8
	ld	s1,88(sp)
	.cfi_restore 9
	ld	s2,80(sp)
	.cfi_restore 18
	ld	s3,72(sp)
	.cfi_restore 19
	ld	s4,64(sp)
	.cfi_restore 20
	ld	s5,56(sp)
	.cfi_restore 21
	ld	s6,48(sp)
	.cfi_restore 22
	ld	s7,40(sp)
	.cfi_restore 23
	ld	s8,32(sp)
	.cfi_restore 24
	ld	s9,24(sp)
	.cfi_restore 25
	ld	s10,16(sp)
	.cfi_restore 26
	ld	s11,8(sp)
	.cfi_restore 27
	addi	sp,sp,112
	.cfi_def_cfa_offset 0
	jr	ra
.L52:
	.cfi_restore_state
	mv	a4,s10
	mv	a3,s8
	mv	a2,s9
	mv	a1,s7
	li	a0,2
	call	__printf_chk@plt
	li	s6,0
	j	.L45
.L53:
	lla	a0,.LC3
	call	puts@plt
	li	a0,0
	j	.L47
	.cfi_endproc
.LFE43:
	.size	main, .-main
	.ident	"GCC: (Ubuntu 13.3.0-6ubuntu2~24.04) 13.3.0"
	.section	.note.GNU-stack,"",@progbits