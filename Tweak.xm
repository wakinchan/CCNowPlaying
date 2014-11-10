//
//  Tweak.xm
//  CCNowPlaying
//
//  Created by kinda on 01.01.2014.
//  Copyright (c) 2014 kinda. All rights reserved.
//

%config(generator=MobileSubstrate);

#import <Social/Social.h>
#import <QuartzCore/QuartzCore.h>
#import <Accounts/ACAccount.h>
#import <Accounts/ACAccountStore.h>
#import <Accounts/ACAccountType.h>
#import <AppSupport/AppSupport.h>
#import <UIKit/UIKit2.h>
#import "substrate.h"
#import "Headers.h"

static NSString *kArtist = @"_ARTIST_";
static NSString *kSong = @"_SONG_";
static NSString *kAlbum = @"_ALBUM_";
static NSString *kApplication = @"_APP_";

static int leftChoice;
static int rightChoice;
static int leftBtnImage;
static int rightBtnImage;

static NSString *format;
static NSString *formatNoArtwork;
static BOOL isArtwork;
static BOOL isAutoCloseCC;
static BOOL isShowWhenPlaying;
static BOOL isEnableEgg;
static BOOL isRemoveSpace;
static float position;

static SBMediaController *mc;
static SLComposeViewController *vc;
static CPDistributedMessagingCenter *c;

static __weak SBCCMediaControlsSectionController *sc = nil;
static int choice = 0;

%hook SBMediaController
- (void)setNowPlayingInfo:(id)info
{
    %orig;
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(globalQueue, ^{
        dispatch_queue_t subQueue = dispatch_queue_create("com.kindadev.ccnowplaying.dispatch", NULL);
        dispatch_sync(subQueue, ^{
            [c sendMessageName:@"com.kindadev.ccnowplaying.info.changed" userInfo:nil];
        });
        dispatch_release(subQueue);
    });
}
%end

%hook SBCCMediaControlsSectionController
- (void)viewDidLoad
{
    %orig;
    if (!isShowWhenPlaying) [self addButtons];
    if (!c) {
        c = [CPDistributedMessagingCenter centerNamed:@"com.kindadev.ccnowplaying.center"];
        [c runServerOnCurrentThread];
    }
    [c registerForMessageName:@"com.kindadev.ccnowplaying.info.changed" target:self selector:@selector(handleMessageNamed:userInfo:)];
}

%new
- (void)handleMessageNamed:(NSString *)name userInfo:(NSDictionary *)userInfo
{
    if (!mc) mc = [[%c(SBMediaController) sharedInstance] init];
    if ([name isEqualToString:@"com.kindadev.ccnowplaying.info.changed"]) {
        if (![mc isPlaying] && isShowWhenPlaying) {
            [self clearButton:self.view];
        } else {
            [self clearButton:self.view];
            [self addButtons];
        }
    }
}

