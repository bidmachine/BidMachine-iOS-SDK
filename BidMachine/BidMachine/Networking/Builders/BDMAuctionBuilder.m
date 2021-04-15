//
//  BDMRequestBuilder.m
//
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMAuctionBuilder.h"
#import "BDMTransformers.h"
#import "BDMSdk+Project.h"
#import "BDMAdapterDefines.h"

#import "BDMProtoAPI-Umbrella.h"
#import <StackFoundation/StackFoundation.h>
#import <StackProductPresentation/StackProductPresentation.h>


@interface BDMAuctionBuilder ()

@property (nonatomic, assign) BOOL testMode;

@property (nonatomic,   copy) NSString *sellerID;
@property (nonatomic,   copy) NSString *sessionID;
@property (nonatomic,   copy) NSArray<BDMPriceFloor *> *priceFloors;

@property (nonatomic, strong) BDMTargeting *targeting;
@property (nonatomic, strong) BDMPublisherInfo *publisherInfo;
@property (nonatomic, strong) BDMUserRestrictions *restrictions;
@property (nonatomic, strong) id<BDMAuctionSettings> auctionSettings;
@property (nonatomic, strong) id<BDMContextualProtocol> contextualData;
@property (nonatomic, strong) id<BDMPlacementRequestBuilder> placementBuilder;

@end

@implementation BDMAuctionBuilder

- (BDMAuctionBuilder *(^)(BDMTargeting *))appendTargeting {
    return ^id(BDMTargeting *targeting) {
        self.targeting = targeting;
        return self;
    };
}

- (BDMAuctionBuilder *(^)(NSString *))appendSellerID {
    return ^id(NSString * sellerID) {
        self.sellerID = sellerID;
        return self;
    };
}

- (BDMAuctionBuilder *(^)(NSString *))appendSessionID {
    return ^id(NSString * sessionID) {
        self.sessionID = sessionID;
        return self;
    };
}

- (BDMAuctionBuilder *(^)(id<BDMAuctionSettings>))appendAuctionSettings {
    return ^id(id<BDMAuctionSettings> auctionSettings) {
        self.auctionSettings = auctionSettings;
        return self;
    };
}

- (BDMAuctionBuilder *(^)(id<BDMPlacementRequestBuilder>))appendPlacementBuilder {
    return ^id(id<BDMPlacementRequestBuilder> plcBuilder) {
        self.placementBuilder = plcBuilder;
        return self;
    };
}

- (BDMAuctionBuilder *(^)(BOOL))appendTestMode {
    return ^id(BOOL testMode) {
        self.testMode = testMode;
        return self;
    };
}

- (BDMAuctionBuilder *(^)(NSArray<BDMPriceFloor *> *))appendPriceFloors {
    return ^id(NSArray<BDMPriceFloor *> *priceFloors) {
        self.priceFloors = priceFloors;
        return self;
    };
}

- (BDMAuctionBuilder *(^)(BDMUserRestrictions *))appendRestrictions {
    return ^id(BDMUserRestrictions * restrictions) {
        self.restrictions = restrictions;
        return self;
    };
}

- (BDMAuctionBuilder *(^)(BDMPublisherInfo *))appendPublisherInfo {
    return ^id(BDMPublisherInfo * publisherInfo) {
        self.publisherInfo = publisherInfo;
        return self;
    };
}

- (BDMAuctionBuilder *(^)(id<BDMContextualProtocol>))appendContextualData {
    return ^id(id<BDMContextualProtocol> contextualData) {
        self.contextualData = contextualData;
        return self;
    };
}

