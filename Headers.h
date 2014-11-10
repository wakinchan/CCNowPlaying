//
//  Headers.h
//  CCNowPlaying
//
//  Created by kinda on 01.01.2014.
//  Copyright (c) 2014 kinda. All rights reserved.
//

#ifndef kCFCoreFoundationVersionNumber_iOS_8_0
#define kCFCoreFoundationVersionNumber_iOS_8_0 1141.14
// #define kCFCoreFoundationVersionNumber_iOS_8_0 1129.15
#endif

#define IS_IOS8() (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0)


@interface SBUIControlCenterButton : UIButton
+ (void)initialize;
+ (id)circularButton;
+ (id)circularButtonWithGlyphImage:(id)image;
+ (id)roundRectButton;
+ (id)roundRectButtonWithGlyphImage:(id)image;
- (void)_updateSelected:(BOOL)selected highlighted:(BOOL)highlighted;
+ (id)_buttonWithBGImage:(id)bgImage1 selectedBGImage:(id)bgImage2 glyphImage:(id)glyphImage naturalHeight:(float)height;

// iOS 8 or heigher.
+ (id)_buttonWithBGImage:(id)bgImage1 glyphImage:(id)glyphImage naturalHeight:(float)height;
- (void)setIsCircleButton:(BOOL)arg1;
- (void)setIsRectButton:(BOOL)arg1;
@end

@interface SBControlCenterSectionViewController : UIViewController {
    // id<SBControlCenterSectionViewControllerDelegate> _delegate;
}
// @property(readonly, assign, nonatomic) NSString* sectionIdentifier;
// @property(assign, nonatomic) id<SBControlCenterSectionViewControllerDelegate> delegate;
+ (Class)viewClass;
- (void)controlCenterDidFinishTransition;
- (void)controlCenterWillBeginTransition;
- (void)controlCenterDidDismiss;
- (void)controlCenterWillPresent;
- (void)noteSettingsDidUpdate:(id)noteSettings;
- (CGSize)contentSizeForOrientation:(int)orientation;
- (BOOL)enabledForOrientation:(int)orientation;
- (id)view;
- (void)loadView;
@end

@interface MPUNowPlayingController
@property(readonly, nonatomic) UIImage *currentNowPlayingArtwork;
@property(readonly, nonatomic) NSDictionary *currentNowPlayingInfo;
@end

@protocol MPUSystemMediaControlsDelegate <NSObject>
@optional
- (void)systemMediaControlsViewController:(id)controller didTapOnTrackInformationView:(id)view;
- (void)systemMediaControlsViewController:(id)controller didReceiveTapOnControlType:(int)type;
@end

@interface MPUSystemMediaControlsViewController : UIViewController
    // MPUNowPlayingController *_nowPlayingController;
@end

@interface SBCCMediaControlsSectionController : SBControlCenterSectionViewController <MPUSystemMediaControlsDelegate> {
    // MPUSystemMediaControlsViewController* _systemMediaViewController;
}

- (void)systemMediaControlsViewController:(id)controller didReceiveTapOnControlType:(int)type;
- (void)viewDidLoad;
- (CGSize)contentSizeForOrientation:(int)orientation;
- (id)sectionIdentifier;
- (void)dealloc;
- (id)initWithNibName:(id)nibName bundle:(id)bundle;

- (void)addButtons;
- (void)clearButton:(UIView *)containerView;
- (SBUIControlCenterButton *)makeGlyphButton:(int)choice;
- (void)handleMessageNamed:(NSString *)name userInfo:(NSDictionary *)userInfo;
- (void)dismissNotificationCenter;

- (void)makeShareComposeViewController:(int)choice;
- (NSDictionary *)currentNowPlayingInfo;
- (UIImage *)currentNowPlayingArtwork;
- (NSString *)getImageName:(int)choice;
- (NSString *)getServiceType:(int)choice;
- (NSString *)getServiceTypeName:(int)choice;
- (NSString *)getAccountTypeIdentifier:(int)choice;

- (NSString *)platforms;
- (BOOL)isPad;
- (BOOL)orientationIsPortrait;
@end

@interface SBMediaController
+ (id)sharedInstance;
- (id)nowPlayingAlbum;
- (id)nowPlayingTitle;
- (id)nowPlayingArtist;
- (id)nowPlayingApplication;
- (id)_nowPlayingInfo;
- (BOOL)isPlaying;
@end


@interface SpringBoard : UIApplication
- (BOOL)isLocked;
- (void)requestDeviceUnlock;
- (int)activeInterfaceOrientation;
@end

@interface SBUserAgent
+ (id)sharedUserAgent;
- (BOOL)deviceIsPasscodeLockedRemotely;
- (BOOL)deviceIsPasscodeLocked;
@end

@interface SBApplication
- (id)displayName;
@end

@interface SBControlCenterController
+ (id)sharedInstance;
- (void)dismissAnimated:(BOOL)arg1;
@end

@interface SBNotificationCenterController
+ (id)sharedInstance;
- (void)dismissAnimated:(BOOL)arg1;
@end

@interface UIViewController (CCNowPlaying)
- (void)setInterfaceOrientation:(int)arg1;
@end

@interface UIWindow (CCNowPlaying)
+ (id)keyWindow;
- (id)firstResponder;
@end
