//
//  BDMContextualController.m
//  BidMachine
//
//  Created by Ilia Lozhkin on 31.08.2020.
//  Copyright © 2020 Appodeal. All rights reserved.
//

#import "BDMContextualController.h"

@interface BDMContextualController ()

@property (nonatomic, strong) NSMapTable <NSString *, NSMutableSet <id<BDMContextualProtocol>>*> *contextualDatas;
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSString *> *lastBundles;
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSString *> *lastAdomain;
@property (nonatomic,   copy) NSDate *startDate;

@end

@implementation BDMContextualController

- (void)start {
    if (!self.startDate) {
        self.startDate          = [NSDate date];
        self.contextualDatas    = [NSMapTable strongToStrongObjectsMapTable];
        self.lastBundles        = NSMutableDictionary.new;
        self.lastAdomain        = NSMutableDictionary.new;
    }
}

- (void)saveContextualData:(id<BDMContextualProtocol>)contextualData {
    NSString *placement = NSStringFromBDMInternalPlacementType(contextualData.placement);
    NSMutableSet <id<BDMContextualProtocol>>* contextualDatas = [self.contextualDatas objectForKey:placement];
    if (!contextualDatas) {
        contextualDatas = NSMutableSet.set;
        [self.contextualDatas setObject:contextualDatas forKey:placement];
    }
    [contextualDatas addObject:contextualData];
}

- (void)saveLastBundle:(NSString *)lastBundle forPlacement:(BDMInternalPlacementType)placement {
    NSString *placementString = NSStringFromBDMInternalPlacementType(placement);
    if (lastBundle) {
        self.lastBundles[placementString] = lastBundle;
    }
}

- (void)saveLastAdomain:(NSString *)lastAdomain forPlacement:(BDMInternalPlacementType)placement {
    NSString *placementString = NSStringFromBDMInternalPlacementType(placement);
    if (lastAdomain) {
        self.lastAdomain[placementString] = lastAdomain;
    }
}

#pragma mark - Generated

- (BDMContextualData *)contextualDataWithUserData:(BDMContextualData *)userData {
    return nil;
}

@end
