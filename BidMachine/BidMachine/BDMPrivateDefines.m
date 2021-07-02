//
//  BDMPrivateDefines.m
//  BidMachine
//
//  Created by Ilia Lozhkin on 31.08.2020.
//  Copyright © 2020 Appodeal. All rights reserved.
//

#import "BDMPrivateDefines.h"
#import "BDMDispatcher.h"

NSInteger const BDMEventError = 1000;

NSInteger const BDMEventTrackingError = 1001;

NSString *NSStringFromBDMEvent(BDMEvent event) {
    switch (event) {
        case BDMEventCreativeLoading: return @"Creative loading"; break;
        case BDMEventClick: return @"User interaction"; break;
        case BDMEventClosed: return @"Closing"; break;
        case BDMEventViewable: return @"Viewable"; break;
        case BDMEventDestroyed: return @"Destroying"; break;
        case BDMEventImpression: return @"Impression"; break;
        case BDMEventAuction: return @"Auction"; break;
        case BDMEventAuctionExpired: return @"Auction Expired"; break;
        case BDMEventAuctionDestroyed: return @"Auction Destroyed"; break;
        case BDMEventContainerAdded: return @"Ad object did added in container"; break;
        case BDMEventInitialisation: return @"Initialisation"; break;
        case BDMEventHeaderBiddingNetworkInitializing: return @"Header Bidding network initialisation"; break;
        case BDMEventHeaderBiddingNetworkPreparing: return @"Header Bidding network preparing"; break;
        case BDMEventHeaderBiddingAllHeaderBiddingNetworksPrepared: return @"Header Bidding preparation"; break;
    }
    return @"unspecified";
}

BDMEvent BDMEventFromNSString(NSString *event) {
    if ([event isEqualToString:@"Creative loading"]) {
        return BDMEventCreativeLoading;
    } else if ([event isEqualToString:@"User interaction"]) {
        return BDMEventClick;
    } else if ([event isEqualToString:@"Closing"]) {
        return BDMEventClosed;
    } else if ([event isEqualToString:@"Viewable"]) {
        return BDMEventViewable;
    } else if ([event isEqualToString:@"Destroying"]) {
        return BDMEventDestroyed;
    } else if ([event isEqualToString:@"Impression"]) {
        return BDMEventImpression;
    } else if ([event isEqualToString:@"Auction"]) {
        return BDMEventAuction;
    } else if ([event isEqualToString:@"Auction Expired"]) {
        return BDMEventAuctionExpired;
    } else if ([event isEqualToString:@"Auction Destroyed"]) {
        return BDMEventAuctionDestroyed;
    } else if ([event isEqualToString:@"Initialisation"]) {
        return BDMEventInitialisation;
    } else if ([event isEqualToString:@"Header Bidding network initialisation"]) {
        return BDMEventHeaderBiddingNetworkInitializing;
    } else if ([event isEqualToString:@"Header Bidding network preparing"]) {
        return BDMEventHeaderBiddingNetworkPreparing;
    } else if ([event isEqualToString:@"Header Bidding preparation"]) {
        return BDMEventHeaderBiddingAllHeaderBiddingNetworksPrepared;
    }
    return 0;
}

NSString *NSStringFromBDMErrorCode(BDMErrorCode code) {
    switch (code) {
        case BDMErrorCodeInternal: return @"Internal"; break;
        case BDMErrorCodeTimeout: return @"Timeout"; break;
        case BDMErrorCodeException: return @"Exception"; break;
        case BDMErrorCodeNoContent: return @"No content"; break;
        case BDMErrorCodeWasClosed: return @"Was closed"; break;
        case BDMErrorCodeUnknown: return @"Unknown"; break;
        case BDMErrorCodeBadContent: return @"Bad content"; break;
        case BDMErrorCodeWasExpired: return @"Was expired"; break;
        case BDMErrorCodeNoConnection: return @"No internet connection"; break;
        case BDMErrorCodeWasDestroyed: return @"Was destroyed"; break;
        case BDMErrorCodeHTTPBadRequest: return @"Bad request"; break;
        case BDMErrorCodeHTTPServerError: return @"Internal server error"; break;
        case BDMErrorCodeHeaderBiddingNetwork: return @"Ad Network specific error"; break;
        default: return @"Unspecified error"; break;
    }
}

NSString *NSStringFromBDMInternalPlacementType(BDMInternalPlacementType type) {
    switch (type) {
        case BDMInternalPlacementTypeInterstitial: return @"Interstitial"; break;
        case BDMInternalPlacementTypeRewardedVideo: return  @"RewardedVideo"; break;
        case BDMInternalPlacementTypeBanner: return @"Banner"; break;
        case BDMInternalPlacementTypeNative: return @"Native"; break;
    }
    return @"Session";
}

