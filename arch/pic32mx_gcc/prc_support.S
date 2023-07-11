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
 *		プロセッサ依存モジュール アセンブリ言語部（PIC32MX用）
 */

#define	TOPPERS_MACRO_ONLY
#define UINT_C(val)			(val)		/* uint_t型の定数を作るマクロ */
#define ULONG_C(val)		(val)		/* ulong_t型の定数を作るマクロ */
#define CAST(type, val)		(val)		/* 型キャストを行うマクロ */
#include "kernel_impl.h"
#include "offset.h"

#include "xc.h"
#include <cp0defs.h>

/*
 *  タスクディスパッチャ
 */
	.section .text.dispatch,code,keep
	.globl dispatch
dispatch:
	/*
	 *  このルーチンは，タスクコンテキスト・CPUロック状態・ディスパッチ
	 *  許可状態・（モデル上の）割込み優先度マスク全解除状態で呼び出さ
	 *  れる．
	 */
	addi	sp, sp, -11*4				/* レジスタを保存 */
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

	lw		t0, p_runtsk				/* p_runtskをt0に */
	sw		sp, TCB_msp(t0)				/* タスクスタックを保存 */
	la		t1, dispatch_r
	sw		t1, TCB_pc(t0)				/* 実行再開番地を保存 */
	j		dispatcher
	nop

dispatch_r:
	lw		ra, 10*4(sp)				/* レジスタを復帰 */
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
	beq		t1, zero, dispatch_r_1		/* enatexがfalseならリターン */
	nop

	lw		t1, TCB_texptn(t0)
	beq		t1, zero, dispatch_r_1		/* texptnが0ならリターン */
	nop

	lw		t1, ipmflg
	bne		t1, zero, call_texrtn		/* ipmflgがtrueであればタスク例外処理ルーチンの呼出し */
	nop

dispatch_r_1:
	jr		ra
	nop

/*
 *  ディスパッチャの動作開始（prc_support.S）
 */
	.globl start_dispatch
start_dispatch:
	/*
	 *  このルーチンは，カーネル起動時に，すべての割込みを禁止した状態
	 * （割込みロック状態と同等）で呼び出される．また，割込みモード（非
	 *  タスクコンテキストと同等）で呼び出されることを想定している．
	 *
	 *  prc_initializeで，lock_flagをtrueに，saved_iipmをIIPM_ENAALLに
	 *  初期化しているため，カーネル管理外の割込みを許可することで，
	 *  CPUロック状態・（モデル上の）割込み優先度マスク全解除状態になる．
	 *  また，initialize_taskでdisdspをfalseに初期化しているため，ディ
	 *  スパッチ許可状態になっている．
	 */
	sw		zero, int_cnt				/* マスタモードに */
	mfc0	t0, _CP0_STATUS				/*  カーネル管理外の割込みを許可 */
	li		t1, ~0x00001C00
	and		t0, t0, t1
	li		t1, IIPM_LOCK
	or		t0, t0, t1
	mtc0	t0, _CP0_STATUS
	j		dispatcher_0
	nop

/*
 *  現在のコンテキストを捨ててディスパッチ
 */
	.globl exit_and_dispatch
exit_and_dispatch:
	/* ディスパッチャ本体（dispatcher）へ */

/*
 *  ディスパッチャ本体
 */
dispatcher:
	/*
	 *  このルーチンは，タスクコンテキスト・CPUロック状態・ディスパッチ
	 *  許可状態・（モデル上の）割込み優先度マスク全解除状態で呼び出さ
	 *  れる．
	 *
	 *  すなわち，マスタモード・lock_flagがtrue・disdspがfalse・dspflg
	 *  がtrue・saved_iipmがIIPM_ENAALLとなっている．実行再開番地へもこ
	 *  の状態のまま分岐する．
	 */

#ifdef LOG_DSP_ENTER
	lw		a0, p_runtsk
	jal		log_dsp_enter
	nop

#endif /* LOG_DSP_ENTER */

