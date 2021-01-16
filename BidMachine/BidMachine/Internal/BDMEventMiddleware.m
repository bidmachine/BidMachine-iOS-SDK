//
//  BDMEventMidleware.m
//  BidMachine
//
//  Created by Stas Kochkin on 28/11/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//


#import "BDMEventObject.h"
#import "BDMEventMiddleware.h"
#import "NSArray+BDMExtension.h"
#import "BDMServerCommunicator.h"

#import <StackFoundation/StackFoundation.h>


@interface BDMEventMiddlewareBuilder ()

@property (nonatomic, copy) NSArray<BDMEventURL *> *(^updateEvents)(void);
@property (nonatomic, copy) id<BDMAdEventProducer> (^updateProducer)(void);

@end

@implementation BDMEventMiddlewareBuilder

- (BDMEventMiddlewareBuilder *(^)(NSArray<BDMEventURL *> *(^)(void)))events {
    return ^id(NSArray<BDMEventURL *> *(^updateEvents)(void)) {
        self.updateEvents = [updateEvents copy];
        return self;
    };
}

- (BDMEventMiddlewareBuilder *(^)(id<BDMAdEventProducer> (^)(void)))producer {
    return ^id(id<BDMAdEventProducer>(^updateProducer)(void)) {
        self.updateProducer = [updateProducer copy];
        return self;
    };
}

@end


@interface BDMEventMiddleware ()

@property (nonatomic, strong) NSMutableArray <BDMEventObject *> *eventObjects;
@property (nonatomic,   copy) NSArray<BDMEventURL *> *(^updateEvents)(void);
@property (nonatomic,   copy) id<BDMAdEventProducer> (^updateProducer)(void);

@end


@implementation BDMEventMiddleware

+ (instancetype)buildMiddleware:(void(^)(BDMEventMiddlewareBuilder *))build {
    BDMEventMiddlewareBuilder * builder = BDMEventMiddlewareBuilder.new;
    build(builder);
    return [[self alloc] initWithBuilder:builder];
}

#pragma mark - Start

- (void)startEvent:(BDMEvent)type {
    [self startEvent:type
           placement:NSNotFound];
}

- (void)startEvent:(BDMEvent)type
           network:(NSString *)network {
    [self startEvent:type
           placement:NSNotFound
             network:network];
}

- (void)startEvent:(BDMEvent)type
         placement:(BDMInternalPlacementType)placement {
    [self startEvent:type
           placement:placement
             network:nil];
}

- (void)startEvent:(BDMEvent)type
         placement:(BDMInternalPlacementType)placement
           network:(NSString *)network {
    BDMEventObject *event = [[BDMEventObject alloc] initWithSessionId:@(self.hash).stringValue
                                                                event:type
                                                              network:network
                                                            placement:placement];
    @synchronized (self) {
        [self.eventObjects addObject:event];
    }
}

#pragma mark - Fulfill

- (void)fulfillEvent:(BDMEvent)type {
    [self fulfillEvent:type placement:NSNotFound];
}

- (void)fulfillEvent:(BDMEvent)type
             network:(NSString *)network {
    [self fulfillEvent:type
             placement:NSNotFound
               network:network];
}

- (void)fulfillEvent:(BDMEvent)type
           placement:(BDMInternalPlacementType)placement {
    [self fulfillEvent:type
             placement:placement
               network:nil];
}

- (void)fulfillEvent:(BDMEvent)type
           placement:(BDMInternalPlacementType)placement
             network:(NSString *)network {
    @synchronized (self) {
        NSArray *events = [self.eventObjects copy];
        BDMEventObject *event = ANY(events).filter(^BOOL(BDMEventObject *obj){
            return [obj isEqual:[[BDMEventObject alloc] initWithSessionId:@(self.hash).stringValue
                                                                    event:type
                                                                  network:network
                                                                placement:placement]];
        }).array.firstObject;
        
        if (!event) {
            return;
        }
        
        if (!event.isTracked) {
            [self notifyProducerDelegateIfNeeded:type];
        }
        
        [event complete];
       
        NSArray <BDMEventURL *> *trackers = STK_RUN_BLOCK(self.updateEvents);
        BDMEventURL *URL = [trackers bdm_searchTrackerOfType:type];
        if (!URL) {
            return;
        }
        
        BDMEventURL *fallbackURL = [trackers bdm_searchTrackerOfType:BDMEventTrackingError];
        
        URL = URL
        .extendedByStartTime(event.startTime)
        .extendedByFinishTime(event.finishTime)
        .extendedByType(NSStringFromBDMInternalPlacementType(placement))
        .extendedByAdNetwork(network);
        
        __weak typeof(self) weakSelf = self;
        [BDMServerCommunicator.sharedCommunicator trackEvent:URL
                                                     success:nil
                                                     failure:^(NSError * error) {
            [weakSelf fallback:type
                           url:fallbackURL
                          code:error.code
                     startTime:event.startTime
                    finishTime:event.finishTime];
        }];
    }
}

#pragma mark - Reject