- (GPBMessage *)message {
    ORTBOpenrtb *openRtbMessage = [ORTBOpenrtb message];
    openRtbMessage.ver         = ANY(self.auctionSettings.protocolVersion).string;
    openRtbMessage.domainspec  = ANY(self.auctionSettings.domainSpec).string;
    openRtbMessage.domainver   = ANY(self.auctionSettings.domainVersion).string;
    openRtbMessage.request     = ({
        ORTBRequest *requestMessage    = [ORTBRequest message];
        requestMessage.test            = self.testMode;
        requestMessage.tmax            = self.auctionSettings.tmax;
        requestMessage.at              = (uint32_t)self.auctionSettings.auctionType;
        requestMessage.curArray        = ANY(self.auctionSettings.auctionCurrency).array.mutableCopy;
        // Setup context
        requestMessage.context         = self.adcomContextMessage;
        // Setup items
        requestMessage.itemArray       = self.requestItemsMessage;
        // Setup extensions
        requestMessage.extProtoArray   = self.requestExtensionsMessage;
        requestMessage;
    });
    
    BOOL isGDPRRestricted = self.restrictions.subjectToGDPR && !self.restrictions.hasConsent;
    BOOL isCoppa = self.restrictions.coppa;
    
    if (isGDPRRestricted || isCoppa) {
        openRtbMessage = [self restrictOpenRtbMessage:openRtbMessage gdpr:isGDPRRestricted coppa:isCoppa];
    }
    
    return openRtbMessage;
}

#pragma mark - Private

- (ORTBOpenrtb *)restrictOpenRtbMessage:(ORTBOpenrtb *)message
                                   gdpr:(BOOL)gdp
                                  coppa:(BOOL)coppa
{
    NSDictionary *baseRestrictedPath = @{
                                         @"gender"      : @"user.gender",
                                         @"yob"         : @"user.yob",
                                         @"keywords"    : @"user.keywords",
                                         @"userId"      : @"user.id_p",
                                         @"country"     : @"user.geo",
                                         @"city"        : @"user.geo",
                                         @"zip"         : @"user.geo",
                                         
                                         @"lat"         : @"device.geo.lat",
                                         @"lon"         : @"device.geo.lon",
                                         @"accur"       : @"device.geo.accur",
                                         @"lastfix"     : @"device.geo.lastfix",
                                         @"type"        : @"device.geo.type"
                                         };
    
    NSDictionary *coppaAdditionalRestrictedPath = @{
                                                    @"contype"     : @"device.contype",
                                                    @"mccmnc"      : @"device.mccmnc",
                                                    @"carrier"     : @"device.carrier",
                                                    @"hwv"         : @"device.hwv",
                                                    @"make"        : @"device.make",
                                                    @"model"       : @"device.model",
                                                    @"lang"        : @"device.lang",
                                                    @"ua"          : @"device.ua",
                                                    };
    
    
    NSMutableDictionary *restrictedPath = [NSMutableDictionary dictionary];
    if (gdp || coppa) {
        [restrictedPath addEntriesFromDictionary:baseRestrictedPath];
    }
    
    if (coppa) {
        [restrictedPath addEntriesFromDictionary:coppaAdditionalRestrictedPath];
    }
    
    NSError *error = nil;
    ADCOMContext *context = [[ADCOMContext alloc] initWithData:message.request.context.value error:&error];
    
    if (!error) {
        [restrictedPath enumerateKeysAndObjectsUsingBlock:^(NSString  *key, NSString *path, BOOL * _Nonnull stop) {
            id message = [context stk_valueForKeyPath:path];
            if (GPBMessage.stk_isValid(message)) {
                [message clear];
            }
            else if (NSString.stk_isValid(message)) {
                [context setValue:nil forKeyPath:path];
            }
            else if (NSNumber.stk_isValid(message)) {
                [context setValue:@0 forKeyPath:path];
            }
        }];
        message.request.context = [GPBAny anyWithMessage:context error:nil];
    }
    
    return message;
}

