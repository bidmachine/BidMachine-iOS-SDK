//
//  BDMCreative.m
//  BidMachine
//
//  Created by Stas Kochkin on 21/11/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMCreative.h"
#import "ADCOMAd_Display_Native+BDMSdk.h"
#import "BDMProtoAPI-Umbrella.h"
#import "BDMTransformers.h"
#import "ADCOMAd+Private.h"

#import <StackFoundation/StackFoundation.h>
#import <StackUIKit/StackUIKit.h>


static NSString * const kBDMCreativeKey     = @"creative";
static NSString * const kBDMWidthKey        = @"w";
static NSString * const kBDMHeightKey       = @"h";


static NSString * const kBDMMRAIDClosableViewDelayKey   = @"closable_view_delay";
static NSString * const kBDMCompanionSkipOffset         = @"companion_skip_offset";
static NSString * const kBDMUseNativeClose              = @"use_native_close";
static NSString * const kBDMSkipOffset                  = @"skip_offset";


@interface BDMCreative ()

@property (nonatomic, copy, readwrite) NSArray <BDMEventURL *> *trackers;
@property (nonatomic, copy, readwrite) BDMViewabilityMetricConfiguration * viewabilityConfig;
@property (nonatomic, copy, readwrite) NSArray <NSString *> *adDomains;
@property (nonatomic, copy, readwrite) NSArray <NSString *> *bundles;
@property (nonatomic, copy, readwrite) NSString *displaymanager;
@property (nonatomic, copy, readwrite) NSString *ID;
@property (nonatomic, copy, readwrite) NSDictionary <NSString *, NSString *> *renderingInfo;
@property (nonatomic, copy, readwrite) NSDictionary <NSString *, id> *customParams;
@property (nonatomic, assign, readwrite) BDMCreativeFormat format;

@end

@implementation BDMCreative

+ (instancetype)parseFromBid:(ORTBResponse_Seatbid_Bid *)bid {
    return [[self alloc] initWithBid:bid];
}

- (instancetype)initWithBid:(ORTBResponse_Seatbid_Bid *)bid {
    if (self = [super init]) {
        // Parse ad model
        NSData *data = bid.media.value;
        NSError * error;
        ADCOMAd * ad = [ADCOMAd parseFromData:data error:&error];
        NSData * raw = ad.extProtoArray.firstObject.value;
        BDMAdExtension * extension = raw ? [BDMAdExtension parseFromData:raw error:&error] : nil;
        
        // Populate all data needed for adapter
        [self populateRenderingData:ad bid:bid extensions:extension];
        // Populate all events
        [self populateEvents:extension.eventArray];
        // Populate viewability
        [self populateVieabilityConfig:extension];
        // Populate info
        self.adDomains = ad.adomainArray.copy;
        self.bundles = ad.bundleArray.copy;
        self.ID = ad.id_p;
    }
    return self;
}

#pragma mark - Private

