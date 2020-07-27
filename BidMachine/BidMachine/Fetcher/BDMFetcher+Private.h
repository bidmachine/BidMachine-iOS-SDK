//
//  BDMFetcher+Private.h
//  BidMachine
//
//  Created by Ilia Lozhkin on 27.07.2020.
//  Copyright © 2020 Appodeal. All rights reserved.
//

#import <BidMachine/BDMFetcher.h>

NS_ASSUME_NONNULL_BEGIN

@interface BDMFetcher ()

- (nullable NSString *)fetchPrice:(NSNumber *)price
                             type:(BDMInternalPlacementType)type
                    serverPresets:(NSArray <id<BDMFetcherPresetProtocol>> *_Nullable)serverPresets
                      userFetcher:(id<BDMFetcherProtocol> _Nullable)userFetcher;

@end

NS_ASSUME_NONNULL_END
