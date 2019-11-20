//
//  BDMFacebookNativeAdDisplayAdapter.h
//  BDMFacebookAdapter
//
//  Created by Ilia Lozhkin on 11/20/19.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

@import Foundation;
@import BidMachine.Adapters;
@import FBAudienceNetwork;

NS_ASSUME_NONNULL_BEGIN

@interface BDMFacebookNativeAdDisplayAdapter : NSObject <BDMNativeAdAdapter>

@property (nonatomic, weak, nullable) id<BDMNativeAdAdapterDelegate> delegate;

+ (instancetype)displayAdapterForAd:(FBNativeAd *)ad;

@end

NS_ASSUME_NONNULL_END
