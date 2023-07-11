#
#		Makefileのプロセッサ依存部（PIC32MX用）
#

#
#  GNU開発環境のターゲットアーキテクチャの定義
#
GCC_TARGET = xc32

#
#  プロセッサ依存部ディレクトリ名の定義
#
PRCDIR = $(SRCDIR)/arch/$(PRC)_$(TOOL)

#
#  コンパイルオプション
#
INCLUDES := $(INCLUDES) \
			-I$(SRCDIR)/arch/$(PRC)_$(TOOL)/framework
COPTS := $(COPTS) -mprocessor=32MX570F512L -ffunction-sections -fgnu89-inline
#LDFLAGS := $(LDFLAGS) -mprocessor=32MX570F512L
LDFLAGS := $(LDFLAGS) -nostartfiles

#
#  カーネルに関する定義
#
KERNEL_DIR := $(KERNEL_DIR) $(PRCDIR) \
			$(SRCDIR)/arch/$(PRC)_$(TOOL)/framework/system/int/src
			
KERNEL_ASMOBJS := $(KERNEL_ASMOBJS) prc_support.o
KERNEL_COBJS := $(KERNEL_COBJS) prc_config.o sys_int_pic32.o

#
#  コンフィギュレータ関係の変数の定義
#
CFG_TABS := $(CFG_TABS) --cfg1-def-table $(PRCDIR)/prc_def.csv

#
#  オフセットファイル生成のための定義
#
OFFSET_TF = $(PRCDIR)/prc_offset.tf
