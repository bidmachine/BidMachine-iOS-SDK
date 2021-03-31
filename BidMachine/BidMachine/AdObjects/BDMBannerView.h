//
//  BDMBannerView.h
//  BidMachine
//
//  Created by Stas Kochkin on 10/11/2017.
//  Copyright © 2017 Appodeal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BidMachine/BDMAdRequests.h>
#import <BidMachine/BDMAdEventProducerProtocol.h>


@class BDMBannerView;

@protocol BDMBannerDelegate <NSObject>
/// Called when banner is ready to render creative
/// @param bannerView Ready to present banner view
- (void)bannerViewReadyToPresent:(nonnull BDMBannerView *)bannerView;
/// @param bannerView Failed instance of banner view
/// @param error Error object
- (void)bannerView:(nonnull BDMBannerView *)bannerView failedWithError:(nonnull NSError *)error;
/// Called when user interacts with banner
/// @param bannerView Ready banner view
- (void)bannerViewRecieveUserInteraction:(nonnull BDMBannerView *)bannerView;
@optional
/// Called in case banner performed request by itself
/// when instance of banner view expired
/// @param bannerView banner view
- (void)bannerViewDidExpire:(nonnull BDMBannerView *)bannerView;
/// Called when banner opens product link in external
/// browser (Safari) after user interaction
/// @param bannerView Banner that revieve user interaction
- (void)bannerViewWillLeaveApplication:(nonnull BDMBannerView *)bannerView;
/// Called before banner opens product link in StoreKit or Safari
/// view controller internally in application after user interaction
/// @param bannerView Banner that receives user interaction
- (void)bannerViewWillPresentScreen:(nonnull BDMBannerView *)bannerView;
/// Called after banner dissmissed product link in StoreKit or Safari
/// view controller internally in application after user interaction
/// @param bannerView Banner that recieved user interaction
- (void)bannerViewDidDismissScreen:(nonnull BDMBannerView *)bannerView;
@end

@interface BDMBannerView : UIView <BDMAdEventProducer>
/// Delegate of producer
@property (nonatomic, weak, nullable) id<BDMAdEventProducerDelegate> producerDelegate;
/// Callback handler
@property (nonatomic, weak, nullable) id<BDMBannerDelegate> delegate;
/// Root view controller for presenting modal controllers and
/// viewability tracking
@property (nonatomic, weak, nullable) IBOutlet UIViewController *rootViewController;
/// Info of latest successful auction
@property (nonatomic, copy, readonly, nullable) BDMAuctionInfo *latestAuctionInfo;
/// Getter that indicates if ad is ready or not
@property (nonatomic, assign, readonly, getter=isLoaded) BOOL loaded;
/// Boolean flag that indicates if SDK can show ad or not
@property (nonatomic, assign, readonly) BOOL canShow;
/// Adds request to ad object instance. If request was not
/// performed, ad object will perform request by itslef
/// @param request Request
- (void)populateWithRequest:(nonnull BDMBannerRequest *)request;
@end