BDMInternalPlacementType BDMInternalPlacementTypeFromNSString(NSString *type) {
    if ([type isEqualToString:@"Interstitial"]) {
        return BDMInternalPlacementTypeInterstitial;
    } else if ([type isEqualToString:@"RewardedVideo"]) {
        return BDMInternalPlacementTypeRewardedVideo;
    } else if ([type isEqualToString:@"Banner"]) {
        return BDMInternalPlacementTypeBanner;
    } else if ([type isEqualToString:@"Native"]) {
        return BDMInternalPlacementTypeNative;
    } else {
        return 0;
    }
}

//////////

NSString * NSStringEventFromBDMAdUnitFormat(BDMAdUnitFormat format) {
    NSString *eventString = @"Session";
    if (BDMAdUnitFormatIsBanner(format)) {
        eventString = @"Banner";
    } else if (BDMAdUnitFormatIsInterstitial(format)) {
        eventString = @"Interstitial";
    } else if (BDMAdUnitFormatIsRewarded(format)) {
        eventString = @"RewardedVideo";
    } else if (BDMAdUnitFormatIsNativeAd(format)) {
        eventString = @"Native";
    }
    return eventString;
}

BOOL BDMAdUnitFormatEqual(BDMAdUnitFormat format1, BDMAdUnitFormat format2) {
    if (format2 == BDMAdUnitFormatUnknown) {
        return NO;
    }
    switch (format1) {
        case BDMAdUnitFormatInLineBanner: return
            format2 == BDMAdUnitFormatInLineBanner ||
            format2 == BDMAdUnitFormatBanner320x50 ||
            format2 == BDMAdUnitFormatBanner728x90 ||
            format2 == BDMAdUnitFormatBanner300x250;
            break;
        case BDMAdUnitFormatBanner320x50: return
            format2 == BDMAdUnitFormatInLineBanner ||
            format2 == BDMAdUnitFormatBanner320x50 ;
            break;
        case BDMAdUnitFormatBanner728x90: return
            format2 == BDMAdUnitFormatInLineBanner ||
            format2 == BDMAdUnitFormatBanner728x90 ;
            break;
        case BDMAdUnitFormatBanner300x250: return
            format2 == BDMAdUnitFormatInLineBanner ||
            format2 == BDMAdUnitFormatBanner300x250 ;
            break;
        case BDMAdUnitFormatInterstitialUnknown: return
            format2 == BDMAdUnitFormatInterstitialUnknown ||
            format2 == BDMAdUnitFormatInterstitialVideo ||
            format2 == BDMAdUnitFormatInterstitialStatic ;
            break;
        case BDMAdUnitFormatInterstitialVideo: return
            format2 == BDMAdUnitFormatInterstitialUnknown ||
            format2 == BDMAdUnitFormatInterstitialVideo ;
            break;
        case BDMAdUnitFormatInterstitialStatic: return
            format2 == BDMAdUnitFormatInterstitialUnknown ||
            format2 == BDMAdUnitFormatInterstitialStatic ;
            break;
        case BDMAdUnitFormatRewardedUnknown: return
            format2 == BDMAdUnitFormatRewardedUnknown ||
            format2 == BDMAdUnitFormatRewardedPlayable ||
            format2 == BDMAdUnitFormatRewardedVideo ;
            break;
        case BDMAdUnitFormatRewardedVideo: return
            format2 == BDMAdUnitFormatRewardedUnknown ||
            format2 == BDMAdUnitFormatRewardedVideo ;
            break;
        case BDMAdUnitFormatRewardedPlayable: return
            format2 == BDMAdUnitFormatRewardedUnknown ||
            format2 == BDMAdUnitFormatRewardedPlayable ;
            break;
        case BDMAdUnitFormatNativeAdUnknown: return
            format2 == BDMAdUnitFormatNativeAdIcon ||
            format2 == BDMAdUnitFormatNativeAdImage ||
            format2 == BDMAdUnitFormatNativeAdVideo ||
            format2 == BDMAdUnitFormatNativeAdIconAndVideo ||
            format2 == BDMAdUnitFormatNativeAdIconAndImage ||
            format2 == BDMAdUnitFormatNativeAdImageAndVideo ||
            format2 == BDMAdUnitFormatNativeAdUnknown;
            break;
        case BDMAdUnitFormatNativeAdIcon: return
            format2 == BDMAdUnitFormatNativeAdIcon ||
            format2 == BDMAdUnitFormatNativeAdUnknown;
            break;
        case BDMAdUnitFormatNativeAdImage: return
            format2 == BDMAdUnitFormatNativeAdImage ||
            format2 == BDMAdUnitFormatNativeAdUnknown;
            break;
        case BDMAdUnitFormatNativeAdVideo: return
            format2 == BDMAdUnitFormatNativeAdVideo ||
            format2 == BDMAdUnitFormatNativeAdUnknown;
            break;
        case BDMAdUnitFormatNativeAdIconAndVideo: return
            format2 == BDMAdUnitFormatNativeAdIconAndVideo ||
            format2 == BDMAdUnitFormatNativeAdUnknown;
            break;
        case BDMAdUnitFormatNativeAdIconAndImage: return
            format2 == BDMAdUnitFormatNativeAdIconAndImage ||
            format2 == BDMAdUnitFormatNativeAdUnknown;
            break;
        case BDMAdUnitFormatNativeAdImageAndVideo: return
            format2 == BDMAdUnitFormatNativeAdImageAndVideo ||
            format2 == BDMAdUnitFormatNativeAdUnknown;
            break;
            
        default: return NO; break;
    }
}

