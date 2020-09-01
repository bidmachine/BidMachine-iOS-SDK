//
//  BDMEventObject.h
//  BidMachine
//
//  Created by Ilia Lozhkin on 31.08.2020.
//  Copyright © 2020 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDMContextualProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol BDMEventObjectProtocol <BDMContextualProtocol, NSCopying>

@property (nonatomic, assign, readonly) BOOL isTracked;
@property (nonatomic,   copy, readonly) NSString *network;

@end

@interface BDMEventObject : NSObject <BDMEventObjectProtocol>

- (instancetype)initWithSessionId:(NSString *)sessionId
                            event:(BDMEvent)event
                          network:(NSString *)network
                        placement:(BDMInternalPlacementType)placement;

- (void)complete;

- (void)reject:(BDMErrorCode)code;

@end

NS_ASSUME_NONNULL_END
