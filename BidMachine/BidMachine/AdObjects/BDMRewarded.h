//
//  BDMRewarded.h
//  BidMachine
//
//  Created by Stas Kochkin on 07/11/2017.
//  Copyright © 2017 Appodeal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BidMachine/BDMAdRequests.h>
#import <BidMachine/BDMAdEventProducerProtocol.h>


@class BDMRewarded;

@protocol BDMRewardedDelegate <NSObject>
/// Called when rewarded ad is ready to be presented on screen
/// @param rewarded Ready to present rewarded
- (void)rewardedReadyToPresent:(nonnull BDMRewarded *)rewarded;
/// Triggers when ad failed to load
/// @param rewarded Failed instance of rewarded ad
/// @param error Error object that contains information about reason of failure
- (void)rewarded:(nonnull BDMRewarded *)rewarded failedWithError:(nonnull NSError *)error;
/// Triggers what ad failed to present
/// @param rewarded Failed instance of rewarded ad
/// @param error Error object that contains information about reason of failure
- (void)rewarded:(nonnull BDMRewarded *)rewarded failedToPresentWithError:(nonnull NSError *)error;
/// Triggers when rewarded ad was presented
/// @param rewarded Presenting instance of rewarded ad
- (void)rewardedWillPresent:(nonnull BDMRewarded *)rewarded;
/// Triggers when rewarded ad was closed
/// @param rewarded Presented instance of rewarded ad
- (void)rewardedDidDismiss:(nonnull BDMRewarded *)rewarded;
/// Triggers when rewarded ad registered user interaction with creative
/// @param rewarded Presenting instance of rewarded ad
- (void)rewardedRecieveUserInteraction:(nonnull BDMRewarded *)rewarded;
/// Triggers when rewarded ad registered completion of reward action in creative
/// @param rewarded Presenting rewarded adinterstitial
- (void)rewardedFinishRewardAction:(nonnull BDMRewarded *)rewarded;
@optional
/// Triggers when rewarded ad expired
/// @param rewarded Expired instance of rewarded
- (void)rewardedDidExpire:(nonnull BDMRewarded *)rewarded;
@end

@interface BDMRewarded : NSObject <BDMAdEventProducer>
/// Delegate of producer
@property (nonatomic, weak, nullable) id<BDMAdEventProducerDelegate> producerDelegate;
/// Callback handler
@property (nonatomic, weak, nullable) id<BDMRewardedDelegate> delegate;
/// Info of latest successful auction
@property (nonatomic, copy, readonly, nullable) BDMAuctionInfo * auctionInfo;
/// Boolean flag that indicates if ad is available
@property (nonatomic, assign, readonly, getter=isLoaded) BOOL loaded;
/// Boolean flag that indicates if SDK can show ad or not
@property (nonatomic, assign, readonly) BOOL canShow;
/// Presented ad view. If ad is not on screen - this property is nil
@property (nonatomic, readonly, nullable) UIView * adView;
/// Adds request to ad object instance. If request was not
/// performed, ad object will perform request by itslef
/// @param request Request
- (void)populateWithRequest:(nonnull BDMRewardedRequest *)request;
/// Begins presentation of ad if it's available
/// @param rootViewController view controller for presentation
- (void)presentFromRootViewController:(nonnull UIViewController *)rootViewController;
/// Remove all loaded ad data
- (void)invalidate;
@end
