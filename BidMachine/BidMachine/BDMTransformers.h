//
//  BDMTransformers.h
//
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <StackFoundation/StackFoundation.h>

#import "BDMProtoAPI-Umbrella.h"
#import "BDMTargeting.h"
#import "BDMEventURL.h"
#import "BDMRequest+Private.h"
#import "BDMPlacement.h"
#import "BDMAdNetworkConfiguration.h"


@interface BDMTransformers : NSObject

+ (ADCOMDeviceType(^)(STKDeviceType))deviceType;

+ (ADCOMConnectionType(^)(NSString *))connectionType;

+ (ADCOMOS(^)(NSString *))osType;

+ (GPBStruct *)structFromValue:(NSDictionary *)value;

+ (GPBListValue *)listFromValue:(NSArray *)value;

+ (GPBValue *)valueFrom:(id)value;

+ (NSString *(^)(BDMUserGender *))gender;

+ (NSNumber *(^)(float))batteryLevel;

+ (NSNumber *(^)(NSNumber *))bytesToMb;

+ (NSString *)deviceAccessability;

+ (ADCOMContext_Geo *(^)(CLLocation * userProvidedLocation))geoMessage;

+ (NSArray <BDMEventURL *> *(^)(NSArray <ADCOMAd_Event *> *))eventURLs;

+ (NSArray <BDMAdUnit *> *(^)(BDMAdNetworkConfiguration *, BDMPlacement *))adUnits;

@end
