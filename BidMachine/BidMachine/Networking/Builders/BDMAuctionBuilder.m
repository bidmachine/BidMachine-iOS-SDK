//
//  BDMRequestBuilder.m
//
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMAuctionBuilder.h"
#import "BDMTransformers.h"
#import "BDMSdk+Project.h"

#import "BDMProtoAPI-Umbrella.h"
#import <StackFoundation/StackFoundation.h>


@interface BDMAuctionBuilder ()

@property (nonatomic, copy) NSString * sellerID;
@property (nonatomic, assign) BOOL testMode;

@property (nonatomic, strong) BDMRequest *request;
@property (nonatomic, strong) BDMPublisherInfo *publisherInfo;
@property (nonatomic, strong) BDMUserRestrictions *restrictions;
@property (nonatomic, strong) id<BDMAuctionSettings> auctionSettings;
@property (nonatomic, strong) id<BDMPlacementRequestBuilder> placementBuilder;

@end

@implementation BDMAuctionBuilder

- (BDMAuctionBuilder *(^)(BDMRequest *))appendRequest {
    return ^id(BDMRequest *request) {
        self.request = request;
        return self;
    };
}

- (BDMAuctionBuilder *(^)(NSString *))appendSellerID {
    return ^id(NSString * sellerID) {
        self.sellerID = sellerID;
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

- (GPBMessage *)message {
    ORTBOpenrtb *openRtbMessage = [ORTBOpenrtb message];
    openRtbMessage.ver         = self.auctionSettings.protocolVersion;
    openRtbMessage.domainspec  = self.auctionSettings.domainSpec;
    openRtbMessage.domainver   = self.auctionSettings.domainVersion;
    openRtbMessage.request     = ({
        ORTBRequest *requestMessage    = [ORTBRequest message];
        requestMessage.test            = self.testMode;
        requestMessage.tmax            = self.auctionSettings.tmax;
        requestMessage.at              = (uint32_t)self.auctionSettings.auctionType;
        requestMessage.curArray        = [NSMutableArray arrayWithObject:self.auctionSettings.auctionCurrency];
        // Setup context
        requestMessage.context         = self.adcomContextMessage;
        // Setup items
        requestMessage.itemArray       = self.requestItemsMessage;
        // Setup extensions
        requestMessage.extArray        = self.requestExtensionsMessage;
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
    NSMutableArray <GPBAny *> * extensions = [NSMutableArray arrayWithCapacity:1];
    BDMRequestExtension * ext = [BDMRequestExtension message];
    ext.sellerId = self.sellerID;
    ext.ifv = STKAd.vendorIdentifier;
    ext.bmIfv = STKAd.generatedVendorIdentifier;
    ext.headerBiddingType = self.request.priceFloors > 0 ? BDMHeaderBiddingType_HeaderBiddingTypeDisabled : BDMHeaderBiddingType_HeaderBiddingTypeEnabled;
    GPBAny * extAny = [[GPBAny alloc] initWithMessage:ext error:nil];
    extAny ? [extensions addObject:extAny] : nil;
    return extensions;
}

#pragma mark - Item

- (NSMutableArray <ORTBRequest_Item *> *)requestItemsMessage {
    NSArray <BDMPriceFloor *> * pricefloors = self.request.priceFloors.count ? self.request.priceFloors : @[BDMPriceFloor.new]; // Use default pricfloor
    ORTBRequest_Item *itemMessage   = [ORTBRequest_Item message];
    itemMessage.qty                 = 1;
    itemMessage.id_p                = NSUUID.UUID.UUIDString; // For Parallel Bidding it should be ad unit id
    itemMessage.spec                = self.adcomPlacementMessage;
    itemMessage.dealArray           = [pricefloors stk_transform:^ORTBRequest_Item_Deal *(BDMPriceFloor * floor, NSUInteger idx) {
        ORTBRequest_Item_Deal * deal = ORTBRequest_Item_Deal.message;
        deal.id_p   = floor.ID;
        deal.flr    = floor.value.doubleValue;
        deal.flrcur = self.auctionSettings.auctionCurrency;
        return deal;
    }].mutableCopy;
    return [NSMutableArray arrayWithObject:itemMessage];
}

#pragma mark - ADCOM Placements

- (GPBAny *)adcomPlacementMessage {
    ADCOMPlacement * placement = (ADCOMPlacement *)self.placementBuilder.placement;
    placement.secure = !STKDevice.isHTTPSupport;
    GPBAny *placementMessageAny = [GPBAny anyWithMessage:placement error:nil];
    return placementMessageAny;
}

#pragma mark - ADCOM Context

- (GPBAny *)adcomContextMessage {
    ADCOMContext *contextMessage   = [ADCOMContext message];
    
    contextMessage.restrictions = ({
        ADCOMContext_Restrictions *restrictions = [ADCOMContext_Restrictions message];
        restrictions.bcatArray = self.request.targeting.blockedCategories.mutableCopy;
        restrictions.badvArray = self.request.targeting.blockedAdvertisers.mutableCopy;
        restrictions.bappArray = self.request.targeting.blockedApps.mutableCopy;
        restrictions;
    });
    
    contextMessage.app             = self.adcomContextAppMessage;
    contextMessage.device          = self.adcomContextDeviceMessage;
    contextMessage.user            = self.adcomContextUserMessage;
    contextMessage.regs            = self.adcomContextRegsMessage;
    
    GPBAny * contextMessageAny = [GPBAny anyWithMessage:contextMessage error:nil];
    return contextMessageAny;
}

- (ADCOMContext_App *)adcomContextAppMessage {
    ADCOMContext_App *app = [ADCOMContext_App message];
    app.storeid     = self.request.targeting.storeId;
    app.storeurl    = self.request.targeting.storeURL.absoluteString;
    app.paid        = self.request.targeting.paid;
    app.pub         = self.adcomContextAppPublisherMessage;
    app.bundle      = STKBundle.ID;
    app.ver         = STKBundle.bundleVersion;
    app.name        = [NSBundle.mainBundle objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey];
    return app;
}

- (ADCOMContext_Device *)adcomContextDeviceMessage {
    ADCOMContext_Device *device = [ADCOMContext_Device message];
    device.type     = BDMTransformers.deviceType(STKDevice.type);
    device.ua       = STKDevice.userAgent;
    device.lmt      = !STKAd.advertisingTrackingEnabled;
    device.contype  = BDMTransformers.connectionType(STKConnection.statusName);
    device.mccmnc   = STKConnection.mccmnc;
    device.carrier  = STKConnection.carrierName;
    device.w        = STKScreen.width * STKScreen.ratio;
    device.h        = STKScreen.height * STKScreen.ratio;
    device.ppi      = STKScreen.ppi;
    device.pxratio  = STKScreen.ratio;
    device.os       = BDMTransformers.osType(STKDevice.os);
    device.osv      = STKDevice.osV;
    device.hwv      = STKDevice.hardwareV;
    device.make     = STKDevice.maker;
    device.model    = STKDevice.name;
    device.lang     = STKDevice.language;
    device.geo      = BDMTransformers.geoMessage(self.request.targeting.deviceLocation);
    
    if (self.restrictions.subjectToGDPR && !self.restrictions.hasConsent) {
        device.ifa = @"00000000-0000-0000-0000-000000000000";
    } else {
        device.ifa = STKAd.advertisingIdentifier;
    }
    
    return device;
}

- (ADCOMContext_User *)adcomContextUserMessage {
    ADCOMContext_User *user = [ADCOMContext_User message];
    user.gender     = BDMTransformers.gender(self.request.targeting.gender);
    user.yob        = self.request.targeting.yearOfBirth.unsignedIntValue;
    user.keywords   = self.request.targeting.keywords;
    user.id_p       = self.request.targeting.userId;
    
    if (self.restrictions.consentString) {
        user.consent    = self.restrictions.consentString;
    } else {
        user.consent    = self.restrictions.hasConsent ? @"1" : @"0";
    }
    
    user.geo = ({
        ADCOMContext_Geo *geo = [ADCOMContext_Geo message];
        geo.country = self.request.targeting.country;
        geo.city    = self.request.targeting.city;
        geo.zip     = self.request.targeting.zip;
        geo;
    });
    return user;
}

- (ADCOMContext_Regs *)adcomContextRegsMessage {
    ADCOMContext_Regs *regs = [ADCOMContext_Regs message];
    BDMRegsCcpaExtension *ccpa = [BDMRegsCcpaExtension message];
    ccpa.usPrivacy = self.restrictions.USPrivacyString;
    
    regs.coppa = self.restrictions.coppa;
    regs.gdpr = self.restrictions.subjectToGDPR;
    regs.extArray = @[ccpa].mutableCopy;
    
    return regs;
}

- (ADCOMContext_App_Publisher *)adcomContextAppPublisherMessage {
    ADCOMContext_App_Publisher *publisher = [ADCOMContext_App_Publisher message];
    publisher.id_p = self.publisherInfo.publisherId;
    publisher.name = self.publisherInfo.publisherName;
    publisher.domain = self.publisherInfo.publisherDomain;
    publisher.catArray = self.publisherInfo.publisherCategories.mutableCopy;
    return publisher;
}

@end
