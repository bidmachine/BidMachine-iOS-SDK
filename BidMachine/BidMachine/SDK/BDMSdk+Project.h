//
//  BDMSdk-Private.h
//  BidMachine
//
//  Created by Stas Kochkin on 07/11/2017.
//  Copyright © 2017 Appodeal. All rights reserved.
//

#import <BidMachine/BidMachine.h>
#import "BDMSdk.h"
#import "BDMRequest.h"
#import "BDMRegistry.h"
#import "BDMAuctionSettings.h"
#import "BDMPlacementAdUnit.h"
#import "BDMRequest+Private.h"
#import "BDMContextualController.h"
#import "BDMAdNetworkConfiguration.h"


@protocol BDMSdkContext <NSObject>

@property (nonatomic, copy, readonly) NSString *sellerID;
@property (nonatomic, copy, readonly) BDMTargeting *targeting;
@property (nonatomic, copy, readonly) BDMUserRestrictions *restrictions;
@property (nonatomic, copy, readonly) BDMPublisherInfo *publisherInfo;

@property (nonatomic, assign, readonly) BOOL testMode;
@property (nonatomic, assign, readonly) BOOL isDeviceReachable;

@property (nonatomic, strong, readonly) BDMOpenRTBAuctionSettings *auctionSettings;

- (id <BDMBannerAdapter>)bannerAdapterForNetwork:(NSString *)networkName;
- (id <BDMFullscreenAdapter>)interstitialAdAdapterForNetwork:(NSString *)networkName;
- (id <BDMFullscreenAdapter>)videoAdapterForNetwork:(NSString *)networkName;
- (id <BDMNativeAdServiceAdapter>)nativeAdAdapterForNetwork:(NSString *)networkName;

@end


@protocol BDMSdkHeaderBiddingContext <NSObject>

@property (nonatomic, copy, readonly) NSString *ssp;

- (void)collectHeaderBiddingAdUnits:(NSArray <BDMAdNetworkConfiguration *> *)configs
                          placement:(BDMInternalPlacementType)placementType
                         completion:(void (^)(NSArray<id<BDMPlacementAdUnit>> *))completion;

- (void)initializeNetworks:(NSArray <BDMAdNetworkConfiguration *> *)configs
                completion:(void(^)(void))completion;

- (void)registerNetworks;

@end


@interface BDMSdk (Project) <BDMSdkContext, BDMSdkHeaderBiddingContext>

@property (nonatomic,   copy, readonly) NSURL *baseURL;

@property (nonatomic, strong, readonly) BDMContextualController *contextualController;

@end
