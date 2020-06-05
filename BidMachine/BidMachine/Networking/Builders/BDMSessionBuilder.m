//
//  BDMSessionBuilder.m
//
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMSessionBuilder.h"
#import "BDMProtoAPI-Umbrella.h"
#import "BDMTransformers.h"
#import "BDMSdk+Project.h"

#import <StackFoundation/StackFoundation.h>


@interface BDMSessionBuilder ()

@property (nonatomic, copy) NSURL *baseURL;
@property (nonatomic, copy) NSString *sellerID;
@property (nonatomic, copy) BDMTargeting *targeting;

@end

@implementation BDMSessionBuilder

- (BDMSessionBuilder *(^)(NSString *))appendSellerID {
    return ^id(NSString * sellerID) {
        self.sellerID = sellerID;
        return self;
    };
}

- (BDMSessionBuilder *(^)(BDMTargeting *))appendTargeting {
    return ^id(BDMTargeting * targeting) {
        self.targeting = targeting;
        return self;
    };
}

- (BDMSessionBuilder *(^)(NSURL *))appendBaseURL {
    return ^id(NSURL *baseURL) {
        self.baseURL = [baseURL URLByAppendingPathComponent:@"init"];
        return self;
    };
}

- (GPBMessage *)message {
    BOOL isGDPRRestricted = BDMSdk.sharedSdk.restrictions.subjectToGDPR && !BDMSdk.sharedSdk.restrictions.hasConsent;
    BOOL isCoppa = BDMSdk.sharedSdk.restrictions.coppa;
    
    BDMInitRequest *requestMessage = BDMInitRequest.message;
    requestMessage.sellerId = self.sellerID;
    requestMessage.bundle = STKBundle.ID;
    requestMessage.os = BDMTransformers.osType(STKDevice.os);
    requestMessage.osv = STKDevice.osV;
    requestMessage.sdk = @"BidMachine SDK";
    requestMessage.sdkver = kBDMVersion;
    requestMessage.geo = self.geoMessage;
    requestMessage.deviceType = BDMTransformers.deviceType(STKDevice.type);
    requestMessage.ifv = STKAd.vendorIdentifier;
    
    if (!isGDPRRestricted && !isCoppa) {
        requestMessage.ifa = STKAd.advertisingIdentifier;
    }
    
    if (!isCoppa) {
        requestMessage.contype  = BDMTransformers.connectionType(STKConnection.statusName);
    }
    
    return requestMessage;
}

- (ADCOMContext_Geo *)geoMessage {
    ADCOMContext_Geo * geoMessage;
    BOOL isGDPRRestricted = BDMSdk.sharedSdk.restrictions.subjectToGDPR && !BDMSdk.sharedSdk.restrictions.hasConsent;
    BOOL isCoppa = BDMSdk.sharedSdk.restrictions.coppa;
    BOOL shouldRestictGeoData = isGDPRRestricted || isCoppa;
    
    if (shouldRestictGeoData) {
        geoMessage = ADCOMContext_Geo.message;
    } else {
        geoMessage = BDMTransformers.geoMessage(self.targeting.deviceLocation);
        geoMessage.country = self.targeting.country;
        geoMessage.city    = self.targeting.city;
        geoMessage.zip     = self.targeting.zip;
    }
    
    geoMessage.utcoffset = (int)STKLocation.utc;
    
    return geoMessage;
}

@end
