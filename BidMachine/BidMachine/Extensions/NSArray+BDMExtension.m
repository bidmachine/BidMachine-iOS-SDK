//
//  NSArray+BDMExtension.m
//  BidMachine
//
//  Created by Ilia Lozhkin on 16.01.2021.
//  Copyright © 2021 Appodeal. All rights reserved.
//

#import "NSArray+BDMExtension.h"

#import <StackFoundation/StackFoundation.h>

@implementation NSArray (BDMEventURL)

- (BDMEventURL *)bdm_searchTrackerOfType:(NSInteger)type {
    return [self stk_filter:^BOOL(BDMEventURL * tracker) {
        if (!BDMEventURL.stk_isValid(tracker)) {
            return false;
        }
        return tracker.type == type;
    }].firstObject;
}

@end

@implementation NSArray (BDMAdNetworkConfiguration)

- (NSArray<BDMAdNetworkConfiguration *> *)bdm_configurationConcat:(NSArray<BDMAdNetworkConfiguration *> *)configuration {
    if (self.count == 0) {
        return configuration ?: @[];
    }
    
    __block NSArray<BDMAdNetworkConfiguration *> *concurentConfig = configuration ?: @[];
    [self enumerateObjectsUsingBlock:^(BDMAdNetworkConfiguration * obj, NSUInteger idx, BOOL *stop) {
        *stop = concurentConfig.count == 0;
        concurentConfig = ANY(concurentConfig.copy).filter(^BOOL(BDMAdNetworkConfiguration *conf){
            return ![obj.networkClass isEqual:conf.networkClass];
        }).array.mutableCopy;
    }];
    
    return [NSArray stk_concat:self, concurentConfig, nil];
}

@end
