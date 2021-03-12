//
//  BDMBannerRequest.m
//  BidMachine
//
//  Created by Stas Kochkin on 11/01/2019.
//  Copyright © 2019 Appodeal. All rights reserved.
//

#import "BDMAdRequests.h"
#import "BDMRequest+Private.h"

#import <StackFoundation/StackFoundation.h>


@implementation BDMBannerRequest

- (instancetype)init {
    if (self = [super init]) {
        self.adSize = STKDevice.isIPhone ? BDMBannerAdSize320x50 : BDMBannerAdSize728x90;
    }
    return self;
}

- (void)performWithDelegate:(id<BDMRequestDelegate>)delegate {
    BDMBannerPlacement *placement = [[BDMBannerPlacement alloc] initWithBannerType:self.adSize];
    [self registerDelegate: delegate];
    [super performWithRequest:self withPlacement:placement];
}

@end

@implementation BDMInterstitialRequest

- (instancetype)init {
    if (self = [super init]) {
        self.type = BDMFullscreenAdTypeAll;
    }
    return self;
}

- (void)performWithDelegate:(id<BDMRequestDelegate>)delegate {
    BDMInterstitialPlacement *placement = [[BDMInterstitialPlacement alloc] initWithIntersitialType:self.type];
    [self registerDelegate: delegate];
    [super performWithRequest:self withPlacement:placement];
}

@end

@interface BDMRewardedRequest ()

@property (nonatomic, assign) BDMFullscreenAdType type;

@end

@implementation BDMRewardedRequest

- (instancetype)init {
    if (self = [super init]) {
        self.type = BDMFullscreenAdTypeAll;
    }
    return self;
}

- (void)performWithDelegate:(id<BDMRequestDelegate>)delegate {
    BDMRewardedPlacement *placement = [[BDMRewardedPlacement alloc] initWithRewardedType:self.type];
    [self registerDelegate: delegate];
    [super performWithRequest:self withPlacement:placement];
}

@end

@implementation BDMNativeAdRequest

- (instancetype)init {
    if (self = [super init]) {
        self.type = BDMNativeAdTypeIcon | BDMNativeAdTypeImage;
    }
    return self;
}

- (void)performWithDelegate:(id<BDMRequestDelegate>)delegate {
    BDMNativeAdPlacement *placement = [[BDMNativeAdPlacement alloc] initWithNativeAdType:self.type];
    [self registerDelegate: delegate];
    [super performWithRequest:self withPlacement:placement];
}

@end
