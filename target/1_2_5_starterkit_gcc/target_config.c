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
 *		ターゲット依存モジュール（1_2_5_StarterKit用）
 */

#include "kernel_impl.h"
#include <sil.h>
#include "system_definitions.h"

/*
 *  プロセッサ識別のための変数（マルチプロセッサ対応）
 */
uint_t	board_id;			/* ボードID */
void	*board_addr;		/* ローカルメモリの先頭アドレス */

/*
 *  ターゲット依存の初期化
 */
void
target_initialize(void)
{
	/*
	 *  プロセッサ依存の初期化
	 */
	prc_initialize();

	/* Initialize all MPLAB Harmony modules, including application(s). */
	SYS_Initialize ( NULL );

	/*
	 *  SYS_Initialize() の中で割り込み許可を行ったが、ここではまだ早いので、すぐに禁止
	 *  本当の割り込み許可は、start_r で行う
	 */
	SYS_INT_Disable();
}

/*
 *  ターゲット依存の終了処理
 */
void
target_exit(void)
{
	/*
	 *  プロセッサ依存の終了処理
	 */
	prc_terminate();

	while(1);
}

/*
 *  システムログの低レベル出力のための文字出力
 */
void
target_fput_log(char c)
{
	if (c == '\n') {
		/* Wait till TX buffer is available as blocking operation is selected */
		while (PLIB_USART_TransmitterBufferIsFull(USART_ID_1));
		/* Send one byte */
		PLIB_USART_TransmitterByteSend(USART_ID_1, '\r');
	}
	/* Wait till TX buffer is available as blocking operation is selected */
	while (PLIB_USART_TransmitterBufferIsFull(USART_ID_1));
	/* Send one byte */
	PLIB_USART_TransmitterByteSend(USART_ID_1, c);
}

/*
 *  割込み要求ラインの属性の設定
 *
 *  ASPカーネルでの利用を想定して，パラメータエラーはアサーションでチェッ
 *  クしている．cfg_intサービスコールを設ける場合には，エラーを返すよう
 *  にすべきであろう．
 */
void
x_config_int(INTNO intno, ATR intatr, PRI intpri)
{
	int vectors[] = {
			 0,  1,  2,  3,  4,  5,  5,  6,  7,  8,  9,  9, 10, 11, 12, 13,
			13, 14, 15, 16, 17, 17, 18, 19, 20, 21, 21, 22, 23, 24, 25, 26,
			27, 28, 29, 30, 30, 30, 31, 31, 31, 32, 32, 32, 33, 33, 33, 33,
			33, 33, 33, 34, 34, 35, 35, 35, 36, 36, 36, 37, 37, 37, 38, 38,
			38, 39, 39, 39, 40, 40, 40, 41, 42, 43, 44, 45, 46, 47, 48, 48,
			48, 49, 49, 49
	};

	assert(VALID_INTNO_CFGINT(intno));
	assert(TMIN_INTPRI <= intpri && intpri <= TMAX_INTPRI);

	/*
	 *  割込みのマスク
	 *
	 *  割込みを受け付けたまま，レベルトリガ／エッジトリガの設定や，割
	 *  込み優先度の設定を行うのは危険なため，割込み属性にかかわらず，
	 *  一旦マスクする．
	 */
	(void) x_disable_int(intno);

	SYS_INT_VectorPrioritySet(vectors[intno], -(intpri));

	/*
	 *  割込みのマスク解除（必要な場合）
 	 */
	if ((intatr & TA_ENAINT) != 0U) {
		(void) x_enable_int(intno);
	}
}

/*
 *  割込み要求禁止フラグのセット
 *
 *  割込み属性が設定されていない割込み要求ラインに対して割込み要求禁止
 *  フラグをセットしようとした場合には，falseを返す．
 */
bool_t
x_disable_int(INTNO intno)
{
	SYS_INT_SourceDisable(intno);
	return true;
}

/*
 *  割込み要求禁止フラグのクリア
 *
 *  割込み属性が設定されていない割込み要求ラインに対して割込み要求禁止
 *  フラグをクリアしようとした場合には，falseを返す．
 */
bool_t
x_enable_int(INTNO intno)
{
	SYS_INT_SourceEnable(intno);
	return true;
}

/*
 *  割込み要求のクリア
 */
void
x_clear_int(INTNO intno)
{
	SYS_INT_SourceStatusClear(intno);
}

/*
 *  割込み要求のチェック
 */
bool_t
x_probe_int(INTNO intno)
{
	return SYS_INT_SourceStatusGet(intno);
}
