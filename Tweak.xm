//
//  Tweak.xm
//  CCNowPlaying
//
//  Created by kinda on 01.01.2014.
//  Copyright (c) 2014 kinda. All rights reserved.
//

%config(generator=MobileSubstrate);
UIKIT_EXTERN UIApplication* UIApp;

#import <Social/Social.h>
#import <QuartzCore/QuartzCore.h>
#import <Accounts/Accounts.h>
#import <AppSupport/AppSupport.h>
#import "substrate.h"
#import "Headers.h"

static NSString *kArtist = @"_ARTIST_";
static NSString *kSong = @"_SONG_";
static NSString *kAlbum = @"_ALBUM_";
static NSString *kApplication = @"_APP_";

static int leftChoice;
static int rightChoice;
static int leftBtnStyle;
static int rightBtnStyle;

static NSString *format;
static NSString *formatNoArtwork;
static BOOL isArtwork;
static BOOL isAutoCloseCC;
static BOOL isShowWhenPlaying;
static BOOL isEnableEgg;
static BOOL isRemoveSpace;
static float position;

static SBMediaController *mc = nil;
static SLComposeViewController *vc = nil;
static SBAppSwitcherController *asc = nil;
static CPDistributedMessagingCenter *c = nil;
static SBCCMediaControlsSectionController *sc = nil;
static int choice = 0;

static NSString * GetImageName(int choice);
static NSString * GetServiceType(int choice);
static NSString * GetServiceTypeName(int choice);
static NSString * GetAccountTypeIdentifier(int choice);
static void ClearButton(UIView * view);
static SBUIControlCenterButton * MakeGlyphButton(int choice, int rightOrLeft);
static void AddButtons(id cself, BOOL isUmino);
static BOOL IsPad();
static BOOL OrientationIsPortrait();
static MPUNowPlayingController * GetNowPlayingConteroller(id cself);
static UIImage * CurrentNowPlayingArtwork(id cself);
static NSDictionary * CurrentNowPlayingInfo(id cself);
static void ShowComposeViewController(id cself, id parent, int choice);
static void DismissControlCenter();

static NSString * GetImageName(int choice)
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

static NSString * GetServiceType(int choice)
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

static NSString * GetServiceTypeName(int choice)
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

static NSString * GetAccountTypeIdentifier(int choice)
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

static void ClearButton(UIView * view)
{
    for (id subview in [view subviews]) {
        if ([subview isKindOfClass:[%c(SBUIControlCenterButton) class]]) {
            [subview removeFromSuperview];
        }
    }
}

static SBUIControlCenterButton * MakeGlyphButton(int choice, int rightOrLeft)
{
    UIImage *img = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"/Library/Application Support/CCNowPlaying/%@.png", GetImageName(choice)]];
    SBUIControlCenterButton *btn = [%c(SBUIControlCenterButton) new];
    switch (rightOrLeft == 0 ? leftBtnStyle : rightBtnStyle) {
        default:
        case 0:
            if ([[%c(SBUIControlCenterButton) class] respondsToSelector:@selector(_buttonWithBGImage:glyphImage:naturalHeight:)]) {
                btn = [%c(SBUIControlCenterButton) _buttonWithBGImage:nil glyphImage:img naturalHeight:0.0];
            } else {
                btn = [%c(SBUIControlCenterButton) _buttonWithBGImage:nil selectedBGImage:nil glyphImage:img naturalHeight:0.0];
            }
            break;
        case 1:
            if ([[%c(SBUIControlCenterButton) class] respondsToSelector:@selector(_buttonWithBGImage:glyphImage:naturalHeight:)]) {
                btn = [%c(SBUIControlCenterButton) _buttonWithBGImage:nil glyphImage:img naturalHeight:0.0];
                [btn setIsCircleButton:YES];
            } else {
                btn = [%c(SBUIControlCenterButton) circularButtonWithGlyphImage:img];
            }
            break;
        case 2:
            if ([[%c(SBUIControlCenterButton) class] respondsToSelector:@selector(_buttonWithBGImage:glyphImage:naturalHeight:)]) {
                btn = [%c(SBUIControlCenterButton) _buttonWithBGImage:nil glyphImage:img naturalHeight:0.0];
                [btn setIsRectButton:YES];
            } else {
                btn = [%c(SBUIControlCenterButton) roundRectButtonWithGlyphImage:img];
            }
            break;
    }
    return btn;
}

