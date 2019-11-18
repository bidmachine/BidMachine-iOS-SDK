//
//  BDMBannerRequest.h
//  BidMachine
//
//  Created by Stas Kochkin on 11/01/2019.
//  Copyright © 2019 Appodeal. All rights reserved.
//

#import <BidMachine/BDMRequest.h>
#import <BidMachine/BDMDefines.h>

/**
 Request for banner ad
 */
@interface BDMBannerRequest : BDMRequest
/**
 Banner ad size
 */
@property (nonatomic, assign, readwrite) BDMBannerAdSize adSize;
/**
 Perform auction for current parameters

 @param delegate Delegate object
 */
- (void)performWithDelegate:(id<BDMRequestDelegate>)delegate;

@end


/**
 Request for interstitial ad
 */
@interface BDMInterstitialRequest : BDMRequest
/**
 Specify ad type of interstitial
 */
@property (nonatomic, assign, readwrite) BDMFullscreenAdType type;
/**
 Perform auction for current parameters
 
 @param delegate Delegate object
 */
- (void)performWithDelegate:(id<BDMRequestDelegate>)delegate;

@end


/**
 Request for rewarded ad
 */
@interface BDMRewardedRequest : BDMRequest
/**
 Perform auction for current parameters
 
 @param delegate Delegate object
 */
- (void)performWithDelegate:(id<BDMRequestDelegate>)delegate;

@end

/**
 Request for native ad
 */
@interface BDMNativeAdRequest : BDMRequest
/**
 Specify ad type of native ad
 */
@property (nonatomic, assign, readwrite) BDMNativeAdType type;
/**
 Perform auction for current parameters
 
 @param delegate Delegate object
 */
- (void)performWithDelegate:(id<BDMRequestDelegate>)delegate;

@end
