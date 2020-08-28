//
//  BDMHeaderBiddingTransformOperation.m
//  BidMachine
//
//  Created by Stas Kochkin on 17/07/2019.
//  Copyright © 2019 Appodeal. All rights reserved.
//

#import "BDMHeaderBiddingPreparationOperation.h"
#import "BDMPlacementAdUnit.h"
#import "BDMDefines.h"
#import "BDMTransformers.h"
#import "NSError+BDMSdk.h"

#import <StackFoundation/StackFoundation.h>


@interface BDMHeaderBiddingPreparationOperation ()

@property (nonatomic, weak) BDMHeaderBiddingController *controller;
@property (nonatomic, copy) NSArray <BDMAdNetworkConfiguration *> *configs;
@property (nonatomic, copy) NSError *error;
@property (nonatomic, strong) dispatch_group_t preparationGroup;
@property (nonatomic, strong) NSMutableArray <id<BDMPlacementAdUnit>> *mutablePlacementAdUnits;
@property (nonatomic, strong) STKTimer *timer;

@property (nonatomic, assign) BDMInternalPlacementType placement;
@property (nonatomic, assign) NSTimeInterval startTimestamp;
@property (nonatomic, assign) NSTimeInterval executionTime;

@end


@implementation BDMHeaderBiddingPreparationOperation

+ (instancetype)preparationOperationForNetworks:(NSArray<BDMAdNetworkConfiguration *> *)networks
                                     controller:(BDMHeaderBiddingController *)controller
                                      placement:(BDMInternalPlacementType)placement {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    BDMHeaderBiddingPreparationOperation *operation = [super operationOnThread:queue action:^(BDMAsyncOperation *operation) {
        [(BDMHeaderBiddingPreparationOperation *)operation execute];
    }];
    operation.configs = networks;
    operation.controller = controller;
    operation.placement = placement;
    return operation;
}

- (NSMutableArray<id<BDMPlacementAdUnit>> *)mutablePlacementAdUnits {
    if (!_mutablePlacementAdUnits) {
        _mutablePlacementAdUnits = [NSMutableArray new];
    }
    return _mutablePlacementAdUnits;
}

- (NSArray<id<BDMPlacementAdUnit>> *)result {
    return self.mutablePlacementAdUnits;
}

- (void)complete {
    if (self.isFinished || self.isCancelled) {
        return;
    }
    
    [super complete];
    self.preparationGroup = nil;
    self.executionTime = self.startTimestamp > 0 ? [NSDate stk_currentTimeInMilliseconds] - self.startTimestamp : 0;
}

- (NSTimeInterval)timeout {
    NSOperation *operation = self.dependencies.firstObject;
    NSTimeInterval timeout = self.configs.firstObject.timeout;
    if ([operation conformsToProtocol:@protocol(BDMHeaderBiddingOperation)]) {
        timeout = MAX(timeout - [(id<BDMHeaderBiddingOperation>)operation executionTime], 1);
    }
    return timeout / 1000;
}

- (void)execute {
    if (self.configs.count == 0) {
        [self complete];
        return;
    }
    self.preparationGroup = dispatch_group_create();
    self.startTimestamp = NSDate.stk_currentTimeInMilliseconds;
    [self.configs enumerateObjectsUsingBlock:^(BDMAdNetworkConfiguration *config, NSUInteger idx, BOOL *stop) {
        NSArray <BDMAdUnit *> *adUnits = BDMTransformers.adUnits(config, self.placement);
        [adUnits enumerateObjectsUsingBlock:^(BDMAdUnit *adUnit, NSUInteger idx, BOOL *stop) {
            dispatch_group_enter(self.preparationGroup);
            __weak typeof(self) weakSelf = self;
            @autoreleasepool {
                [self.controller prepareAdUnit:adUnit
                                     placement:self.placement
                                       network:config.name
                                    completion:^(id<BDMPlacementAdUnit> placementUnit) {
                    if (placementUnit) {
                        NSLock *lock = [NSLock new];
                        [lock lock];
                        [weakSelf.mutablePlacementAdUnits addObject:placementUnit];
                        [lock unlock];
                    }
                    weakSelf.preparationGroup ? dispatch_group_leave(weakSelf.preparationGroup) : nil;
                }];
            }
        }];
    }];
    
    __weak typeof(self) weakSelf = self;
    dispatch_group_notify(self.preparationGroup, dispatch_get_main_queue(), ^{
        [weakSelf complete];
    });

    
    self.timer = [STKTimer timerWithInterval:self.timeout periodic:NO block:^{
        weakSelf.error = [NSError bdm_errorWithCode:BDMErrorCodeTimeout description:@"Preparing was canceled by timeout"];
        [weakSelf.configs enumerateObjectsUsingBlock:^(BDMAdNetworkConfiguration *config, NSUInteger idx, BOOL *stop) {
            NSArray <BDMAdUnit *> *adUnits = BDMTransformers.adUnits(config, self.placement);
            [adUnits enumerateObjectsUsingBlock:^(BDMAdUnit *adUnit, NSUInteger idx, BOOL *stop) {
                [weakSelf.controller invalidateAdUnit:adUnit
                                            placement:weakSelf.placement
                                              network:config.name];
            }];
        }];
        [weakSelf complete];
    }];
}

@end
