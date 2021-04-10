//
//  BDMPlacement.m
//  BidMachine
//
//  Created by Ilia Lozhkin on 12.03.2021.
//  Copyright © 2021 Appodeal. All rights reserved.
//

#import "BDMPlacement.h"
#import "BDMPrivateDefines.h"


@implementation BDMPlacement

- (instancetype)initWithType:(BDMInternalPlacementType)type {
    if (self = [super init]) {
        _type = type;
    }
    return self;
}

- (BOOL)isSupportedFormat:(BDMAdUnitFormat)format {
    return NO;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    return [[self.class alloc] initWithType:self.type];
}

@end

@implementation BDMBannerPlacement

- (instancetype)initWithBannerType:(BDMBannerAdSize)type {
    if (self = [super initWithType:BDMInternalPlacementTypeBanner]) {
        _bannerType = type;
    }
    return self;
}

- (BOOL)isSupportedFormat:(BDMAdUnitFormat)format {
    if (![NSStringFromBDMAdUnitFormat(format) containsString:@"banner"]) {
        return NO;
    }
    switch (format) {
        case BDMAdUnitFormatInLineBanner: return YES; break;
        case BDMAdUnitFormatBanner320x50: return self.bannerType == BDMBannerAdSize320x50; break;
        case BDMAdUnitFormatBanner300x250: return self.bannerType == BDMBannerAdSize300x250; break;
        case BDMAdUnitFormatBanner728x90: return self.bannerType == BDMBannerAdSize728x90; break;
        default: break;
    }
    return NO;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    return [[self.class alloc] initWithBannerType:self.bannerType];
}

@end

@implementation BDMInterstitialPlacement

- (instancetype)initWithIntersitialType:(BDMFullscreenAdType)type {
    if (self = [super initWithType:BDMInternalPlacementTypeInterstitial]) {
        _interstitialType = type;
    }
    return self;
}

- (BOOL)isSupportedFormat:(BDMAdUnitFormat)format {
    if (![NSStringFromBDMAdUnitFormat(format) containsString:@"interstitial"]) {
        return NO;
    }
    
    if (self.interstitialType == BDMFullscreenAdTypeAll) {
        return YES;
    }
    
    switch (format) {
        case BDMAdUnitFormatInterstitialUnknown: return YES; break;
        case BDMAdUnitFormatInterstitialVideo: return self.interstitialType & BDMFullscreenAdTypeVideo; break;
        case BDMAdUnitFormatInterstitialStatic: return self.interstitialType & BDMFullsreenAdTypeBanner; break;
        default: break;
    }
    return NO;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    return [[self.class alloc] initWithIntersitialType:self.interstitialType];
}

@end

@implementation BDMRewardedPlacement

- (instancetype)initWithRewardedType:(BDMFullscreenAdType)type {
    if (self = [super initWithType:BDMInternalPlacementTypeRewardedVideo]) {
        _rewardedType = type;
    }
    return self;
}

- (BOOL)isSupportedFormat:(BDMAdUnitFormat)format {
    if (![NSStringFromBDMAdUnitFormat(format) containsString:@"rewarded"]) {
        return NO;
    }
    
    if (self.rewardedType == BDMFullscreenAdTypeAll) {
        return YES;
    }
    
    switch (format) {
        case BDMAdUnitFormatRewardedUnknown: return YES; break;
        case BDMAdUnitFormatRewardedVideo: return self.rewardedType & BDMFullscreenAdTypeVideo; break;
        case BDMAdUnitFormatRewardedPlayable: return self.rewardedType & BDMFullsreenAdTypeBanner; break;
        default: break;
    }
    return NO;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    return [[self.class alloc] initWithRewardedType:self.rewardedType];
}

@end

@implementation BDMNativeAdPlacement

- (instancetype)initWithNativeAdType:(BDMNativeAdType)type {
    if (self = [super initWithType:BDMInternalPlacementTypeNative]) {
        _nativeAdType = type;
    }
    return self;
}

- (BOOL)isSupportedFormat:(BDMAdUnitFormat)format {
    if (![NSStringFromBDMAdUnitFormat(format) containsString:@"nativeAd"]) {
        return NO;
    }
    
    if (self.nativeAdType == BDMFullscreenAdTypeAll) {
        return YES;
    }
    
    switch (format) {
        case BDMAdUnitFormatNativeAdUnknown: return YES; break;
        case BDMAdUnitFormatNativeAdIcon: return self.nativeAdType & BDMNativeAdTypeIcon; break;
        case BDMAdUnitFormatNativeAdImage: return self.nativeAdType & BDMNativeAdTypeImage; break;
        case BDMAdUnitFormatNativeAdVideo: return self.nativeAdType & BDMNativeAdTypeVideo; break;
        case BDMAdUnitFormatNativeAdIconAndImage: return self.nativeAdType & BDMNativeAdTypeIconAndImage; break;
        case BDMAdUnitFormatNativeAdIconAndVideo: return self.nativeAdType & BDMNativeAdTypeIconAndVideo; break;
        case BDMAdUnitFormatNativeAdImageAndVideo: return self.nativeAdType & BDMNativeAdTypeImageAndVideo; break;
        default: break;
    }
    return NO;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    return [[self.class alloc] initWithNativeAdType:self.nativeAdType];
}

@end
