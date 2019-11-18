//
//  BDMNativeAd.h
//  BidMachine
//
//  Created by Stas Kochkin on 31/10/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BidMachine/BidMachine.h>
#import <BidMachine/BDMAdEventProducerProtocol.h>


@class BDMNativeAd;
/// Native ad rendering protocol
@protocol BDMNativeAdRendering <NSObject>
/// Label for title
/// @return Nonnul instance of label
- (nonnull UILabel *)titleLabel;
/// Label for call to action text
/// @return Nonnul instance of label
- (nonnull UILabel *)callToActionLabel;
/// Container with all required and optional BDMNativeAdRendering views
/// @return Nonnul instance of UIView
- (nonnull UIView *)containerView;
/// Label for description text
/// @return Nonnul instance of label
- (nonnull UILabel *)descriptionLabel;
@optional
/// Icon view for icon asset rendering
/// @return Nonnul instance of label may contains placeholder
- (nonnull UIImageView *)iconView;
/// Container for media content
/// @return  Nonnul instance of label may contains with aspect ratio 16:9
- (nonnull UIView *)mediaContainerView;
/// Is called with rating value
/// @param rating Rating value number
- (void)setStarRating:(nonnull NSNumber *)rating;

@end
/// Callback handler of native ad
@protocol BDMNativeAdDelegate <NSObject>
/// Trigger ready event
/// @param nativeAd Ready instance of native ad
/// @param auctionInfo Auction info
- (void)nativeAd:(nonnull BDMNativeAd *)nativeAd readyToPresentAd:(nonnull BDMAuctionInfo *)auctionInfo;
/// Trigger fail to load event
/// @param nativeAd Failed instance of native ad
/// @param error Error object that contains information about fail reason
- (void)nativeAd:(nonnull BDMNativeAd *)nativeAd failedWithError:(nonnull NSError *)error;
@optional
/// Trigger when native ad did expire
/// @param nativeAd Expired instance of native
- (void)nativeAdDidExpire:(nonnull BDMNativeAd *)nativeAd;

@end
/// Native ad object that provides native
@interface BDMNativeAd : NSObject <BDMAdEventProducer>
/// Delegate of producer
@property (nonatomic, weak, nullable) id<BDMAdEventProducerDelegate> producerDelegate;
/// Info of latest sucessful auctuion
@property (nonatomic, copy, readonly, nullable) BDMAuctionInfo * auctionInfo;
/// Callback handler
@property (nonatomic, weak, readwrite, nullable) id <BDMNativeAdDelegate> delegate;
/// Getter that indicates that ad ready or not
@property (nonatomic, assign, readonly, getter=isLoaded) BOOL loaded;
/// Boolean flag indicates can SDK show ad or not
@property (nonatomic, assign, readonly) BOOL canShow;
/// Begin loading of native ad
/// @param request Request with mediation specific parameters
- (void)makeRequest:(nonnull BDMNativeAdRequest *)request;
/// Present ready native ad in container
/// @param adRendering Native ad rendering object that conforms BDMNativeAdRendering
/// @param controller Current view controller
/// @param error Autorelease error pointer that indicates rendering error
- (void)presentOn:(nonnull id <BDMNativeAdRendering>)adRendering
       controller:(nonnull UIViewController *)controller
            error:(NSError *_Nullable __autoreleasing* _Nullable)error;
/// Remove all loaded ad data
- (void)invalidate;

@end
