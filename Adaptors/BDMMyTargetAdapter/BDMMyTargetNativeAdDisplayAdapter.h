//
//  BDMMyTargetNativeAdDisplayAdapter.h
//  BDMMyTargetAdapter
//
//  Created by Ilia Lozhkin on 11/20/19.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

@import Foundation;
@import MyTargetSDK;
@import BidMachine.Adapters;


NS_ASSUME_NONNULL_BEGIN

@interface BDMMyTargetNativeAdDisplayAdapter : NSObject <BDMNativeAdAdapter>

@property (nonatomic, weak, nullable) id<BDMNativeAdAdapterDelegate> delegate;

+ (instancetype)displayAdapterForAd:(MTRGNativeAd *)ad;

@end

NS_ASSUME_NONNULL_END
