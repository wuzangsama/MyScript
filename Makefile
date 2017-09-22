###############################################################################
#
# A smart Makefile template for GNU/LINUX programming
#
# Author: zhanghf@zailingtech.com
# Date:   2017/05/15
#
# Usage:
#   $ make           Compile and link (or archive)
#   $ make clean     Clean the objectives and target.
###############################################################################

# 交叉编译使用，一般不更改
CROSS_COMPILE =
# 需要编译的文件的后缀，一般不需要修改
SUFFIX        = c cpp cc cxx hpp
# 优化级别，debug版不优化，方便调试，release可以修改
OPTIMIZE := -O0
# 告警输出，一般不更改
WARNINGS := -Wall -Wno-unused -Wno-format
# 可以添加代码中使用的宏定义
DEFS     := 
# 额外的编译选项
EXTRA_CFLAGS  := 
# 额外的链接选项
EXTRA_LDFLAGS := 
# 源目录，当前目录已经默认包含
SRC_DIR   = 
# 额外的src文件
EXTRA_SRC = 
# 需要排除的src文件
EXCLUDE_FILES  = 

#############################主要修改项#########################################
# include目录
INC_DIR   = ../main 
# 需要链接的库
LIBS     := ../../bin/x64/libzllog.so.1 ../../bin/x64/liblog4cxx.so.10 ../../bin/x64/libapr-1.so.0.5.2 ../../bin/x64/libaprutil-1.so.0.5.4 -pthread
# .o文件输出路径
OBJ_DIR   = out/target
# 目标输出路径及名称，路径必须存在，否则失败
TARGET   := ../../bin/x64/test

# TYPE根据需要修改，ar是编译静态库，app是编译可执行程序，so是编译动态库
#TARGET_TYPE  := ar
TARGET_TYPE  := app
#TARGET_TYPE  := so


#####################################################################################
#  Do not change any part of them unless you have understood this script very well  #
#  This is a kind remind.                                                           #
#####################################################################################

#FUNC#  Add a new line to the input stream.
define add_newline
$1

endef

#FUNC# set the variable `src-x' according to the input $1
define set_src_x
src-$1 = $(filter-out $4,$(foreach d,$2,$(wildcard $d/*.$1)) $(filter %.$1,$3))

endef

#FUNC# set the variable `obj-x' according to the input $1
define set_obj_x
obj-$1 = $(patsubst %.$1,$3%.$1.o,$(notdir $2))

endef

#VAR# Get the uniform representation of the object directory path name
ifneq ($(OBJ_DIR),)
prefix_objdir  = $(shell echo $(OBJ_DIR)|sed 's:\(\./*\)*::')
prefix_objdir := $(filter-out /,$(prefix_objdir)/)
endif

GCC      := $(CROSS_COMPILE)gcc
G++      := $(CROSS_COMPILE)g++
RANLIB   := $(CROSS_COMPILE)ranlib
SUFFIX_CXX := cpp cc cxx hpp
SRC_DIR := $(sort . $(SRC_DIR))
inc_dir = $(foreach d,$(sort $(INC_DIR) $(SRC_DIR)),-I$d)

#--# Do smart deduction automatically
$(eval $(foreach i,$(SUFFIX),$(call set_src_x,$i,$(SRC_DIR),$(EXTRA_SRC),$(EXCLUDE_FILES))))
$(eval $(foreach i,$(SUFFIX),$(call set_obj_x,$i,$(src-$i),$(prefix_objdir))))
$(eval $(foreach f,$(EXTRA_SRC),$(call add_newline,vpath $(notdir $f) $(dir $f))))
$(eval $(foreach d,$(SRC_DIR),$(foreach i,$(SUFFIX),$(call add_newline,vpath %.$i $d))))

all_objs = $(foreach i,$(SUFFIX),$(obj-$i))
all_srcs = $(foreach i,$(SUFFIX),$(src-$i))

CFLAGS       = $(EXTRA_CFLAGS) $(WARNINGS) $(OPTIMIZE) $(DEFS)
LDFLAGS      = -Wl,-rpath=./ $(EXTRA_LDFLAGS)
TARGET_TYPE := $(strip $(TARGET_TYPE))

ifeq ($(filter $(TARGET_TYPE),so ar app),)
$(error Unexpected TARGET_TYPE `$(TARGET_TYPE)')
endif

ifeq ($(TARGET_TYPE),so)
 CFLAGS  += -fpic -shared
 LDFLAGS += -shared
endif

PHONY = all .mkdir clean

all: .mkdir $(TARGET)

define cmd_o
$$(obj-$1): $2%.$1.o: %.$1  $(MAKEFILE_LIST)
	$(if $(filter $1,$(SUFFIX_CXX)),$(G++),$GCC) $(inc_dir) -Wp,-MT,$$@ -Wp,-MMD,$$@.d $(CFLAGS) -c -o $$@ $$<

endef
$(eval $(foreach i,$(SUFFIX),$(call cmd_o,$i,$(prefix_objdir))))

ifeq ($(TARGET_TYPE),ar)
$(TARGET): AR := $(CROSS_COMPILE)ar
$(TARGET): $(all_objs)
	rm -f $@
	$(AR) rcvs $@ $(all_objs)
	$(RANLIB) $@
else
$(TARGET): LD = $(if $(strip $(src-cpp) $(src-cc) $(src-cxx)),$(G++),$(GCC))
$(TARGET): $(all_objs)
	$(LD) $(LDFLAGS) $(all_objs) $(LIBS) -o $@
endif

.mkdir:
	@if [ ! -d $(OBJ_DIR) ]; then mkdir -p $(OBJ_DIR); fi

clean:
	rm -f $(prefix_objdir)*.o $(prefix_objdir)*.d $(TARGET)

-include $(patsubst %.o,%.o.d,$(all_objs))

.PHONY: $(PHONY)

