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
@protocol BDMNetwork;

NS_ASSUME_NONNULL_BEGIN

@protocol BDMNetwork <NSObject>
/**
 Ad network name
 */
@property (nonatomic, copy, readonly) NSString *name;

/**
 Available initialiser
 
 @return Instance of network
 */
- (instancetype)init;
/**
 Available initialiser
 
 @return Instance of network
 */
+ (instancetype)new;

@optional
/**
 Indicates SDK version
 */
@property (nonatomic, copy, readonly) NSString *sdkVersion;
/**
 Starts session in ad network
 
 @param parameters Custom dictionary that contains parameters for network initialisation
 @param completion Triggers when network completes initialisation
 */
- (void)initialiseWithParameters:(NSDictionary <NSString *, id>*)parameters
                      completion:(void(^_Nonnull)(BOOL, NSError *_Nullable))completion;
/**
 Transfoms and populate adunit information for auction
 Need to implement if Third party SDK contains several info
 that BidMachine SDK doesn't have
 
 @param parameters Received information
 @param adUnitFormat AdUnitFormat
 @param completion Block that fires when ad network finished collecting information
 */
- (void)collectHeaderBiddingParameters:(NSDictionary <NSString *, id> *)parameters
                          adUnitFormat:(BDMAdUnitFormat)adUnitFormat
                            completion:(void(^_Nonnull)(NSDictionary <NSString *, id> *_Nullable, NSError *_Nullable))completion;
/**
 Returns banner adapter
 
 @param sdk Current sdk
 @return Banner adapter
 */
- (id<BDMBannerAdapter>)bannerAdapterForSdk:(BDMSdk *)sdk;
/**
 Returns interstitial adapter
 
 @param sdk Current sdk
 @return Interstitial adapter
 */
- (id<BDMFullscreenAdapter>)interstitialAdAdapterForSdk:(BDMSdk *)sdk;
/**
 Returns video adapter
 
 @param sdk Current sdk
 @return Video adapter
 */
- (id<BDMFullscreenAdapter>)videoAdapterForSdk:(BDMSdk *)sdk;
/**
 Returns native ad adapter
 
 @param sdk Current sdk
 @return Native ad adapter
 */
- (id<BDMNativeAdServiceAdapter>)nativeAdAdapterForSdk:(BDMSdk *)sdk;
@end

NS_ASSUME_NONNULL_END
