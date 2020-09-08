//
//  BDMNASTDisplayAdapter.h
//  BDMNASTAdapter
//
//  Created by Stas Kochkin on 04/11/2018.
//  Copyright © 2018 Stas Kochkin. All rights reserved.
//

@import Foundation;
@import StackNASTKit;
@import BidMachine.Adapters;


NS_ASSUME_NONNULL_BEGIN

@interface BDMNASTDisplayAdapter : NSObject <BDMNativeAdAdapter>

@property (nonatomic, weak, nullable) id<BDMNativeAdAdapterDelegate> delegate;

+ (instancetype)displayAdapterForAd:(STKNASTAd *)ad contentInfo:(NSDictionary<NSString *,NSString *> *)contentInfo;

@end

NS_ASSUME_NONNULL_END

