//
//  BDMEventTracker.m
//  BidMachine
//
//  Created by Stas Kochkin on 24/10/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMEventURL.h"
#import "BDMProtoAPI-Umbrella.h"


NSInteger BDMEventTrackerTypeFromBDMEvent(BDMEvent event) {
    return (BDMEventTypeExtended)event;
}

NSInteger BDMActionTypeFromBDMEvent(BDMEvent event) {
    return (BDMActionType)event;
}


@interface BDMEventURL ()

@property (nonatomic, readwrite, assign) NSInteger type;

@end


@implementation BDMEventURL

+ (BDMEventURL *)trackerWithStringURL:(NSString *)stringURL type:(NSInteger)type {
    BDMEventURL *tracker = [self URLWithString:stringURL];
    tracker.type = type;
    return tracker;
}

- (BDMEventURL *(^)(NSInteger))extendedByEvent {
    return ^id(NSInteger eventCode) {
        return [self trackerByReplaceMacros:@"BM_EVENT_CODE" withParameter:@(eventCode).stringValue];
    };
}

- (BDMEventURL *(^)(NSInteger))extendedByAction {
    return ^id(NSInteger actionCode) {
        BDMEventURL * tracker = [self trackerByReplaceMacros:@"BM_PROCESS_CODE" withParameter:@(actionCode).stringValue];
        tracker = [tracker trackerByReplaceMacros:@"BM_ACTION_CODE" withParameter:@(actionCode).stringValue];
        return tracker;
    };
}

- (BDMEventURL *(^)(BDMErrorCode))extendedByErrorCode {
    return ^id(BDMErrorCode code) {
        return [self trackerByReplaceMacros:@"BM_ERROR_REASON" withParameter:@(code).stringValue];
    };
}

- (BDMEventURL *(^)(NSDate *))extendedByStartTime {
    return ^id(NSDate *startTime) {
        return [self trackerByReplaceMacros:@"BM_ACTION_START" withParameter:@((long long)(startTime.timeIntervalSince1970 * 1000)).stringValue];
    };
}

- (BDMEventURL *(^)(NSDate *))extendedByFinishTime {
    return ^id(NSDate *finishTime) {
        return [self trackerByReplaceMacros:@"BM_ACTION_FINISH" withParameter:@((long long)(finishTime.timeIntervalSince1970 * 1000)).stringValue];
    };
}

- (BDMEventURL *(^)(NSString *))extendedByType {
    return ^id(NSString *type) {
        return [self trackerByReplaceMacros:@"BM_AD_TYPE" withParameter:type];
    };
}

- (BDMEventURL *(^)(NSString *))extendedByAdNetwork {
    return ^id(NSString *adNetwork) {
        return [self trackerByReplaceMacros:@"HB_NETWORK" withParameter:adNetwork];
    };
}

#pragma mark - Private

- (BDMEventURL *)trackerByReplaceMacros:(NSString *)macros
                              withParameter:(NSString *)parameter {
    if (!parameter) {
        return self.copy;
    }
    
    __block NSString * result = self.absoluteString.copy;
    
    [self.macrosPattern enumerateObjectsUsingBlock:^(NSString * pattern, NSUInteger idx, BOOL * stop) {
        NSString * populatedMacros = [NSString stringWithFormat:pattern, macros];
        result = [result stringByReplacingOccurrencesOfString:populatedMacros
                                                   withString:parameter ? : @""];
    }];
    
    return [BDMEventURL URLWithString:result];
}

- (NSString *)description {
    // Reduce log size. Query is ridiculously big
    return [NSString stringWithFormat:@"SCHEME: %@; HOST: %@; PATH: %@; QUERY: %@...", self.scheme ?: @"", self.host ?: @"", self.path ?: @"", [self.query substringWithRange:NSMakeRange(0, MIN(30, self.query.length))] ?: @""];
}

- (NSArray <NSString *>*)macrosPattern {
    return @[
             @"%%25%%25%@%%25%%25",
             @"%%%%%@%%%%",
             @"${%@}",
             @"%%24%%7B%@%%7D",
             @"$%%7B%@%%7D",
             @"%%5B%@%%5D",
             @"[%@]"
             ];
}

#pragma mark - NSSecureCoding, NSCopying

- (id)copyWithZone:(NSZone *)zone {
    BDMEventURL *copy = [super copyWithZone:zone];
    copy.type = self.type;
    return copy;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.type = [aDecoder decodeIntegerForKey:@"type"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeInteger:self.type forKey:@"type"];
}

@end
