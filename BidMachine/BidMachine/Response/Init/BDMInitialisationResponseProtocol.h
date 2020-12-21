//
//  BDMInitialisationResponseProtocol.h
//  BidMachine
//
//  Created by Stas Kochkin on 05/12/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDMEventURL.h"
#import "BDMAdNetworkConfiguration.h"


@protocol BDMInitialisationResponse <NSObject>

@property (nonatomic, copy, readonly) NSURL *auctionURL;
@property (nonatomic, copy, readonly) NSArray <BDMEventURL *> *eventURLs;
@property (nonatomic, copy, readonly) NSArray <BDMAdNetworkConfiguration *> *networkConfigurations;

@property (nonatomic, assign, readonly) NSTimeInterval sessionDelay;

@end

