/*
 *  TOPPERS/ASP Kernel
 *      Toyohashi Open Platform for Embedded Real-Time Systems/
 *      Advanced Standard Profile Kernel
 *
 *  Copyright (C) 2000-2003 by Embedded and Real-Time Systems Laboratory
 *                              Toyohashi Univ. of Technology, JAPAN
 *  Copyright (C) 2005-2010 by Embedded and Real-Time Systems Laboratory
 *              Graduate School of Information Science, Nagoya Univ., JAPAN
 *
 *  ��L���쌠�҂́C�ȉ���(1)�`(4)�̏����𖞂����ꍇ�Ɍ���C�{�\�t�g�E�F
 *  �A�i�{�\�t�g�E�F�A�����ς������̂��܂ށD�ȉ������j���g�p�E�����E��
 *  �ρE�Ĕz�z�i�ȉ��C���p�ƌĂԁj���邱�Ƃ𖳏��ŋ�������D
 *  (1) �{�\�t�g�E�F�A���\�[�X�R�[�h�̌`�ŗ��p����ꍇ�ɂ́C��L�̒���
 *      ���\���C���̗��p��������щ��L�̖��ۏ؋K�肪�C���̂܂܂̌`�Ń\�[
 *      �X�R�[�h���Ɋ܂܂�Ă��邱�ƁD
 *  (2) �{�\�t�g�E�F�A���C���C�u�����`���ȂǁC���̃\�t�g�E�F�A�J���Ɏg
 *      �p�ł���`�ōĔz�z����ꍇ�ɂ́C�Ĕz�z�ɔ����h�L�������g�i���p
 *      �҃}�j���A���Ȃǁj�ɁC��L�̒��쌠�\���C���̗��p��������щ��L
 *      �̖��ۏ؋K����f�ڂ��邱�ƁD
 *  (3) �{�\�t�g�E�F�A���C�@��ɑg�ݍ��ނȂǁC���̃\�t�g�E�F�A�J���Ɏg
 *      �p�ł��Ȃ��`�ōĔz�z����ꍇ�ɂ́C���̂����ꂩ�̏����𖞂�����
 *      �ƁD
 *    (a) �Ĕz�z�ɔ����h�L�������g�i���p�҃}�j���A���Ȃǁj�ɁC��L�̒�
 *        �쌠�\���C���̗��p��������щ��L�̖��ۏ؋K����f�ڂ��邱�ƁD
 *    (b) �Ĕz�z�̌`�Ԃ��C�ʂɒ�߂���@�ɂ���āCTOPPERS�v���W�F�N�g��
 *        �񍐂��邱�ƁD
 *  (4) �{�\�t�g�E�F�A�̗��p�ɂ�蒼�ړI�܂��͊ԐړI�ɐ����邢���Ȃ鑹
 *      �Q������C��L���쌠�҂����TOPPERS�v���W�F�N�g��Ɛӂ��邱�ƁD
 *      �܂��C�{�\�t�g�E�F�A�̃��[�U�܂��̓G���h���[�U����̂����Ȃ闝
 *      �R�Ɋ�Â�����������C��L���쌠�҂����TOPPERS�v���W�F�N�g��
 *      �Ɛӂ��邱�ƁD
 *
 *  �{�\�t�g�E�F�A�́C���ۏ؂Œ񋟂���Ă�����̂ł���D��L���쌠�҂�
 *  ���TOPPERS�v���W�F�N�g�́C�{�\�t�g�E�F�A�Ɋւ��āC����̎g�p�ړI
 *  �ɑ΂���K�������܂߂āC�����Ȃ�ۏ؂��s��Ȃ��D�܂��C�{�\�t�g�E�F
 *  �A�̗��p�ɂ�蒼�ړI�܂��͊ԐړI�ɐ����������Ȃ鑹�Q�Ɋւ��Ă��C��
 *  �̐ӔC�𕉂�Ȃ��D
 *
 *	2023/7/04 Ryutaro Morita
 */

/*
 *		�v���Z�b�T�ˑ����W���[�� �A�Z���u�����ꕔ�iPIC32MX�p�j
 */

#define	TOPPERS_MACRO_ONLY
#define UINT_C(val)			(val)		/* uint_t�^�̒萔�����}�N�� */
#define ULONG_C(val)		(val)		/* ulong_t�^�̒萔�����}�N�� */
#define CAST(type, val)		(val)		/* �^�L���X�g���s���}�N�� */
#include "kernel_impl.h"
#include "offset.h"

#include "xc.h"
#include <cp0defs.h>

/*
 *  �^�X�N�f�B�X�p�b�`��
 */
	.section .text.dispatch,code,keep
	.globl dispatch
dispatch:
	/*
	 *  ���̃��[�`���́C�^�X�N�R���e�L�X�g�ECPU���b�N��ԁE�f�B�X�p�b�`
	 *  ����ԁE�i���f����́j�����ݗD��x�}�X�N�S������ԂŌĂяo��
	 *  ���D
	 */
	addi	sp, sp, -11*4				/* ���W�X�^��ۑ� */
	sw		s0,  0*4(sp)
	sw		s1,  1*4(sp)
	sw		s2,  2*4(sp)
	sw		s3,  3*4(sp)
	sw		s4,  4*4(sp)
	sw		s5,  5*4(sp)
	sw		s6,  6*4(sp)
	sw		s7,  7*4(sp)
	sw		gp,  8*4(sp)
	sw		fp,  9*4(sp)
	sw		ra, 10*4(sp)

	lw		t0, p_runtsk				/* p_runtsk��t0�� */
	sw		sp, TCB_msp(t0)				/* �^�X�N�X�^�b�N��ۑ� */
	la		t1, dispatch_r
	sw		t1, TCB_pc(t0)				/* ���s�ĊJ�Ԓn��ۑ� */
	j		dispatcher
	nop

