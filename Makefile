export ARCHS = armv7 armv7s arm64
export TARGET_IPHONEOS_DEPLOYMENT_VERSION = 7.0
export GO_EASY_ON_ME = 1
export THEOS_BUILD_DIR = debs

include /opt/theos/makefiles/common.mk

TWEAK_NAME = CCNowPlaying
CCNowPlaying_FILES = Tweak.xm
CCNowPlaying_CFLAGS = -fobjc-arc
CCNowPlaying_FRAMEWORKS = UIKit Social Accounts QuartzCore
CCNowPlaying_PRIVATE_FRAMEWORKS = AppSupport
CCNowPlaying_LIBRARIES = substrate

include $(THEOS_MAKE_PATH)/tweak.mk

BUNDLE_NAME = CCNowPlayingSettings
CCNowPlayingSettings_FILES = Preference.m
CCNowPlayingSettings_CFLAGS = -fobjc-arc
CCNowPlayingSettings_INSTALL_PATH = /Library/PreferenceBundles
CCNowPlayingSettings_FRAMEWORKS = UIKit Social Accounts
CCNowPlayingSettings_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

after-install::
	install.exec "killall -9 SpringBoard"

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/CCNowPlaying.plist$(ECHO_END)
