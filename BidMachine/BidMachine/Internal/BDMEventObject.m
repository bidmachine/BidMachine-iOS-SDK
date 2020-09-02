//
//  BDMEventObject.m
//  BidMachine
//
//  Created by Ilia Lozhkin on 31.08.2020.
//  Copyright © 2020 Appodeal. All rights reserved.
//

#import "BDMEventObject.h"
#import "BDMPrivateDefines.h"

@interface BDMEventObject ()

@property (nonatomic, assign, readwrite) BDMInternalPlacementType placement;
@property (nonatomic, assign, readwrite) BDMEvent event;
@property (nonatomic, assign, readwrite) BOOL isTracked;
@property (nonatomic,   copy, readwrite) NSDate *finishTime;
@property (nonatomic,   copy, readwrite) NSDate *startTime;
@property (nonatomic,   copy, readwrite) NSString *sessionID;
@property (nonatomic,   copy, readwrite) NSString *network;

@property (nonatomic, assign) NSUInteger iteraction;

@end

@implementation BDMEventObject

- (instancetype)initWithSessionId:(NSString *)sessionId
                            event:(BDMEvent)event
                          network:(NSString *)network
                        placement:(BDMInternalPlacementType)placement
{
    if (self = [super init]) {
        _isTracked      = NO;
        _event          = event;
        _placement      = placement;
        _sessionID      = sessionId;
        _startTime      = [NSDate date];
        _network        = network ?: @"unspecified";
    }
    return self;
    
}

- (void)complete {
    self.isTracked = YES;
    self.finishTime = [NSDate date];
    self.iteraction ++;
    BDMLog(@"[Event] %@ event complete(%li), timing: %1.2f sec",
           self.description,
           self.iteraction,
           self.finishTime.timeIntervalSince1970 - self.startTime.timeIntervalSince1970);
}

- (void)reject:(BDMErrorCode)code {
    if (!self.isTracked) {
        self.finishTime = [NSDate date];
        BDMLog(@"[Event] lifecycle error: %@ for %@ event, timing: %1.2f sec",
               NSStringFromBDMErrorCode(code),
               self.description,
               self.finishTime.timeIntervalSince1970 - self.startTime.timeIntervalSince1970);
    }
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
    return  [NSString stringWithFormat:@"%@:::%@:::%@",
             NSStringFromBDMEvent(self.event),
             NSStringFromBDMInternalPlacementType(self.placement),
             self.network];
}

- (id)copyWithZone:(NSZone *)zone {
    BDMEventObject *copy = [[self class] new];
    copy.event = self.event;
    copy.isTracked = self.isTracked;
    copy.placement = self.placement;
    copy.network = self.network.copy;
    copy.finishTime = self.finishTime.copy;
    copy.startTime = self.startTime.copy;
    copy.sessionID = self.sessionID;
    return copy;
}

@end
