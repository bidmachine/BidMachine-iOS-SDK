//
//  BDMCreative.m
//  BidMachine
//
//  Created by Stas Kochkin on 21/11/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMCreative.h"
#import "BDMTransformers.h"
#import "BDMAdapterDefines.h"
#import "OpenRTB+BDMCreative.h"

#import <StackFoundation/StackFoundation.h>

@interface BDMCreative ()

@property (nonatomic, copy, readwrite) NSArray <BDMEventURL *> *trackers;
@property (nonatomic, copy, readwrite) BDMViewabilityMetricConfiguration * viewabilityConfig;
@property (nonatomic, copy, readwrite) NSArray <NSString *> *adDomains;
@property (nonatomic, copy, readwrite) NSArray <NSString *> *bundles;
@property (nonatomic, copy, readwrite) NSString *displaymanager;
@property (nonatomic, copy, readwrite) NSString *ID;

@property (nonatomic, copy, readwrite) NSMutableDictionary <NSString *, id> *renderingInfo;
@property (nonatomic, copy, readwrite) NSMutableDictionary <NSString *, id> *customParams;

@property (nonatomic, assign, readwrite) BDMCreativeFormat format;

@end

@implementation BDMCreative

+ (instancetype)parseFromBid:(ORTBResponse_Seatbid_Bid *)bid {
    return [[self alloc] initWithBid:bid];
}

- (instancetype)initWithBid:(ORTBResponse_Seatbid_Bid *)bid {
    if (self = [super init]) {
        NSError *error               = nil;
        ADCOMAd *ad                  = [bid bdmAdcomAd:&error];
        BDMAdExtension *adExtension  = [ad bdmAdExtension:&error];
        
        [self populateRenderingAdWithAd:ad];
        [self populateRenderingAdWithAdExtension:adExtension];
        [self populateRenderingAdWithBidExtension:bid];

        self.adDomains = ad.adomainArray.copy;
        self.bundles = ad.bundleArray.copy;
        self.ID = ad.id_p;
    }
    return self;
}

#pragma mark - Accessor

- (NSMutableDictionary <NSString *, id> *)renderingInfo {
    if (!_renderingInfo) {
        _renderingInfo = NSMutableDictionary.new;
    }
    return _renderingInfo;
}

- (NSDictionary<NSString *, id> *)customParams {
    if (!_customParams) {
        _customParams = NSMutableDictionary.new;
    }
    return _customParams;
}

#pragma mark - Private

- (void)populateRenderingAdWithAd:(ADCOMAd *)ad {
    if (ad.video.adm.length > 0) {
        self.displaymanager = @"vast";
        self.format = BDMCreativeFormatVideo;
        [self.renderingInfo addEntriesFromDictionary:ad.video.bdmJSONRepresentation ?: nil];
    } else if (ad.display.adm.length > 0) {
        self.displaymanager = @"mraid";
        self.format = BDMCreativeFormatBanner;
        [self.renderingInfo addEntriesFromDictionary:ad.display.bdmJSONRepresentation ?: nil];
    } else if (ad.display.native.assetArray.count > 0) {
        self.displaymanager = @"nast";
        self.format = BDMCreativeFormatNative;
        [self.renderingInfo addEntriesFromDictionary:ad.display.native.bdmJSONRepresentation ?: nil];
    } else {
        BDMHeaderBiddingAd *headerBiddingAd;
        if ((headerBiddingAd = ad.bdmNativeHeaderBiddingAd)) {
            self.format = BDMCreativeFormatNative;
        } else if ((headerBiddingAd = ad.bdmVideoHeaderBiddingAd)) {
            self.format = BDMCreativeFormatVideo;
        } else if ((headerBiddingAd = ad.bdmBannerHeaderBiddingAd)) {
            self.format = BDMCreativeFormatBanner;
        }
        self.displaymanager = headerBiddingAd.bidder;
        [self populateRenderingAdWithHeaderBidding:headerBiddingAd];
    }
}

- (void)populateRenderingAdWithHeaderBidding:(BDMHeaderBiddingAd *)headerBidding {
    [self.renderingInfo addEntriesFromDictionary:headerBidding.clientParams ?: @{}];
    [self.renderingInfo addEntriesFromDictionary:headerBidding.serverParams ?: @{}];
    
    NSString *bidmachineString = nil;
    if ((bidmachineString = ANY(headerBidding.clientParams).from(@"bdm_ext").string)) {
        NSData *extensionData = [[NSData alloc] initWithBase64EncodedString:bidmachineString options:0];
        NSDictionary *extension = [STKJSONSerialization JSONObjectWithData:extensionData options:NSJSONReadingAllowFragments error:nil];
        [self.customParams addEntriesFromDictionary:extension ?: @{}];
    }
    
}

- (void)populateRenderingAdWithAdExtension:(BDMAdExtension *)extension {
    [self.customParams addEntriesFromDictionary:extension.customParams ?: @{}];
    [self.renderingInfo addEntriesFromDictionary:extension.bdmJSONRepresentation ?: @{}];
    
    self.trackers = BDMTransformers.eventURLs(extension.eventArray);
    
    BDMViewabilityMetricConfiguration * config = [BDMViewabilityMetricConfiguration new];
    config.visiblePercent = extension.viewabilityPixelThreshold > 0.1 ? extension.viewabilityPixelThreshold * 100 : config.visiblePercent;
    config.impressionInterval = extension.viewabilityTimeThreshold > 0.1 ? extension.viewabilityTimeThreshold : config.impressionInterval;
    self.viewabilityConfig = config;
}

- (void)populateRenderingAdWithBidExtension:(ORTBResponse_Seatbid_Bid *)bid {
    [self.renderingInfo addEntriesFromDictionary:bid.bdmSKStoreJSONRepresentation ?: @{}];
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
