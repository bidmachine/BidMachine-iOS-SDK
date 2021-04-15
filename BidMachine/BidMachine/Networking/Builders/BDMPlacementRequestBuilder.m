//
//  BDMPlacementRequestBuilder.m
//
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMPlacementRequestBuilder.h"
#import "BDMProtoAPI-Umbrella.h"
#import "BDMTransformers.h"

#import <StackFoundation/StackFoundation.h>

@interface BDMPlacementOMIDBuilder ()

@property (nonatomic, copy) NSString *sdkName;
@property (nonatomic, copy) NSString *sdkVer;

@end

@implementation BDMPlacementOMIDBuilder

- (id<BDMPlacementOMIDBuilder> (^)(NSString *))appendSDK {
    return ^id<BDMPlacementOMIDBuilder>(NSString *sdk){
        self.sdkName = sdk;
        return self;
    };
}

- (id<BDMPlacementOMIDBuilder> (^)(NSString *))appendSDKVer {
    return ^id<BDMPlacementOMIDBuilder>(NSString *ver){
        self.sdkVer = ver;
        return self;
    };
}

@end

@interface BDMPlacementRequestBuilder ()

@property (nonatomic, readwrite, strong) ADCOMPlacement *placement;

@end

@implementation BDMPlacementRequestBuilder

BOOL isBDMAdUnitFormatVideo(BDMAdUnitFormat fmt) {
    switch (fmt) {
        case BDMAdUnitFormatInterstitialUnknown: return YES; break;
        case BDMAdUnitFormatInterstitialVideo: return YES; break;
        case BDMAdUnitFormatRewardedUnknown: return YES; break;
        case BDMAdUnitFormatRewardedVideo: return YES; break;
        default: return NO; break;
    }
}

- (id<BDMPlacementRequestBuilder> (^)(NSString *))appendSDK {
    return ^id<BDMPlacementRequestBuilder>(NSString * sdk){
        self.placement.sdk = sdk;
        return self;
    };
}

- (id<BDMPlacementRequestBuilder> (^)(NSString *))appendSDKVer {
    return ^id<BDMPlacementRequestBuilder>(NSString * sdkVer){
        self.placement.sdkver = sdkVer;
        return self;
    };
}

- (id<BDMPlacementRequestBuilder> (^)(BOOL))appendReward {
    return ^id<BDMPlacementRequestBuilder>(BOOL reward) {
        self.placement.reward = reward;
        return self;
    };
}

- (id<BDMPlacementRequestBuilder> (^)(void (^)(id<BDMPlacementOMIDBuilder>)))appendOMID {
    return ^id<BDMPlacementRequestBuilder>(void (^builder)(id<BDMPlacementOMIDBuilder>)) {
        BDMPlacementOMIDBuilder *omidBuilder = BDMPlacementOMIDBuilder.new;
        builder(omidBuilder);
        NSMutableDictionary *omid = NSMutableDictionary.new;
        omid[@"omidpn"] = omidBuilder.sdkName;
        omid[@"omidpv"] = omidBuilder.sdkVer;
        GPBStruct *extModel = [BDMTransformers structFromValue:omid];
        
        self.placement.ext = extModel;
        return self;
    };
}

- (id<BDMDisplayPlacementBuilder> (^)(NSArray <id<BDMPlacementAdUnit>> *))appendHeaderBidding {
    return ^id(NSArray <id<BDMPlacementAdUnit>> *adUnits) {
        NSArray <id<BDMPlacementAdUnit>> *videoExt = ANY(adUnits).filter(^BOOL(id<BDMPlacementAdUnit> unit) { return isBDMAdUnitFormatVideo(unit.format); }).array;
        NSArray <id<BDMPlacementAdUnit>> *displayExt = ANY(adUnits).filter(^BOOL(id<BDMPlacementAdUnit> unit) { return !isBDMAdUnitFormatVideo(unit.format); }).array;
        
        if (displayExt.count) {
            self.placement.display.extProtoArray = [self headerBiddingExt:displayExt];
        }
        
        if (videoExt.count) {
            self.placement.video.extProtoArray = [self headerBiddingExt:videoExt];
        }
        
        return self;
    };
}

