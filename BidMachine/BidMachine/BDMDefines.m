//
//  BDMDefines.m
//  BidMachine
//
//  Created by Stas Kochkin on 07/11/2017.
//  Copyright © 2017 Appodeal. All rights reserved.
//

#import "BDMDefines.h"

NSString * const kBDMVersion = @"1.3.2";

NSString * const kBDMUserGenderMale     = @"M";
NSString * const kBDMUserGenderFemale   = @"F";
NSString * const kBDMUserGenderUnknown  = @"O";

NSInteger const kBDMUndefinedYearOfBirth = 0;

NSString * kBDMErrorDomain = @"com.adx.error";
BOOL BDMSdkLoggingEnabled = NO;


CGSize CGSizeFromBDMSize(BDMBannerAdSize adSize) {
    switch (adSize) {
        case BDMBannerAdSize320x50: return CGSizeMake(320, 50); break;
        case BDMBannerAdSize300x250: return CGSizeMake(300, 250); break;
        case BDMBannerAdSize728x90: return CGSizeMake(728, 90); break;
        case BDMBannerAdSizeUnknown: return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? CGSizeMake(728, 90) : CGSizeMake(320, 50);
    }
}


BDMAdUnitFormatKey *BDMAdUnitFormatKeyFromEnum(BDMAdUnitFormat fmt) {
    return @(fmt);
}


BDMAdUnitFormat BDMAdUnitFormatFromKey(BDMAdUnitFormatKey *key) {
    return key.integerValue > -1 && key.integerValue < 10 ?
        (BDMAdUnitFormat)[key integerValue] :
        BDMAdUnitFormatUnknown;
}


BDMAdUnitFormat BDMAdUnitFormatFromString(NSString *key) {
    NSArray *adTypes = @[
                         @"banner",
                         @"banner_320x50",
                         @"banner_728x90",
                         @"banner_300x250",
                         @"interstitial_video",
                         @"interstitial_static",
                         @"interstitial",
                         @"rewarded_video",
                         @"rewarded_static",
                         @"rewarded"
                         ];
    NSUInteger idx = key ? [adTypes indexOfObject:key] : NSNotFound;
    return idx == NSNotFound ? BDMAdUnitFormatUnknown : (BDMAdUnitFormat)idx;
}


NSString *NSStringFromBDMAdUnitFormat(BDMAdUnitFormat fmt) {
    switch (fmt) {
        case BDMAdUnitFormatUnknown: return @"unknown"; break;
        case BDMAdUnitFormatInLineBanner: return @"banner"; break;
        case BDMAdUnitFormatBanner320x50: return @"banner_320x50"; break;
        case BDMAdUnitFormatBanner728x90: return @"banner_728x90"; break;
        case BDMAdUnitFormatBanner300x250: return @"banner_300x250"; break;
        case BDMAdUnitFormatInterstitialVideo: return @"interstitial_video"; break;
        case BDMAdUnitFormatInterstitialStatic: return @"interstitial_static"; break;
        case BDMAdUnitFormatInterstitialUnknown: return @"interstitial"; break;
        case BDMAdUnitFormatRewardedVideo: return @"rewarded_video"; break;
        case BDMAdUnitFormatRewardedPlayable: return @"rewarded_static"; break;
        case BDMAdUnitFormatRewardedUnknown: return @"rewarded"; break;
    }
}
