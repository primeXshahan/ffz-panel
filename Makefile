ARCHS = arm64
DEBUG = 0
FINALPACKAGE = 1
FOR_RELEASE = 1
THEOS_PACKAGE_SCHEME = rootless
THEOS_LEAN_AND_MEAN = 1
THEOS_NO_DEFAULTS = 1
# TARGET: deployment target only (15.0 for iPhone 7 compatibility)
# SDK path: set via SYSROOT env var by GitHub Actions workflow
# On iPhone (no SYSROOT): Theos uses its bundled SDK
TARGET = iphone:clang:15.0
FRAMEWORK_OUTPUT_DIR = res

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ffz



$(TWEAK_NAME)_CCFLAGS = -std=c++17 -fno-rtti -DNDEBUG -Wall -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-value -Wno-unused-function -Wno-module-import-in-extern-c -fvisibility=default -x objective-c++

$(TWEAK_NAME)_CFLAGS = -fobjc-arc -Wall -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-value -Wno-unused-function -fvisibility=default

$(TWEAK_NAME)_LDFLAGS = -lSystem
$(TWEAK_NAME)_LDFLAGS += -L$(THEOS_PROJECT_DIR)
$(TWEAK_NAME)_LDFLAGS += API/libAPIClient.a
$(TWEAK_NAME)_LDFLAGS += JRMemory.framework/JRMemory 

KITTYMEMORY_PATH = KittyMemory
$(TWEAK_NAME)_OBJ_FILES = $(KITTYMEMORY_PATH)/Deps/Keystone/libs-ios/$(THEOS_CURRENT_ARCH)/libkeystone.a

ifeq ($(IGNORE_WARNINGS),1)
  $(TWEAK_NAME)_CFLAGS += -w
  $(TWEAK_NAME)_CCFLAGS += -w
endif

$(TWEAK_NAME)_FRAMEWORKS = UIKit Foundation Security QuartzCore CoreGraphics CoreText AVFoundation Accelerate GLKit SystemConfiguration GameController

$(TWEAK_NAME)_FILES = Draw.mm Themes/ThemeManager.mm menuUIKIT/buttons.mm Themes/UIComponents.mm menuUIKIT/touchView.mm $(wildcard Others/*.mm) $(wildcard Web/*.mm) $(wildcard Esp/*.mm) $(wildcard Hosts/*.m) $(wildcard Hosts/*.mm) $(wildcard Hidestream/*.mm) $(wildcard JRMemory.framework/*.mm) $(wildcard KittyMemory/*.mm) $(wildcard KittyMemory/*.cpp) $(wildcard Esp/*.m) $(wildcard hook/*.c) Helper/KeyAuth.mm

include $(THEOS_MAKE_PATH)/tweak.mk
