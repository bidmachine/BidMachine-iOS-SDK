//
//  BDMNASTNativeServiceAdapter.h
//  BDMNASTAdapter
//
//  Created by Stas Kochkin on 04/11/2018.
//  Copyright © 2018 Stas Kochkin. All rights reserved.
//

@import Foundation;
@import BidMachine.Adapters;


NS_ASSUME_NONNULL_BEGIN

@interface BDMNASTNativeAdServiceAdapter : NSObject <BDMNativeAdServiceAdapter>

@property (nonatomic, weak) id <BDMAdapterDisplayDelegate> displayDelegate;
@property (nonatomic, weak) id <BDMNativeAdServiceAdapterLoadingDelegate> loadingDelegate;

@end

NS_ASSUME_NONNULL_END

