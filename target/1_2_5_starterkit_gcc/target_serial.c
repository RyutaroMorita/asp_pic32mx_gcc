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
 *  上記著作権者は，以下の(1)～(4)の条件を満たす場合に限り，本ソフトウェ
 *  ア（本ソフトウェアを改変したものを含む．以下同じ）を使用・複製・改
 *  変・再配布（以下，利用と呼ぶ）することを無償で許諾する．
 *  (1) 本ソフトウェアをソースコードの形で利用する場合には，上記の著作
 *      権表示，この利用条件および下記の無保証規定が，そのままの形でソー
 *      スコード中に含まれていること．
 *  (2) 本ソフトウェアを，ライブラリ形式など，他のソフトウェア開発に使
 *      用できる形で再配布する場合には，再配布に伴うドキュメント（利用
 *      者マニュアルなど）に，上記の著作権表示，この利用条件および下記
 *      の無保証規定を掲載すること．
 *  (3) 本ソフトウェアを，機器に組み込むなど，他のソフトウェア開発に使
 *      用できない形で再配布する場合には，次のいずれかの条件を満たすこ
 *      と．
 *    (a) 再配布に伴うドキュメント（利用者マニュアルなど）に，上記の著
 *        作権表示，この利用条件および下記の無保証規定を掲載すること．
 *    (b) 再配布の形態を，別に定める方法によって，TOPPERSプロジェクトに
 *        報告すること．
 *  (4) 本ソフトウェアの利用により直接的または間接的に生じるいかなる損
 *      害からも，上記著作権者およびTOPPERSプロジェクトを免責すること．
 *      また，本ソフトウェアのユーザまたはエンドユーザからのいかなる理
 *      由に基づく請求からも，上記著作権者およびTOPPERSプロジェクトを
 *      免責すること．
 *
 *  本ソフトウェアは，無保証で提供されているものである．上記著作権者お
 *  よびTOPPERSプロジェクトは，本ソフトウェアに関して，特定の使用目的
 *  に対する適合性も含めて，いかなる保証も行わない．また，本ソフトウェ
 *  アの利用により直接的または間接的に生じたいかなる損害に関しても，そ
 *  の責任を負わない．
 *
 *	2023/7/04 Ryutaro Morita
 */

/*
 *		シリアルI/Oデバイス（SIO）ドライバ（1_2_5_StarterKit用）
 */

#include <kernel.h>
#include <t_syslog.h>
#include "target_syssvc.h"
#include "target_serial.h"
#include "system_definitions.h"

/*
 * レジスタ設定値
 */
#define INDEX_PORT(x)   ((x) - 1)
#define GET_SIOPCB(x)   (&siopcb_table[INDEX_PORT(x)])

/*
 *  シリアルポートの管理ブロック
 */
struct sio_port_control_block {
    ID port;
    uint32_t reg;
    intptr_t exinf;
};

/*
 * シリアルI/Oポート管理ブロックエリア
 */
SIOPCB siopcb_table[TNUM_PORT];

static const uint32_t sioreg_table[TNUM_PORT] = {
	(uint32_t)USART_ID_1,
};

/*
 *  SIOドライバの初期化
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
 *  シリアルI/Oポートのオープン
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
 *  シリアルI/Oポートのクローズ
 */
void
sio_cls_por(SIOPCB *p_siopcb)
{
	SYS_INT_SourceDisable(INT_SOURCE_USART_1_TRANSMIT);
	SYS_INT_SourceDisable(INT_SOURCE_USART_1_RECEIVE);
}

/*
 *  SIOの割込みサービスルーチン
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
 *  シリアルI/Oポートへの文字送信
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
 *  シリアルI/Oポートからの文字受信
 */
int_t
sio_rcv_chr(SIOPCB *siopcb)
{
	return PLIB_USART_ReceiverByteReceive(USART_ID_1);
}

/*
 *  シリアルI/Oポートからのコールバックの許可
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
 *  シリアルI/Oポートからのコールバックの禁止
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