- (NSMutableArray <GPBAny *> *)requestExtensionsMessage {
    BDMRequestExtension *ext = [BDMRequestExtension message];
    ext.sellerId = ANY(self.sellerID).string;
    ext.sessionId = ANY(self.sessionID).string;
    ext.ifv = ANY(STKAd.vendorIdentifier).string;
    ext.bmIfv = ANY(STKAd.generatedVendorIdentifier).string;
    ext.headerBiddingType = self.priceFloors > 0 ? BDMHeaderBiddingType_HeaderBiddingTypeDisabled : BDMHeaderBiddingType_HeaderBiddingTypeEnabled;
    return ANY([[GPBAny alloc] initWithMessage:ext error:nil]).array.mutableCopy;
}

#pragma mark - Item

- (NSMutableArray <ORTBRequest_Item *> *)requestItemsMessage {
    NSArray <BDMPriceFloor *> *pricefloors = self.priceFloors.count ? self.priceFloors : @[BDMPriceFloor.new]; // Use default pricfloor
    NSArray <ORTBRequest_Item_Deal *> *dealArray = [pricefloors stk_transform:^ORTBRequest_Item_Deal *(BDMPriceFloor * floor, NSUInteger idx) {
        ORTBRequest_Item_Deal *deal = ORTBRequest_Item_Deal.message;
        deal.id_p   = ANY(floor.ID).string;
        deal.flr    = floor.value.doubleValue;
        deal.flrcur = ANY(self.auctionSettings.auctionCurrency).string;
        return deal;
    }];
    
    ORTBRequest_Item *itemMessage   = [ORTBRequest_Item message];
    itemMessage.qty                 = 1;
    itemMessage.id_p                = ANY(NSUUID.UUID.UUIDString).string; // For Parallel Bidding it should be ad unit id
    itemMessage.spec                = self.adcomPlacementMessage;
    itemMessage.dealArray           = dealArray.mutableCopy;
    return ANY(itemMessage).array.mutableCopy;
}

#pragma mark - ADCOM Placements

- (GPBAny *)adcomPlacementMessage {
    ADCOMPlacement *placement   = (ADCOMPlacement *)self.placementBuilder.placement;
    placement.secure            = !STKDevice.isHTTPSupport;
    placement.ext               = self.placementExtension;
    return [GPBAny anyWithMessage:placement error:nil];
}

#pragma mark - ADCOM Context

- (GPBAny *)adcomContextMessage {
    ADCOMContext *contextMessage   = [ADCOMContext message];
    
    contextMessage.restrictions = ({
        ADCOMContext_Restrictions *restrictions = [ADCOMContext_Restrictions message];
        restrictions.bcatArray = ANY(self.targeting.blockedCategories).arrayOfString.mutableCopy;
        restrictions.badvArray = ANY(self.targeting.blockedAdvertisers).arrayOfString.mutableCopy;
        restrictions.bappArray = ANY(self.targeting.blockedApps).arrayOfString.mutableCopy;
        restrictions;
    });
    
    contextMessage.app             = self.adcomContextAppMessage;
    contextMessage.device          = self.adcomContextDeviceMessage;
    contextMessage.user            = self.adcomContextUserMessage;
    contextMessage.regs            = self.adcomContextRegsMessage;

    return [GPBAny anyWithMessage:contextMessage error:nil];
}

- (ADCOMContext_App *)adcomContextAppMessage {
    ADCOMContext_App *app = [ADCOMContext_App message];
    app.storeid         = ANY(self.targeting.storeId).string;
    app.storeurl        = ANY(self.targeting.storeURL.absoluteString).string;
    app.paid            = self.targeting.paid;
    app.pub             = self.adcomContextAppPublisherMessage;
    app.bundle          = ANY(STKBundle.ID).string;
    app.ver             = ANY(STKBundle.bundleVersion).string;
    app.name            = ANY([NSBundle.mainBundle objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey]).string;
    app.ext             = self.appExtension;
    return app;
}

