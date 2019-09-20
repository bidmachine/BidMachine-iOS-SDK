//
//  BDMAmazonBannerAdapter.h
//  BDMAmazonAdapter
//
//  Created by Yaroslav Skachkov on 9/10/19.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

@import Foundation;
@import BidMachine;
@import BidMachine.Adapters;

NS_ASSUME_NONNULL_BEGIN

@interface BDMAmazonBannerAdapter : NSObject <BDMBannerAdapter>

@property (nonatomic, weak, nullable) id <BDMAdapterLoadingDelegate> loadingDelegate;
@property (nonatomic, weak, nullable) id <BDMBannerAdapterDisplayDelegate> displayDelegate;

@end

NS_ASSUME_NONNULL_END
