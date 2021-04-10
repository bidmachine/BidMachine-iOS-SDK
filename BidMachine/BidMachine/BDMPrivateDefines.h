//
//  BDMPrivateDefines.h
//  BidMachine
//
//  Created by Ilia Lozhkin on 31.08.2020.
//  Copyright © 2020 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BidMachine/BDMDefines.h>

FOUNDATION_EXPORT NSInteger const BDMEventError;

FOUNDATION_EXPORT NSInteger const BDMEventTrackingError;

typedef NS_ENUM(NSInteger, BDMEvent) {
    BDMEventCreativeLoading = 500,
    BDMEventImpression = 501,
    BDMEventViewable = 502,
    BDMEventClick = 503,
    BDMEventClosed = 504,
    BDMEventDestroyed = 505,
    BDMEventInitialisation = 506,
    BDMEventAuction = 507,
    BDMEventAuctionExpired = 509,
    BDMEventAuctionDestroyed = 510,
    BDMEventHeaderBiddingNetworkInitializing = 701,
    BDMEventHeaderBiddingNetworkPreparing = 702,
    BDMEventHeaderBiddingAllHeaderBiddingNetworksPrepared = 703
};

NS_ASSUME_NONNULL_BEGIN


FOUNDATION_EXTERN NSString *NSStringFromBDMEvent(BDMEvent event);

FOUNDATION_EXTERN BDMEvent BDMEventFromNSString(NSString *event);

FOUNDATION_EXTERN NSString *NSStringFromBDMErrorCode(BDMErrorCode code);

FOUNDATION_EXTERN NSString *NSStringFromBDMInternalPlacementType(BDMInternalPlacementType type);

FOUNDATION_EXTERN BDMInternalPlacementType BDMInternalPlacementTypeFromNSString(NSString *type);

FOUNDATION_EXTERN BDMAdUnitFormat BDMAdUnitFormatFromString(NSString *_Nullable);

FOUNDATION_EXTERN NSString * NSStringFromBDMAdUnitFormat(BDMAdUnitFormat);

FOUNDATION_EXTERN NSString * NSStringEventFromBDMAdUnitFormat(BDMAdUnitFormat);

FOUNDATION_EXTERN BOOL BDMAdUnitFormatEqual(BDMAdUnitFormat, BDMAdUnitFormat);

FOUNDATION_EXTERN BOOL BDMAdUnitFormatIsBanner(BDMAdUnitFormat format);

FOUNDATION_EXTERN BOOL BDMAdUnitFormatIsInterstitial(BDMAdUnitFormat format);

FOUNDATION_EXTERN BOOL BDMAdUnitFormatIsRewarded(BDMAdUnitFormat format);

FOUNDATION_EXTERN BOOL BDMAdUnitFormatIsNativeAd(BDMAdUnitFormat format);

FOUNDATION_EXTERN BOOL BDMAdUnitFormatIsDisplay(BDMAdUnitFormat format);

FOUNDATION_EXTERN BOOL BDMAdUnitFormatIsVideo(BDMAdUnitFormat format);

FOUNDATION_EXTERN CGSize BDMAdUnitFormatBannerSize(BDMAdUnitFormat format);

FOUNDATION_EXTERN BOOL BDMAdUnitFormatIsInterstitialStatic(BDMAdUnitFormat format);

FOUNDATION_EXTERN BOOL BDMAdUnitFormatIsInterstitialVideo(BDMAdUnitFormat format);

FOUNDATION_EXTERN BOOL BDMAdUnitFormatIsRewardedStatic(BDMAdUnitFormat format);

FOUNDATION_EXTERN BOOL BDMAdUnitFormatIsRewardedVideo(BDMAdUnitFormat format);

FOUNDATION_EXTERN BOOL BDMAdUnitFormatIsNativeIcon(BDMAdUnitFormat format);

FOUNDATION_EXTERN BOOL BDMAdUnitFormatIsNativeImage(BDMAdUnitFormat format);

FOUNDATION_EXTERN BOOL BDMAdUnitFormatIsNativeVideo(BDMAdUnitFormat format);

NS_ASSUME_NONNULL_END
