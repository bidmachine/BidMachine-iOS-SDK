//
//  BDMCriteoAdNetwork.h
//
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

@import Foundation;
@import BidMachine;
@import BidMachine.Adapters;
@import CriteoPublisherSdk;


NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const BDMCriteoIDKey;
FOUNDATION_EXPORT NSString *const BDMCriteoPriceKey;
FOUNDATION_EXPORT NSString *const BDMCriteoAdUnitIDKey;
FOUNDATION_EXPORT NSString *const BDMCriteoOrienationKey;
FOUNDATION_EXPORT NSString *const BDMCriteoBannerAdUnitsKey;
FOUNDATION_EXPORT NSString *const BDMCriteoInterstitialAdUnitsKey;

@protocol BDMCriteoAdNetworkProvider <NSObject>

- (nullable CRBid *)bidForAdUnitId:(NSString *)adUnitId;

@end

@interface BDMCriteoAdNetwork : NSObject <BDMNetwork, BDMCriteoAdNetworkProvider>

@end

NS_ASSUME_NONNULL_END
