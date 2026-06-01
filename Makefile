TARGET := iphone:clang:latest:15.0
ARCHS := arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME := NebulaT

NebulaT_FILES := Tweak.x
NebulaT_CFLAGS := -fobjc-arc -O3 -fvisibility=hidden

include $(THEOS_MAKE_PATH)/tweak.mk
