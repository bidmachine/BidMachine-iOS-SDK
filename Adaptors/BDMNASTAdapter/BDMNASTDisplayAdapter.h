//
//  BDMNASTDisplayAdapter.h
//  BDMNASTAdapter
//
//  Created by Stas Kochkin on 04/11/2018.
//  Copyright © 2018 Stas Kochkin. All rights reserved.
//

#import <Foundation/Foundation.h>
@import BidMachine.Adapters;

NS_ASSUME_NONNULL_BEGIN

@import StackNASTKit;

@interface BDMNASTDisplayAdapter : NSObject <BDMNativeAdAdapter>

@property (nonatomic, weak, nullable) id<BDMNativeAdAdapterDelegate> delegate;

+ (instancetype)displayAdapterForAd:(STKNASTAd *)ad;

@end

NS_ASSUME_NONNULL_END

