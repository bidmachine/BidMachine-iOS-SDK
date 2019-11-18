//
//  BDMNASTDisplayAdapter.h
//  BDMNASTAdapter
//
//  Created by Stas Kochkin on 04/11/2018.
//  Copyright © 2018 Stas Kochkin. All rights reserved.
//

#import <Foundation/Foundation.h>
@import BidMachine.Adapters;

@import StackNASTKit;


@interface BDMNASTDisplayAdapter : NSObject <BDMNativeAdAdapter>

+ (instancetype)displayAdapterForAd:(STKNASTAd *)ad;

@end