dispatcher_0:
	lw		t0, p_schedtsk				/* p_schedtskをp_runtskに */
	sw		t0, p_runtsk
	beq		t0, zero, dispatcher_1		/* p_runtskがNULLならdispatcher_1へ */
	nop

	lw		sp, TCB_msp(t0)				/* タスクスタックを復帰 */

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
	 *  CPUロック状態を解除する準備をする．
	 */
	li		t0, 1						/* 割込みモードに */
	sw		t0, int_cnt
	lw		sp, _kernel_istkpt
	mfc0	t0, _CP0_STATUS				/* Statusをt0に保存 */
	sw		zero, lock_flag				/* CPUロック解除状態に */
	li		t1, ~0x00001C00
	and		t2, t0, t1
	mtc0	t2, _CP0_STATUS

dispatcher_2:
	/*
	 *  割込みを許可し，割込みモードに切り換えて，割込みを待つ．
	 *
	 *  ここで割込みモードに切り換えるのは，ここで発生する割込み処理に
	 *  どのスタックを使うかという問題の解決と，割込みハンドラ内でのタ
	 *  スクディスパッチの防止という2つの意味がある．
	 *
	 *  プロセッサを割込み待ちに移行させる処理と，割込み許可とは，不可
	 *  分に行なう必要がある（M68040ではstop命令で両方行なうので問題な
	 *  い）．これを不可分に行なわない場合，割込みを許可した直後に割込
	 *  みが入り，その中でタスクが実行可能状態になると，実行すべきタス
	 *  クがあるにもかかわらずプロセッサが割込み待ちになってしまう．
	 *
	 *  割込み待ちの間は，p_runtskをNULL（＝0）に設定しなければならな
	 *  い．このように設定しないと，割込みハンドラからiget_tidを呼び出
	 *  した際の動作が仕様に合致しなくなる．
	 */
	ei
	ehb
	di
	ehb
	lw		t1, reqflg
	beq		t1, zero, dispatcher_2		/* reqflgがfalseならdispatcher_2へ */
	nop

	mtc0	t0, _CP0_STATUS				/* 元の状態に戻す */
	sw		zero, reqflg				/* reqflgをfalseに */
	/*
	 *  CPUロック状態に戻す．割込み待ちの間に実行した割込みハンドラによ
	 *  り，saved_iipmが書き換えられる可能性があるため，元の値に戻す必
	 *  要がある．dispatcherが実行される時は，saved_iipmがIIPM_ENAALL
	 *  となっているため，ここではsaved_iipmをIIPM_ENAALL（＝0）に戻せ
	 *  ばよい．
	 */
	sw		zero, int_cnt				/* マスタモードに */
	sw		zero, saved_iipm			/* saved_iipmを0にする */
	li		t0, 1						/* CPUロック状態に */
	sw		t0, lock_flag
	j		dispatcher_0
	nop

/*
 *  カーネルの終了処理の呼出し
 *
 *  M68040では，モード切換えによりスタックも切り換わるため，明示的なス
 *  タック切換えは必要ない．最初から割込みモードであった場合も，同じ処
 *  理でよい．
 */
	.globl call_exit_kernel
call_exit_kernel:
	li		t0, 1						/* 割込みモードに */
	sw		t0, int_cnt
	lw		sp, _kernel_istkpt
	j		exit_kernel					/* カーネルの終了処理を呼ぶ */
	nop

/*
 *  タスク開始時処理
 *
 *  dispatcherから呼び出されるため，TCBのアドレスはt0に入っている
 */
	.section .text.start_r,code,keep
	.globl start_r
start_r:
	sw		zero, lock_flag				/* CPUロック解除状態に */
	mfc0	t2, _CP0_STATUS				/*  カーネル管理外の割込みを許可 */
	li		t1, ~0x00001C00
	and		t2, t2, t1
	mtc0	t2, _CP0_STATUS
	ei
	ehb
	lw		t1, TCB_p_tinib(t0)			/* p_runtsk->p_tinibをt1に */
	lw		a0, TINIB_exinf(t1)			/* exinfをタスクへの引数に */
	la		ra, ext_tsk					/* タスクからの戻り番地をext_tskに設定 */
	lw		t2, TINIB_task(t1)			/* タスクの起動番地をt1に */
	jr		t2
	nop