- (ADCOMContext_Device *)adcomContextDeviceMessage {
    ADCOMContext_Device *device = [ADCOMContext_Device message];
    device.type         = BDMTransformers.deviceType(STKDevice.type);
    device.ua           = ANY(STKDevice.userAgent).string;
    device.lmt          = !STKAd.advertisingTrackingEnabled;
    device.contype      = BDMTransformers.connectionType(STKConnection.statusName);
    device.mccmnc       = ANY(STKConnection.mccmnc).string;
    device.carrier      = ANY(STKConnection.carrierName).string;
    device.w            = STKScreen.width * STKScreen.ratio;
    device.h            = STKScreen.height * STKScreen.ratio;
    device.ppi          = STKScreen.ppi;
    device.pxratio      = STKScreen.ratio;
    device.os           = BDMTransformers.osType(STKDevice.os);
    device.osv          = ANY(STKDevice.osv).string;
    device.hwv          = ANY(STKDevice.hardwarev).string;
    device.make         = ANY(STKDevice.maker).string;
    device.model        = ANY(STKDevice.name).string;
    device.lang         = ANY(STKDevice.language).string;
    
    device.geo          = BDMTransformers.geoMessage(self.targeting.deviceLocation);
    device.ext          = self.deviceExtension;
    
    if (self.restrictions.subjectToGDPR && !self.restrictions.hasConsent) {
        device.ifa      = ANY(@"00000000-0000-0000-0000-000000000000").string;
    } else {
        device.ifa      = ANY(STKAd.advertisingIdentifier).string;
    }
    
    return device;
}

- (ADCOMContext_User *)adcomContextUserMessage {
    ADCOMContext_User *user = [ADCOMContext_User message];
    user.gender         = ANY(BDMTransformers.gender(self.targeting.gender)).string;
    user.yob            = self.targeting.yearOfBirth.unsignedIntValue;
    user.keywords       = ANY(self.targeting.keywords).string;
    user.id_p           = ANY(self.targeting.userId).string;
    user.ext            = self.userExtension;
    
    if (self.restrictions.consentString) {
        user.consent    = ANY(self.restrictions.consentString).string;
    } else {
        user.consent    = self.restrictions.hasConsent ? @"1" : @"0";
    }
    
    user.geo = ({
        ADCOMContext_Geo *geo = [ADCOMContext_Geo message];
        geo.country     = ANY(self.targeting.country).string;
        geo.city        = ANY(self.targeting.city).string;
        geo.zip         = ANY(self.targeting.zip).string;
        geo;
    });
    return user;
}

- (ADCOMContext_Regs *)adcomContextRegsMessage {
    ADCOMContext_Regs *regs = [ADCOMContext_Regs message];
    BDMRegsCcpaExtension *ccpa = [BDMRegsCcpaExtension message];
    ccpa.usPrivacy      = ANY(self.restrictions.USPrivacyString).string;
    regs.coppa          = self.restrictions.coppa;
    regs.gdpr           = self.restrictions.subjectToGDPR;
    regs.extProtoArray  = ANY(ccpa).array.mutableCopy;
    
    return regs;
}

- (ADCOMContext_App_Publisher *)adcomContextAppPublisherMessage {
    ADCOMContext_App_Publisher *publisher = [ADCOMContext_App_Publisher message];
    publisher.id_p = ANY(self.publisherInfo.publisherId).string;
    publisher.name = ANY(self.publisherInfo.publisherName).string;
    publisher.domain = ANY(self.publisherInfo.publisherDomain).string;
    publisher.catArray = ANY(self.publisherInfo.publisherCategories).arrayOfString.mutableCopy;
    return publisher;
}

#pragma mark - EXT

