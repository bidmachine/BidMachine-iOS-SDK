//
//  BDMEventObject.h
//  BidMachine
//
//  Created by Ilia Lozhkin on 31.08.2020.
//  Copyright © 2020 Appodeal. All rights reserved.
//

#import "BDMPrivateDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface BDMEventObject : NSObject

@property (nonatomic, assign, readonly) BDMInternalPlacementType placement;
@property (nonatomic, assign, readonly) BDMEvent event;
@property (nonatomic, assign, readonly) BOOL isTracked;
@property (nonatomic,   copy, readonly) NSDate *finishTime;
@property (nonatomic,   copy, readonly) NSDate *startTime;
@property (nonatomic,   copy, readonly) NSString *sessionID;
@property (nonatomic,   copy, readonly) NSString *network;

- (instancetype)initWithSessionId:(NSString *)sessionId
                            event:(BDMEvent)event
                          network:(NSString *)network
                        placement:(BDMInternalPlacementType)placement;

- (void)complete;

- (void)reject:(BDMErrorCode)code;

@end

NS_ASSUME_NONNULL_END