/*
 *  割込みエントリ（a0にエントリ番号が入る）
 */
	.section .text.inthdr_entry,code,keep
	.globl inthdr_entry
inthdr_entry:
	di
	ehb
	addi	sp, sp, -24*4				/* スクラッチレジスタを保存 */
	sw		v0,  0*4(sp)
	sw		v1,  1*4(sp)
//	sw		a0,   *4(sp)				/* エントリ番号 */
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
	ins		t0, t1, 10, 3				/* 多重割り込み許可 */
	mtc0	t0, _CP0_STATUS
	mfc0	t0, _CP0_EPC
	sw		t0, 22*4(sp)				/* EPC */
	mfc0	t0, _CP0_SRSCTL
	sw		t0, 23*4(sp)				/* SRSCtl */

	lw		t0, int_cnt
	addi	t0, t0, 1					/* 割込みモードに */
	sw		t0, int_cnt
	li		t1, 1
	bne		t0 ,t1, interrupt_from_int 	/* 加算前が0でなければ多重割込み */
	nop

	sw		sp, int_sp
	lw		sp, _kernel_istkpt
	j		inthdr_entry_0
	nop

interrupt_from_int:
	j		inthdr_entry_0
	nop

inthdr_entry_0:
	ei									/* 割込み許可(CPUロック解除状態) */
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
	jal		log_inh_enter				/* log_exc_enterを呼び出す */
	nop

	lw		t0,  1*4(sp)
	lw		a0,  0*4(sp)
	addi	sp, sp, 2*4
#endif /* LOG_EXC_ENTER */

	jalr	t0							/* Cルーチン呼び出し */
	nop

#ifdef LOG_INH_LEAVE
	lw		a0,  0*4(sp)
	addi	sp, sp, 1*4
	jal		log_inh_leave
	nop

#endif /* LOG_INH_LEAVE */


/*
 *  割込みハンドラ出口処理
 *
 *  ret_intは，割込みハンドラから戻った直後に実行するルーチンで，
 *  INTHDR_ENTRYマクロで展開する割込みハンドラの入口処理で，割込みハン
 *  ドラからの戻り番地に設定される．
 */
//	.section .text.ret_int,code,keep
	.globl ret_int
ret_int:
	di
	ehb
	lw		t0, int_cnt					/* 戻り先が割込みモードなら */
	addi	t0, -1
	sw		t0, int_cnt
	bne		t0, zero, ret_int_1_d		/*           すぐにリターン */
	nop

	/*
	 *  カーネル管理の割込みを禁止する．この時点では，CPUロック状態に
	 *  はならない（lock_flagとsaved_iipmは更新しない）．
	 *
	 *  reqflgをチェックする前に割込みを禁止するのは，reqflgをチェック
	 *  した直後に割込みハンドラが起動され，その中でディスパッチが要求
	 *  された場合に，すぐにディスパッチされないという問題が生じるため
	 *  である．
	 */
	mfc0	t0, _CP0_STATUS				/* カーネル管理の割込みを禁止 */
	li		t1, ~0x00001C00
	and		t0, t0, t1
	li		t1, IIPM_LOCK
	or		t0, t0, t1
	mtc0	t0, _CP0_STATUS
	ei
	ehb

	lw		t0, reqflg
	bne		t0, zero, ret_int_2			/* reqflgがtrueであればret_int_2へ */
	nop

	lw		sp, int_sp					/* マスタモードに（スタック切換え） */

ret_int_1:
	/*
	 *  割込み処理からのリターンにより，CPUロック解除状態に移行するよう
	 *  準備する．割込み優先度マスクは，RTE命令により元の値に戻るため，
	 *  lock_flagをfalseにしておけばよい（lock_flagをfalseにするのは，
	 *  CPUロック状態のまま割込みハンドラから戻った時の対策）．
	 */
	sw		zero, lock_flag				/* CPUロック解除の準備 */

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
	lw		ra, 17*4(sp)				/* スクラッチレジスタを復帰 */
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
//	lw		a0,   *4(sp)				/* エントリ番号 */
	lw		v1,  1*4(sp)
	lw		v0,  0*4(sp)
	addi	sp, sp, 24*4
