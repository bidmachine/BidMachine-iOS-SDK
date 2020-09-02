//
//  BDMBannerRequest.m
//  BidMachine
//
//  Created by Stas Kochkin on 11/01/2019.
//  Copyright © 2019 Appodeal. All rights reserved.
//

#import "BDMAdRequests.h"
#import "BDMRequest+Private.h"
#import "BDMAdTypePlacement.h"

@implementation BDMBannerRequest

- (void)performWithDelegate:(id<BDMRequestDelegate>)delegate {
    [self registerDelegate: delegate];
    id <BDMPlacementRequestBuilder> builder = [BDMAdTypePlacement bannerPlacementWithAdSize:self.adSize];
    [super performWithRequest:self placementBuilder:builder];
}

- (BDMInternalPlacementType)placementType {
    return BDMInternalPlacementTypeBanner;
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
    [self registerDelegate: delegate];
    id <BDMPlacementRequestBuilder> builder = [BDMAdTypePlacement interstitialPlacementWithAdType:self.type];
    [self performWithRequest:self placementBuilder:builder];
}

- (BDMInternalPlacementType)placementType {
    return BDMInternalPlacementTypeInterstitial;
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
    [self registerDelegate: delegate];
    id<BDMPlacementRequestBuilder> builder = [BDMAdTypePlacement rewardedPlacementWithAdType:self.type];
    [self performWithRequest:self placementBuilder:builder];
}

- (BDMInternalPlacementType)placementType {
    return BDMInternalPlacementTypeRewardedVideo;
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
    [self registerDelegate: delegate];
    id<BDMPlacementRequestBuilder> builder = [BDMAdTypePlacement nativePlacementWithAdType:self.type];
    [self performWithRequest:self placementBuilder:builder];
}

- (BDMInternalPlacementType)placementType {
    return BDMInternalPlacementTypeNative;
}

@end
