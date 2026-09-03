TARGET := iphone:clang:17.5:15.0
ARCHS = arm64 arm64e
include $(THEOS)/makefiles/common.mk
TWEAK_NAME = SleepNativeBridge
SleepNativeBridge_FILES = NativeSleepPatch.m
SleepNativeBridge_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-nonportable-include-path -Wno-arc-performSelector-leaks
SleepNativeBridge_OBJCFLAGS = $(SleepNativeBridge_CFLAGS)
SleepNativeBridge_FRAMEWORKS = UIKit Foundation Security
SleepNativeBridge_INSTALL_TARGET_PROCESSES = ARIFIxIOS
include $(THEOS_MAKE_PATH)/tweak.mk
