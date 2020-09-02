//
//  BDMEventMidleware.h
//  BidMachine
//
//  Created by Stas Kochkin on 28/11/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDMAdEventProducerProtocol.h"
#import "BDMDefines.h"
#import "BDMRequest+Private.h"
#import "BDMPrivateDefines.h"

@class BDMEventURL;

@interface BDMEventMiddlewareBuilder : NSObject

@property (nonatomic, copy, readonly) BDMEventMiddlewareBuilder *(^events)(NSArray <BDMEventURL *>*(^)(void));
@property (nonatomic, copy, readonly) BDMEventMiddlewareBuilder *(^producer)(id<BDMAdEventProducer>(^)(void));

@end

@interface BDMEventMiddleware : NSObject

+ (instancetype)buildMiddleware:(void(^)(BDMEventMiddlewareBuilder *))build;

- (void)rejectAll:(BDMErrorCode)code;

- (void)startEvent:(BDMEvent)type;
- (void)startEvent:(BDMEvent)type
         placement:(BDMInternalPlacementType)placement;
- (void)startEvent:(BDMEvent)type
           network:(NSString *)network;
- (void)startEvent:(BDMEvent)type
         placement:(BDMInternalPlacementType)placement
           network:(NSString *)network;

- (void)fulfillEvent:(BDMEvent)type;
- (void)fulfillEvent:(BDMEvent)type
             network:(NSString *)network;
- (void)fulfillEvent:(BDMEvent)type
           placement:(BDMInternalPlacementType)placement;
- (void)fulfillEvent:(BDMEvent)type
           placement:(BDMInternalPlacementType)placement
             network:(NSString *)network;

- (void)rejectEvent:(BDMEvent)type
               code:(BDMErrorCode)code;
- (void)rejectEvent:(BDMEvent)type
            network:(NSString *)network
               code:(BDMErrorCode)code;
- (void)rejectEvent:(BDMEvent)type
          placement:(BDMInternalPlacementType)placement
               code:(BDMErrorCode)code;
- (void)rejectEvent:(BDMEvent)type
          placement:(BDMInternalPlacementType)placement
            network:(NSString *)network
               code:(BDMErrorCode)code;

- (void)removeEvent:(BDMEvent)type;
- (void)removeEvent:(BDMEvent)type
            network:(NSString *)network;
- (void)removeEvent:(BDMEvent)type
          placement:(BDMInternalPlacementType)placement;
- (void)removeEvent:(BDMEvent)type
          placement:(BDMInternalPlacementType)placement
            network:(NSString *)network;

@end

