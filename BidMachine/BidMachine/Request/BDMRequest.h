//
//  BDMRequest.h
//  BidMachine
//
//  Created by Stas Kochkin on 08/11/2017.
//  Copyright © 2017 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BidMachine/BDMDefines.h>
#import <BidMachine/BDMPriceFloor.h>
#import <BidMachine/BDMTargeting.h>
#import <BidMachine/BDMAuctionInfo.h>


@class BDMRequest;

@protocol BDMRequestDelegate <NSObject>
/**
 Nethod called in case auction failed

 @param request Failed request
 @param error Error that contains description of failure
 */
- (void)request:(nonnull BDMRequest *)request failedWithError:(nonnull NSError *)error;
/**
 Method called when auction was successfully completed

 @param request Ready to render request
 @param info Auction info
 */
- (void)request:(nonnull BDMRequest *)request completeWithInfo:(nonnull BDMAuctionInfo *)info;
/**
 Method called if successful auction result expired

 @param request Expired request
 */
- (void)requestDidExpire:(nonnull BDMRequest *)request;
@end

/**
 Request object that contains necessary information for bidding
 */
@interface BDMRequest : NSObject 
/**
 Auction info. Nil if auction was not performed or failed
 */
@property (copy, nonatomic, readonly, nullable) BDMAuctionInfo *info;
/**
 Bid prices configuration for current request
 */
@property (copy, nonatomic, readwrite, nonnull) NSArray <BDMPriceFloor *> *priceFloors;
/**
 Current targeting data for request
 */
@property (copy, nonatomic, readwrite, nullable) BDMTargeting *targeting;

@property (copy, nonatomic, readwrite, nullable) NSNumber *timeout;
/**
 Call when mediation win
 */
- (void)notifyMediationWin;
/**
 Call when mediation loss
*/
- (void)notifyMediationLoss;
@end
