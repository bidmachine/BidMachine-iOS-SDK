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

- (BDMAuctionBuilder *(^)(NSString *))appendSellerID;
- (BDMAuctionBuilder *(^)(BDMRequest *))appendRequest;
- (BDMAuctionBuilder *(^)(id<BDMAuctionSettings>))appendAuctionSettings;
- (BDMAuctionBuilder *(^)(id<BDMPlacementRequestBuilder>))appendPlacementBuilder;
- (BDMAuctionBuilder *(^)(id<BDMContextualProtocol>))appendContextualData;
- (BDMAuctionBuilder *(^)(BOOL))appendTestMode;
- (BDMAuctionBuilder *(^)(BDMUserRestrictions *))appendRestrictions;
- (BDMAuctionBuilder *(^)(BDMPublisherInfo *))appendPublisherInfo;

@end
