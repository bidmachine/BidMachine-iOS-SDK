//
//  BDMNetworkProtocol.h
//  BidMachine
//
//  Created by Stas Kochkin on 07/11/2017.
//  Copyright © 2017 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BidMachine/BDMAdapterProtocol.h>
#import <BidMachine/BDMDefines.h>

@class BDMSdk;
@class BDMAdUnit;
@protocol BDMNetwork;

NS_ASSUME_NONNULL_BEGIN

typedef void(^BDMCollectBiddingParamtersBlock)(BDMStringToStringMap *_Nullable, NSError *_Nullable);
typedef void(^BDMInitializeBiddingNetworkBlock)(BOOL, NSError *_Nullable);

@protocol BDMNetwork <NSObject>

- (instancetype)init;
+ (instancetype)new;

/// Ad network name
@property (nonatomic, copy, readonly) NSString *name;
/// Indicates SDK version
@property (nonatomic, copy, readonly) NSString *sdkVersion;
@optional
/// Starts session in ad network
/// @param parameters Custom dictionary that contains parameters for network initialization
/// @param units Array of all initialized ad untits
/// @param completion Triggers when network completes initialisation (return YES if network was initialized first time)
- (void)initializeWithParameters:(BDMStringToStringMap *)parameters
                           units:(NSArray <BDMAdUnit *> *)units
                      completion:(BDMInitializeBiddingNetworkBlock)completion;
/// Transfoms and populate adunit information for auction
/// Need to implement if Third party SDK contains several info
/// that BidMachine SDK doesn't have
/// @param unit Current adUnit
/// @param completion Block that fires when ad network finished collecting information
- (void)collectHeaderBiddingParameters:(BDMAdUnit *)unit
                            completion:(BDMCollectBiddingParamtersBlock)completion;
/// Returns banner adapter
/// @param sdk Current sdk
- (id<BDMBannerAdapter>)bannerAdapterForSdk:(BDMSdk *)sdk;
/// Returns interstitial adapter
/// @param sdk Current sdk
- (id<BDMFullscreenAdapter>)interstitialAdAdapterForSdk:(BDMSdk *)sdk;
/// Returns video adapter
/// @param sdk Current sdk
- (id<BDMFullscreenAdapter>)videoAdapterForSdk:(BDMSdk *)sdk;
/// Returns native ad adapter
/// @param sdk Native ad adapter
- (id<BDMNativeAdServiceAdapter>)nativeAdAdapterForSdk:(BDMSdk *)sdk;
@end

NS_ASSUME_NONNULL_END
