//
//  BDMMRAIDInterstitialAdapter.h
//
//  Copyright © 2018 Appodeal. All rights reserved.
//

@import Foundation;
@import BidMachine.Adapters;


NS_ASSUME_NONNULL_BEGIN

@interface BDMMRAIDInterstitialAdapter : NSObject <BDMFullscreenAdapter>

@property (nonatomic, assign) BOOL rewarded;
@property (nonatomic,   copy) NSString *adContent;
@property (nonatomic,   weak) id <BDMAdapterLoadingDelegate> loadingDelegate;
@property (nonatomic,   weak) id <BDMFullscreenAdapterDisplayDelegate> displayDelegate;

@end

NS_ASSUME_NONNULL_END
