//
//  BDMPlacementRequestBuilderProtocol.h
//  BidMachine
//
//  Created by Stas Kochkin on 14/11/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "BDMPlacementAdUnit.h"


@protocol BDMNativeFormatTypeBuilder <NSObject>

@property (nonatomic, readonly) id format;

- (id<BDMNativeFormatTypeBuilder>(^)(unsigned int))appendId;
- (id<BDMNativeFormatTypeBuilder>(^)(BOOL))appendReq;

@end

@protocol BDMNativeFormatBuilder <NSObject>

@property (nonatomic, readonly) id format;

- (id<BDMNativeFormatBuilder>(^)(id <BDMNativeFormatTypeBuilder>))appendTitle;
- (id<BDMNativeFormatBuilder>(^)(id <BDMNativeFormatTypeBuilder>))appendIcon;
- (id<BDMNativeFormatBuilder>(^)(id <BDMNativeFormatTypeBuilder>))appendImage;
- (id<BDMNativeFormatBuilder>(^)(id <BDMNativeFormatTypeBuilder>))appendDescription;
- (id<BDMNativeFormatBuilder>(^)(id <BDMNativeFormatTypeBuilder>))appendCta;
- (id<BDMNativeFormatBuilder>(^)(id <BDMNativeFormatTypeBuilder>))appendRating;
- (id<BDMNativeFormatBuilder>(^)(id <BDMNativeFormatTypeBuilder>))appendSponsored;
- (id<BDMNativeFormatBuilder>(^)(id <BDMNativeFormatTypeBuilder>))appendVideo;


@end

@protocol BDMDisplayPlacementBuilder <NSObject>

@property (nonatomic, readonly) id placement;

- (id<BDMDisplayPlacementBuilder>(^)(unsigned int))appendPos;
- (id<BDMDisplayPlacementBuilder>(^)(BOOL))appendInstl;
- (id<BDMDisplayPlacementBuilder>(^)(unsigned int))appendApi;
- (id<BDMDisplayPlacementBuilder>(^)(id<BDMNativeFormatBuilder>))appendNativeFmt;
- (id<BDMDisplayPlacementBuilder>(^)(unsigned int))appendUnit;
- (id<BDMDisplayPlacementBuilder>(^)(float))appendWidth;
- (id<BDMDisplayPlacementBuilder>(^)(float))appendHeight;
- (id<BDMDisplayPlacementBuilder>(^)(NSArray<NSString *> *))appendMimes;

@end

@protocol BDMVideoPlacementBuilder <NSObject>

@property (nonatomic, readonly) id placement;

- (id<BDMVideoPlacementBuilder>(^)(unsigned int))appendPos;
- (id<BDMVideoPlacementBuilder>(^)(BOOL))appendskip;
- (id<BDMVideoPlacementBuilder>(^)(unsigned int))appendApi;
- (id<BDMVideoPlacementBuilder>(^)(NSArray<NSNumber *>*))appendCType;
- (id<BDMVideoPlacementBuilder> (^)(unsigned int))appendUnit;
- (id<BDMVideoPlacementBuilder>(^)(float))appendWidth;
- (id<BDMVideoPlacementBuilder>(^)(float))appendHeight;
- (id<BDMVideoPlacementBuilder>(^)(NSArray<NSString *> *))appendMimes;
- (id<BDMVideoPlacementBuilder>(^)(unsigned int))appendMaxdur;
- (id<BDMVideoPlacementBuilder>(^)(unsigned int))appendMindur;
- (id<BDMVideoPlacementBuilder>(^)(unsigned int))appendMinbitr;
- (id<BDMVideoPlacementBuilder>(^)(unsigned int))appendMaxbitr;
- (id<BDMVideoPlacementBuilder>(^)(unsigned int))appendLinearity;

@end

@protocol BDMPlacementOMIDBuilder <NSObject>

- (id<BDMPlacementOMIDBuilder>(^)(NSString *))appendSDK;
- (id<BDMPlacementOMIDBuilder>(^)(NSString *))appendSDKVer;

@end

@protocol BDMPlacementRequestBuilder <NSObject>

@property (nonatomic, readonly) id placement;

- (id<BDMPlacementRequestBuilder>(^)(NSString *))appendSDK;
- (id<BDMPlacementRequestBuilder>(^)(NSString *))appendSDKVer;
- (id<BDMPlacementRequestBuilder>(^)(BOOL))appendReward;
- (id<BDMPlacementRequestBuilder>(^)(void(^)(id<BDMPlacementOMIDBuilder>)))appendOMID;

- (id<BDMPlacementRequestBuilder>(^)(id<BDMDisplayPlacementBuilder>))appendDisplayPlacement;
- (id<BDMPlacementRequestBuilder>(^)(id<BDMVideoPlacementBuilder>))appendVideoPlacement;
- (id<BDMDisplayPlacementBuilder>(^)(NSArray <id<BDMPlacementAdUnit>> *))appendHeaderBidding;

@end


