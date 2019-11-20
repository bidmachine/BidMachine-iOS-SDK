//
//  BDMMintegralNativeAdDisplayAdapter.h
//  BDMMintegralAdapter
//
//  Created by Ilia Lozhkin on 11/20/19.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

@import Foundation;
@import BidMachine.Adapters;

#import <MTGSDK/MTGSDK.h>
#import <MTGSDK/MTGNativeAd.h>

NS_ASSUME_NONNULL_BEGIN

@interface BDMMintegralNativeAdDisplayAdapter : NSObject <BDMNativeAdAdapter>

@property (nonatomic, weak, nullable) id<BDMNativeAdAdapterDelegate> delegate;

+ (instancetype)displayAdapterForAd:(MTGCampaign *)ad manager:(MTGBidNativeAdManager *)manager;

@end

NS_ASSUME_NONNULL_END
