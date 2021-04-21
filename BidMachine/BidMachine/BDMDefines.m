//
//  BDMDefines.m
//  BidMachine
//
//  Created by Stas Kochkin on 07/11/2017.
//  Copyright © 2017 Appodeal. All rights reserved.
//

#import "BDMDefines.h"

NSString * const kBDMVersion = @"1.7.3.0";

NSString * const kBDMUserGenderMale     = @"M";
NSString * const kBDMUserGenderFemale   = @"F";
NSString * const kBDMUserGenderUnknown  = @"O";

BDMFmwName * const BDMNativeFramework   = @"native";
BDMFmwName * const BDMNUnityFramework   = @"unity";

NSInteger const kBDMUndefinedYearOfBirth = 0;

NSString * kBDMErrorDomain = @"com.adx.error";
BOOL BDMSdkLoggingEnabled = NO;


CGSize CGSizeFromBDMSize(BDMBannerAdSize adSize) {
    CGSize defaultSize = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? CGSizeMake(728, 90) : CGSizeMake(320, 50);
    switch (adSize) {
        case BDMBannerAdSize320x50: return CGSizeMake(320, 50); break;
        case BDMBannerAdSize300x250: return CGSizeMake(300, 250); break;
        case BDMBannerAdSize728x90: return CGSizeMake(728, 90); break;
        case BDMBannerAdSizeUnknown: return defaultSize;
    }
    return defaultSize;
}

NSString *NSStringFromBDMCreativeFormat(BDMCreativeFormat fmt) {
    switch (fmt) {
        case BDMCreativeFormatBanner: return @"display"; break;
        case BDMCreativeFormatVideo: return @"video"; break;
        case BDMCreativeFormatNative: return @"native"; break;
    }
    return @"display";
}

static inline NSArray<NSString *> * BDMAdUnitFormatConstants(void) {
    return @[
        @"banner",
        @"banner_320x50",
        @"banner_728x90",
        @"banner_300x250",
        @"interstitial_video",
        @"interstitial_static",
        @"interstitial",
        @"rewarded_video",
        @"rewarded_static",
        @"rewarded",
        @"nativeAd_icon",
        @"nativeAd_image",
        @"nativeAd_video",
        @"nativeAd_icon_video",
        @"nativeAd_icon_image",
        @"nativeAd_image_video",
        @"nativeAd",
    ];
}

BDMAdUnitFormat BDMAdUnitFormatFromString(NSString *value) {
    NSUInteger idx = value ? [BDMAdUnitFormatConstants() indexOfObject:value] : NSNotFound;
    return idx == NSNotFound ? BDMAdUnitFormatUnknown : (BDMAdUnitFormat)idx;
}

NSString * NSStringFromBDMAdUnitFormat(BDMAdUnitFormat format) {
    if (format < 0 || format + 1 > BDMAdUnitFormatConstants().count ) {
        return @"unknown";
    }
    return  [BDMAdUnitFormatConstants() objectAtIndex:format];
}