//	wrpgpr	sp, sp
	lw		a0, 0(sp)					/* エントリ番号 */
	addi	sp, sp, 4
	eret								/* 割込み/例外処理からの復帰 */
	nop

ret_int_1_d:
	j		ret_int_1
	nop

ret_int_2:
	lw		sp, int_sp					/* マスタモードに（スタック切換え） */

ret_int_3:
	/*
	 *  ここへは，CPU例外ハンドラの出口処理からも分岐してくる．
	 *
	 *  ここでは，戻り先がタスクであり，スタックは，例外スタックフレー
	 *  ムの上にスクラッチレジスタのみが保存された状態になっている．ま
	 *  た，プロセッサは，マスタモード・カーネル管理の割込みを禁止した
	 *  状態となっている．
	 */
	sw		zero, reqflg				/* reqflgをfalseに */

	/*
	 *  CPUロック状態に移行し，割込み優先度マスクを割込み処理前の値に設
	 *	定する．カーネル管理の割込みはすでに禁止しているので，lock_flag
	 *  とsaved_iipmを更新する．saved_iipmは，戻り先の割込み優先度マス
	 *  ク（の内部表現）に設定する．
	 *
	 *  この時点でCPUロック状態とするのは，dispatcherへ分岐する時と，
	 *  call_texrtnを呼び出す時に，CPUロック状態になっている必要がある
	 *  ためである．
	 */
	lw		t0,  20*4(sp)				/* 戻り先のStatusをt0に */
	li		t1, 0x00001C00				/* IPMを取り出してsaved_iipmに */
	and		t0, t0, t1
	sw		t0, saved_iipm
	li		t0, 1						/* lock_flagをtrueに */
	sw		t0, lock_flag

	/*
	 *  dspflgがfalseである場合と，p_runtskとp_schedtskが同じ場合には，
	 *  ディスパッチを行わない．このチェックが必要なのは，タスク例外処
	 *  理ルーチンの呼出しが必要な場合に，ディスパッチが必要なくても，
	 *  reqflgをtrueにするためである．
	 */

	lw		t0, p_runtsk				/* p_runtskをt0に */
	lw		t1, dspflg
	beq		t1, zero, ret_int_4			/* dspflgがfalseならret_int_4へ */
	nop
	lw		t1, p_schedtsk				/* p_runtskとp_schedtskが同じなら */
	seq		t2, t0, t1
	bne		t2, zero, ret_int_4			/*                    ret_int_4へ */
	nop

	addi	sp, sp, -11*4				/* 残りのレジスタを保存 */
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

	sw		sp, TCB_msp(t0)				/* タスクスタックを保存 */
	la		t1, ret_int_r				/* 実行再開番地を保存 */
	sw		t1, TCB_pc(t0)
	j		dispatcher
	nop

ret_int_r:
	lw		ra, 10*4(sp)				/* レジスタを復帰 */
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
	 *  enatexがtrueで，texptnが0でなく，ipmflgがtrueであれば，タスク
	 *  例外処理ルーチンを呼び出す．
	 */
	lb		t1, TCB_enatex(t0)
	andi	t1, t1, TCB_enatex_mask
	beq		t1, zero, ret_int_5			/* enatexがfalseならret_int_5へ */
	nop

	lw		t1, TCB_texptn(t0)
	beq		t1, zero, ret_int_5			/* texptnが0ならret_int_5へ */
	nop

	lw		t1, ipmflg
	beq		t1, zero, ret_int_5			/* ipmflgがfalseならret_int_5へ  */
	nop

	jal		call_texrtn					/* タスク例外処理ルーチンの呼出し */
	nop