- (void)rejectEvent:(BDMEvent)type
               code:(BDMErrorCode)code {
    [self rejectEvent:type
            placement:NSNotFound
                 code:code];
}

- (void)rejectEvent:(BDMEvent)type
            network:(NSString *)network
               code:(BDMErrorCode)code {
    [self rejectEvent:type
            placement:NSNotFound
              network:network
                 code:code];
}

- (void)rejectEvent:(BDMEvent)type
          placement:(BDMInternalPlacementType)placement
               code:(BDMErrorCode)code {
    [self rejectEvent:type
            placement:placement
              network:nil
                 code:code];
}

- (void)rejectEvent:(BDMEvent)type
          placement:(BDMInternalPlacementType)placement
            network:(NSString *)network
               code:(BDMErrorCode)code {
    @synchronized (self) {
        NSArray *events = [self.eventObjects copy];
        BDMEventObject *event = ANY(events).filter(^BOOL(BDMEventObject *obj){
            return [obj isEqual:[[BDMEventObject alloc] initWithSessionId:@(self.hash).stringValue
                                                                    event:type
                                                                  network:network
                                                                placement:placement]];
        }).array.firstObject;
        
        if (!event) {
            return;
        }
        
        [event reject:code];
        
        @synchronized (self) {
             [self.eventObjects removeObject:event];
        }
        
        NSArray <BDMEventURL *> *trackers = STK_RUN_BLOCK(self.updateEvents);
        BDMEventURL *URL = [trackers bdm_searchTrackerOfType:BDMEventError];
        if (!URL) {
            return;
        }
        
        //TODO: server fraud filter
        if (type == BDMEventAuction && code == BDMErrorCodeNoContent) {
            return;
        }
        
        URL = URL
        .extendedByStartTime(event.startTime)
        .extendedByFinishTime(event.finishTime)
        .extendedByAction(type)
        .extendedByErrorCode(code)
        .extendedByType(NSStringFromBDMInternalPlacementType(placement))
        .extendedByAdNetwork(network);
        
        [BDMServerCommunicator.sharedCommunicator trackEvent:URL];
    }
}

- (void)rejectAll:(BDMErrorCode)code {
    NSArray *events = [self.eventObjects copy];
    [events enumerateObjectsUsingBlock:^(BDMEventObject *obj, NSUInteger idx, BOOL *stop) {
        // Send trackers for requiered events
        if (obj.event != BDMEventViewable &&
            obj.event != BDMEventClosed &&
            obj.event != BDMEventImpression &&
            obj.event != BDMEventClick) {
            [self rejectEvent:obj.event code:code];
            // Just remove non required
        } else {
            @synchronized (self) {
                [self.eventObjects removeObject:obj];
            }
        }
    }];
}

#pragma mark - Remove

- (void)removeEvent:(BDMEvent)type {
    [self removeEvent:type network:nil];
}

- (void)removeEvent:(BDMEvent)type
            network:(NSString *)network {
    [self removeEvent:type
            placement:NSNotFound
              network:network];
}

- (void)removeEvent:(BDMEvent)type
          placement:(BDMInternalPlacementType)placement {
    [self removeEvent:type
            placement:placement
              network:nil];
}

- (void)removeEvent:(BDMEvent)type
          placement:(BDMInternalPlacementType)placement
            network:(NSString *)network {
    BDMEventObject *event = [[BDMEventObject alloc] initWithSessionId:@(self.hash).stringValue
                                                                event:type
                                                              network:network
                                                            placement:placement];
    @synchronized (self) {
        [self.eventObjects removeObject:event];
    }
}

#pragma mark - Private

- (instancetype)initWithBuilder:(BDMEventMiddlewareBuilder *)builder {
    if (self = [super init]) {
        self.updateEvents           = [builder.updateEvents copy];
        self.updateProducer         = [builder.updateProducer copy];
        self.eventObjects           = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)fallback:(BDMEvent)event
             url:(BDMEventURL *)url
            code:(BDMErrorCode)code
       startTime:(NSDate *)startTime
      finishTime:(NSDate *)finishTime {
    
    if (!url) {
        return;
    }
    
    BDMLog(@"[Event] tracking error: %@ for event %@, timing: %1.2f sec",
           NSStringFromBDMErrorCode(code),
           NSStringFromBDMEvent(event),
           finishTime.timeIntervalSince1970 - startTime.timeIntervalSince1970);
    
    url = url
    .extendedByStartTime(startTime)
    .extendedByFinishTime(finishTime)
    .extendedByEvent(event)
    .extendedByErrorCode(code);
    
    [BDMServerCommunicator.sharedCommunicator trackEvent:url];
}

- (void)notifyProducerDelegateIfNeeded:(BDMEvent)event {
    switch (event) {
        case BDMEventViewable: {
            [[STK_RUN_BLOCK(self.updateProducer) producerDelegate] didProduceImpression:STK_RUN_BLOCK(self.updateProducer)];
            break; }
        case BDMEventClick: {
            [[STK_RUN_BLOCK(self.updateProducer) producerDelegate] didProduceUserAction:STK_RUN_BLOCK(self.updateProducer)];
            break; }
        default: break;
    }
}

@end
