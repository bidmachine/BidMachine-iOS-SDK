//
//  BDMAmazonInterstitialAdapter.h
//  BDMAmazonAdapter
//
//  Created by Yaroslav Skachkov on 9/11/19.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

@import Foundation;
@import BidMachine;
@import BidMachine.Adapters;

NS_ASSUME_NONNULL_BEGIN

@interface BDMAmazonInterstitialAdapter : NSObject <BDMFullscreenAdapter>

@property (nonatomic, weak, nullable) id <BDMFullscreenAdapterDisplayDelegate> displayDelegate;
@property (nonatomic, weak, nullable) id <BDMAdapterLoadingDelegate> loadingDelegate;

@end

NS_ASSUME_NONNULL_END
