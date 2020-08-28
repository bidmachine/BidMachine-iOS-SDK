//
//  BDMAsyncOperation.m
//  BidMachine
//
//  Created by Stas Kochkin on 12/02/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMAsyncOperation.h"
#import <StackFoundation/StackFoundation.h>

typedef NS_ENUM(NSInteger, BDMAsyncOperationState){
    BDMAsyncOperationReady = 0,
    BDMAsyncOperationExecuting,
    BDMAsyncOperationStateFinished
};


@interface BDMAsyncOperation ()

@property (nonatomic, assign) BDMAsyncOperationState state;
@property (nonatomic, strong) dispatch_queue_t thread;
@property (nonatomic, copy) void(^action)(BDMAsyncOperation *);

@end

@implementation BDMAsyncOperation

+ (instancetype)operationOnThread:(dispatch_queue_t)thread
                           action:(void(^)(BDMAsyncOperation *))action {
    BDMAsyncOperation * operation = [self new];
    operation.thread = thread;
    operation.action = action;
    return operation;
}

- (void)setState:(BDMAsyncOperationState)state {
    switch (state) {
        case BDMAsyncOperationReady: {
            _state = BDMAsyncOperationReady;
            break;
        }
        case BDMAsyncOperationExecuting: {
            [self willChangeValueForKey:@"isExecuting"];
            _state = BDMAsyncOperationExecuting;
            [self didChangeValueForKey:@"isExecuting"];
            break;
        }
        case BDMAsyncOperationStateFinished: {
            [self willChangeValueForKey:@"isExecuting"];
            [self willChangeValueForKey:@"isFinished"];
            _state = BDMAsyncOperationStateFinished;
            [self didChangeValueForKey:@"isExecuting"];
            [self didChangeValueForKey:@"isFinished"];
            break;
        }
    }
}

- (BOOL)isAsynchronous {
    return YES;
}

- (BOOL)isExecuting {
    return self.state == BDMAsyncOperationExecuting;
}

- (BOOL)isFinished {
    return self.state == BDMAsyncOperationStateFinished;
}

- (void)start {
    if (self.cancelled) {
        self.state = BDMAsyncOperationStateFinished;
    } else {
        self.state = BDMAsyncOperationReady;
        [self main];
    }
}

- (void)main {
    self.state = self.cancelled ? BDMAsyncOperationStateFinished : BDMAsyncOperationExecuting;
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.thread ?: dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        STK_RUN_BLOCK(strongSelf.action, strongSelf);
    });
}

- (void)complete {
    self.state = BDMAsyncOperationStateFinished;
}

@end
