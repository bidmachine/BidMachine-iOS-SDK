//
//  BDMInitializationOperation.m
//  BidMachine
//
//  Created by Stas Kochkin on 19/02/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMHeaderBiddingInitialisationOperation.h"
#import "BDMFactory.h"
#import "BDMDefines.h"
#import "NSError+BDMSdk.h"

#import <StackFoundation/StackFoundation.h>


@interface BDMHeaderBiddingInitialisationOperation ()

@property (nonatomic, weak) BDMHeaderBiddingController *controller;
@property (nonatomic, copy) NSArray <BDMAdNetworkConfiguration *> *configs;
@property (nonatomic, copy) NSError *error;
@property (nonatomic, strong) dispatch_group_t initializationGroup;
@property (nonatomic, strong) STKTimer *timer;

@property (nonatomic, assign) BOOL waitUntilFinished;
@property (nonatomic, assign) NSTimeInterval startTimestamp;
@property (nonatomic, assign) NSTimeInterval executionTime;

@end


@implementation BDMHeaderBiddingInitialisationOperation

+ (instancetype)initialisationOperationForNetworks:(NSArray<BDMAdNetworkConfiguration *> *)networks
                                        controller:(BDMHeaderBiddingController *)controller
                                 waitUntilFinished:(BOOL)waitUntilFinished {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    BDMHeaderBiddingInitialisationOperation *operation = [super operationOnThread:queue
                                                                           action:^(BDMAsyncOperation *operation) {
        [(BDMHeaderBiddingInitialisationOperation *)operation execute];
    }];
    operation.controller = controller;
    operation.waitUntilFinished = waitUntilFinished;
    operation.configs = networks;
    return operation;
}

- (void)complete {
    if (self.isFinished || self.isCancelled) {
        return;
    }
    
    [super complete];
    [self.timer cancel];
    self.initializationGroup = nil;
    self.executionTime = self.startTimestamp > 0 ? [NSDate stk_currentTimeInMilliseconds] - self.startTimestamp : 0;
}

- (void)execute {
    if (self.configs.count == 0) {
        [self complete];
        return;
    }
    
    self.initializationGroup = dispatch_group_create();
    self.startTimestamp = NSDate.stk_currentTimeInMilliseconds;
    [self.configs enumerateObjectsUsingBlock:^(BDMAdNetworkConfiguration *config, NSUInteger idx, BOOL *stop) {
        self.waitUntilFinished ? dispatch_group_enter(self.initializationGroup) : nil;
        __weak typeof(self) weakSelf = self;
        [self.controller initializeNetwork:config completion:^{
            weakSelf.waitUntilFinished && weakSelf.initializationGroup ? dispatch_group_leave(weakSelf.initializationGroup) : nil;
        }];
    }];
    
    if (self.waitUntilFinished) {
        __weak typeof(self) weakSelf = self;
        dispatch_group_notify(self.initializationGroup, dispatch_get_main_queue(), ^{
            [weakSelf complete];
        });
        
        self.timer = [STKTimer timerWithInterval:self.configs.firstObject.timeout / 1000 periodic:NO block:^{
            weakSelf.error = [NSError bdm_errorWithCode:BDMErrorCodeTimeout description:@"Initialisation was canceled by timeout"];
            [weakSelf complete];
        }];
    } else {
        [self complete];
    }
}

@end
