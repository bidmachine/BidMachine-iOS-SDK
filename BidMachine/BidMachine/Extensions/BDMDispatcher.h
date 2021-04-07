//
//  BDMDispatcher.h
//  BidMachine
//
//  Created by Ilia Lozhkin on 01.04.2021.
//  Copyright © 2021 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BDMDispatcher : NSObject

+ (void)dispatchMainSemaphore:(dispatch_block_t)completion;

+ (void)dispatchAsyncMain:(dispatch_block_t)completion;

@end

NS_ASSUME_NONNULL_END