BOOL BDMAdUnitFormatIsBanner(BDMAdUnitFormat format) {
    return [NSStringFromBDMAdUnitFormat(format) containsString:@"banner"];
}

BOOL BDMAdUnitFormatIsInterstitial(BDMAdUnitFormat format) {
    return [NSStringFromBDMAdUnitFormat(format) containsString:@"interstitial"];
}

BOOL BDMAdUnitFormatIsRewarded(BDMAdUnitFormat format) {
    return [NSStringFromBDMAdUnitFormat(format) containsString:@"rewarded"];
}

BOOL BDMAdUnitFormatIsNativeAd(BDMAdUnitFormat format) {
    return [NSStringFromBDMAdUnitFormat(format) containsString:@"nativeAd"];
}

BOOL BDMAdUnitFormatIsDisplay(BDMAdUnitFormat format) {
    return
    BDMAdUnitFormatIsBanner(format) ||
    BDMAdUnitFormatIsNativeAd(format) ||
    (BDMAdUnitFormatIsInterstitial(format) && format == BDMAdUnitFormatInterstitialUnknown) ||
    (BDMAdUnitFormatIsInterstitial(format) && format == BDMAdUnitFormatInterstitialStatic) ||
    (BDMAdUnitFormatIsRewarded(format) && format == BDMAdUnitFormatRewardedUnknown) ||
    (BDMAdUnitFormatIsRewarded(format) && format == BDMAdUnitFormatRewardedPlayable);
}

BOOL BDMAdUnitFormatIsVideo(BDMAdUnitFormat format) {
    return
    (BDMAdUnitFormatIsInterstitial(format) && format == BDMAdUnitFormatInterstitialUnknown) ||
    (BDMAdUnitFormatIsInterstitial(format) && format == BDMAdUnitFormatInterstitialVideo) ||
    (BDMAdUnitFormatIsRewarded(format) && format == BDMAdUnitFormatRewardedUnknown) ||
    (BDMAdUnitFormatIsRewarded(format) && format == BDMAdUnitFormatRewardedVideo);
}


CGSize BDMAdUnitFormatBannerSize(BDMAdUnitFormat format) {
    __block CGSize size = CGSizeZero;
    [BDMDispatcher dispatchMainSemaphore:^{
        switch (format) {
            case BDMAdUnitFormatBanner320x50: size = CGSizeMake(320, 50); break;
            case BDMAdUnitFormatBanner728x90: size = CGSizeMake(300, 250); break;
            case BDMAdUnitFormatBanner300x250: size = CGSizeMake(728, 90); break;
            case BDMAdUnitFormatInLineBanner: size =
                UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad ?
                CGSizeMake(728, 90) :
                CGSizeMake(320, 50);
                break;
            default: break;
        }
    }];
    return size;
}

BOOL BDMAdUnitFormatIsInterstitialStatic(BDMAdUnitFormat format) {
    return BDMAdUnitFormatIsInterstitial(format) && BDMAdUnitFormatIsDisplay(format);
}

BOOL BDMAdUnitFormatIsInterstitialVideo(BDMAdUnitFormat format) {
    return BDMAdUnitFormatIsInterstitial(format) && BDMAdUnitFormatIsVideo(format);
}

BOOL BDMAdUnitFormatIsRewardedStatic(BDMAdUnitFormat format) {
    return BDMAdUnitFormatIsRewarded(format) && BDMAdUnitFormatIsDisplay(format);
}

BOOL BDMAdUnitFormatIsRewardedVideo(BDMAdUnitFormat format) {
    return BDMAdUnitFormatIsRewarded(format) && BDMAdUnitFormatIsVideo(format);
}

BOOL BDMAdUnitFormatIsNativeIcon(BDMAdUnitFormat format) {
    return BDMAdUnitFormatIsNativeAd(format) && [NSStringFromBDMAdUnitFormat(format) containsString:@"icon"];
}

BOOL BDMAdUnitFormatIsNativeImage(BDMAdUnitFormat format) {
    return BDMAdUnitFormatIsNativeAd(format) && [NSStringFromBDMAdUnitFormat(format) containsString:@"image"];
}

BOOL BDMAdUnitFormatIsNativeVideo(BDMAdUnitFormat format) {
    return BDMAdUnitFormatIsNativeAd(format) && [NSStringFromBDMAdUnitFormat(format) containsString:@"video"];
}
