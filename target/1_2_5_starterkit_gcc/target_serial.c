/*
 *  TOPPERS/ASP Kernel
 *      Toyohashi Open Platform for Embedded Real-Time Systems/
 *      Advanced Standard Profile Kernel
 *
 *  Copyright (C) 2000-2003 by Embedded and Real-Time Systems Laboratory
 *                              Toyohashi Univ. of Technology, JAPAN
 *  Copyright (C) 2005-2011 by Embedded and Real-Time Systems Laboratory
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
 *		�V���A��I/O�f�o�C�X�iSIO�j�h���C�o�i1_2_5_StarterKit�p�j
 */

#include <kernel.h>
#include <t_syslog.h>
#include "target_syssvc.h"
#include "target_serial.h"
#include "system_definitions.h"

/*
 * ���W�X�^�ݒ�l
 */
#define INDEX_PORT(x)   ((x) - 1)
#define GET_SIOPCB(x)   (&siopcb_table[INDEX_PORT(x)])

/*
 *  �V���A���|�[�g�̊Ǘ��u���b�N
 */
struct sio_port_control_block {
    ID port;
    uint32_t reg;
    intptr_t exinf;
};

/*
 * �V���A��I/O�|�[�g�Ǘ��u���b�N�G���A
 */
SIOPCB siopcb_table[TNUM_PORT];

static const uint32_t sioreg_table[TNUM_PORT] = {
	(uint32_t)USART_ID_1,
};

/*
 *  SIO�h���C�o�̏�����
 */
void
sio_initialize(intptr_t exinf)
{
	int i;

	for (i = 0; i < TNUM_PORT; i++) {
		siopcb_table[i].port = i;
		siopcb_table[i].reg = sioreg_table[i];
		siopcb_table[i].exinf = 0;
	}
}

/*
 *  �V���A��I/O�|�[�g�̃I�[�v��
 */
SIOPCB *
sio_opn_por(ID siopid, intptr_t exinf)
{
	SIOPCB	*siopcb;

	if (siopid > TNUM_PORT) {
		return NULL;
	}

	siopcb = GET_SIOPCB(siopid);
	siopcb->exinf = exinf;

	return(siopcb);
}

/*
 *  �V���A��I/O�|�[�g�̃N���[�Y
 */
void
sio_cls_por(SIOPCB *p_siopcb)
{
	SYS_INT_SourceDisable(INT_SOURCE_USART_1_TRANSMIT);
	SYS_INT_SourceDisable(INT_SOURCE_USART_1_RECEIVE);
}

/*
 *  SIO�̊����݃T�[�r�X���[�`��
 */
void
sio_isr(intptr_t exinf)
{
	SIOPCB* siopcb = GET_SIOPCB(exinf);

	/* Clear pending interrupt */
	SYS_INT_SourceStatusClear(INT_SOURCE_USART_1_RECEIVE);

	if (SYS_INT_SourceIsEnabled(INT_SOURCE_USART_1_RECEIVE)) {
		if (SYS_INT_SourceStatusGet(INT_SOURCE_USART_1_RECEIVE)) {
			sio_irdy_rcv(siopcb->exinf);
		}
	}

	if (SYS_INT_SourceIsEnabled(INT_SOURCE_USART_1_TRANSMIT)) {
		if (SYS_INT_SourceStatusGet(INT_SOURCE_USART_1_TRANSMIT)) {
			/* Clear pending interrupt */
			SYS_INT_SourceStatusClear(INT_SOURCE_USART_1_TRANSMIT);
			sio_irdy_snd(siopcb->exinf);
		}
	}
}

/*
 *  �V���A��I/O�|�[�g�ւ̕������M
 */
bool_t
sio_snd_chr(SIOPCB *siopcb, char c)
{
    if (PLIB_USART_TransmitterBufferIsFull(USART_ID_1))
		return false;
	PLIB_USART_TransmitterByteSend(USART_ID_1, c);
	return true;
}

/*
 *  �V���A��I/O�|�[�g����̕�����M
 */
int_t
sio_rcv_chr(SIOPCB *siopcb)
{
	return PLIB_USART_ReceiverByteReceive(USART_ID_1);
}

/*
 *  �V���A��I/O�|�[�g����̃R�[���o�b�N�̋���
 */
void
sio_ena_cbr(SIOPCB *siopcb, uint_t cbrtn)
{
	switch (cbrtn) {
	case SIO_RDY_SND:
		SYS_INT_SourceStatusClear(INT_SOURCE_USART_1_TRANSMIT);
		SYS_INT_SourceEnable(INT_SOURCE_USART_1_TRANSMIT);
		break;
	case SIO_RDY_RCV:
		SYS_INT_SourceStatusClear(INT_SOURCE_USART_1_RECEIVE);
		SYS_INT_SourceEnable(INT_SOURCE_USART_1_RECEIVE);
		break;
	default:
		break;
	}
}

/*
 *  �V���A��I/O�|�[�g����̃R�[���o�b�N�̋֎~
 */
void
sio_dis_cbr(SIOPCB *siopcb, uint_t cbrtn)
{
	switch (cbrtn) {
	case SIO_RDY_SND:
		SYS_INT_SourceDisable(INT_SOURCE_USART_1_TRANSMIT);
		break;
	case SIO_RDY_RCV:
		SYS_INT_SourceDisable(INT_SOURCE_USART_1_RECEIVE);
		break;
	default:
		break;
	}
}
