DEBUG=0
FINALPACKAGE=1
GO_EASY_ON_ME=1

THEOS_PACKAGE_SCHEME = rootless

THEOS_USE_NEW_ABI=1
TARGET = iphone:clang:latest:14.0
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = CoolCCPref

CoolCCPref_FILES = CCCRootListController.m
CoolCCPref_INSTALL_PATH = /Library/PreferenceBundles
CoolCCPref_FRAMEWORKS = UIKit
CoolCCPref_PRIVATE_FRAMEWORKS = Preferences
CoolCCPref_CFLAGS = -fobjc-arc
CoolCCPref_LIBRARIES = colorpicker

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/CoolCCPref.plist$(ECHO_END)