static void AddButtons(id cself, BOOL isUmino)
{
    if (leftChoice != 0) {
        SBUIControlCenterButton *leftBtn = MakeGlyphButton(leftChoice, 0);
        [leftBtn addTarget:cself action:@selector(leftButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        if (IsPad()) {
            float scale = [[UIScreen mainScreen] scale];
            leftBtn.frame = CGRectMake(OrientationIsPortrait() ? -(2.5*scale) : 17.5*scale, OrientationIsPortrait() ? 11.0*scale : 10.0*scale, 20.0*scale, 20.0*scale);
        } else {
            if (isUmino) {
                leftBtn.frame = CGRectMake(3.0, 163.0+position, 40.0, 40.0);
            } else {
                leftBtn.frame = CGRectMake(10.0, 71.0+position, 40.0, 40.0);
            }
        }
        if (isUmino) {
            [cself addSubview:leftBtn];
        } else {
            [[cself view] addSubview:leftBtn];
        }
    }

    if (rightChoice != 0) {
        SBUIControlCenterButton *rightBtn = MakeGlyphButton(rightChoice, 1);
        [rightBtn addTarget:cself action:@selector(rightButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        if (IsPad()) {
            float scale = [[UIScreen mainScreen] scale];
            rightBtn.frame = CGRectMake(OrientationIsPortrait() ? 90.0*scale : 111.0*scale, OrientationIsPortrait() ? 11.0*scale : 10.0*scale, 20.0*scale, 20.0*scale);
        } else {
            CGSize s = [[UIScreen mainScreen] applicationFrame].size;
            float w = (s.width < s.height) ? s.width : s.height;
            if (isUmino) {
                rightBtn.frame = CGRectMake(w-40.0-3.0, 163.0+position, 40.0, 40.0);
            } else {
                rightBtn.frame = CGRectMake(w-40.0-3.0, 71.0+position, 40.0, 40.0);
            }
        }
        if (isUmino) {
            [cself addSubview:rightBtn];
        } else {
            [[cself view] addSubview:rightBtn];
        }
    }
}

static BOOL IsPad()
{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

static BOOL OrientationIsPortrait()
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

static MPUNowPlayingController * GetNowPlayingConteroller(id cself)
{
    MPUNowPlayingController *npc = nil;
    if ([cself isKindOfClass:[%c(SBCCMediaControlsSectionController) class]]) {
        MPUSystemMediaControlsViewController *smc = MSHookIvar<MPUSystemMediaControlsViewController *>(cself, "_systemMediaViewController");
        npc = MSHookIvar<MPUNowPlayingController *>(smc, "_nowPlayingController");
    } else {
        npc = MSHookIvar<MPUNowPlayingController *>(cself, "_nowPlayingController");
    }
    return npc;
}

static UIImage * CurrentNowPlayingArtwork(id cself)
{
    MPUNowPlayingController *npc = GetNowPlayingConteroller(cself);
    return [npc currentNowPlayingArtwork];
}

static NSDictionary * CurrentNowPlayingInfo(id cself)
{
    MPUNowPlayingController *npc = GetNowPlayingConteroller(cself);
    return [npc currentNowPlayingInfo];
}

static void ShowComposeViewController(id cself, id parent, int choice)
{
    if (vc) vc = nil;
    NSString *type = GetServiceType(choice);
    NSString *typeName = GetServiceTypeName(choice);
    NSString *accountTypeIdentifier = GetAccountTypeIdentifier(choice);

    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:accountTypeIdentifier];

    // check accounts.
    NSArray *accounts = [accountStore accountsWithAccountType:accountType];
    if (accounts.count == 0) {
        [[[UIAlertView alloc] initWithTitle:@"CCNowPlaying" message:[NSString stringWithFormat:@"Please set from iOS default \"%@\" section.", typeName] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        if (isAutoCloseCC) {
            DismissControlCenter();
        }
        return;
    }

    vc = [SLComposeViewController composeViewControllerForServiceType:type];
    vc.completionHandler = ^(SLComposeViewControllerResult result) {
        [parent dismissViewControllerAnimated:YES completion:nil];
        vc = nil;
        if (isAutoCloseCC) {
            DismissControlCenter();
        }
    };

    if ([mc isPlaying]) {
        // NOTE: SBMediaController(nowPlayingAlbum, nowPlayingTitle, nowPlayingArtist) is dead on iOS 8.
        // get artwork
        UIImage *artwork = CurrentNowPlayingArtwork(cself);

        // get song info
        NSDictionary *info = CurrentNowPlayingInfo(cself);
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
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [parent presentViewController:vc animated:YES completion:nil];
        });
    } else {
        [parent presentViewController:vc animated:YES completion:nil];
    }
}

static void DismissControlCenter()
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

%hook SBMediaController
- (void)setNowPlayingInfo:(id)info
{
    %orig;
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(globalQueue, ^{
        dispatch_queue_t subQueue = dispatch_queue_create(CCNOWPLAYING_DISPATCH_QUEUE, NULL);
        dispatch_sync(subQueue, ^{
            [c sendMessageName:SEND_MESSAGE_NAME_INFO_CHANGED userInfo:nil];
            [c sendMessageName:SEND_MESSAGE_NAME_AUXO_3_CHANGED userInfo:nil];
        });
    });
}
%end

%hook SBCCMediaControlsSectionController
- (void)viewDidLoad
{
    %orig;
    if (!isShowWhenPlaying) {
        ClearButton(self.view);
        AddButtons(self, NO);
    }
    if (!c) {
        c = [CPDistributedMessagingCenter centerNamed:CCNOWPLAYING_CENTER_NAME];
        [c runServerOnCurrentThread];
    }
    [c registerForMessageName:SEND_MESSAGE_NAME_INFO_CHANGED target:self selector:@selector(handleMessageNamed:userInfo:)];
}

%new
- (void)handleMessageNamed:(NSString *)name userInfo:(NSDictionary *)userInfo
{
    if (!mc) mc = [[%c(SBMediaController) sharedInstance] init];
    if ([name isEqualToString:SEND_MESSAGE_NAME_INFO_CHANGED]) {
        if (![mc isPlaying] && isShowWhenPlaying) {
            ClearButton(self.view);
        } else {
            ClearButton(self.view);
            AddButtons(self, NO);
        }
    }
}

%new
- (void)leftButtonTapped:(id)sender
{
    [self handleTaped:leftChoice withSender:sender];
}

%new
- (void)rightButtonTapped:(id)sender
{
    [self handleTaped:rightChoice withSender:sender];
}

%new
- (void)handleTaped:(int)tapedChoice withSender:(id)sender
{
    sc = self;
    choice = tapedChoice;
    [(SBUIControlCenterButton *)sender _updateSelected:NO highlighted:NO];
    // Device can not launch the appex from a locked state by further strengthening sandbox in iOS 8.
    // If you attempt to launch forcibly, SpringBoard would crash.
    // I have more of a good solution cannot think..
    if (IS_IOS8() && [[%c(SBUserAgent) sharedUserAgent] deviceIsPasscodeLocked]) {
        [(SpringBoard *)UIApp requestDeviceUnlock];
        return;
    }
    ShowComposeViewController(self, self, choice);
}
%end

%hook SBLockScreenManager
- (BOOL)attemptUnlockWithPasscode:(id)passcode
{
    BOOL success = %orig;
    if (success) {
        if (sc) {
            ShowComposeViewController(sc, sc, choice);
        }
    }
    return success;
}
%end

%hook SpringBoard
- (void)_lockButtonDown:(id)arg1 fromSource:(int)arg2
{
    if (sc) {
        [vc dismissViewControllerAnimated:YES completion:^{
            vc = nil;
            DismissControlCenter();
        }];
    }
    return %orig;
}
%end

%hook SBControlCenterController
- (void)dismissAnimated:(BOOL)animated
{
    if (!vc) %orig;
}

- (void)_dismissWithDuration:(double)duration additionalAnimations:(id)animations completion:(id)completion
{
    if (!vc) %orig;
}

- (void)dismissAnimated:(BOOL)animated withAdditionalAnimations:(id)animations completion:(id)completion
{
    if (!vc) %orig;
}

- (void)dismissAnimated:(BOOL)animated completion:(id)completion
{
    if (!vc) %orig;
}

-(void)_beginPresentation
{
    %orig;
    [c sendMessageName:SEND_MESSAGE_NAME_INFO_CHANGED userInfo:nil];
}
%end


%group Auxo3
%hook UminoControlCenterBottomView
- (void)scrollViewWillBeginDragging:(UminoControlCenterBottomScrollView *)scrollView
{
    [self alphaButtonWithScrollView:scrollView];
    %orig;
}

- (void)scrollViewDidScroll:(UminoControlCenterBottomScrollView *)scrollView
{
    [self alphaButtonWithScrollView:scrollView];
    %orig;
}

%new
- (void)alphaButtonWithScrollView:(UminoControlCenterBottomScrollView *)scrollView
{
    for (id subview in [self subviews]) {
        if ([subview isKindOfClass:[%c(SBUIControlCenterButton) class]]) {
            UIButton *ccb = subview;
            ccb.alpha = 1.0-(scrollView.contentOffset.y/AUXO_3_TRACK_INFO_VIEW_HEIGHT);
        }
    }
}

- (void)layoutSubviews
{
    %orig;
    if (!isShowWhenPlaying) {
        ClearButton(self);
        AddButtons(self, YES);
        UminoControlCenterBottomScrollView *scrollView = MSHookIvar<UminoControlCenterBottomScrollView *>(self, "_scrollView");
        [self alphaButtonWithScrollView:scrollView];
    }
    if (!c) {
        c = [CPDistributedMessagingCenter centerNamed:CCNOWPLAYING_CENTER_NAME_AUXO_3];
        [c runServerOnCurrentThread];
    }
    [c registerForMessageName:SEND_MESSAGE_NAME_AUXO_3_CHANGED target:self selector:@selector(handleMessageNamed:userInfo:)];
}

%new
- (void)handleMessageNamed:(NSString *)name userInfo:(NSDictionary *)userInfo
{
    if (!mc) mc = [[%c(SBMediaController) sharedInstance] init];
    if ([name isEqualToString:SEND_MESSAGE_NAME_AUXO_3_CHANGED]) {
        if (![mc isPlaying] && isShowWhenPlaying) {
            ClearButton(self);
        } else {
            ClearButton(self);
            AddButtons(self, YES);
            UminoControlCenterBottomScrollView *scrollView = MSHookIvar<UminoControlCenterBottomScrollView *>(self, "_scrollView");
            [self alphaButtonWithScrollView:scrollView];
        }
    }
}

%new
- (void)leftButtonTapped:(id)sender
{
    [self handleTaped:leftChoice withSender:sender];
}

%new
- (void)rightButtonTapped:(id)sender
{
    [self handleTaped:rightChoice withSender:sender];
}

%new
- (void)handleTaped:(int)tapedChoice withSender:(id)sender
{
    [(SBUIControlCenterButton *)sender _updateSelected:NO highlighted:NO];
    asc = [[%c(SBUIController) sharedInstance] switcherController];
    [asc addObserver:self forKeyPath:@"startingDisplayLayout" options:NSKeyValueObservingOptionNew context:nil];
    ShowComposeViewController(self, asc, tapedChoice);
}

%new
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqual:@"startingDisplayLayout"]) {
        if (change[@"new"] == [NSNull null]) {
            [vc dismissViewControllerAnimated:YES completion:^{
                vc = nil;
            }];
            [asc removeObserver:self forKeyPath:@"startingDisplayLayout"];
        }
    }
}
%end

%hook UminoTrackInfoView
- (id)initWithFrame:(CGRect)rect
{
    rect.origin.x+=60.f;
    rect.size.width-=60.f;
    return %orig(rect);
}
%end
%end

%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)application
{
    %orig;
    if (IS_IOS8()) {
        %init(Auxo3);
    }
}
%end

static void LoadSettings()
{
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:CCNOWPLAYING_PREFERENCES_PATH];
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

    id existLeftBtnStyle = [dict objectForKey:@"leftBtnImage"];
    leftBtnStyle = existLeftBtnStyle ? [existLeftBtnStyle intValue] : 1;
    id existRightBtnStyle = [dict objectForKey:@"rightBtnImage"];
    rightBtnStyle = existRightBtnStyle ? [existRightBtnStyle intValue] : 1;

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
