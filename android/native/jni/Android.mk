RARCH_VERSION		= "0.9.8-beta2"
LOCAL_PATH := $(call my-dir)
PERF_TEST := 0
HAVE_OPENSL     := 1

include $(CLEAR_VARS)

ifeq ($(TARGET_ARCH),arm)
LOCAL_CFLAGS += -DANDROID_ARM -marm
LOCAL_ARM_MODE := arm
endif

ifeq ($(TARGET_ARCH),x86)
LOCAL_CFLAGS += -DANDROID_X86 -DHAVE_SSSE3
endif

ifeq ($(TARGET_ARCH_ABI),armeabi-v7a)
#LOCAL_CFLAGS += -mfpu=neon
LOCAL_CFLAGS += -DANDROID_ARM_V7
endif

ifeq ($(TARGET_ARCH),mips)
LOCAL_CFLAGS += -DANDROID_MIPS -D__mips__ -D__MIPSEL__
endif

LOCAL_MODULE    := retroarch-activity

RARCH_PATH  := ../../..
LOCAL_SRC_FILES    =	$(RARCH_PATH)/console/griffin/griffin.c

ifeq ($(PERF_TEST), 1)
LOCAL_CFLAGS += -DPERF_TEST
endif

LOCAL_CFLAGS += -O3 -fno-stack-protector -funroll-loops -DNDEBUG -DHAVE_GRIFFIN -DANDROID -DHAVE_DYNAMIC -DHAVE_OPENGL -DHAVE_OPENGLES -DHAVE_VID_CONTEXT -DHAVE_OPENGLES2 -DGLSL_DEBUG -DHAVE_GLSL -DHAVE_ZLIB -DINLINE=inline -DLSB_FIRST -DHAVE_THREAD -D__LIBRETRO__ -DHAVE_CONFIGFILE=1 -DRARCH_PERFORMANCE_MODE -DRARCH_GPU_PERFORMANCE_MODE -DPACKAGE_VERSION=\"$(RARCH_VERSION)\" -std=gnu99

LOCAL_LDLIBS	:= -L$(SYSROOT)/usr/lib -landroid -lEGL -lGLESv2 -llog -ldl -lz

ifeq ($(HAVE_OPENSL), 1)
LOCAL_CFLAGS += -DHAVE_SL
LOCAL_LDLIBS += -lOpenSLES
endif

include $(BUILD_SHARED_LIBRARY)