- (GPBStruct *)placementExtension {
    NSMutableDictionary *extension = NSMutableDictionary.new;
    extension[@"omidpn"] = kBDMOMPartnerName;
    extension[@"omidpv"] = kBDMVersion;
    
    if (STKDevice.availableIOS(14)) {
        NSMutableDictionary *skExtension = [NSMutableDictionary dictionaryWithCapacity:4];
        skExtension[@"version"]           = STKProductController.supportedSKAdNetworkVersions.firstObject;
        skExtension[@"versions"]          = STKProductController.supportedSKAdNetworkVersions;
        skExtension[@"sourceapp"]         = self.targeting.storeId;
        skExtension[@"skadnetids"]        = STKBundle.registeredSKAdNetworkIdentifiers;
        extension[@"skadn"]               = skExtension;
    }
    GPBStruct *extModel             = [BDMTransformers structFromValue:extension];
    return extModel;
}

- (GPBStruct *)deviceExtension {
    NSMutableDictionary *extension = [NSMutableDictionary dictionaryWithCapacity:20];
    extension[@"ifv"]               = STKAd.vendorIdentifier;
    extension[@"inputlanguage"]     = STKDevice.inputLanguage;
    extension[@"diskspace"]         = BDMTransformers.bytesToMb(STKDevice.freeDiskSpaceBytes);
    extension[@"totaldisk"]         = BDMTransformers.bytesToMb(STKDevice.totalDiskSpaceBytes);
    extension[@"charging"]          = @([STKDevice.batteryState isEqualToString:@"charging"]);
    extension[@"headset"]           = @(STKDevice.isHeadsetConnected);
    extension[@"batterylevel"]      = BDMTransformers.batteryLevel(STKDevice.batteryLevel);
    extension[@"batterysaver"]      = @(STKDevice.lowPowerMode);
    extension[@"darkmode"]          = @([STKInterface.style isEqualToString:@"dark"]);
    extension[@"time"]              = @(NSDate.stk_currentTimeInSeconds);
    extension[@"screenbright"]      = @(STKDevice.brightness);
    extension[@"jailbreak"]         = @(STKDevice.isJailbroken);
    extension[@"lastbootup"]        = @(STKDevice.bootdate.stk_timeIntervalSince1970InMilliseconds);
    extension[@"emoji"]             = STKDevice.emoji;
    extension[@"access"]            = BDMTransformers.deviceAccessability;
    extension[@"headsetname"]       = STKDevice.audioOutput;
    extension[@"totalmem"]          = @(STKDevice.totalRAM);
    extension[@"atts"]              = @(STKAd.trackingAuthorizationStatus);
    
    BOOL isGDPRRestricted = self.restrictions.subjectToGDPR && !self.restrictions.hasConsent;
    BOOL isCoppa = self.restrictions.coppa;
    
    if (!isGDPRRestricted && !isCoppa) {
        extension[@"devicename"]    = STKDevice.userName;
    }
    GPBStruct *extModel             = [BDMTransformers structFromValue:extension];
    return extModel;
}



- (GPBStruct *)appExtension {
    NSMutableDictionary *extension = [NSMutableDictionary dictionaryWithCapacity:3];
    extension[@"storecat"]          = self.targeting.storeCategory;
    extension[@"storesubcat"]       = self.targeting.storeSubcategory;
    extension[@"fmwname"]           = self.targeting.frameworkName;
    GPBStruct *extModel             = [BDMTransformers structFromValue:extension];
    return extModel;
}

- (GPBStruct *)userExtension {
    NSMutableDictionary *extension = [NSMutableDictionary dictionaryWithCapacity:7];
    extension[@"impdepth"]          = @(self.contextualData.impressions);
    extension[@"sessionduration"]   = @(self.contextualData.sessionDuration);
    extension[@"lastbundle"]        = self.contextualData.lastBundle;
    extension[@"lastadomain"]       = self.contextualData.lastAdomain;
    extension[@"clickrate"]         = @(self.contextualData.clickRate);
    extension[@"lastclick"]         = @(self.contextualData.lastClickForImpression);
    extension[@"completionrate"]    = @(self.contextualData.completionRate);
    GPBStruct *extModel             = [BDMTransformers structFromValue:extension];
    return extModel;
}

@end
