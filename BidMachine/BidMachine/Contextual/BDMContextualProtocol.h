//
//  BDMContextualProtocol.h
//  BidMachine
//
//  Created by Ilia Lozhkin on 31.08.2020.
//  Copyright © 2020 Appodeal. All rights reserved.
//

#import "BDMPrivateDefines.h"

NS_ASSUME_NONNULL_BEGIN

@protocol BDMContextualProtocol <NSObject>

@property (nonatomic, assign, readonly) BDMInternalPlacementType placement;
@property (nonatomic, assign, readonly) BDMEvent event;
@property (nonatomic,   copy, readonly) NSDate *finishTime;
@property (nonatomic,   copy, readonly) NSDate *startTime;
@property (nonatomic,   copy, readonly) NSString *sessionID;

@end

NS_ASSUME_NONNULL_END