dispatch_r:
	lw		ra, 10*4(sp)				/* ���W�X�^�𕜋A */
	lw		fp,  9*4(sp)
	lw		gp,  8*4(sp)
	lw		s7,  7*4(sp)
	lw		s6,  6*4(sp)
	lw		s5,  5*4(sp)
	lw		s4,  4*4(sp)
	lw		s3,  3*4(sp)
	lw		s2,  2*4(sp)
	lw		s1,  1*4(sp)
	lw		s0,  0*4(sp)
	addi    sp, sp, 11*4

	lb		t1, TCB_enatex(t0)
	andi	t1, t1, TCB_enatex_mask
	beq		t1, zero, dispatch_r_1		/* enatex��false�Ȃ烊�^�[�� */
	nop

	lw		t1, TCB_texptn(t0)
	beq		t1, zero, dispatch_r_1		/* texptn��0�Ȃ烊�^�[�� */
	nop

	lw		t1, ipmflg
	bne		t1, zero, call_texrtn		/* ipmflg��true�ł���΃^�X�N��O�������[�`���̌ďo�� */
	nop

dispatch_r_1:
	jr		ra
	nop

/*
 *  �f�B�X�p�b�`���̓���J�n�iprc_support.S�j
 */
	.globl start_dispatch
start_dispatch:
	/*
	 *  ���̃��[�`���́C�J�[�l���N�����ɁC���ׂĂ̊����݂��֎~�������
	 * �i�����݃��b�N��ԂƓ����j�ŌĂяo�����D�܂��C�����݃��[�h�i��
	 *  �^�X�N�R���e�L�X�g�Ɠ����j�ŌĂяo����邱�Ƃ�z�肵�Ă���D
	 *
	 *  prc_initialize�ŁClock_flag��true�ɁCsaved_iipm��IIPM_ENAALL��
	 *  ���������Ă��邽�߁C�J�[�l���Ǘ��O�̊����݂������邱�ƂŁC
	 *  CPU���b�N��ԁE�i���f����́j�����ݗD��x�}�X�N�S������ԂɂȂ�D
	 *  �܂��Cinitialize_task��disdsp��false�ɏ��������Ă��邽�߁C�f�B
	 *  �X�p�b�`����ԂɂȂ��Ă���D
	 */
	sw		zero, int_cnt				/* �}�X�^���[�h�� */
	mfc0	t0, _CP0_STATUS				/*  �J�[�l���Ǘ��O�̊����݂����� */
	li		t1, ~0x00001C00
	and		t0, t0, t1
	li		t1, IIPM_LOCK
	or		t0, t0, t1
	mtc0	t0, _CP0_STATUS
	j		dispatcher_0
	nop

/*
 *  ���݂̃R���e�L�X�g���̂Ăăf�B�X�p�b�`
 */
	.globl exit_and_dispatch
exit_and_dispatch:
	/* �f�B�X�p�b�`���{�́idispatcher�j�� */

/*
 *  �f�B�X�p�b�`���{��
 */
dispatcher:
	/*
	 *  ���̃��[�`���́C�^�X�N�R���e�L�X�g�ECPU���b�N��ԁE�f�B�X�p�b�`
	 *  ����ԁE�i���f����́j�����ݗD��x�}�X�N�S������ԂŌĂяo��
	 *  ���D
	 *
	 *  ���Ȃ킿�C�}�X�^���[�h�Elock_flag��true�Edisdsp��false�Edspflg
	 *  ��true�Esaved_iipm��IIPM_ENAALL�ƂȂ��Ă���D���s�ĊJ�Ԓn�ւ���
	 *  �̏�Ԃ̂܂ܕ��򂷂�D
	 */

#ifdef LOG_DSP_ENTER
	lw		a0, p_runtsk
	jal		log_dsp_enter
	nop

#endif /* LOG_DSP_ENTER */

dispatcher_0:
	lw		t0, p_schedtsk				/* p_schedtsk��p_runtsk�� */
	sw		t0, p_runtsk
	beq		t0, zero, dispatcher_1		/* p_runtsk��NULL�Ȃ�dispatcher_1�� */
	nop

	lw		sp, TCB_msp(t0)				/* �^�X�N�X�^�b�N�𕜋A */

#ifdef LOG_DSP_LEAVE
	addi	sp, sp, -1*4
	sw		t0,  0*4(sp)
	lw		a0, t0
	jal		log_dsp_leave
	nop

	lw		t0,  0*4(sp)
	addi	sp, sp, 1*4
#endif /* LOG_DSP_LEAVE */

	lw		t1, TCB_pc(t0)
	jr		t1
	nop

