//
//  BDMExternalAdapterSDKController.h
//  BidMachine
//
//  Created by Ilia Lozhkin on 02.03.2021.
//  Copyright © 2021 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BidMachine/BDMExternalAdapterConfiguration.h>


NS_ASSUME_NONNULL_BEGIN

@interface BDMExternalAdapterSDKController : NSObject

+ (instancetype)shared;

- (void)startControllerWithConfiguration:(nullable BDMExternalAdapterConfiguration *)configuration
                              completion:(void(^_Nullable)(NSError *_Nullable))completion;


+ (instancetype)new __unavailable;

- (instancetype)init __unavailable;

@end

NS_ASSUME_NONNULL_END
