//
//  OpenRTB+BDMCreative.m
//  BidMachine
//
//  Created by Ilia Lozhkin on 23.12.2020.
//  Copyright © 2020 Appodeal. All rights reserved.
//

#import "OpenRTB+BDMCreative.h"
#import "BDMAdapterDefines.h"

#import <StackFoundation/StackFoundation.h>
#import <StackUIKit/StackUIKit.h>

@implementation ORTBResponse_Seatbid_Bid (BDMCreative)

- (ADCOMAd *)bdmAdcomAd:(NSError *__autoreleasing  _Nullable *)error {
    NSData *data = self.media.value;
    if (!data) {
        STK_SET_AUTORELASE_VAR(error, [STKError errorWithDescription:@"ORTBResponse_Seatbid_Bid.media.value == nil"])
        return nil;
    }
    ADCOMAd *ad = [ADCOMAd parseFromData:data error:error];
    return ad;
}

- (NSDictionary *)bdmSKStoreJSONRepresentation {
    NSMutableDictionary *store = NSMutableDictionary.dictionary;
    NSDictionary <NSString*, GPBValue*> *bidStructFields = self.ext.fields[@"skadn"].structValue.fields;
    store[STKProductParameterItemIdentifier]                      = bidStructFields[@"itunesitem"].stringValue;
    store[STKProductParameterAdNetworkSourceAppStoreIdentifier]   = bidStructFields[@"sourceapp"].stringValue;
    store[STKProductParameterAdNetworkVersion]                    = bidStructFields[@"version"].stringValue;
    store[STKProductParameterClickThrough]                        = bidStructFields[@"?"].stringValue;
    store[STKProductParameterAdNetworkAttributionSignature]       = bidStructFields[@"signature"].stringValue;
    store[STKProductParameterAdNetworkCampaignIdentifier]         = bidStructFields[@"campaign"].stringValue;
    store[STKProductParameterAdNetworkIdentifier]                 = bidStructFields[@"network"].stringValue;
    store[STKProductParameterAdNetworkNonce]                      = bidStructFields[@"nonce"].stringValue;
    store[STKProductParameterAdNetworkTimestamp]                  = bidStructFields[@"timestamp"].stringValue;
    return @{kBDMCreativeStoreParams : store};
}

@end

@implementation ADCOMAd (BDMCreative)

- (BDMAdExtension *)bdmAdExtension:(NSError *__autoreleasing  _Nullable *)error {
    NSData *data = self.extProtoArray.firstObject.value;
    if (!data) {
        STK_SET_AUTORELASE_VAR(error, [STKError errorWithDescription:@"ADCOMAd.extProtoArray.firstObject.value == nil"])
        return nil;
    }
    BDMAdExtension *extension = [BDMAdExtension parseFromData:data error:error];
    return extension;
}

- (BDMHeaderBiddingAd *)bdmBannerHeaderBiddingAd {
    return [self bdmHeaderBiddingAdFromExtensions:self.display.banner.extProtoArray];
}

- (BDMHeaderBiddingAd *)bdmVideoHeaderBiddingAd {
    return [self bdmHeaderBiddingAdFromExtensions:self.video.extProtoArray];
}

- (BDMHeaderBiddingAd *)bdmNativeHeaderBiddingAd {
    return [self bdmHeaderBiddingAdFromExtensions:self.display.native.extProtoArray];
}

- (BDMHeaderBiddingAd *)bdmHeaderBiddingAdFromExtensions:(NSArray <GPBAny *> *)extensions {
    return ANY(extensions)
    .filter(^BOOL(GPBAny *ext) {
        return [ext.typeURL hasSuffix:@"HeaderBiddingAd"];
    })
    .flatMap(^id(GPBAny *ext) {
        return ext.value ? [[BDMHeaderBiddingAd alloc] initWithData:ext.value error:nil] : nil;
    })
    .array.firstObject;
}

@end

@implementation ADCOMAd_Video (BDMCreative)

- (NSDictionary *)bdmJSONRepresentation {
    NSMutableDictionary *video = NSMutableDictionary.dictionary;
    video[kBDMCreativeAdm]     = self.adm;
    return video;
}

@end

@implementation ADCOMAd_Display (BDMCreative)

- (NSDictionary *)bdmJSONRepresentation {
    NSMutableDictionary *display = NSMutableDictionary.dictionary;
    display[kBDMCreativeAdm]          = self.adm;
    display[kBDMCreativeWidth]        = @(self.w);
    display[kBDMCreativeHeight]       = @(self.h);
    return display;
}

@end

@implementation ADCOMAd_Display_Native (BDMCreative)