- (id<BDMPlacementRequestBuilder> (^)(id<BDMVideoPlacementBuilder>))appendVideoPlacement {
    return ^id<BDMPlacementRequestBuilder>(id<BDMVideoPlacementBuilder> placement){
        self.placement.video = (ADCOMPlacement_VideoPlacement *)placement.placement;
        return self;
    };
}

- (id<BDMPlacementRequestBuilder> (^)(id<BDMDisplayPlacementBuilder>))appendDisplayPlacement {
    return ^id<BDMPlacementRequestBuilder>(id<BDMDisplayPlacementBuilder> placement){
        self.placement.display = (ADCOMPlacement_DisplayPlacement *)placement.placement;
        return self;
    };
}

- (ADCOMPlacement *)placement {
    if (!_placement) {
        _placement = [ADCOMPlacement message];
    }
    return _placement;
}

- (NSMutableArray <GPBAny *> *)headerBiddingExt:(NSArray <id<BDMPlacementAdUnit>> *)adUnits {
    BDMHeaderBiddingPlacement *placement = [BDMHeaderBiddingPlacement message];
    placement.adUnitsArray =  ANY(adUnits).flatMap(^BDMHeaderBiddingPlacement_AdUnit *(id<BDMPlacementAdUnit> unit) {
        BDMHeaderBiddingPlacement_AdUnit *message = [BDMHeaderBiddingPlacement_AdUnit message];
        message.bidder = unit.bidder;
        message.bidderSdkver = unit.bidderSdkVersion;
        message.clientParams = unit.clientParams.mutableCopy;
        return message;
    }).array.mutableCopy;
    
    GPBAny *any = [GPBAny anyWithMessage:placement error:nil];
    return any ? [NSMutableArray arrayWithObject:any] : [NSMutableArray new];
}

@end


@interface BDMVideoPlacementBuilder ()

@property (nonatomic, readwrite, strong) ADCOMPlacement_VideoPlacement *placement;

@end

@implementation BDMVideoPlacementBuilder

- (id<BDMVideoPlacementBuilder> (^)(unsigned int))appendPos {
    return ^id<BDMVideoPlacementBuilder>(unsigned int pos){
        self.placement.pos = (ADCOMPlacementPosition)pos;
        return self;
    };
}

- (id<BDMVideoPlacementBuilder> (^)(BOOL))appendskip {
    return ^id<BDMVideoPlacementBuilder>(BOOL skip){
        self.placement.skip = skip;
        return self;
    };
}

- (id<BDMVideoPlacementBuilder> (^)(unsigned int))appendApi {
    return ^id<BDMVideoPlacementBuilder>(unsigned int api){
        [self.placement.apiArray addValue:api];
        return self;
    };
}

- (id<BDMVideoPlacementBuilder> (^)(unsigned int))appendUnit {
    return ^id<BDMVideoPlacementBuilder>(unsigned int unitSize){
        self.placement.unit = (ADCOMSizeUnit)unitSize;
        return self;
    };
}

- (id<BDMVideoPlacementBuilder> (^)(NSArray<NSNumber *>*))appendCType {
    return ^id<BDMVideoPlacementBuilder>(NSArray<NSNumber *>* cTypes){
        self.placement.ctypeArray = ANY(cTypes).reduce([GPBEnumArray array], ^(GPBEnumArray *array, NSNumber *value){
            [array addValue:value.unsignedIntValue];
        }).value;
        return self;
    };
}

- (id<BDMVideoPlacementBuilder> (^)(float))appendHeight {
    return ^id<BDMVideoPlacementBuilder>(float value){
        self.placement.h = value;
        return self;
    };
}

- (id<BDMVideoPlacementBuilder> (^)(float))appendWidth {
    return ^id<BDMVideoPlacementBuilder>(float value){
        self.placement.w = value;
        return self;
    };
}

