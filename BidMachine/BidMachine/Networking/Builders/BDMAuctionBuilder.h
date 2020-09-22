//
//  BDMRequestBuilder.h
//
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDMRequest.h"
#import "BDMAuctionSettings.h"
#import "BDMPublisherInfo.h"
#import "BDMPlacementRequestBuilderProtocol.h"

@class GPBMessage;

@interface BDMAuctionBuilder : NSObject

@property (nonatomic, readonly) GPBMessage *message;

- (BDMAuctionBuilder *(^)(BOOL))appendTestMode;
- (BDMAuctionBuilder *(^)(NSString *))appendSellerID;
- (BDMAuctionBuilder *(^)(BDMTargeting *))appendTargeting;
- (BDMAuctionBuilder *(^)(BDMPublisherInfo *))appendPublisherInfo;
- (BDMAuctionBuilder *(^)(BDMUserRestrictions *))appendRestrictions;
- (BDMAuctionBuilder *(^)(NSArray <BDMPriceFloor *> *))appendPriceFloors;
- (BDMAuctionBuilder *(^)(id<BDMAuctionSettings>))appendAuctionSettings;
- (BDMAuctionBuilder *(^)(id<BDMContextualProtocol>))appendContextualData;
- (BDMAuctionBuilder *(^)(id<BDMPlacementRequestBuilder>))appendPlacementBuilder;

@end
