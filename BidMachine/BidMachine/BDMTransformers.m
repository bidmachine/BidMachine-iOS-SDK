//
//  BDMTransformers.m
//
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMTransformers.h"

@implementation BDMTransformers

BOOL isBDMAdUnitFormatSatisfyToPlacement(BDMInternalPlacementType placement, BDMAdUnitFormat fmt) {
    switch (fmt) {
        case BDMAdUnitFormatUnknown: return NO; break;
        case BDMAdUnitFormatRewardedVideo: return placement == BDMInternalPlacementTypeRewardedVideo; break;
        case BDMAdUnitFormatRewardedPlayable: return placement == BDMInternalPlacementTypeRewardedVideo; break;
        case BDMAdUnitFormatRewardedUnknown: return placement == BDMInternalPlacementTypeRewardedVideo; break;
            
        case BDMAdUnitFormatInterstitialVideo: return placement == BDMInternalPlacementTypeInterstitial; break;
        case BDMAdUnitFormatInterstitialStatic: return placement == BDMInternalPlacementTypeInterstitial; break;
        case BDMAdUnitFormatInterstitialUnknown: return placement == BDMInternalPlacementTypeInterstitial; break;
            
        case BDMAdUnitFormatInLineBanner: return placement == BDMInternalPlacementTypeBanner; break;
        case BDMAdUnitFormatBanner320x50: return placement == BDMInternalPlacementTypeBanner; break;
        case BDMAdUnitFormatBanner728x90: return placement == BDMInternalPlacementTypeBanner; break;
        case BDMAdUnitFormatBanner300x250: return placement == BDMInternalPlacementTypeBanner; break;
    }
}

+ (ADCOMDeviceType (^)(STKDeviceType))deviceType {
    return ^ADCOMDeviceType (STKDeviceType type){
        return STKDevice.isIphone ? ADCOMDeviceType_DeviceTypePhoneDevice : ADCOMDeviceType_DeviceTypeTablet;
    };
}

+ (ADCOMConnectionType (^)(NSString *))connectionType {
    return ^ADCOMConnectionType (NSString *connectionType){
        return ANY((@{@"other"  : @(ADCOMConnectionType_ConnectionTypeInvalid),
                      @"wifi"   : @(ADCOMConnectionType_ConnectionTypeWifi),
                      @"mobile" : @(ADCOMConnectionType_ConnectionTypeCellularNetworkUnknown)
        }))
        .from(connectionType)
        .number
        .unsignedIntValue;
    };
}

+ (ADCOMOS (^)(NSString *))osType {
    return ^ADCOMOS (NSString *type){
        return ADCOMOS_OsIos;
    };
}

+ (NSString *(^)(BDMUserGender *))gender {
    return ^NSString *(BDMUserGender * gender){
        return ANY((@{kBDMUserGenderMale     : @"M",
                      kBDMUserGenderFemale   : @"F",
                      kBDMUserGenderUnknown  : @"O"
        }))
        .from(gender)
        .string;
    };
}

+ (ADCOMContext_Geo *(^)(CLLocation *))geoMessage {
    return ^ADCOMContext_Geo *(CLLocation * userProvidedLocation) {
        ADCOMContext_Geo *geo = [ADCOMContext_Geo message];
        
        geo.utcoffset = (int)STKLocation.utc;
        ADCOMLocationType type = ADCOMLocationType_LocationTypeInvalid;
        
        CLLocation * deviceLocation = STKLocation.location;
        CLLocation * desiredLocation;
        
        if (userProvidedLocation && deviceLocation) {
            NSComparisonResult comrasionResult = [userProvidedLocation.timestamp compare:deviceLocation.timestamp];
            if (comrasionResult == NSOrderedAscending) {
                type = ADCOMLocationType_LocationTypeUser;
                desiredLocation = userProvidedLocation;
            } else {
                type = ADCOMLocationType_LocationTypeGps;
                desiredLocation = deviceLocation;
            }
        } else if (deviceLocation) {
            type = ADCOMLocationType_LocationTypeGps;
            desiredLocation = deviceLocation;
        } else {
            type = ADCOMLocationType_LocationTypeUser;
            desiredLocation = userProvidedLocation;
        }
        
        if (desiredLocation) {
            geo.type = type;
            geo.lastfix = desiredLocation.timestamp.timeIntervalSince1970;
            geo.accur = desiredLocation.horizontalAccuracy;
            geo.lat = desiredLocation.coordinate.latitude;
            geo.lon = desiredLocation.coordinate.longitude;
        }
        return geo;
    };
}

+ (NSArray <BDMEventURL *> *(^)(NSArray <ADCOMAd_Event *> *))eventURLs {
    return ^id(NSArray <ADCOMAd_Event *> *events) {
        if (!events.count) {
            return @[];
        }
        
        NSArray <BDMEventURL *> *trackers = [events stk_transform:^id(ADCOMAd_Event * event, NSUInteger idx) {
            if (!event.URL.length) {
                return nil;
            }
            
            int32_t rawType = ADCOMAd_Event_Type_RawValue(event);
            if (!BDMEventTypeExtended_IsValidValue(rawType)) {
                return nil;
            }
            
            BDMEventURL * tracker = [BDMEventURL trackerWithStringURL:event.URL type:rawType];
            return tracker;
        }];
        return trackers;
    };
}

+ (NSDictionary<NSString *,NSString *> *(^)(NSMutableDictionary<NSString *,NSString *> *))jsonObject {
    return ^id(NSMutableDictionary<NSString *,NSString *> *protobufMap) {
        return protobufMap ?: @{};
    };
}

+ (NSMutableDictionary<NSString *,NSString *> *(^)(NSDictionary<NSString *,id> *))protobufMap {
    return ^id(NSDictionary<NSString *,id> *jsonObject) {
        NSMutableDictionary <NSString *, NSString *> *protobufMap = [NSMutableDictionary dictionaryWithCapacity:jsonObject.count];
        [jsonObject enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
            if ([obj isKindOfClass:NSString.class]) {
                protobufMap[key] = (NSString *)obj;
            } else if ([obj isKindOfClass:NSNumber.class]) {
                protobufMap[key] = [(NSNumber *)obj stringValue];
            }
        }];
        return protobufMap;
    };
}

+ (NSArray <BDMAdUnit *> *(^)(BDMAdNetworkConfiguration *, BDMInternalPlacementType))adUnits {
    return ^NSArray *(BDMAdNetworkConfiguration *config, BDMInternalPlacementType placement) {
        return ANY(config.adUnits).filter(^BOOL(BDMAdUnit *unit){
                return isBDMAdUnitFormatSatisfyToPlacement(placement, unit.format);
            }).array ?: @[];
    };
}


@end
