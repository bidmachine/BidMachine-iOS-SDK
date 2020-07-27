//
//  BDMRequestStorage+Private.h
//  BidMachine
//
//  Created by Ilia Lozhkin on 27.07.2020.
//  Copyright © 2020 Appodeal. All rights reserved.
//

#import <BidMachine/BDMRequestStorage.h>

NS_ASSUME_NONNULL_BEGIN

@interface BDMRequestStorage ()

- (void)saveRequest:(BDMRequest *)request withPrice:(NSString *)price type:(BDMInternalPlacementType)type;

@end

NS_ASSUME_NONNULL_END
