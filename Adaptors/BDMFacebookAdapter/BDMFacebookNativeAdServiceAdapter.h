//
//  BDMFacebookNativeAdServiceAdapter.h
//  BDMFacebookAdapter
//
//  Created by Ilia Lozhkin on 11/20/19.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

@import Foundation;
@import BidMachine.Adapters;


@interface BDMFacebookNativeAdServiceAdapter : NSObject <BDMNativeAdServiceAdapter>

@property (nonatomic, weak) id <BDMNativeAdServiceAdapterLoadingDelegate> loadingDelegate;
@property (nonatomic, weak) id <BDMAdapterDisplayDelegate> displayDelegate;

@end
