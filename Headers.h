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

#define AUXO_3_TRACK_INFO_VIEW_HEIGHT 73.0
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
- (void)setIsCircleButton:(BOOL)button;
- (void)setIsRectButton:(BOOL)button;
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
- (void)handleMessageNamed:(NSString *)name userInfo:(NSDictionary *)userInfo;
- (void)handleTaped:(int)tapedChoice withSender:(id)sender;
- (void)dismissNotificationCenter;
@end

@interface UminoControlCenterBottomView : UIView
- (void)alphaButtonWithScrollView:(UIView *)scrollView;
- (void)handleMessageNamed:(NSString *)name userInfo:(NSDictionary *)userInfo;
- (void)handleTaped:(int)tapedChoice withSender:(id)sender;
- (void)dismissNotificationCenter;
@end

@interface UminoControlCenterBottomScrollView : UIScrollView
- (_Bool)gestureRecognizer:(id)arg1 shouldReceiveTouch:(id)arg2;
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

@interface SBAppSwitcherController : UIViewController
@end

@interface SBUserAgent
+ (id)sharedUserAgent;
- (BOOL)deviceIsPasscodeLockedRemotely;
- (BOOL)deviceIsPasscodeLocked;
@end

@interface SBApplication
- (id)displayName;
@end

@interface SBUIController
+(id)sharedInstance;
-(id)switcherController;
@end

@interface SBControlCenterController
+ (id)sharedInstance;
- (void)dismissAnimated:(BOOL)animated;
@end

@interface SBNotificationCenterController
+ (id)sharedInstance;
- (void)dismissAnimated:(BOOL)animated;
@end

@interface UIViewController (CCNowPlaying)
- (void)setInterfaceOrientation:(int)orientation;
@end

@interface UIWindow (CCNowPlaying)
+ (id)keyWindow;
- (id)firstResponder;
@end

