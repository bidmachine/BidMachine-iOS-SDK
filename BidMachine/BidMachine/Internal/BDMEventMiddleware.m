//
//  BDMEventMidleware.m
//  BidMachine
//
//  Created by Stas Kochkin on 28/11/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//


#import "BDMEventMiddleware.h"
#import "NSArray+BDMEventURL.h"
#import "BDMServerCommunicator.h"

#import <StackFoundation/StackFoundation.h>


static NSInteger const BDMEventError = 1000;
static NSInteger const BDMEventTrackingError = 1001;


NSString *NSStringFromBDMEvent(BDMEvent event) {
    switch (event) {
        case BDMEventCreativeLoading: return @"Creative loading"; break;
        case BDMEventClick: return @"User interaction"; break;
        case BDMEventClosed: return @"Closing"; break;
        case BDMEventViewable: return @"Viewable"; break;
        case BDMEventDestroyed: return @"Destroying"; break;
        case BDMEventImpression: return @"Impression"; break;
        case BDMEventAuction: return @"Auction"; break;
        case BDMEventInitialisation: return @"Initialisation"; break;
        case BDMEventHeaderBiddingNetworkInitializing: return @"Header Bidding network initialisation"; break;
        case BDMEventHeaderBiddingNetworkPreparing: return @"Header Bidding network preparing"; break;
        case BDMEventHeaderBiddingAllHeaderBiddingNetworksPrepared: return @"Header Bidding preparation"; break;
    }
    return @"unspecified";
}


BDMEvent BDMEventFromNSString(NSString *event) {
    if ([event isEqualToString:@"Creative loading"]) {
        return BDMEventCreativeLoading;
    } else if ([event isEqualToString:@"User interaction"]) {
        return BDMEventClick;
    } else if ([event isEqualToString:@"Closing"]) {
        return BDMEventClosed;
    } else if ([event isEqualToString:@"Viewable"]) {
        return BDMEventViewable;
    } else if ([event isEqualToString:@"Destroying"]) {
        return BDMEventDestroyed;
    } else if ([event isEqualToString:@"Impression"]) {
        return BDMEventImpression;
    } else if ([event isEqualToString:@"Auction"]) {
        return BDMEventAuction;
    } else if ([event isEqualToString:@"Initialisation"]) {
        return BDMEventInitialisation;
    } else if ([event isEqualToString:@"Header Bidding network initialisation"]) {
        return BDMEventHeaderBiddingNetworkInitializing;
    } else if ([event isEqualToString:@"Header Bidding network preparing"]) {
        return BDMEventHeaderBiddingNetworkPreparing;
    } else if ([event isEqualToString:@"Header Bidding preparation"]) {
        return BDMEventHeaderBiddingAllHeaderBiddingNetworksPrepared;
    }
    return 0;
}


NSString *NSStringFromBDMErrorCode(BDMErrorCode code) {
    switch (code) {
        case BDMErrorCodeInternal: return @"Internal"; break;
        case BDMErrorCodeTimeout: return @"Timeout"; break;
        case BDMErrorCodeException: return @"Exception"; break;
        case BDMErrorCodeNoContent: return @"No content"; break;
        case BDMErrorCodeWasClosed: return @"Was closed"; break;
        case BDMErrorCodeUnknown: return @"Unknown"; break;
        case BDMErrorCodeBadContent: return @"Bad content"; break;
        case BDMErrorCodeWasExpired: return @"Was expired"; break;
        case BDMErrorCodeNoConnection: return @"No internet connection"; break;
        case BDMErrorCodeWasDestroyed: return @"Was destroyed"; break;
        case BDMErrorCodeHTTPBadRequest: return @"Bad request"; break;
        case BDMErrorCodeHTTPServerError: return @"Internal server error"; break;
        case BDMErrorCodeHeaderBiddingNetwork: return @"Ad Network specific error"; break;
    }
}

NSString *NSStringFromBDMInternalPlacementType(BDMInternalPlacementType type) {
    switch (type) {
        case BDMInternalPlacementTypeInterstitial: return @"Interstitial"; break;
        case BDMInternalPlacementTypeRewardedVideo: return  @"RewardedVideo"; break;
        case BDMInternalPlacementTypeBanner: return @"Banner"; break;
        case BDMInternalPlacementTypeNative: return @"Native"; break;
    }
    return @"Session";
}

BDMInternalPlacementType BDMInternalPlacementTypeFromNSString(NSString *type) {
    if ([type isEqualToString:@"Interstitial"]) {
        return BDMInternalPlacementTypeInterstitial;
    } else if ([type isEqualToString:@"RewardedVideo"]) {
        return BDMInternalPlacementTypeRewardedVideo;
    } else if ([type isEqualToString:@"Banner"]) {
        return BDMInternalPlacementTypeBanner;
    } else if ([type isEqualToString:@"Native"]) {
        return BDMInternalPlacementTypeNative;
    } else {
        return 0;
    }
}

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

