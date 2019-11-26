//
//  BDMFullscreenAdDisplayHelper.m
//  BidMachine
//
//  Created by Stas Kochkin on 26/10/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMFullscreenAdDisplayAd.h"
#import "NSError+BDMSdk.h"
#import <StackFoundation/StackFoundation.h>
#import "BDMSdk+Project.h"


@interface BDMFullscreenAdDisplayAd () <BDMFullscreenAdapterDisplayDelegate>

@property (nonatomic, strong) id<BDMFullscreenAdapter> adapter;
@property (nonatomic, weak) UIViewController *rootViewController;
@property (nonatomic, assign) NSTimeInterval startViewTimestamp;

@end


@implementation BDMFullscreenAdDisplayAd

#pragma mark - BDMDisplayAd

+ (instancetype)displayAdWithResponse:(id<BDMResponse>)response placementType:(BDMInternalPlacementType)placementType {
    if (placementType > BDMInternalPlacementTypeRewardedVideo) {
        BDMLog(@"Trying to initialise BDMFullscreenAdDisplayAd with placement of unsupported type");
        return nil;
    }
    
    id <BDMFullscreenAdapter> adapter;
    BDMFullscreenAdDisplayAd * displayAd = [[BDMFullscreenAdDisplayAd alloc] initWithResponse:response];
    switch (response.creative.format) {
        case BDMCreativeFormatVideo: adapter = [BDMSdk.sharedSdk videoAdapterForNetwork:displayAd.displayManager]; break;
        default: adapter = [BDMSdk.sharedSdk interstitialAdAdapterForNetwork:displayAd.displayManager]; break;
    }
    
    if (placementType == BDMInternalPlacementTypeRewardedVideo &&
        [adapter respondsToSelector:@selector(setRewarded:)]) {
        [adapter setRewarded:YES];
    }
    
    displayAd.adapter = adapter;
    adapter.displayDelegate = displayAd;
    
    return displayAd;
}

- (void)invalidate {
    self.adapter = nil;
    [super invalidate];
}

- (UIView *)adView {
    return self.adapter.adView;
}

- (void)prepare {
    [self prepareAdapter:self.adapter];
}

- (void)presentAd:(UIViewController *)controller container:(UIView *)container {
    BDMLog(@"Trying to present fullscreen adapter: %@ from root view controller: %@", self.adapter, controller);
    if (![BDMSdk.sharedSdk isDeviceReachable]) {
        NSError * error = [NSError bdm_errorWithCode:BDMErrorCodeNoConnection description:@"You don't have internet connection."];
        [self.delegate displayAd:self failedToPresent:error];
        return;
    }
    
    self.rootViewController = controller;
    @try {
        [self.adapter present];
    } @catch (NSException *exception) {
        BDMLog(@"Adapter: %@ raised exception: %@", self.adapter, exception);
        [self.delegate displayAd:self failedToPresent:exception.bdm_wrappedError];
    }
}

#pragma mark - BDMFullscreenAdapterDisplayDelegate

- (void)adapter:(id<BDMAdapter>)adapter failedToPresentAdWithError:(NSError *)error {
    BDMLog(@"Adapter: %@ failed to present with error: %@", adapter, error);
    [self.delegate displayAd:self failedToPresent:error];
}

- (UIViewController *)rootViewControllerForAdapter:(id<BDMFullscreenAdapter>)adapter {
    return self.rootViewController;
}

- (void)adapterWillPresent:(id<BDMFullscreenAdapter>)adapter {
    BDMLog(@"Adapter: %@ will present ad", adapter);
    self.startViewTimestamp = NSDate.stk_currentTimeInMilliseconds;
    [self.delegate displayAdLogStartView:self];
}

- (void)adapterDidDismiss:(id<BDMFullscreenAdapter>)adapter {
    // Log impression if needed
    NSTimeInterval finishViewTimestamp = NSDate.stk_currentTimeInMilliseconds;
    if ((finishViewTimestamp - self.startViewTimestamp) > self.viewabilityConfig.impressionInterval) {
        BDMLog(@"Adapter: %@ will log impression", adapter);
        [self.delegate displayAdLogImpression:self];
    }
    // Log finish needed
    BDMLog(@"Adapter: %@ will dismiss", adapter);
    [self.delegate displayAdLogFinishView:self];
}

- (void)adapterRegisterUserInteraction:(id<BDMFullscreenAdapter>)adapter {
    BDMLog(@"Adapter: %@ will log user interaction", adapter);
    [self.delegate displayAdLogUserInteraction:self];
}

- (void)adapterFinishRewardAction:(id<BDMFullscreenAdapter>)adapter {
    BDMLog(@"Adapter: %@ finish reward action", adapter);
    if ([self.delegate respondsToSelector:@selector(displayAdCompleteRewardAction:)]) {
        [self.delegate displayAdCompleteRewardAction:self];
    }
}

@end
