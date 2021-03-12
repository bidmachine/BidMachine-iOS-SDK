//
//  BDMPlacement.h
//  BidMachine
//
//  Created by Ilia Lozhkin on 12.03.2021.
//  Copyright © 2021 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BidMachine/BDMDefines.h>


NS_ASSUME_NONNULL_BEGIN

@interface BDMPlacement : NSObject <NSCopying>

@property (nonatomic, assign, readonly) BDMInternalPlacementType type;

- (BOOL)isSupportedFormat:(BDMAdUnitFormat)format;

@end

@interface BDMBannerPlacement : BDMPlacement

@property (nonatomic, assign, readonly) BDMBannerAdSize bannerType;

- (instancetype)initWithBannerType:(BDMBannerAdSize)type;

@end

@interface BDMInterstitialPlacement : BDMPlacement

@property (nonatomic, assign, readonly) BDMFullscreenAdType interstitialType;

- (instancetype)initWithIntersitialType:(BDMFullscreenAdType)type;

@end

@interface BDMRewardedPlacement : BDMPlacement

@property (nonatomic, assign, readonly) BDMFullscreenAdType rewardedType;

- (instancetype)initWithRewardedType:(BDMFullscreenAdType)type;

@end

@interface BDMNativeAdPlacement : BDMPlacement

@property (nonatomic, assign, readonly) BDMNativeAdType nativeAdType;

- (instancetype)initWithNativeAdType:(BDMNativeAdType)type;

@end

NS_ASSUME_NONNULL_END