@interface BDMEventObject : NSObject

@property (nonatomic, assign, readonly) BOOL isTracked;
@property (nonatomic, assign, readonly) BDMEvent event;
@property (nonatomic, strong, readonly) NSDate *startTime;
@property (nonatomic, strong, readonly) NSString *network;
@property (nonatomic, assign, readonly) BDMInternalPlacementType placement;

@end

@implementation BDMEventObject


- (instancetype)initWithEvent:(BDMEvent)event
                      network:(NSString *)network
                    placement:(BDMInternalPlacementType)placement {
    if (self = [super init]) {
        _isTracked      = NO;
        _event          = event;
        _placement      = placement;
        _startTime      = [NSDate date];
        _network        = network ?: @"unspecified";
    }
    return self;
    
}

- (void)updateTracked {
    _isTracked = YES;
}

- (BOOL)isEqual:(BDMEventObject *)object {
    if (![object isKindOfClass:BDMEventObject.class]) {
        return NO;
    }
    NSString *network = object.network ?: @"unspecified";
    return
    self.event == object.event &&
    self.placement == object.placement &&
    [self.network isEqualToString:network];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@:::%@:::%@",
            NSStringFromBDMEvent(self.event),
            NSStringFromBDMInternalPlacementType(self.placement),
            self.network];
}

@end


@interface BDMEventMiddleware ()

@property (nonatomic, strong) NSMutableArray <BDMEventObject *> *eventObjects;
@property (nonatomic, copy) NSArray<BDMEventURL *> *(^updateEvents)(void);
@property (nonatomic, copy) id<BDMAdEventProducer> (^updateProducer)(void);

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
    [self.eventObjects addObject:[[BDMEventObject alloc] initWithEvent:type network:network placement:placement]];
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
    BDMEventObject *event = ANY(self.eventObjects).filter(^BOOL(BDMEventObject *obj){
        return [obj isEqual:[[BDMEventObject alloc] initWithEvent:type network:network placement:placement]];
    }).array.firstObject;
    
    if (!event) {
        return;
    }
    
    if (!event.isTracked) {
        [self notifyProducerDelegateIfNeeded:type];
    }
    
    [event updateTracked];
    NSDate *finishTime = [NSDate date];
    BDMLog(@"[Event] %@ event, timing: %1.2f sec", event.description, finishTime.timeIntervalSince1970 - event.startTime.timeIntervalSince1970);
    
    NSArray <BDMEventURL *> *trackers = STK_RUN_BLOCK(self.updateEvents);
    BDMEventURL *URL = [trackers bdm_searchTrackerOfType:type];
    if (!URL) {
        return;
    }
    
    BDMEventURL *fallbackURL = [trackers bdm_searchTrackerOfType:BDMEventTrackingError];
    
    URL = URL
    .extendedByStartTime(event.startTime)
    .extendedByFinishTime(finishTime)
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
                                                             finishTime:finishTime];
                                                 }];
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
    BDMEventObject *event = ANY(self.eventObjects).filter(^BOOL(BDMEventObject *obj){
        return [obj isEqual:[[BDMEventObject alloc] initWithEvent:type network:network placement:placement]];
    }).array.firstObject;
    
    if (!event) {
        return;
    }
    
    NSDate *finishTime = [NSDate date];
    [self.eventObjects removeObject:event];
    BDMLog(@"[Event] lifecycle error: %@ for %@ event, timing: %1.2f sec",
           NSStringFromBDMErrorCode(code),
           event.description,
           finishTime.timeIntervalSince1970 - event.startTime.timeIntervalSince1970);
    
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
    .extendedByFinishTime(finishTime)
    .extendedByAction(type)
    .extendedByErrorCode(code)
    .extendedByType(NSStringFromBDMInternalPlacementType(placement))
    .extendedByAdNetwork(network);
    
    [BDMServerCommunicator.sharedCommunicator trackEvent:URL];
}

- (void)rejectAll:(BDMErrorCode)code {
    NSArray *events = [self.eventObjects copy];
    [events enumerateObjectsUsingBlock:^(BDMEventObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // Send trackers for requiered events
        if (obj.event != BDMEventViewable &&
            obj.event != BDMEventClosed &&
            obj.event != BDMEventImpression &&
            obj.event != BDMEventClick) {
            [self rejectEvent:obj.event code:code];
            // Just remove non required
        } else {
            [self.eventObjects removeObject:obj];
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
    [self.eventObjects removeObject:[[BDMEventObject alloc] initWithEvent:type network:network placement:placement]];
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
