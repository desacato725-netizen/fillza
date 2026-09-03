TARGET := iphone:clang:17.5:15.0
ARCHS = arm64 arm64e
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SleepStoreAuth
SleepStoreAuth_FILES = LoginViewController.m SleepStoreAuthGate.m SleepStoreAuthIntegration.m
SleepStoreAuth_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-nonportable-include-path
SleepStoreAuth_OBJCFLAGS = $(SleepStoreAuth_CFLAGS)
SleepStoreAuth_FRAMEWORKS = UIKit Foundation Security
SleepStoreAuth_INSTALL_TARGET_PROCESSES = ARIFIxIOS
include $(THEOS_MAKE_PATH)/tweak.mk
