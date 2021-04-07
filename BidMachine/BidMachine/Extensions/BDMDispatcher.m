//
//  BDMDispatcher.m
//  BidMachine
//
//  Created by Ilia Lozhkin on 01.04.2021.
//  Copyright © 2021 Appodeal. All rights reserved.
//

#import "BDMDispatcher.h"

@implementation BDMDispatcher

+ (void)dispatchMainSemaphore:(dispatch_block_t)completion {
    if (NSThread.isMainThread) {
        completion ? completion() : nil;
    } else {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_async(dispatch_get_main_queue(), ^{
            completion ? completion() : nil;
            dispatch_semaphore_signal(semaphore);
        });
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
}

+ (void)dispatchAsyncMain:(dispatch_block_t)completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        completion ? completion() : nil;
    });
}

@end
