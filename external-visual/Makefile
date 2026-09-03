TARGET := iphone:clang:17.5:15.0
ARCHS = arm64 arm64e
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SleepStoreVisual
SleepStoreVisual_FILES = NativeVisualPatch.m
SleepStoreVisual_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
SleepStoreVisual_OBJCFLAGS = $(SleepStoreVisual_CFLAGS)
SleepStoreVisual_FRAMEWORKS = UIKit Foundation
SleepStoreVisual_INSTALL_TARGET_PROCESSES = ARIFIxIOS
include $(THEOS_MAKE_PATH)/tweak.mk