dispatcher_1:
	/*
	 *  CPU���b�N��Ԃ��������鏀��������D
	 */
	li		t0, 1						/* �����݃��[�h�� */
	sw		t0, int_cnt
	lw		sp, _kernel_istkpt
	mfc0	t0, _CP0_STATUS				/* Status��t0�ɕۑ� */
	sw		zero, lock_flag				/* CPU���b�N������Ԃ� */
	li		t1, ~0x00001C00
	and		t2, t0, t1
	mtc0	t2, _CP0_STATUS

dispatcher_2:
	/*
	 *  �����݂������C�����݃��[�h�ɐ؂芷���āC�����݂�҂D
	 *
	 *  �����Ŋ����݃��[�h�ɐ؂芷����̂́C�����Ŕ������銄���ݏ�����
	 *  �ǂ̃X�^�b�N���g�����Ƃ������̉����ƁC�����݃n���h�����ł̃^
	 *  �X�N�f�B�X�p�b�`�̖h�~�Ƃ���2�̈Ӗ�������D
	 *
	 *  �v���Z�b�T�������ݑ҂��Ɉڍs�����鏈���ƁC�����݋��Ƃ́C�s��
	 *  ���ɍs�Ȃ��K�v������iM68040�ł�stop���߂ŗ����s�Ȃ��̂Ŗ���
	 *  ���j�D�����s���ɍs�Ȃ�Ȃ��ꍇ�C�����݂�����������Ɋ���
	 *  �݂�����C���̒��Ń^�X�N�����s�\��ԂɂȂ�ƁC���s���ׂ��^�X
	 *  �N������ɂ�������炸�v���Z�b�T�������ݑ҂��ɂȂ��Ă��܂��D
	 *
	 *  �����ݑ҂��̊Ԃ́Cp_runtsk��NULL�i��0�j�ɐݒ肵�Ȃ���΂Ȃ��
	 *  ���D���̂悤�ɐݒ肵�Ȃ��ƁC�����݃n���h������iget_tid���Ăяo
	 *  �����ۂ̓��삪�d�l�ɍ��v���Ȃ��Ȃ�D
	 */
	ei
	ehb
	di
	ehb
	lw		t1, reqflg
	beq		t1, zero, dispatcher_2		/* reqflg��false�Ȃ�dispatcher_2�� */
	nop

	mtc0	t0, _CP0_STATUS				/* ���̏�Ԃɖ߂� */
	sw		zero, reqflg				/* reqflg��false�� */
	/*
	 *  CPU���b�N��Ԃɖ߂��D�����ݑ҂��̊ԂɎ��s���������݃n���h���ɂ�
	 *  ��Csaved_iipm��������������\�������邽�߁C���̒l�ɖ߂��K
	 *  �v������Ddispatcher�����s����鎞�́Csaved_iipm��IIPM_ENAALL
	 *  �ƂȂ��Ă��邽�߁C�����ł�saved_iipm��IIPM_ENAALL�i��0�j�ɖ߂�
	 *  �΂悢�D
	 */
	sw		zero, int_cnt				/* �}�X�^���[�h�� */
	sw		zero, saved_iipm			/* saved_iipm��0�ɂ��� */
	li		t0, 1						/* CPU���b�N��Ԃ� */
	sw		t0, lock_flag
	j		dispatcher_0
	nop

/*
 *  �J�[�l���̏I�������̌ďo��
 *
 *  M68040�ł́C���[�h�؊����ɂ��X�^�b�N���؂芷��邽�߁C�����I�ȃX
 *  �^�b�N�؊����͕K�v�Ȃ��D�ŏ����犄���݃��[�h�ł������ꍇ���C������
 *  ���ł悢�D
 */
	.globl call_exit_kernel
call_exit_kernel:
	li		t0, 1						/* �����݃��[�h�� */
	sw		t0, int_cnt
	lw		sp, _kernel_istkpt
	j		exit_kernel					/* �J�[�l���̏I���������Ă� */
	nop

/*
 *  �^�X�N�J�n������
 *
 *  dispatcher����Ăяo����邽�߁CTCB�̃A�h���X��t0�ɓ����Ă���
 */
	.section .text.start_r,code,keep
	.globl start_r
start_r:
	sw		zero, lock_flag				/* CPU���b�N������Ԃ� */
	mfc0	t2, _CP0_STATUS				/*  �J�[�l���Ǘ��O�̊����݂����� */
	li		t1, ~0x00001C00
	and		t2, t2, t1
	mtc0	t2, _CP0_STATUS
	ei
	ehb
	lw		t1, TCB_p_tinib(t0)			/* p_runtsk->p_tinib��t1�� */
	lw		a0, TINIB_exinf(t1)			/* exinf���^�X�N�ւ̈����� */
	la		ra, ext_tsk					/* �^�X�N����̖߂�Ԓn��ext_tsk�ɐݒ� */
	lw		t2, TINIB_task(t1)			/* �^�X�N�̋N���Ԓn��t1�� */
	jr		t2
	nop

/*
 *  �����݃G���g���ia0�ɃG���g���ԍ�������j
 */
	.section .text.inthdr_entry,code,keep
	.globl inthdr_entry
inthdr_entry:
	di
	ehb
	addi	sp, sp, -24*4				/* �X�N���b�`���W�X�^��ۑ� */
	sw		v0,  0*4(sp)
	sw		v1,  1*4(sp)