ret_int_5:
	/*
	 *  割込み処理からのリターンにより，CPUロック解除状態に移行するよ
	 *  う準備する．割込み優先度マスクは，RTE命令により元の値に戻るた
	 *  め，lock_flagをfalseにしておけばよい．
	 */
	sw		zero, lock_flag				/* CPUロック解除の準備 */

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
	lw		ra, 17*4(sp)				/* スクラッチレジスタを復帰 */
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
//	lw		a0,   *4(sp)				/* エントリ番号 */
	lw		v1,  1*4(sp)
	lw		v0,  0*4(sp)
	addi	sp, sp, 24*4
//	wrpgpr	sp, sp
	lw		a0, 0(sp)					/* エントリ番号 */
	addi	sp, sp, 4
	eret								/* 割込み/例外処理からの復帰 */
	nop

/*
 *  CPU例外ハンドラ出入口処理
 *
 *  exchdr_entryは，CPU例外が発生した時に実行するルーチンで，EXCHDR_ENTRY
 *  マクロで展開するCPU例外ハンドラの入口処理から，CPU例外ハンドラの番地を
 *  A1に，CPU例外ハンドラ番号をD1に入れて分岐してくる．
 *
 *  CPU例外ハンドラは，非タスクコンテキストで実行する．そのため，CPU例
 *  外ハンドラを呼び出す前に割込みモードに移行し，リターンしてきた後に
 *  元のモードに戻す．元のモードに戻すために，割込みモードに移行する前
 *  のSRを割込みスタック上に保存する（リターン先のSRを参照する手もある
 *  が，タスクスタック上に保存される場合があり，参照するのが面倒）．
 */
	.section .text._general_exception_context,code,keep
	.globl _general_exception_context
_general_exception_context:
exchdr_entry:
	di
	ehb
	addi	sp, sp, -4					/* スクラッチレジスタを保存 */
	sw		a0, 0(sp)					/* エントリ番号 */
	addi	sp, sp, -24*4				/* スクラッチレジスタを保存 */
	sw		v0,  0*4(sp)
	sw		v1,  1*4(sp)
//	sw		a0,   *4(sp)				/* エントリ番号 */
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
	mfc0	t0, _CP0_STATUS				/* 例外発生前のStatusをt2に */
	li		t1, 0x00000001
	or		t2, t0, t1
	sw		t2, 20*4(sp)				/* Status */
	mfc0	t1, _CP0_CAUSE
	srl		a0, t1, 2
	andi	a0, 0x0000001F				/* 例外エントリ番号をt0に */
	sw		t1, 21*4(sp)				/* Cause */
	srl		t1, t1, 10
	ins		t0, zero, 1, 15
	ins		t0, t1, 10, 3				/* 多重割り込み許可 */
	mtc0	t0, _CP0_STATUS
	mfc0	t0, _CP0_EPC				/* 割り込み以外の例外の場合はEPCに4を加算 */
	addi	t0, t0, 4
	mtc0	t0, _CP0_EPC
	sw		t0, 22*4(sp)				/* EPC */
	mfc0	t0, _CP0_SRSCTL
	sw		t0, 23*4(sp)				/* SRSCtl */

	lw		t0, int_cnt
	addi	t0, t0, 1					/* 割込みモードに */
	sw		t0, int_cnt
	li		t1, 1
	bne		t0 ,t1, exception_from_int 	/* 加算前が0でなければ多重割込み */
	nop

	sw		sp, int_sp
	lw		sp, _kernel_istkpt
	j		exchdr_entry_0
	nop

exception_from_int:
	j		exchdr_entry_0
	nop

