#
#		Makefile�̃v���Z�b�T�ˑ����iPIC32MX�p�j
#

#
#  GNU�J�����̃^�[�Q�b�g�A�[�L�e�N�`���̒�`
#
GCC_TARGET = xc32

#
#  �v���Z�b�T�ˑ����f�B���N�g�����̒�`
#
PRCDIR = $(SRCDIR)/arch/$(PRC)_$(TOOL)

#
#  �R���p�C���I�v�V����
#
INCLUDES := $(INCLUDES) \
			-I$(SRCDIR)/arch/$(PRC)_$(TOOL)/framework
COPTS := $(COPTS) -mprocessor=32MX570F512L -ffunction-sections -fgnu89-inline
#LDFLAGS := $(LDFLAGS) -mprocessor=32MX570F512L
LDFLAGS := $(LDFLAGS) -nostartfiles

#
#  �J�[�l���Ɋւ����`
#
KERNEL_DIR := $(KERNEL_DIR) $(PRCDIR) \
			$(SRCDIR)/arch/$(PRC)_$(TOOL)/framework/system/int/src
			
KERNEL_ASMOBJS := $(KERNEL_ASMOBJS) prc_support.o
KERNEL_COBJS := $(KERNEL_COBJS) prc_config.o sys_int_pic32.o

#
#  �R���t�B�M�����[�^�֌W�̕ϐ��̒�`
#
CFG_TABS := $(CFG_TABS) --cfg1-def-table $(PRCDIR)/prc_def.csv

#
#  �I�t�Z�b�g�t�@�C�������̂��߂̒�`
#
OFFSET_TF = $(PRCDIR)/prc_offset.tf