//	sw		a0,   *4(sp)				/* �G���g���ԍ� */
	sw		a1,  2*4(sp)
	sw		a2,  3*4(sp)
	sw		a3,  4*4(sp)
	sw		t0,  5*4(sp)
	sw		t1,  6*4(sp)
	sw		t2,  7*4(sp)
	sw		t3,  8*4(sp)
	sw		t4,  9*4(sp)
	sw		t5, 10*4(sp)
	sw		t6, 11*4(sp)
	sw		t7, 12*4(sp)
	sw		t8, 13*4(sp)
	sw		t9, 14*4(sp)
	sw		gp, 15*4(sp)
	sw		fp, 16*4(sp)
	sw		ra, 17*4(sp)
	mfhi	t0							/* HI */
	sw		t0, 18*4(sp)
	mflo	t0							/* LO */
	sw		t0, 19*4(sp)
	mfc0	t0, _CP0_STATUS
	li		t1, 0x00000001
	or		t2, t0, t1
	sw		t2, 20*4(sp)				/* Status */
	mfc0	t1, _CP0_CAUSE
	sw		t1, 21*4(sp)				/* Cause */
	srl		t1, t1, 10
	ins		t0, zero, 1, 15
	ins		t0, t1, 10, 3				/* ���d���荞�݋��� */
	mtc0	t0, _CP0_STATUS
	mfc0	t0, _CP0_EPC
	sw		t0, 22*4(sp)				/* EPC */
	mfc0	t0, _CP0_SRSCTL
	sw		t0, 23*4(sp)				/* SRSCtl */

	lw		t0, int_cnt
	addi	t0, t0, 1					/* �����݃��[�h�� */
	sw		t0, int_cnt
	li		t1, 1
	bne		t0 ,t1, interrupt_from_int 	/* ���Z�O��0�łȂ���Α��d������ */
	nop

	sw		sp, int_sp
	lw		sp, _kernel_istkpt
	j		inthdr_entry_0
	nop

interrupt_from_int:
	j		inthdr_entry_0
	nop

inthdr_entry_0:
	ei									/* �����݋���(CPU���b�N�������) */
	ehb
//	move	k0, a0	// Debug
	la		t1, _kernel_int_tbl
//	move	k1, t2	// Debug
	li		t0, 4
	mul		t0, t0, a0
	add		t1, t0, t1
	lw		t0, (t1)

#ifdef LOG_INH_LEAVE
	addi	sp, sp, -1*4
	sw		a0,  0*4(sp)
#endif

#ifdef LOG_INH_ENTER
	addi	sp, sp, -2*4
	sw		a0,  0*4(sp)
	sw		t0,  1*4(sp)
	jal		log_inh_enter				/* log_exc_enter���Ăяo�� */
	nop

	lw		t0,  1*4(sp)
	lw		a0,  0*4(sp)
	addi	sp, sp, 2*4
#endif /* LOG_EXC_ENTER */

	jalr	t0							/* C���[�`���Ăяo�� */
	nop

#ifdef LOG_INH_LEAVE
	lw		a0,  0*4(sp)
	addi	sp, sp, 1*4
	jal		log_inh_leave
	nop

#endif /* LOG_INH_LEAVE */


/*
 *  �����݃n���h���o������
 *
 *  ret_int�́C�����݃n���h������߂�������Ɏ��s���郋�[�`���ŁC
 *  INTHDR_ENTRY�}�N���œW�J���銄���݃n���h���̓��������ŁC�����݃n��
 *  �h������̖߂�Ԓn�ɐݒ肳���D
 */
//	.section .text.ret_int,code,keep
	.globl ret_int
ret_int:
	di
	ehb
	lw		t0, int_cnt					/* �߂�悪�����݃��[�h�Ȃ� */
	addi	t0, -1
	sw		t0, int_cnt
	bne		t0, zero, ret_int_1_d		/*           �����Ƀ��^�[�� */
	nop

	/*
	 *  �J�[�l���Ǘ��̊����݂��֎~����D���̎��_�ł́CCPU���b�N��Ԃ�
	 *  �͂Ȃ�Ȃ��ilock_flag��saved_iipm�͍X�V���Ȃ��j�D
	 *
	 *  reqflg���`�F�b�N����O�Ɋ����݂��֎~����̂́Creqflg���`�F�b�N
	 *  ��������Ɋ����݃n���h�����N������C���̒��Ńf�B�X�p�b�`���v��
	 *  ���ꂽ�ꍇ�ɁC�����Ƀf�B�X�p�b�`����Ȃ��Ƃ�����肪�����邽��
	 *  �ł���D
	 */
	mfc0	t0, _CP0_STATUS				/* �J�[�l���Ǘ��̊����݂��֎~ */
	li		t1, ~0x00001C00
	and		t0, t0, t1
	li		t1, IIPM_LOCK
	or		t0, t0, t1
	mtc0	t0, _CP0_STATUS
	ei
	ehb

	lw		t0, reqflg
	bne		t0, zero, ret_int_2			/* reqflg��true�ł����ret_int_2�� */
	nop

	lw		sp, int_sp					/* �}�X�^���[�h�Ɂi�X�^�b�N�؊����j */

