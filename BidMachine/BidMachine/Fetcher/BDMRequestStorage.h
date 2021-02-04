//
//  BDMRequestStorage.h
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
/// Saves request for future use
/// Will be removed in future versions
/// @param request Current request
/// @param price Rounded price
- (void)saveRequest:(BDMRequest *)request withPrice:(NSString *)price __deprecated_msg("Will be removed in future versions use: saveRequest:");
/// Saves request for future use
/// @param request Current request
- (void)saveRequest:(BDMRequest *)request;
/// Gets saved request
/// @param price Rounded price
/// @param type Creative type
- (nullable BDMRequest *)requestForPrice:(NSString *)price type:(BDMInternalPlacementType)type;
/// Returns the value of prebeid integration
/// @param type Creative type
- (BOOL)isPrebidRequestsForType:(BDMInternalPlacementType)type;

@end

NS_ASSUME_NONNULL_END