- (void)populateRenderingData:(ADCOMAd *)ad
                          bid:(ORTBResponse_Seatbid_Bid *)bid
                   extensions:(BDMAdExtension *)extensions
{
    NSMutableDictionary <NSString *, NSString *> * renderingInfo = [NSMutableDictionary new];
    BDMHeaderBiddingAd *headerBiddingAd;
    // Check DSP Creative from video placement first
    if (ad.video.adm.length > 0) {
        // All video creatives are displayed by VAST
        self.displaymanager = @"vast";
        self.format = BDMCreativeFormatVideo;
        renderingInfo[kBDMCreativeKey]                  = ad.video.adm;
        renderingInfo[kBDMSkipOffset]                   = @(extensions.skipoffset).stringValue;
        renderingInfo[kBDMCompanionSkipOffset]          = @(extensions.companionSkipoffset).stringValue;
        renderingInfo[kBDMUseNativeClose]               = @(extensions.useNativeClose).stringValue;
        [self populateRenderingInfo:renderingInfo withBid:bid];
    // Check DSP Creative from display placement
    } else if (ad.display.adm.length > 0) {
        // All video creatives are displayed by MRAID
        self.displaymanager = @"mraid";
        self.format = BDMCreativeFormatBanner;
        
        renderingInfo[kBDMCreativeKey]                  = ad.display.adm;
        renderingInfo[kBDMWidthKey]                     = @(ad.display.w).stringValue;
        renderingInfo[kBDMHeightKey]                    = @(ad.display.h).stringValue;
        renderingInfo[kBDMSkipOffset]                   = @(extensions.skipoffset).stringValue;
        renderingInfo[kBDMUseNativeClose]               = @(extensions.useNativeClose).stringValue;
        [self populateRenderingInfo:renderingInfo withBid:bid];
    // Check DSP Creative of native fmt
    } else if (ad.display.native.assetArray.count > 0) {
        self.displaymanager = @"nast";
        self.format = BDMCreativeFormatNative;
        renderingInfo = ad.display.native.JSONRepresentation;
        [self populateRenderingInfo:renderingInfo withBid:bid];
    } else {
        // Then try to get Header Bidding Ad
        if ((headerBiddingAd = ad.bdm_nativeHeaderBiddingAd)) {
            self.format = BDMCreativeFormatNative;
        } else if ((headerBiddingAd = ad.bdm_videoHeaderBiddingAd)) {
            self.format = BDMCreativeFormatVideo;
        } else if ((headerBiddingAd = ad.bdm_bannerHeaderBiddingAd)) {
            self.format = BDMCreativeFormatBanner;
        }
        
        self.displaymanager = headerBiddingAd.bidder;
        [renderingInfo addEntriesFromDictionary:BDMTransformers.jsonObject(headerBiddingAd.clientParams)];
        [renderingInfo addEntriesFromDictionary:BDMTransformers.jsonObject(headerBiddingAd.serverParams)];
    }
    
    NSMutableDictionary *customParams = BDMTransformers.jsonObject(extensions.customParams).mutableCopy;
    if (headerBiddingAd.clientParams) {
        NSMutableDictionary *extDict = NSMutableDictionary.new;
        NSString *extString = headerBiddingAd.clientParams[@"bdm_ext"];
        NSData *dataExt = [[NSData alloc] initWithBase64EncodedString:extString options:0];
        extDict = [STKJSONSerialization JSONObjectWithData:dataExt options:NSJSONReadingAllowFragments error:nil];
        [customParams addEntriesFromDictionary:extDict ?: @{}];
    }
    
    self.renderingInfo = renderingInfo;
    self.customParams = customParams;
}

- (void)populateEvents:(NSArray <ADCOMAd_Event *> *)events {
    self.trackers = BDMTransformers.eventURLs(events);
}

- (void)populateVieabilityConfig:(BDMAdExtension *)extension {
    BDMViewabilityMetricConfiguration * config = [BDMViewabilityMetricConfiguration new];
    config.visiblePercent = extension.viewabilityPixelThreshold > 0.1 ? extension.viewabilityPixelThreshold * 100 : config.visiblePercent;
    config.impressionInterval = extension.viewabilityTimeThreshold > 0.1 ? extension.viewabilityTimeThreshold : config.impressionInterval;
    self.viewabilityConfig = config;
}

- (void)populateRenderingInfo:(NSMutableDictionary <NSString *, NSString *> *)info withBid:(ORTBResponse_Seatbid_Bid *)bid {
    NSDictionary <NSString*, GPBValue*> *bidStructFields = bid.ext.fields[@"skadn"].structValue.fields;
    info[STKProductParameterItemIdentifier]                      = bidStructFields[@"itunesitem"].stringValue;
    info[STKProductParameterAdNetworkSourceAppStoreIdentifier]   = bidStructFields[@"sourceapp"].stringValue;
    info[STKProductParameterAdNetworkVersion]                    = bidStructFields[@"version"].stringValue;
    info[STKProductParameterClickThrough]                        = bidStructFields[@"?"].stringValue;
    info[STKProductParameterAdNetworkAttributionSignature]       = bidStructFields[@"signature"].stringValue;
    info[STKProductParameterAdNetworkCampaignIdentifier]         = bidStructFields[@"campaign"].stringValue;
    info[STKProductParameterAdNetworkIdentifier]                 = bidStructFields[@"network"].stringValue;
    info[STKProductParameterAdNetworkNonce]                      = bidStructFields[@"nonce"].stringValue;
    info[STKProductParameterAdNetworkTimestamp]                  = bidStructFields[@"timestamp"].stringValue;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    BDMCreative * copy = [BDMCreative new];
    
    copy.trackers            = self.trackers;
    copy.viewabilityConfig   = self.viewabilityConfig;
    copy.displaymanager      = self.displaymanager;
    copy.renderingInfo       = self.renderingInfo;
    copy.adDomains           = self.adDomains;
    copy.bundles             = self.bundles;
    copy.ID                  = self.ID;
    copy.format              = self.format;
    copy.customParams        = self.customParams;
    
    return copy;
}    

@end
