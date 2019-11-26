//
//  BDMEventTracker.h
//  BidMachine
//
//  Created by Stas Kochkin on 24/10/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDMDefines.h"
#import "BDMProtoAPI-Umbrella.h"
#import "BDMEventMiddleware.h"


/**
 Wrapper for event for mapping BDMEventTypeExtended to Extension from proto models
 @param event Event (or extended errors)
 @return Raw value of BDMEventTypeExtended
 */
NSInteger BDMEventTrackerTypeFromBDMEvent(BDMEvent event);
/**
 Wrapper for event for mapping BDMActionType from Extension from proto models

 @param event Event, extended errors are not supported here!
 @return Raw value of BDMActionType
 */
NSInteger BDMActionTypeFromBDMEvent(BDMEvent event);


@interface BDMEventURL : NSURL

@property (nonatomic, readonly, assign) NSInteger type;
/**
 Replaces BM_ACTION_START in URL
 */
@property (nonatomic, readonly, copy) BDMEventURL *(^extendedByStartTime)(NSDate *);
/**
 Replaces BM_ACTION_FINISH in URL
 */
@property (nonatomic, readonly, copy) BDMEventURL *(^extendedByFinishTime)(NSDate *);
/**
 Replaces macros
 */
@property (nonatomic, readonly, copy) BDMEventURL *(^extendedByAction)(NSInteger);
/**
 Replaces event macros
 */
@property (nonatomic, readonly, copy) BDMEventURL *(^extendedByEvent)(NSInteger);
/**
 Replaces error codes
 */
@property (nonatomic, readonly, copy) BDMEventURL *(^extendedByErrorCode)(BDMErrorCode);
/**
 Replaces type
 */
@property (nonatomic, readonly, copy) BDMEventURL *(^extendedByType)(NSString *);
/**
 Replaces network name
 */
@property (nonatomic, readonly, copy) BDMEventURL *(^extendedByAdNetwork)(NSString *);
/**
 Instantiate event

 @param stringURL Destination URL string
 @param type Type of event
 @return Event URL
 */
+ (BDMEventURL *)trackerWithStringURL:(NSString *)stringURL type:(NSInteger)type;

@end