ret_int_1:
	/*
	 *  �����ݏ�������̃��^�[���ɂ��CCPU���b�N������ԂɈڍs����悤
	 *  ��������D�����ݗD��x�}�X�N�́CRTE���߂ɂ�茳�̒l�ɖ߂邽�߁C
	 *  lock_flag��false�ɂ��Ă����΂悢�ilock_flag��false�ɂ���̂́C
	 *  CPU���b�N��Ԃ̂܂܊����݃n���h������߂������̑΍�j�D
	 */
	sw		zero, lock_flag				/* CPU���b�N�����̏��� */

	lw		t0, 23*4(sp)				/* SRSCtl */
	mtc0	t0, _CP0_SRSCTL
	lw		t0, 22*4(sp)				/* EPC */
	mtc0	t0, _CP0_EPC
	lw		t0, 21*4(sp)				/* Cause */
	mtc0	t0, _CP0_CAUSE
	lw		t0, 20*4(sp)				/* Status */
	mtc0	t0, _CP0_STATUS
	lw		t0, 19*4(sp)
	mtlo	t0							/* LO */
	lw		t0, 18*4(sp)
	mthi	t0							/* HI */
	lw		ra, 17*4(sp)				/* �X�N���b�`���W�X�^�𕜋A */
	lw		fp, 16*4(sp)
	lw		gp, 15*4(sp)
	lw		t9, 14*4(sp)
	lw		t8, 13*4(sp)
	lw		t7, 12*4(sp)
	lw		t6, 11*4(sp)
	lw		t5, 10*4(sp)
	lw		t4,  9*4(sp)
	lw		t3,  8*4(sp)
	lw		t2,  7*4(sp)
	lw		t1,  6*4(sp)
	lw		t0,  5*4(sp)
	lw		a3,  4*4(sp)
	lw		a2,  3*4(sp)
	lw		a1,  2*4(sp)
//	lw		a0,   *4(sp)				/* �G���g���ԍ� */
	lw		v1,  1*4(sp)
	lw		v0,  0*4(sp)
	addi	sp, sp, 24*4
//	wrpgpr	sp, sp
	lw		a0, 0(sp)					/* �G���g���ԍ� */
	addi	sp, sp, 4
	eret								/* ������/��O��������̕��A */
	nop

ret_int_1_d:
	j		ret_int_1
	nop

ret_int_2:
	lw		sp, int_sp					/* �}�X�^���[�h�Ɂi�X�^�b�N�؊����j */

ret_int_3:
	/*
	 *  �����ւ́CCPU��O�n���h���̏o��������������򂵂Ă���D
	 *
	 *  �����ł́C�߂�悪�^�X�N�ł���C�X�^�b�N�́C��O�X�^�b�N�t���[
	 *  ���̏�ɃX�N���b�`���W�X�^�݂̂��ۑ����ꂽ��ԂɂȂ��Ă���D��
	 *  ���C�v���Z�b�T�́C�}�X�^���[�h�E�J�[�l���Ǘ��̊����݂��֎~����
	 *  ��ԂƂȂ��Ă���D
	 */
	sw		zero, reqflg				/* reqflg��false�� */

	/*
	 *  CPU���b�N��ԂɈڍs���C�����ݗD��x�}�X�N�������ݏ����O�̒l�ɐ�
	 *	�肷��D�J�[�l���Ǘ��̊����݂͂��łɋ֎~���Ă���̂ŁClock_flag
	 *  ��saved_iipm���X�V����Dsaved_iipm�́C�߂��̊����ݗD��x�}�X
	 *  �N�i�̓����\���j�ɐݒ肷��D
	 *
	 *  ���̎��_��CPU���b�N��ԂƂ���̂́Cdispatcher�֕��򂷂鎞�ƁC
	 *  call_texrtn���Ăяo�����ɁCCPU���b�N��ԂɂȂ��Ă���K�v������
	 *  ���߂ł���D
	 */
	lw		t0,  20*4(sp)				/* �߂���Status��t0�� */
	li		t1, 0x00001C00				/* IPM�����o����saved_iipm�� */
	and		t0, t0, t1
	sw		t0, saved_iipm
	li		t0, 1						/* lock_flag��true�� */
	sw		t0, lock_flag

	/*
	 *  dspflg��false�ł���ꍇ�ƁCp_runtsk��p_schedtsk�������ꍇ�ɂ́C
	 *  �f�B�X�p�b�`���s��Ȃ��D���̃`�F�b�N���K�v�Ȃ̂́C�^�X�N��O��
	 *  �����[�`���̌ďo�����K�v�ȏꍇ�ɁC�f�B�X�p�b�`���K�v�Ȃ��Ă��C
	 *  reqflg��true�ɂ��邽�߂ł���D
	 */

	lw		t0, p_runtsk				/* p_runtsk��t0�� */
	lw		t1, dspflg
	beq		t1, zero, ret_int_4			/* dspflg��false�Ȃ�ret_int_4�� */
	nop
	lw		t1, p_schedtsk				/* p_runtsk��p_schedtsk�������Ȃ� */
	seq		t2, t0, t1
	bne		t2, zero, ret_int_4			/*                    ret_int_4�� */
	nop

	addi	sp, sp, -11*4				/* �c��̃��W�X�^��ۑ� */
	sw		s0,  0*4(sp)
	sw		s1,  1*4(sp)
	sw		s2,  2*4(sp)
	sw		s3,  3*4(sp)
	sw		s4,  4*4(sp)
	sw		s5,  5*4(sp)
	sw		s6,  6*4(sp)
	sw		s7,  7*4(sp)
	sw		gp,  8*4(sp)
	sw		fp,  9*4(sp)
	sw		ra, 10*4(sp)

	sw		sp, TCB_msp(t0)				/* �^�X�N�X�^�b�N��ۑ� */
	la		t1, ret_int_r				/* ���s�ĊJ�Ԓn��ۑ� */
	sw		t1, TCB_pc(t0)
	j		dispatcher
	nop

