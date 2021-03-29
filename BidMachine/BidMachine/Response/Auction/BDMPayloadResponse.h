//
//  BDMPayloadResponse.h
//  BidMachine
//
//  Created by Ilia Lozhkin on 28.03.2021.
//  Copyright © 2021 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDMResponseProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface BDMPayloadResponse : NSObject

@property (nonatomic, copy, readonly, nullable) id<BDMResponse> response;
@property (nonatomic, copy, readonly, nullable) NSURL *url;

+ (instancetype)parseFromPayload:(NSString *)payload;

@end

NS_ASSUME_NONNULL_END
