//
//  BDMFactory+BDMEventMiddleware.m
//  BidMachine
//
//  Created by Stas Kochkin on 11/01/2019.
//  Copyright © 2019 Appodeal. All rights reserved.
//

#import "BDMFactory+BDMEventMiddleware.h"
#import "BDMRequest+Private.h"
#import "BDMRequest+HeaderBidding.h"
#import "BDMSdk+Project.h"


@implementation BDMFactory (BDMEventMiddleware)

- (BDMEventMiddleware *)middlewareWithRequest:(BDMRequest *)request eventProducer:(id<BDMAdEventProducer>)eventProducer {
    __weak typeof(eventProducer) weakProducer = eventProducer;
    __weak typeof(request) weakRequest = request;
    return [BDMEventMiddleware buildMiddleware:^(BDMEventMiddlewareBuilder * builder) {
        builder.events(^NSArray<BDMEventURL *> *{
            NSArray <BDMEventURL *> *trackers =  weakRequest.eventTrackers ?: @[];
            trackers = BDMSdk.sharedSdk.auctionSettings.eventURLs ? [trackers arrayByAddingObjectsFromArray:BDMSdk.sharedSdk.auctionSettings.eventURLs] : trackers;
            return trackers;
        });
        
        builder.producer(^id<BDMAdEventProducer> {
            return weakProducer;
        });
    }];
}

@end