ret_int_r:
	lw		ra, 10*4(sp)				/* ���W�X�^�𕜋A */
	lw		fp,  9*4(sp)
	lw		gp,  8*4(sp)
	lw		s7,  7*4(sp)
	lw		s6,  6*4(sp)
	lw		s5,  5*4(sp)
	lw		s4,  4*4(sp)
	lw		s3,  3*4(sp)
	lw		s2,  2*4(sp)
	lw		s1,  1*4(sp)
	lw		s0,  0*4(sp)
	addi	sp, sp, 11*4

ret_int_4:
	/*
	 *  enatex��true�ŁCtexptn��0�łȂ��Cipmflg��true�ł���΁C�^�X�N
	 *  ��O�������[�`�����Ăяo���D
	 */
	lb		t1, TCB_enatex(t0)
	andi	t1, t1, TCB_enatex_mask
	beq		t1, zero, ret_int_5			/* enatex��false�Ȃ�ret_int_5�� */
	nop

	lw		t1, TCB_texptn(t0)
	beq		t1, zero, ret_int_5			/* texptn��0�Ȃ�ret_int_5�� */
	nop

	lw		t1, ipmflg
	beq		t1, zero, ret_int_5			/* ipmflg��false�Ȃ�ret_int_5��  */
	nop

	jal		call_texrtn					/* �^�X�N��O�������[�`���̌ďo�� */
	nop

ret_int_5:
	/*
	 *  �����ݏ�������̃��^�[���ɂ��CCPU���b�N������ԂɈڍs�����
	 *  ����������D�����ݗD��x�}�X�N�́CRTE���߂ɂ�茳�̒l�ɖ߂邽
	 *  �߁Clock_flag��false�ɂ��Ă����΂悢�D
	 */
	sw		zero, lock_flag				/* CPU���b�N�����̏��� */

	lw		t0, 23*4(sp)				/* SRSCtl */
	mtc0	t0, _CP0_SRSCTL
	lw		t0, 22*4(sp)				/* EPC */
	mtc0	t0, _CP0_EPC
	lw		t0, 21*4(sp)				/* Cause */
	mtc0	t0, _CP0_CAUSE
	lw		t0, 20*4(sp)				/* Status */
	mtc0	t0, _CP0_STATUS
	lw		t0, 19*4(sp)
	mtlo	t0							/* LO */
	lw		t0, 18*4(sp)
	mthi	t0							/* HI */
	lw		ra, 17*4(sp)				/* �X�N���b�`���W�X�^�𕜋A */
	lw		fp, 16*4(sp)
	lw		gp, 15*4(sp)
	lw		t9, 14*4(sp)
	lw		t8, 13*4(sp)
	lw		t7, 12*4(sp)
	lw		t6, 11*4(sp)
	lw		t5, 10*4(sp)
	lw		t4,  9*4(sp)
	lw		t3,  8*4(sp)
	lw		t2,  7*4(sp)
	lw		t1,  6*4(sp)
	lw		t0,  5*4(sp)
	lw		a3,  4*4(sp)
	lw		a2,  3*4(sp)
	lw		a1,  2*4(sp)
//	lw		a0,   *4(sp)				/* �G���g���ԍ� */
	lw		v1,  1*4(sp)
	lw		v0,  0*4(sp)
	addi	sp, sp, 24*4
//	wrpgpr	sp, sp
	lw		a0, 0(sp)					/* �G���g���ԍ� */
	addi	sp, sp, 4
	eret								/* ������/��O��������̕��A */
	nop

/*
 *  CPU��O�n���h���o��������
 *
 *  exchdr_entry�́CCPU��O�������������Ɏ��s���郋�[�`���ŁCEXCHDR_ENTRY
 *  �}�N���œW�J����CPU��O�n���h���̓�����������CCPU��O�n���h���̔Ԓn��
 *  A1�ɁCCPU��O�n���h���ԍ���D1�ɓ���ĕ��򂵂Ă���D
 *
 *  CPU��O�n���h���́C��^�X�N�R���e�L�X�g�Ŏ��s����D���̂��߁CCPU��
 *  �O�n���h�����Ăяo���O�Ɋ����݃��[�h�Ɉڍs���C���^�[�����Ă������
 *  ���̃��[�h�ɖ߂��D���̃��[�h�ɖ߂����߂ɁC�����݃��[�h�Ɉڍs����O
 *  ��SR�������݃X�^�b�N��ɕۑ�����i���^�[�����SR���Q�Ƃ���������
 *  ���C�^�X�N�X�^�b�N��ɕۑ������ꍇ������C�Q�Ƃ���̂��ʓ|�j�D
 */
	.section .text._general_exception_context,code,keep
	.globl _general_exception_context