- (NSMutableDictionary *)bdmJSONRepresentation {
    NSMutableDictionary *nast = NSMutableDictionary.dictionary;
    
    if (self.hasLink) {
        NSMutableDictionary *link = NSMutableDictionary.dictionary;
        [link setObject:self.link.URL forKey:@"url"];
        [link setObject:self.link.trkrArray forKey:@"clicktrackers"];
        [nast setObject:link forKey:@"link"];
    }
    
    //TODO: Return implementation with type ADCOMNativeImageAssetType_NativeImageAssetTypeMainImage
    if (self.assetArray_Count > 0) {
        STKAny *assets = ANY(self.assetArray).flatMap(^id(ADCOMAd_Display_Native_Asset *obj) {
            if (obj.hasTitle) {
                NSMutableDictionary *asset = NSMutableDictionary.dictionary;
                NSMutableDictionary *value = NSMutableDictionary.dictionary;
                [asset setObject:@(123) forKey:@"id"];
                [value setObject:obj.title.text forKey:@"text"];
                [asset setObject:value forKey:@"title"];
                return asset;
            }
            
            if (obj.hasImage && obj.id_p == 124) {
                NSMutableDictionary *asset = NSMutableDictionary.dictionary;
                NSMutableDictionary *value = NSMutableDictionary.dictionary;
                [asset setObject:@(124) forKey:@"id"];
                [asset setObject:@(obj.image.w) forKey:@"w"];
                [asset setObject:@(obj.image.h) forKey:@"h"];
                [value setObject:obj.image.URL forKey:@"url"];
                [asset setObject:value forKey:@"img"];
                return asset;
            }
            
            if (obj.hasImage && obj.id_p == 128) {
                NSMutableDictionary *asset = NSMutableDictionary.dictionary;
                NSMutableDictionary *value = NSMutableDictionary.dictionary;
                [asset setObject:@(128) forKey:@"id"];
                [asset setObject:@(obj.image.w) forKey:@"w"];
                [asset setObject:@(obj.image.h) forKey:@"h"];
                [value setObject:obj.image.URL forKey:@"url"];
                [asset setObject:value forKey:@"img"];
                return asset;
            }
            
            if (obj.hasVideo) {
                NSMutableDictionary *asset = NSMutableDictionary.dictionary;
                NSMutableDictionary *value = NSMutableDictionary.dictionary;
                [asset setObject:@(4) forKey:@"id"];
                [value setObject:obj.video.adm forKey:@"vasttag"];
                [asset setObject:value forKey:@"video"];
                return asset;
            }
            
            if (obj.hasData_p && obj.id_p == 127) {
                NSMutableDictionary *asset = NSMutableDictionary.dictionary;
                NSMutableDictionary *value = NSMutableDictionary.dictionary;
                [asset setObject:@(127) forKey:@"id"];
                [value setObject:obj.data_p.value forKey:@"value"];
                [asset setObject:value forKey:@"data"];
                return asset;
            }
            
            if (obj.hasData_p && obj.id_p == 7) {
                NSMutableDictionary *asset = NSMutableDictionary.dictionary;
                NSMutableDictionary *value = NSMutableDictionary.dictionary;
                [asset setObject:@(7) forKey:@"id"];
                [value setObject:obj.data_p.value forKey:@"value"];
                [asset setObject:value forKey:@"data"];
                return asset;
            }
            
            if (obj.hasData_p && obj.id_p == 8) {
                NSMutableDictionary *asset = NSMutableDictionary.dictionary;
                NSMutableDictionary *value = NSMutableDictionary.dictionary;
                [asset setObject:@(8) forKey:@"id"];
                [value setObject:obj.data_p.value forKey:@"value"];
                [asset setObject:value forKey:@"data"];
                return asset;
            }
            
            return nil;
        });
        [nast setObject:assets.array forKey:@"assets"];
    }
    
    return nast;
}

@end

@implementation BDMAdExtension (BDMCreative)

- (NSDictionary *)bdmJSONRepresentation {
    NSMutableDictionary *renderingInfo                  = NSMutableDictionary.dictionary;
    
    renderingInfo[kBDMCreativeCustomR1]                 = @(self.r1);
    renderingInfo[kBDMCreativeCustomR2]                 = @(self.r2);
    renderingInfo[kBDMCreativeDuration]                 = @(self.progressDuration);
    renderingInfo[kBDMCreativeCloseTime]                = @(self.skipoffset);
    renderingInfo[kBDMCreativeProductLink]              = self.storeURL;
    renderingInfo[kBDMCreativeUseNativeClose]           = @(self.useNativeClose);
    renderingInfo[kBDMCreativeBackgroundColor]          = nil;
    renderingInfo[kBDMCreativeIgnoresSafeAreaLayout]    = @(self.ignoresSafeAreaLayoutGuide);
    
    renderingInfo[kBDMControlProgress]                  = self.progress.bdmJSONRepresentation;
    renderingInfo[kBDMControlCountdown]                 = self.countdown.bdmJSONRepresentation;
    renderingInfo[kBDMControlCloseButton]               = self.closeButton.bdmJSONRepresentation;

    return renderingInfo;
}

@end

@implementation BDMAdExtension_ControlAsset (BDMCreative)

- (NSDictionary *)bdmJSONRepresentation {
    NSMutableDictionary *renderingInfo                  = NSMutableDictionary.dictionary;
    renderingInfo[kBDMAssetStyle]                       = self.style;
    renderingInfo[kBDMAssetFont]                        = @(self.fontStyle);
    renderingInfo[kBDMAssetWidth]                       = @(self.width);
    renderingInfo[kBDMAssetHeight]                      = @(self.height);
    renderingInfo[kBDMAssetMargin]                      = self.margin;
    renderingInfo[kBDMAssetVisible]                     = @(self.visible);
    renderingInfo[kBDMAssetOpacity]                     = @(self.opacity);
    renderingInfo[kBDMAssetOutlined]                    = @(self.outlined);
    renderingInfo[kBDMAssetPadding]                     = self.padding;
    renderingInfo[kBDMAssetContent]                     = ![self.content isEqualToString:@""] ? self.content : nil;
    renderingInfo[kBDMAssetPositionX]                   = self.x;
    renderingInfo[kBDMAssetPositionY]                   = self.y;
    renderingInfo[kBDMAssetHideAfter]                   = @(self.hideafter);
    renderingInfo[kBDMAssetFillColor]                   = self.fill;
    renderingInfo[kBDMAssetShadowColor]                 = self.shadow;
    renderingInfo[kBDMAssetStrokeColor]                 = self.stroke;
    renderingInfo[kBDMAssetStrokeWidth]                 = @(self.strokeWidth);
    return renderingInfo;
}

@end
