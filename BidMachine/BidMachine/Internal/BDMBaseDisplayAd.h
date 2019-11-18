//
//  BDMBaseDisplayAd.h
//  BidMachine
//
//  Created by Stas Kochkin on 14/01/2019.
//  Copyright © 2019 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDMDisplayAdProtocol.h"
#import "BDMAdapterProtocol.h"
#import "BDMResponse.h"


@interface BDMBaseDisplayAd : NSObject <BDMDisplayAd, BDMAdapterLoadingDelegate, BDMNativeAdServiceAdapterLoadingDelegate>

@property (nonatomic, weak, readwrite) id<BDMDisplayAdDelegate> delegate;
@property (nonatomic, weak, readonly) UIView *adView;
@property (nonatomic, copy, readonly) NSString *responseID;

@property (nonatomic, copy, readonly) NSString *displayManager;
@property (nonatomic, copy, readonly) BDMViewabilityMetricConfiguration *viewabilityConfig;

- (instancetype)initWithResponse:(BDMResponse *)response;
- (void)prepareAdapter:(id<BDMAdapter>)adapter;

@end