_general_exception_context:
exchdr_entry:
	di
	ehb
	addi	sp, sp, -4					/* �X�N���b�`���W�X�^��ۑ� */
	sw		a0, 0(sp)					/* �G���g���ԍ� */
	addi	sp, sp, -24*4				/* �X�N���b�`���W�X�^��ۑ� */
	sw		v0,  0*4(sp)
	sw		v1,  1*4(sp)
//	sw		a0,   *4(sp)				/* �G���g���ԍ� */
	sw		a1,  2*4(sp)
	sw		a2,  3*4(sp)
	sw		a3,  4*4(sp)
	sw		t0,  5*4(sp)
	sw		t1,  6*4(sp)
	sw		t2,  7*4(sp)
	sw		t3,  8*4(sp)
	sw		t4,  9*4(sp)
	sw		t5, 10*4(sp)
	sw		t6, 11*4(sp)
	sw		t7, 12*4(sp)
	sw		t8, 13*4(sp)
	sw		t9, 14*4(sp)
	sw		gp, 15*4(sp)
	sw		fp, 16*4(sp)
	sw		ra, 17*4(sp)
	mfhi	t0							/* HI */
	sw		t0, 18*4(sp)
	mflo	t0							/* LO */
	sw		t0, 19*4(sp)
	mfc0	t0, _CP0_STATUS				/* ��O�����O��Status��t2�� */
	li		t1, 0x00000001
	or		t2, t0, t1
	sw		t2, 20*4(sp)				/* Status */
	mfc0	t1, _CP0_CAUSE
	srl		a0, t1, 2
	andi	a0, 0x0000001F				/* ��O�G���g���ԍ���t0�� */
	sw		t1, 21*4(sp)				/* Cause */
	srl		t1, t1, 10
	ins		t0, zero, 1, 15
	ins		t0, t1, 10, 3				/* ���d���荞�݋��� */
	mtc0	t0, _CP0_STATUS
	mfc0	t0, _CP0_EPC				/* ���荞�݈ȊO�̗�O�̏ꍇ��EPC��4�����Z */
	addi	t0, t0, 4
	mtc0	t0, _CP0_EPC
	sw		t0, 22*4(sp)				/* EPC */
	mfc0	t0, _CP0_SRSCTL
	sw		t0, 23*4(sp)				/* SRSCtl */

	lw		t0, int_cnt
	addi	t0, t0, 1					/* �����݃��[�h�� */
	sw		t0, int_cnt
	li		t1, 1
	bne		t0 ,t1, exception_from_int 	/* ���Z�O��0�łȂ���Α��d������ */
	nop

	sw		sp, int_sp
	lw		sp, _kernel_istkpt
	j		exchdr_entry_0
	nop

exception_from_int:
	j		exchdr_entry_0
	nop

exchdr_entry_0:
	ei									/* �����݋���(CPU���b�N�������) */
	ehb
	la		t1, _kernel_exc_tbl
	li		t0, 4
	mul		t0, t0, a0
	add		t1, t0, t1
	lw		t0, (t1)
	move	t1, t2
	andi	t1, 0x00001C00				/* IPM��INT_IPM(TMIN_INTPRI) */
	slti	t1, t1, INT_IPM(TMIN_INTPRI)/*    ��菬������΁C�J�[�l�� */
	bnez	t1, exchdr_entry_1			/*    �Ǘ���CPU��O�̏����� */
	nop

	/*
	 *  �J�[�l���Ǘ��O��CPU��O�n���h���̌ďo��
	 */
	lw		t1, lock_flag				/* ����lock_flag���X�^�b�N�ɕۑ� */
	sw		t1, (sp)
	addi	sp, sp, -2*4
	sw		t2,  1*4(sp)				/* ��O�����O��Status��ޔ� */
	la		a0,  1*4(sp)
	jalr	t0							/* C���[�`���Ăяo�� */
	nop

	sw		t2,  1*4(sp)
	addi	sp, sp, 2*4					/* �X�^�b�N��̈������̂Ă� */
	sw		t1, (sp)					/* lock_flag�����ɖ߂� */
	sw		t1, lock_flag
	mtc0	t2, _CP0_STATUS				/* Status�����ɖ߂� */
	lw		sp, int_sp					/* �}�X�^���[�h�Ɂi�X�^�b�N�؊����j */

	lw		t0, 23*4(sp)				/* SRSCtl */
	mtc0	t0, _CP0_SRSCTL
	lw		t0, 22*4(sp)				/* EPC */
	mtc0	t0, _CP0_EPC
	lw		t0, 21*4(sp)				/* Cause */
	mtc0	t0, _CP0_CAUSE
	lw		t0, 20*4(sp)				/* Status */
	mtc0	t0, _CP0_STATUS
	lw		t0, 19*4(sp)
	mtlo	t0							/* LO */
	lw		t0, 18*4(sp)
	mthi	t0							/* HI */
	lw		ra, 17*4(sp)				/* �X�N���b�`���W�X�^�𕜋A */
	lw		fp, 16*4(sp)
	lw		gp, 15*4(sp)
	lw		t9, 14*4(sp)
	lw		t8, 13*4(sp)
	lw		t7, 12*4(sp)
	lw		t6, 11*4(sp)
	lw		t5, 10*4(sp)
	lw		t4,  9*4(sp)
	lw		t3,  8*4(sp)
	lw		t2,  7*4(sp)
	lw		t1,  6*4(sp)
	lw		t0,  5*4(sp)
	lw		a3,  4*4(sp)
	lw		a2,  3*4(sp)
	lw		a1,  2*4(sp)
