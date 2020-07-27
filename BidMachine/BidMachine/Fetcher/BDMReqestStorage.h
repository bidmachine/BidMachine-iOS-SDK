//
//  BDMReqestStorage.h
//  BidMachine
//
//  Created by Ilia Lozhkin on 27.07.2020.
//  Copyright © 2020 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BidMachine/BDMRequest.h>
#import <BidMachine/BDMDefines.h>

NS_ASSUME_NONNULL_BEGIN

@interface BDMRequestStorage : NSObject

+ (instancetype)shared;

- (nullable BDMRequest *)requestForPrice:(NSString *)price type:(BDMInternalPlacementType)type;

- (nullable BDMRequest *)requestForBidId:(NSString *)bidId;

- (BOOL)isPrebidRequestsForType:(BDMInternalPlacementType)type;

@end

NS_ASSUME_NONNULL_END
