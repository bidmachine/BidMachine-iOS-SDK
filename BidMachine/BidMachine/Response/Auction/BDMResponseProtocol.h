//
//  BDMResonseProtocol.h
//  BidMachine
//
//  Created by Stas Kochkin on 07/11/2017.
//  Copyright © 2017 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BDMEventURL.h"
#import "BDMViewabilityMetricProvider.h"
#import "BDMDefines.h"

@protocol BDMCreative <NSObject, NSCopying>

@property (nonatomic, copy, readonly) NSString *ID;
@property (nonatomic, copy, readonly) NSString *displaymanager;
@property (nonatomic, copy, readonly) NSDictionary <NSString *, NSString *> *renderingInfo;
@property (nonatomic, copy, readonly) NSDictionary <NSString *, NSString *> *customParams;
@property (nonatomic, copy, readonly) NSArray <NSString *> *adDomains;
@property (nonatomic, copy, readonly) NSArray <BDMEventURL *> *trackers;
@property (nonatomic, copy, readonly) BDMViewabilityMetricConfiguration *viewabilityConfig;
@property (nonatomic, assign, readonly) BDMCreativeFormat format;

@end


@protocol BDMResponse <NSObject, NSCopying>

@property (nonatomic, copy, readonly) NSString * identifier;
@property (nonatomic, copy, readonly) NSNumber * price;
@property (nonatomic, copy, readonly) NSString * currency;
@property (nonatomic, copy, readonly) NSString * demandSource;
@property (nonatomic, copy, readonly) NSString * pricingType;
@property (nonatomic, copy, readonly) NSNumber * expirationTime;
@property (nonatomic, copy, readonly) NSString * cid;
@property (nonatomic, copy, readonly) NSString * deal;

@property (nonatomic, copy, readonly) id<BDMCreative> creative;

@end