//	lw		a0,   *4(sp)				/* �G���g���ԍ� */
	lw		v1,  1*4(sp)
	lw		v0,  0*4(sp)
	addi	sp, sp, 24*4
//	wrpgpr	sp, sp
	lw		a0, 0(sp)					/* �G���g���ԍ� */
	addi	sp, sp, 4
	eret								/* ������/��O��������̕��A */
	nop

	/*
	 *  �J�[�l���Ǘ���CPU��O�n���h���̌ďo��
	 */
exchdr_entry_1:
#ifdef LOG_EXC_LEAVE
	addi	sp, sp, -4
	sw		a0, (sp)
#endif

#ifdef LOG_EXC_ENTER
	jal		_kernel_log_exc_enter		/* log_exc_enter���Ăяo�� */
	nop

#endif /* LOG_EXC_ENTER */

	addi	sp, sp, -2*4
	sw		t2,  1*4(sp)				/* ��O�����O��Status��ޔ� */
	la		a0,  1*4(sp)
	jalr	t0							/* C���[�`���Ăяo�� */
	nop

	addi	sp, sp, 2*4					/* �X�^�b�N��̈������̂Ă� */

#ifdef LOG_EXC_LEAVE
	lw		a0, (sp)
	addi	sp, sp, 4
	jal		_kernel_log_exc_leave		/* log_exc_enter���Ăяo�� */
	nop

#endif

ret_exc:
	di
	ehb
	lw		t0, int_cnt					/* �߂�悪�����݃��[�h�Ȃ� */
	addi	t0, -1
	sw		t0, int_cnt
	bne		t0, zero, ret_exc_1		/*           �����Ƀ��^�[�� */
	nop
	/*
	 *  �J�[�l���Ǘ��̊����݂��֎~���C�}�X�^���[�h�ɖ߂��D���̎��_�ł́C
	 *  CPU���b�N��Ԃɂ͂Ȃ�Ȃ��ilock_flag��saved_iipm�͍X�V���Ȃ��j�D
	 *
	 *  reqflg���`�F�b�N����O�Ɋ����݂��֎~����̂́Creqflg���`�F�b�N
	 *  ��������Ɋ����݃n���h�����N������C���̒��Ńf�B�X�p�b�`���v��
	 *  ���ꂽ�ꍇ�ɁC�����Ƀf�B�X�p�b�`����Ȃ��Ƃ�����肪�����邽��
	 *  �ł���D
	 */
	lw		sp, int_sp					/* �}�X�^���[�h�Ɂi�X�^�b�N�؊����j */
	mfc0	t0, _CP0_STATUS				/* �J�[�l���Ǘ��̊����݂��֎~ */
	li		t1, ~0x00001C00
	and		t0, t0, t1
	li		t1, IIPM_LOCK
	or		t0, t0, t1
	mtc0	t0, _CP0_STATUS
	ei
	ehb
	lw		t0, reqflg
	bne		t0, zero, ret_int_3			/* reqflg��true�ł����ret_int_3�� */
	nop

ret_exc_1:
	lw		t0, 23*4(sp)				/* SRSCtl */
	mtc0	t0, _CP0_SRSCTL
	lw		t0, 22*4(sp)				/* EPC */
	mtc0	t0, _CP0_EPC
	lw		t0, 21*4(sp)				/* Cause */
	mtc0	t0, _CP0_CAUSE
	lw		t0, 20*4(sp)				/* Status */
	mtc0	t0, _CP0_STATUS
	lw		t0, 19*4(sp)
	mtlo	t0							/* LO */
	lw		t0, 18*4(sp)
	mthi	t0							/* HI */
	lw		ra, 17*4(sp)				/* �X�N���b�`���W�X�^�𕜋A */
	lw		fp, 16*4(sp)
	lw		gp, 15*4(sp)
	lw		t9, 14*4(sp)
	lw		t8, 13*4(sp)
	lw		t7, 12*4(sp)
	lw		t6, 11*4(sp)
	lw		t5, 10*4(sp)
	lw		t4,  9*4(sp)
	lw		t3,  8*4(sp)
	lw		t2,  7*4(sp)
	lw		t1,  6*4(sp)
	lw		t0,  5*4(sp)
	lw		a3,  4*4(sp)
	lw		a2,  3*4(sp)
	lw		a1,  2*4(sp)
//	lw		a0,   *4(sp)				/* �G���g���ԍ� */
	lw		v1,  1*4(sp)
	lw		v0,  0*4(sp)
	addi	sp, sp, 24*4
//	wrpgpr	sp, sp
	lw		a0, 0(sp)					/* �G���g���ԍ� */
	addi	sp, sp, 4
	eret								/* ������/��O��������̕��A */
	nop

ret_exc_1_d:
	j		ret_exc_1
	nop