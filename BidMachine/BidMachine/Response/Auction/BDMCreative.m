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


static NSString * const kBDMCreativeKey     = @"creative";
static NSString * const kBDMWidthKey        = @"w";
static NSString * const kBDMHeightKey       = @"h";


static NSString * const kBDMMRAIDPreloadKey             = @"should_cache";
static NSString * const kBDMMRAIDClosableViewDelayKey   = @"closable_view_delay";
static NSString * const kBDMVASTPostbannerCloseTimeKey  = @"skip_after";


@interface BDMCreative ()

@property (nonatomic, copy, readwrite) NSArray <BDMEventURL *> *trackers;
@property (nonatomic, copy, readwrite) BDMViewabilityMetricConfiguration * viewabilityConfig;
@property (nonatomic, copy, readwrite) NSArray <NSString *> *adDomains;
@property (nonatomic, copy, readwrite) NSString *displaymanager;
@property (nonatomic, copy, readwrite) NSString *ID;
@property (nonatomic, copy, readwrite) NSDictionary <NSString *, NSString *> *renderingInfo;
@property (nonatomic, assign, readwrite) BDMCreativeFormat format;

@end

@implementation BDMCreative

+ (instancetype)parseFromData:(NSData *)data {
    return [[self alloc] initWithData:data];
}

- (instancetype)initWithData:(NSData *)data {
    if (self = [super init]) {
        // Parse ad model
        NSError * error;
        ADCOMAd * ad = [ADCOMAd parseFromData:data error:&error];
        NSData * raw = ad.extArray.firstObject.value;
        BDMAdExtension * extension = raw ? [BDMAdExtension parseFromData:raw error:&error] : nil;
        
        // Populate all data needed for adapter
        [self populateRenderingData:ad extensions:extension];
        // Populate all events
        [self populateEvents:extension.eventArray];
        // Populate viewability
        [self populateVieabilityConfig:extension];
        // Populate info
        self.adDomains = ad.adomainArray.copy;
        self.ID = ad.id_p;
    }
    return self;
}

#pragma mark - Private

- (void)populateRenderingData:(ADCOMAd *)ad extensions:(BDMAdExtension *)extensions {
    NSMutableDictionary <NSString *, NSString *> * renderingInfo = [NSMutableDictionary new];
    BDMHeaderBiddingAd *headerBiddingAd;
    // Check DSP Creative from video placement first
    if (ad.video.adm.length > 0) {
        // All video creatives are displayed by VAST
        self.displaymanager = @"vast";
        self.format = BDMCreativeFormatVideo;
        renderingInfo[kBDMCreativeKey] = ad.video.adm;
        renderingInfo[kBDMVASTPostbannerCloseTimeKey] = @(extensions.skipAfter).stringValue;
    // Check DSP Creative from display placement
    } else if (ad.display.adm.length > 0) {
        // All video creatives are displayed by MRAID
        self.displaymanager = @"mraid";
        self.format = BDMCreativeFormatBanner;
        
        renderingInfo[kBDMCreativeKey]                  = ad.display.adm;
        renderingInfo[kBDMWidthKey]                     = @(ad.display.w).stringValue;
        renderingInfo[kBDMHeightKey]                    = @(ad.display.h).stringValue;
        renderingInfo[kBDMMRAIDPreloadKey]              = @(extensions == nil || extensions.preload).stringValue;
        renderingInfo[kBDMMRAIDClosableViewDelayKey]    = @(extensions.skipAfter).stringValue;
    // Check DSP Creative of native fmt
    } else if (ad.display.native.assetArray.count > 0) {
        self.displaymanager = @"nast";
        self.format = BDMCreativeFormatNative;
        renderingInfo = ad.display.native.JSONRepresentation;
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
    self.renderingInfo = renderingInfo;
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

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    BDMCreative * copy = [BDMCreative new];
    
    copy.trackers            = self.trackers;
    copy.viewabilityConfig   = self.viewabilityConfig;
    copy.displaymanager      = self.displaymanager;
    copy.renderingInfo       = self.renderingInfo;
    copy.adDomains           = self.adDomains;
    copy.ID                  = self.ID;
    copy.format              = self.format;
    
    return copy;
}    

@end