- (id<BDMVideoPlacementBuilder> (^)(NSArray<NSString *> *))appendMimes {
    return ^id<BDMVideoPlacementBuilder>(NSArray<NSString *> * value){
        self.placement.mimeArray = value.mutableCopy;
        return self;
    };
}

- (id<BDMVideoPlacementBuilder> (^)(unsigned int))appendMaxdur {
    return ^id<BDMVideoPlacementBuilder>(unsigned int value){
        self.placement.maxdur = value;
        return self;
    };
}

- (id<BDMVideoPlacementBuilder> (^)(unsigned int))appendMindur {
    return ^id<BDMVideoPlacementBuilder>(unsigned int value){
        self.placement.mindur = value;
        return self;
    };
}

- (id<BDMVideoPlacementBuilder> (^)(unsigned int))appendMinbitr {
    return ^id<BDMVideoPlacementBuilder>(unsigned int value){
        self.placement.minbitr = value;
        return self;
    };
}

- (id<BDMVideoPlacementBuilder> (^)(unsigned int))appendMaxbitr {
    return ^id<BDMVideoPlacementBuilder>(unsigned int value){
        self.placement.maxbitr = value;
        return self;
    };
}

- (id<BDMVideoPlacementBuilder> (^)(unsigned int))appendLinearity {
    return ^id<BDMVideoPlacementBuilder>(unsigned int value){
        self.placement.linear = value;
        return self;
    };
}

- (ADCOMPlacement_VideoPlacement *)placement {
    if (!_placement) {
        _placement = [ADCOMPlacement_VideoPlacement message];
    }
    return _placement;
}

@end


@interface BDMDisplayPlacementBuilder ()

@property (nonatomic, readwrite, strong) ADCOMPlacement_DisplayPlacement *placement;

@end


@implementation BDMDisplayPlacementBuilder

- (id<BDMDisplayPlacementBuilder> (^)(unsigned int))appendPos {
    return ^id<BDMDisplayPlacementBuilder>(unsigned int pos){
        self.placement.pos = (ADCOMPlacementPosition)pos;
        return self;
    };
}

- (id<BDMDisplayPlacementBuilder> (^)(BOOL))appendInstl {
    return ^id<BDMDisplayPlacementBuilder>(BOOL instl){
        self.placement.instl = instl;
        return self;
    };
}

- (id<BDMDisplayPlacementBuilder> (^)(unsigned int))appendApi {
    return ^id<BDMDisplayPlacementBuilder>(unsigned int api){
        [self.placement.apiArray addValue:api];
        return self;
    };
}

- (id<BDMDisplayPlacementBuilder> (^)(float))appendHeight {
    return ^id<BDMDisplayPlacementBuilder>(float value){
        self.placement.h = value;
        return self;
    };
}

- (id<BDMDisplayPlacementBuilder> (^)(float))appendWidth {
    return ^id<BDMDisplayPlacementBuilder>(float value){
        self.placement.w = value;
        return self;
    };
}

- (id<BDMDisplayPlacementBuilder> (^)(id<BDMNativeFormatBuilder>))appendNativeFmt {
    return ^id<BDMDisplayPlacementBuilder>(id<BDMNativeFormatBuilder> fmt){
        self.placement.nativefmt = (ADCOMPlacement_DisplayPlacement_NativeFormat *)fmt.format;
        return self;
    };
}

- (id<BDMDisplayPlacementBuilder> (^)(unsigned int))appendUnit {
    return ^id<BDMDisplayPlacementBuilder>(unsigned int unitSize){
        self.placement.unit = (ADCOMSizeUnit)unitSize;
        return self;
    };
}

- (id<BDMDisplayPlacementBuilder> (^)(NSArray<NSString *> *))appendMimes {
    return ^id<BDMDisplayPlacementBuilder>(NSArray<NSString *> * value){
        self.placement.mimeArray = value.mutableCopy;
        return self;
    };
}

- (ADCOMPlacement_DisplayPlacement *)placement {
    if (!_placement) {
        _placement = [ADCOMPlacement_DisplayPlacement message];
    }
    return _placement;
}

@end


@interface BDMNativeFormatBuilder()

