$
$ 		パス2のターゲット依存テンプレート（1_2_5_StarterKit用）
$

$
$  有効な割込み番号，割込みハンドラ番号
$
$INTNO_VALID = { 0,1,...,83 }$
$INHNO_VALID = { 0,1,...,49 }$

$
$  有効なCPU例外番号
$
$EXCNO_VALID = { 1,2,...,31 }$

$
$  ATT_ISRで使用できる割込み番号とそれに対応する割込みハンドラ番号
$
$INTNO_ATTISR_VALID = INTNO_VALID$
$INHNO_ATTISR_VALID = { 0,1,...,4;5;5;6;7;8;9;9;10;11;12;13;13;14;15;16;17;17;18;19;20;21;21;22,23,...,29;30;30;30;31;31;31;32;32;32;
						33;33;33;33;33;33;33;34;34;35;35;35;36;36;36;37;37;37;38;38;38;39;39;39;40;40;40;41,42,...,47;48;48;48;49,49,49 }$

$
$  DEF_INT／DEF_EXCで使用できる割込みハンドラ番号／CPU例外ハンドラ番号
$
$INHNO_DEFINH_VALID = INHNO_VALID$
$EXCNO_DEFEXC_VALID = EXCNO_VALID$

$
$  CFG_INTで使用できる割込み番号と割込み優先度
$
$INTNO_CFGINT_VALID = INTNO_VALID$
$INTPRI_CFGINT_VALID = { -7,-6,...,-1 }$

$
$  標準テンプレートファイルのインクルード
$
$INCLUDE "kernel/kernel.tf"$

/*$NL$
$SPC$*  Target-dependent Definitions (1_2_5_StarterKit)$NL$
$SPC$*/$NL$
$NL$

$
$   CFG_INTのターゲット依存のエラーチェックと_kernel_bitpat_cfgintの生成
$
const FP _kernel_exc_tbl[] = $NL$
{$NL$
$TAB$NULL, /* 0 : int */$NL$
$FOREACH excno EXCNO_VALID$
	$IF LENGTH(EXC.EXCNO[excno])$
		$TAB$(FP)($EXC.EXCHDR[excno]$),
	$ELSE$
		$TAB$(FP)(_kernel_default_exc_handler),
	$END$
	$SPC$$FORMAT("/* %d */", +excno)$$NL$
$END$
};$NL$
$NL$

const FP _kernel_int_tbl[] = $NL$
{$NL$
$FOREACH inhno INHNO_VALID$
	$IF LENGTH(INH.INHNO[inhno])$
		$TAB$(FP)($INH.INTHDR[inhno]$),
	$ELSE$
		$TAB$(FP)(_kernel_default_int_handler),
	$END$
	$SPC$$FORMAT("/* %d */", +inhno)$$NL$
$END$
};$NL$
$NL$

$FOREACH inhno INHNO_VALID$
	$IF LENGTH(INH.INHNO[inhno])$
		$FORMAT("asm(\".section .text.int_handler_%d,code,keep \\n\\t\"", +inhno)$$NL$
		$FORMAT("\"int_handler_%d: \\n\\t\"", +inhno)$$NL$
		"	addi	$$29, $$29, -4 \n\t"$NL$
		"	sw		$$4, 0($$29) \n\t"$NL$
		$FORMAT("\"	li		$4, %d \\n\\t\"", +inhno)$$NL$
		"	j		inthdr_entry \n\t"$NL$
		"	nop \n\t");$NL$
		$NL$
	$END$
$END$

$FOREACH inhno INHNO_VALID$
	$IF LENGTH(INH.INHNO[inhno])$
		$FORMAT("asm(\".section .vector_%d,code,keep \\n\\t\"", +inhno)$$NL$
		$FORMAT("\"__vector_dispatch_%d: \\n\\t\"", +inhno)$$NL$
		$FORMAT("\"    j	int_handler_%d \\n\\t\"", +inhno)$);$NL$
		$NL$
	$END$
$END$
