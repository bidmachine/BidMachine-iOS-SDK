//
//  BDMContextualController.m
//  BidMachine
//
//  Created by Ilia Lozhkin on 31.08.2020.
//  Copyright © 2020 Appodeal. All rights reserved.
//

#import "BDMContextualController.h"

#import <StackFoundation/StackFoundation.h>


@interface BDMContextualData : NSObject <BDMContextualProtocol>

@property(nonatomic, assign) NSUInteger clicks;
@property(nonatomic, assign) NSUInteger completions;
@property(nonatomic, assign) NSUInteger impressions;
@property(nonatomic, assign) NSUInteger lastClickForImpression;

@property(nonatomic, assign) NSUInteger sessionDuration;
@property(nonatomic, assign) NSUInteger clickRate;
@property(nonatomic, assign) NSUInteger completionRate;

@property(nonatomic,   copy) NSString *lastBundle;
@property(nonatomic,   copy) NSString *lastAdomain;

@end

@implementation BDMContextualData

- (id)copyWithZone:(NSZone *)zone {
    BDMContextualData *copy = self.class.new;
    copy.clicks = self.clicks;
    copy.completions = self.completions;
    copy.impressions = self.impressions;
    copy.lastClickForImpression = self.lastClickForImpression;
    copy.sessionDuration = self.sessionDuration;
    copy.clickRate = self.clickRate;
    copy.completionRate = self.completionRate;
    copy.lastBundle = self.lastBundle.copy;
    copy.lastAdomain = self.lastAdomain.copy;
    return copy;
}

@end

@interface BDMContextualController ()

@property (nonatomic, strong) NSMapTable <NSString *, BDMContextualData *> *contextualDatas;
@property (nonatomic,   copy) NSDate *startDate;

@end

@implementation BDMContextualController

- (void)start {
    if (!self.startDate) {
        self.startDate = [NSDate date];
        [self prepareContextualDatas];
    }
}

- (void)registerImpressionForPlacement:(BDMInternalPlacementType)placement {
    BDMContextualData *contextualData = [self getContextualDataForPlacement:placement];
    contextualData.impressions ++;
    contextualData.lastClickForImpression = 0;
}

- (void)registerClickForPlacement:(BDMInternalPlacementType)placement {
    BDMContextualData *contextualData = [self getContextualDataForPlacement:placement];
    if (!contextualData.lastClickForImpression) {
        contextualData.clicks ++;
    }
    contextualData.lastClickForImpression = 1;
}

- (void)registerCompletionForPlacement:(BDMInternalPlacementType)placement {
    BDMContextualData *contextualData = [self getContextualDataForPlacement:placement];
    contextualData.completions ++;
}

- (void)registerLastBundle:(NSString *)lastBundle forPlacement:(BDMInternalPlacementType)placement {
    BDMContextualData *contextualData = [self getContextualDataForPlacement:placement];
    if (lastBundle) {
        contextualData.lastBundle = lastBundle;
    }
}

- (void)registerLastAdomain:(NSString *)lastAdomain forPlacement:(BDMInternalPlacementType)placement {
    BDMContextualData *contextualData = [self getContextualDataForPlacement:placement];
    if (lastAdomain) {
        contextualData.lastAdomain = lastAdomain;
    }
}

- (id<BDMContextualProtocol>)contextualDataForPlacement:(BDMInternalPlacementType)placement {
    BDMContextualData *contextualData = [self getContextualDataForPlacement:placement].copy;
    contextualData.sessionDuration = NSDate.date.timeIntervalSince1970 - self.startDate.timeIntervalSince1970;
    if (contextualData.impressions > 0) {
        contextualData.clickRate = (@(contextualData.clicks).floatValue / @(contextualData.impressions).floatValue) * 100;
        contextualData.completionRate = (@(contextualData.completions).floatValue / @(contextualData.impressions).floatValue) * 100;
    }
    
    return contextualData;
}

- (BDMContextualData *)getContextualDataForPlacement:(BDMInternalPlacementType)placement {
    NSString *placementName = NSStringFromBDMInternalPlacementType(placement);
    return [self.contextualDatas objectForKey:placementName];
}

#pragma mark - Private

- (void)prepareContextualDatas {
    self.contextualDatas    = [NSMapTable strongToStrongObjectsMapTable];
    for (NSUInteger placement = 0; placement <= BDMInternalPlacementTypeNative; placement ++) {
        NSString *placementName = NSStringFromBDMInternalPlacementType(placement);
        [self.contextualDatas setObject:BDMContextualData.new forKey:placementName];
    }
}

@end
