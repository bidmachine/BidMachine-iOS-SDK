//
//  BDMTransformers.m
//
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMTransformers.h"

#import <UIKit/UIKit.h>


@implementation BDMTransformers

+ (ADCOMDeviceType (^)(STKDeviceType))deviceType {
    return ^ADCOMDeviceType (STKDeviceType type){
        return UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad ? ADCOMDeviceType_DeviceTypeTablet : ADCOMDeviceType_DeviceTypePhoneDevice;
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

+ (GPBStruct *)structFromValue:(NSDictionary *)value {
    GPBStruct *model = [GPBStruct message];
    ANY(value).reduce(model.fields, ^(NSMutableDictionary *map, NSString *key) {
        map[key] = [self valueFrom:value[key]];
    });
    return model;
}

+ (GPBListValue *)listFromValue:(NSArray *)value {
    GPBListValue *listValue = [GPBListValue message];
    listValue.valuesArray = ANY(value).flatMap(^id(id any) { return [self valueFrom:any]; }).array.mutableCopy;
    return listValue;
}

+ (GPBValue *)valueFrom:(id)value {
    GPBValue *modelValue = [GPBValue message];
    if (NSString.stk_isValid(value)) {
        modelValue.stringValue = value;
    } else if (NSNumber.stk_isValid(value)) {
        modelValue.numberValue = [(NSNumber *)value doubleValue];
    } else if (NSDictionary.stk_isValid(value) && ([[value allKeys] count] > 0)) {
        modelValue.structValue = [self structFromValue:value];
    } else if (NSArray.stk_isValid(value) && ([value count] > 0)) {
        modelValue.listValue = [self listFromValue:value];
    }
    return modelValue;
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

+ (NSNumber *(^)(float))batteryLevel {
    return ^NSNumber *(float value) {
        if (value < 0) {
            return @(value);
        }
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        formatter.maximumFractionDigits = 2;
        formatter.roundingMode = NSNumberFormatterRoundHalfUp;
        NSString *roundedString = [formatter stringFromNumber:@(value)];
        return [formatter numberFromString:roundedString];
    };
}

+ (NSNumber *(^)(NSNumber *))bytesToMb {
    return ^NSNumber *(NSNumber *value) {
        return @(value.integerValue / (1024 * 1024));
    };
}

+ (NSString *)deviceAccessability {
    return [@[@(UIAccessibilityIsBoldTextEnabled()),
              @(UIAccessibilityIsShakeToUndoEnabled()),
              @(UIAccessibilityIsReduceMotionEnabled()),
              @(UIAccessibilityDarkerSystemColorsEnabled()),
              @(UIAccessibilityIsReduceTransparencyEnabled())] componentsJoinedByString:@""];
    
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

+ (NSArray <BDMAdUnit *> *(^)(BDMAdNetworkConfiguration *, BDMPlacement *))adUnits {
    return ^NSArray *(BDMAdNetworkConfiguration *config, BDMPlacement * placement) {
        return ANY(config.adUnits).filter(^BOOL(BDMAdUnit *unit){
            return [placement isSupportedFormat:unit.format];
            }).array ?: @[];
    };
}


@end
