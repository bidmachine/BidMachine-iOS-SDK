//
//  ABDMMRAIDBannerAdapter.h
//  BDMMRAIDBannerAdapter
//
//  Created by Pavel Dunyashev on 11/09/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

@import Foundation;
@import BidMachine.Adapters;


NS_ASSUME_NONNULL_BEGIN

@interface BDMMRAIDBannerAdapter : NSObject <BDMBannerAdapter>

@property (nonatomic, strong) NSString *adContent;
@property (nonatomic,   weak) id <BDMAdapterLoadingDelegate> loadingDelegate;
@property (nonatomic,   weak) id <BDMBannerAdapterDisplayDelegate> displayDelegate;
 
@end

NS_ASSUME_NONNULL_END

