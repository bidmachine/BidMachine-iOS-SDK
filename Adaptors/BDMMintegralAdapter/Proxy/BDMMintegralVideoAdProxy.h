//
//  BDMMintegralVideoAdProxy.h
//  BDMMintegralAdapter
//
//  Created by Yaroslav Skachkov on 9/5/19.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

@import Foundation;
@import BidMachine;
@import BidMachine.Adapters;
#import <MTGSDKReward/MTGBidRewardAdManager.h>

NS_ASSUME_NONNULL_BEGIN

@interface BDMMintegralVideoAdProxy : NSObject <MTGRewardAdLoadDelegate, MTGRewardAdShowDelegate>

@property (nonatomic, weak) id <BDMFullscreenAdapter> adapter;
@property (nonatomic, strong, readonly) MTGBidRewardAdManager *manager;

+ (instancetype)sharedInstance;
- (void)loadVideoWithBidToken:(nonnull NSString *)bidToken
                       unitId:(nonnull NSString *)unitId
                      adapter:(nonnull id <BDMFullscreenAdapter>)adapter;
- (void)showVideo:(nonnull NSString *)unitId
     withRewardId:(nonnull NSString *)rewardId
           userId:(nullable NSString *)userId
          adapter:(nonnull id <BDMFullscreenAdapter>)adapter;

@end

NS_ASSUME_NONNULL_END