exchdr_entry_0:
	ei									/* 割込み許可(CPUロック解除状態) */
	ehb
	la		t1, _kernel_exc_tbl
	li		t0, 4
	mul		t0, t0, a0
	add		t1, t0, t1
	lw		t0, (t1)
	move	t1, t2
	andi	t1, 0x00001C00				/* IPMがINT_IPM(TMIN_INTPRI) */
	slti	t1, t1, INT_IPM(TMIN_INTPRI)/*    より小さければ，カーネル */
	bnez	t1, exchdr_entry_1			/*    管理のCPU例外の処理へ */
	nop

	/*
	 *  カーネル管理外のCPU例外ハンドラの呼出し
	 */
	lw		t1, lock_flag				/* 元のlock_flagをスタックに保存 */
	sw		t1, (sp)
	addi	sp, sp, -2*4
	sw		t2,  1*4(sp)				/* 例外発生前のStatusを退避 */
	la		a0,  1*4(sp)
	jalr	t0							/* Cルーチン呼び出し */
	nop

	sw		t2,  1*4(sp)
	addi	sp, sp, 2*4					/* スタック上の引数を捨てる */
	sw		t1, (sp)					/* lock_flagを元に戻す */
	sw		t1, lock_flag
	mtc0	t2, _CP0_STATUS				/* Statusを元に戻す */
	lw		sp, int_sp					/* マスタモードに（スタック切換え） */

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
	lw		ra, 17*4(sp)				/* スクラッチレジスタを復帰 */
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
//	lw		a0,   *4(sp)				/* エントリ番号 */
	lw		v1,  1*4(sp)
	lw		v0,  0*4(sp)
	addi	sp, sp, 24*4
//	wrpgpr	sp, sp
	lw		a0, 0(sp)					/* エントリ番号 */
	addi	sp, sp, 4
	eret								/* 割込み/例外処理からの復帰 */
	nop

	/*
	 *  カーネル管理のCPU例外ハンドラの呼出し
	 */
exchdr_entry_1:
#ifdef LOG_EXC_LEAVE
	addi	sp, sp, -4
	sw		a0, (sp)
#endif

#ifdef LOG_EXC_ENTER
	jal		_kernel_log_exc_enter		/* log_exc_enterを呼び出す */
	nop

#endif /* LOG_EXC_ENTER */

	addi	sp, sp, -2*4
	sw		t2,  1*4(sp)				/* 例外発生前のStatusを退避 */
	la		a0,  1*4(sp)
	jalr	t0							/* Cルーチン呼び出し */
	nop

	addi	sp, sp, 2*4					/* スタック上の引数を捨てる */

#ifdef LOG_EXC_LEAVE
	lw		a0, (sp)
	addi	sp, sp, 4
	jal		_kernel_log_exc_leave		/* log_exc_enterを呼び出す */
	nop

#endif

ret_exc:
	di
	ehb
	lw		t0, int_cnt					/* 戻り先が割込みモードなら */
	addi	t0, -1
	sw		t0, int_cnt
	bne		t0, zero, ret_exc_1		/*           すぐにリターン */
	nop
	/*
	 *  カーネル管理の割込みを禁止し，マスタモードに戻す．この時点では，
	 *  CPUロック状態にはならない（lock_flagとsaved_iipmは更新しない）．
	 *
	 *  reqflgをチェックする前に割込みを禁止するのは，reqflgをチェック
	 *  した直後に割込みハンドラが起動され，その中でディスパッチが要求
	 *  された場合に，すぐにディスパッチされないという問題が生じるため
	 *  である．
	 */
	lw		sp, int_sp					/* マスタモードに（スタック切換え） */
	mfc0	t0, _CP0_STATUS				/* カーネル管理の割込みを禁止 */
	li		t1, ~0x00001C00
	and		t0, t0, t1
	li		t1, IIPM_LOCK
	or		t0, t0, t1
	mtc0	t0, _CP0_STATUS
	ei
	ehb
	lw		t0, reqflg
	bne		t0, zero, ret_int_3			/* reqflgがtrueであればret_int_3へ */
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
	lw		ra, 17*4(sp)				/* スクラッチレジスタを復帰 */
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
//	lw		a0,   *4(sp)				/* エントリ番号 */
	lw		v1,  1*4(sp)
	lw		v0,  0*4(sp)
	addi	sp, sp, 24*4
//	wrpgpr	sp, sp
	lw		a0, 0(sp)					/* エントリ番号 */
	addi	sp, sp, 4
	eret								/* 割込み/例外処理からの復帰 */
	nop

ret_exc_1_d:
	j		ret_exc_1
	nop