@property (nonatomic, readwrite, strong) ADCOMPlacement_DisplayPlacement_NativeFormat *format;

@end

@implementation BDMNativeFormatBuilder

- (id<BDMNativeFormatBuilder> (^)(id<BDMNativeFormatTypeBuilder>))appendTitle {
    return ^id<BDMNativeFormatBuilder> (id<BDMNativeFormatTypeBuilder>builder){
        ADCOMPlacement_DisplayPlacement_NativeFormat_AssetFormat_TitleAssetFormat *title = ADCOMPlacement_DisplayPlacement_NativeFormat_AssetFormat_TitleAssetFormat.new;
        [title setLen:104];
        [(ADCOMPlacement_DisplayPlacement_NativeFormat_AssetFormat *)builder.format setTitle:title];
        [self.format.assetArray stk_addObject:builder.format];
        return self;
    };
}

- (id<BDMNativeFormatBuilder> (^)(id<BDMNativeFormatTypeBuilder>))appendIcon {
    return ^id<BDMNativeFormatBuilder> (id<BDMNativeFormatTypeBuilder>builder){
        ADCOMPlacement_DisplayPlacement_NativeFormat_AssetFormat_ImageAssetFormat *img = ADCOMPlacement_DisplayPlacement_NativeFormat_AssetFormat_ImageAssetFormat.new;
        [img setMimeArray:@[@"image/jpeg", @"image/jpg", @"image/gif", @"image/png"].mutableCopy];
        [img setType:ADCOMNativeImageAssetType_NativeImageAssetTypeIconImage];
        [(ADCOMPlacement_DisplayPlacement_NativeFormat_AssetFormat *)builder.format setImg:img];
        [self.format.assetArray stk_addObject:builder.format];
        return self;
    };
}

- (id<BDMNativeFormatBuilder> (^)(id<BDMNativeFormatTypeBuilder>))appendImage {
    return ^id<BDMNativeFormatBuilder> (id<BDMNativeFormatTypeBuilder>builder){
        ADCOMPlacement_DisplayPlacement_NativeFormat_AssetFormat_ImageAssetFormat *img = ADCOMPlacement_DisplayPlacement_NativeFormat_AssetFormat_ImageAssetFormat.new;
        [img setType:ADCOMNativeImageAssetType_NativeImageAssetTypeMainImage];
        [img setMimeArray:@[@"image/jpeg", @"image/jpg", @"image/gif", @"image/png"].mutableCopy];
        [(ADCOMPlacement_DisplayPlacement_NativeFormat_AssetFormat *)builder.format setImg:img];
        [self.format.assetArray stk_addObject:builder.format];
        return self;
    };
}

- (id<BDMNativeFormatBuilder> (^)(id<BDMNativeFormatTypeBuilder>))appendDescription {
    return ^id<BDMNativeFormatBuilder> (id<BDMNativeFormatTypeBuilder>builder){
        ADCOMPlacement_DisplayPlacement_NativeFormat_AssetFormat_DataAssetFormat *data = ADCOMPlacement_DisplayPlacement_NativeFormat_AssetFormat_DataAssetFormat.new;
        [data setType:ADCOMNativeDataAssetType_NativeDataAssetTypeDesc];
        [(ADCOMPlacement_DisplayPlacement_NativeFormat_AssetFormat *)builder.format setData_p:data];
        [self.format.assetArray stk_addObject:builder.format];
        return self;
    };
}

- (id<BDMNativeFormatBuilder> (^)(id<BDMNativeFormatTypeBuilder>))appendCta {
    return ^id<BDMNativeFormatBuilder> (id<BDMNativeFormatTypeBuilder>builder){
        ADCOMPlacement_DisplayPlacement_NativeFormat_AssetFormat_DataAssetFormat *data = ADCOMPlacement_DisplayPlacement_NativeFormat_AssetFormat_DataAssetFormat.new;
        [data setType:ADCOMNativeDataAssetType_NativeDataAssetTypeCtaText];
        [(ADCOMPlacement_DisplayPlacement_NativeFormat_AssetFormat *)builder.format setData_p:data];
        [self.format.assetArray stk_addObject:builder.format];
        return self;
    };
}