%new
- (void)addButtons
{
    if (leftChoice != 0) {
        SBUIControlCenterButton *leftBtn = [self makeGlyphButton:leftChoice];
        [leftBtn addTarget:self action:@selector(leftButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        if ([self isPad]) {
            float scale = [[UIScreen mainScreen] scale];
            leftBtn.frame = CGRectMake([self orientationIsPortrait] ? -(2.5*scale) : 17.5*scale, [self orientationIsPortrait] ? 11.0*scale : 10.0*scale, 20.0*scale, 20.0*scale);
        } else {
            leftBtn.frame = CGRectMake(10.0, 71.0+position, 40.0, 40.0);
        }
        [self.view addSubview:leftBtn];
    }

    if (rightChoice != 0) {
        SBUIControlCenterButton *rightBtn = [self makeGlyphButton:rightChoice];
        [rightBtn addTarget:self action:@selector(rightButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        if ([self isPad]) {
            float scale = [[UIScreen mainScreen] scale];
            rightBtn.frame = CGRectMake([self orientationIsPortrait] ? 90.0*scale : 111.0*scale, [self orientationIsPortrait] ? 11.0*scale : 10.0*scale, 20.0*scale, 20.0*scale);
        } else {
            CGSize s = self.view.bounds.size;
            float w = (s.width > s.height) ? s.width : s.height;
            rightBtn.frame = CGRectMake(w - 40.0 - 10.0, 71.0 + position, 40.0, 40.0);
        }
        [self.view addSubview:rightBtn];
    }
}

%new
- (SBUIControlCenterButton *)makeGlyphButton:(int)choice
{
    UIImage *img = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"/Library/Application Support/CCNowPlaying/%@.png", [self getImageName:choice]]];
    SBUIControlCenterButton *btn = [%c(SBUIControlCenterButton) new];
    switch (rightBtnImage) {
        default:
        case 0:
            if (IS_IOS8()) {
                btn = [%c(SBUIControlCenterButton) _buttonWithBGImage:nil glyphImage:img naturalHeight:0.0];
            } else {
                btn = [%c(SBUIControlCenterButton) _buttonWithBGImage:nil selectedBGImage:nil glyphImage:img naturalHeight:0.0];
            }
            break;
        case 1:
            if (IS_IOS8()) {
                btn = [%c(SBUIControlCenterButton) _buttonWithBGImage:nil glyphImage:img naturalHeight:0.0];
                [btn setIsCircleButton:YES];
            } else {
                btn = [%c(SBUIControlCenterButton) circularButtonWithGlyphImage:img];
            }
            break;
        case 2:
            if (IS_IOS8()) {
                btn = [%c(SBUIControlCenterButton) _buttonWithBGImage:nil glyphImage:img naturalHeight:0.0];
                [btn setIsRectButton:YES];
            } else {
                btn = [%c(SBUIControlCenterButton) roundRectButtonWithGlyphImage:img];
            }
            break;
    }
    return btn;
}


%new
- (BOOL)isPad
{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

%new
- (BOOL)orientationIsPortrait
{
    switch ([(SpringBoard *)UIApp activeInterfaceOrientation]) {
        default:
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            return YES;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            return NO;
    }
}

%new
- (void)clearButton:(UIView *)view
{
    for (id subview in [view subviews]) {
        if ([subview isKindOfClass:[%c(SBUIControlCenterButton) class]]) {
            [subview removeFromSuperview];
        }
    }
}

%new
- (void)leftButtonTapped:(id)sender
{
    [(SBUIControlCenterButton *)sender _updateSelected:NO highlighted:NO];
    if (IS_IOS8()) {
        if ([[%c(SBUserAgent) sharedUserAgent] deviceIsPasscodeLocked]) {
            sc = self;
            choice = leftChoice;
            [(SpringBoard *)UIApp requestDeviceUnlock];
        } else {
            [self makeShareComposeViewController:leftChoice];
        }
    } else {
        [self makeShareComposeViewController:leftChoice];
    }
}

%new
- (void)rightButtonTapped:(id)sender
{
    [(SBUIControlCenterButton *)sender _updateSelected:NO highlighted:NO];
    if (IS_IOS8()) {
        if ([[%c(SBUserAgent) sharedUserAgent] deviceIsPasscodeLocked]) {
            sc = self;
            choice = rightChoice;
            [(SpringBoard *)UIApp requestDeviceUnlock];
        } else {
            [self makeShareComposeViewController:rightChoice];
        }
    } else {
        [self makeShareComposeViewController:rightChoice];
    }
}

%new
- (void)makeShareComposeViewController:(int)choice
{
    if (vc) vc = nil;

    NSString *type = [self getServiceType:choice];
    NSString *typeName = [self getServiceTypeName:choice];
    NSString *accountTypeIdentifier = [self getAccountTypeIdentifier:choice];

    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:accountTypeIdentifier];

    // check accounts.
    NSArray *accounts = [accountStore accountsWithAccountType:accountType];
    if (accounts.count == 0) {
        [[[UIAlertView alloc] initWithTitle:@"CCNowPlaying" message:[NSString stringWithFormat:@"Please set from iOS default \"%@\" section.", typeName] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        if (isAutoCloseCC) {
            [self dismissNotificationCenter];
        }
        return;
    }

    vc = [SLComposeViewController composeViewControllerForServiceType:type];
    vc.completionHandler = ^(SLComposeViewControllerResult result) {
        [self dismissViewControllerAnimated:YES completion:nil];
        vc = nil;
        [vc release];
        if (isAutoCloseCC) {
            [self dismissNotificationCenter];
        }
    };

    if ([mc isPlaying]) {
        // NOTE: SBMediaController(nowPlayingAlbum, nowPlayingTitle, nowPlayingArtist) is dead on iOS 8.
        // get artwork
        UIImage *artwork = [self currentNowPlayingArtwork];

        // get song info
        NSDictionary *info = [self currentNowPlayingInfo];
        NSString *artist = info[@"kMRMediaRemoteNowPlayingInfoArtist"];
        NSString *album  = info[@"kMRMediaRemoteNowPlayingInfoAlbum"];
        NSString *title  = info[@"kMRMediaRemoteNowPlayingInfoTitle"];

        // get application name
        SBApplication *app = [mc nowPlayingApplication];
        NSString *appName = [NSString stringWithFormat:@"%@", [app displayName]];
        if (isRemoveSpace) appName = [appName stringByReplacingOccurrencesOfString:@" " withString:@""];

        // make share string
        NSString *cStr = [((isEnableEgg && artwork == nil) ? formatNoArtwork : format) stringByReplacingOccurrencesOfString:kArtist withString:[NSString stringWithFormat:@"%@", artist]];
        cStr = [cStr stringByReplacingOccurrencesOfString:kSong withString:[NSString stringWithFormat:@"%@", title]];
        cStr = [cStr stringByReplacingOccurrencesOfString:kAlbum withString:[NSString stringWithFormat:@"%@", album]];
        cStr = [cStr stringByReplacingOccurrencesOfString:kApplication withString:appName];

        [vc setInitialText:cStr];
        if (isArtwork) [vc addImage:artwork];
    }

    if ([[%c(SBUserAgent) sharedUserAgent] deviceIsPasscodeLocked]) {
        NSLog(@"%s: is still locked.", __func__);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self presentViewController:vc animated:YES completion:nil];
        });
    } else {
        [self presentViewController:vc animated:YES completion:nil];
    }
}

%new
- (NSDictionary *)currentNowPlayingInfo
{
    MPUSystemMediaControlsViewController *smc = MSHookIvar<MPUSystemMediaControlsViewController *>(self, "_systemMediaViewController");
    MPUNowPlayingController *npc = MSHookIvar<MPUNowPlayingController *>(smc, "_nowPlayingController");
    return [npc currentNowPlayingInfo];
}

%new
- (UIImage *)currentNowPlayingArtwork
{
    MPUSystemMediaControlsViewController *smc = MSHookIvar<MPUSystemMediaControlsViewController *>(self, "_systemMediaViewController");
    MPUNowPlayingController *npc = MSHookIvar<MPUNowPlayingController *>(smc, "_nowPlayingController");
    return [npc currentNowPlayingArtwork];
}

%new
- (void)dismissNotificationCenter
{
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.hamzasood.multitaskinggestures.plist"];
    id existMCC = [dict objectForKey:@"MoveControlCenter"];
    BOOL isMoveControlCenter = existMCC ? [existMCC boolValue] : YES;
    if ( [[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/MultitaskingGestures.dylib"] && isMoveControlCenter ) {
        [[%c(SBNotificationCenterController) sharedInstance] dismissAnimated:YES];
    } else {
        [[%c(SBControlCenterController) sharedInstance] dismissAnimated:YES];
    }
}

%new
- (NSString *)getImageName:(int)choice
{
    static NSString *imageName;
    switch (choice) {
        case 1: imageName = @"ccNow-twitter"; break;
        case 2: imageName = @"ccNow-faceBk2"; break;
        case 3: imageName = @"ccNow-shina"; break;
        case 4: imageName = @"ccNow-tencent"; break;
        default: imageName = @"ccNow-onpu1"; break;
    }
    return imageName;
}

%new
- (NSString *)getServiceType:(int)choice
{
    static NSString *serviceType;
    switch (choice) {
        default: 
        case 1: serviceType = SLServiceTypeTwitter; break;
        case 2: serviceType = SLServiceTypeFacebook; break;
        case 3: serviceType = SLServiceTypeSinaWeibo; break;
        case 4: serviceType = SLServiceTypeTencentWeibo; break;
    }
    return serviceType;
}

%new
- (NSString *)getServiceTypeName:(int)choice
{
    static NSString *serviceTypeName;
    switch (choice) {
        default: 
        case 1: serviceTypeName = @"Twitter"; break;
        case 2: serviceTypeName = @"Facebook"; break;
        case 3: serviceTypeName = @"Sina Weibo"; break;
        case 4: serviceTypeName = @"Tencent Weibo"; break;
    }
    return serviceTypeName;
}

%new
- (NSString *)getAccountTypeIdentifier:(int)choice
{
    static NSString *accountTypeIdentifier;
    switch (choice) {
        default: 
        case 1: accountTypeIdentifier = ACAccountTypeIdentifierTwitter; break;
        case 2: accountTypeIdentifier = ACAccountTypeIdentifierFacebook; break;
        case 3: accountTypeIdentifier = ACAccountTypeIdentifierSinaWeibo; break;
        case 4: accountTypeIdentifier = ACAccountTypeIdentifierTencentWeibo; break;
    }
    return accountTypeIdentifier;
}
%end

%hook SBControlCenterController
- (void)dismissAnimated:(BOOL)arg1
{
    if (!vc) %orig;
}

- (void)_dismissWithDuration:(double)arg1 additionalAnimations:(id)arg2 completion:(id)arg3
{
    if (!vc) %orig;
}

- (void)dismissAnimated:(BOOL)arg1 withAdditionalAnimations:(id)arg2 completion:(id)arg3
{
    if (!vc) %orig;
}

- (void)dismissAnimated:(BOOL)arg1 completion:(id)arg2
{
    if (!vc) %orig;
}

-(void)_beginPresentation
{
    %orig;
    [c sendMessageName:@"com.kindadev.ccnowplaying.info.changed" userInfo:nil];
}
%end

%hook SBLockScreenManager
- (BOOL)attemptUnlockWithPasscode:(id)passcode
{
    BOOL success = %orig;
    if (success) {
        // dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [sc makeShareComposeViewController:choice];
        // });
    }
    return success;
}
%end

%hook SpringBoard
- (void)_lockButtonDown:(id)arg1 fromSource:(int)arg2
{
    if (vc) {
        [vc dismissViewControllerAnimated:YES completion:^{
            vc = nil;
            [vc release];
            [[%c(SBNotificationCenterController) sharedInstance] dismissAnimated:YES];
        }];
    }
    return %orig;
}
%end



#define PREF_PATH @"/var/mobile/Library/Preferences/com.kindadev.ccnowplaying.plist"

static void LoadSettings()
{
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PREF_PATH];
    id existLeftChoice = [dict objectForKey:@"leftChoice"];
    leftChoice = existLeftChoice ? [existLeftChoice intValue] : 1;
    id existRightChoice = [dict objectForKey:@"rightChoice"];
    rightChoice = existRightChoice ? [existRightChoice intValue] : 2;
    id existFormat = [dict objectForKey:@"format"];
    format = existFormat ? [existFormat copy] : @"#NowPlaying _SONG_ - _ALBUM_ by _ARTIST_ on _APP_";
    id existFormatNoArtwork = [dict objectForKey:@"formatNoArtwork"];
    formatNoArtwork = existFormatNoArtwork ? [existFormatNoArtwork copy] : @"#NowPlaying _SONG_ - _ALBUM_ by _ARTIST_ on _APP_";
    id existArtwork = [dict objectForKey:@"isArtworkEnabled"];
    isArtwork = existArtwork ? [existArtwork boolValue] : YES;
    id existAutoCloseCC = [dict objectForKey:@"autoCloseCC"];
    isAutoCloseCC = existAutoCloseCC ? [existAutoCloseCC boolValue] : YES;
    id existPosition = [dict objectForKey:@"position"];
    position = existPosition ? [existPosition intValue] : 0;
    id existShowWhenPlaying = [dict objectForKey:@"showWhenPlaying"];
    isShowWhenPlaying = existShowWhenPlaying ? [existShowWhenPlaying boolValue] : YES;

    id existLeftBtnImage = [dict objectForKey:@"leftBtnImage"];
    leftBtnImage = existLeftBtnImage ? [existLeftBtnImage intValue] : 1;
    id existRightBtnImage = [dict objectForKey:@"rightBtnImage"];
    rightBtnImage = existRightBtnImage ? [existRightBtnImage intValue] : 1;

    id existEnableEgg = [dict objectForKey:@"enableEgg"];
    isEnableEgg = existEnableEgg ? [existEnableEgg boolValue] : NO;
    id existRemoveSpace = [dict objectForKey:@"removeSpace"];
    isRemoveSpace = existRemoveSpace ? [existRemoveSpace boolValue] : NO;
}

static void PostNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    LoadSettings();
}

%ctor
{
    @autoreleasepool {
        %init;
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, PostNotification, CFSTR("com.kindadev.ccnowplaying.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
        LoadSettings();
    }
}