- (id<BDMNativeFormatBuilder> (^)(id<BDMNativeFormatTypeBuilder>))appendRating {
    return ^id<BDMNativeFormatBuilder> (id<BDMNativeFormatTypeBuilder>builder){
        ADCOMPlacement_DisplayPlacement_NativeFormat_AssetFormat_DataAssetFormat *data = ADCOMPlacement_DisplayPlacement_NativeFormat_AssetFormat_DataAssetFormat.new;
        [data setType:ADCOMNativeDataAssetType_NativeDataAssetTypeRating];
        [(ADCOMPlacement_DisplayPlacement_NativeFormat_AssetFormat *)builder.format setData_p:data];
        [self.format.assetArray stk_addObject:builder.format];
        return self;
    };
}

- (id<BDMNativeFormatBuilder> (^)(id<BDMNativeFormatTypeBuilder>))appendSponsored {
    return ^id<BDMNativeFormatBuilder> (id<BDMNativeFormatTypeBuilder>builder){
        ADCOMPlacement_DisplayPlacement_NativeFormat_AssetFormat_DataAssetFormat *data = ADCOMPlacement_DisplayPlacement_NativeFormat_AssetFormat_DataAssetFormat.new;
        [data setType:ADCOMNativeDataAssetType_NativeDataAssetTypeSponsored];
        [(ADCOMPlacement_DisplayPlacement_NativeFormat_AssetFormat *)builder.format setData_p:data];
        [self.format.assetArray stk_addObject:builder.format];
        return self;
    };
}

- (id<BDMNativeFormatBuilder> (^)(id<BDMNativeFormatTypeBuilder>))appendVideo {
    return ^id<BDMNativeFormatBuilder> (id<BDMNativeFormatTypeBuilder>builder){
        BDMVideoPlacementBuilder *videoBuilder = BDMVideoPlacementBuilder.new;
        videoBuilder.appendCType(@[@2, @3, @5, @6]);
        videoBuilder.appendMimes(@[@"video/mpeg" , @"video/mp4", @"video/quicktime", @"video/avi"]);
        videoBuilder.appendskip(NO);
        videoBuilder.appendMaxdur(30);
        videoBuilder.appendMindur(5);
        videoBuilder.appendMinbitr(56);
        videoBuilder.appendMaxbitr(4096);
        videoBuilder.appendLinearity(1);
        
        ADCOMPlacement_VideoPlacement *video = (ADCOMPlacement_VideoPlacement *)videoBuilder.placement ;
        [(ADCOMPlacement_DisplayPlacement_NativeFormat_AssetFormat *)builder.format setVideo:video];
        [self.format.assetArray stk_addObject:builder.format];
        return self;
    };
}

- (ADCOMPlacement_DisplayPlacement_NativeFormat *)format {
    if (!_format) {
        _format = [ADCOMPlacement_DisplayPlacement_NativeFormat message];
        _format.assetArray = [NSMutableArray array];
    }
    return _format;
}

@end

@interface BDMNativeFormatTypeBuilder ()

@property (nonatomic, readwrite, strong) ADCOMPlacement_DisplayPlacement_NativeFormat_AssetFormat *format;

@end

@implementation BDMNativeFormatTypeBuilder

- (id<BDMNativeFormatTypeBuilder> (^)(unsigned int))appendId {
    return ^id<BDMNativeFormatTypeBuilder>(unsigned int ID){
        self.format.id_p = ID;
        return self;
    };
}

- (id<BDMNativeFormatTypeBuilder> (^)(BOOL))appendReq {
    return ^id<BDMNativeFormatTypeBuilder>(BOOL req){
        self.format.req = req;
        return self;
    };
}

- (ADCOMPlacement_DisplayPlacement_NativeFormat_AssetFormat *)format {
    if (!_format) {
        _format = [ADCOMPlacement_DisplayPlacement_NativeFormat_AssetFormat message];
    }
    return _format;
}

@end
