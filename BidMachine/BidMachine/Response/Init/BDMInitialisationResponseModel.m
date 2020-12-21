//
//  BDMInitialisationResponseModel.m
//  BidMachine
//
//  Created by Stas Kochkin on 05/12/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMInitialisationResponseModel.h"
#import "BDMProtoAPI-Umbrella.h"
#import "BDMTransformers.h"
#import "BDMSdk+Project.h"


@interface BDMInitialisationResponseModel ()

@property (nonatomic, copy, readwrite) NSURL *auctionURL;
@property (nonatomic, copy, readwrite) NSArray <BDMEventURL *> *eventURLs;
@property (nonatomic, copy, readwrite) NSArray <BDMAdNetworkConfiguration *> *networkConfigurations;

@property (nonatomic, assign, readwrite) NSTimeInterval sessionDelay;

@end


@implementation BDMInitialisationResponseModel

+ (instancetype)modelWithData:(NSData *)data {
    BDMInitResponse * responseMessage = [[BDMInitResponse alloc] initWithData:data error:nil];
    if (!responseMessage) {
        return nil;
    }
    
    BDMInitialisationResponseModel * model = BDMInitialisationResponseModel.new;
    model.auctionURL = responseMessage.endpoint ? [NSURL URLWithString:responseMessage.endpoint] : nil;
    model.eventURLs = BDMTransformers.eventURLs(responseMessage.eventArray);
    model.sessionDelay = responseMessage.sessionResetAfter;
    model.networkConfigurations = [responseMessage.adNetworksArray stk_transform:^BDMAdNetworkConfiguration *(BDMAdNetwork *adNetwork, NSUInteger idx) {
        BDMAdNetworkConfiguration *configuration = [BDMAdNetworkConfiguration buildWithBuilder:^(BDMAdNetworkConfigurationBuilder *builer) {
            builer.appendName(adNetwork.name);
            builer.appendNetworkClass(NSClassFromString(adNetwork.className_p));
            builer.appendInitializationParams(adNetwork.customParams);
            [adNetwork.adUnitsArray enumerateObjectsUsingBlock:^(BDMAdNetwork_AdUnit *obj, NSUInteger idx, BOOL *stop) {
                builer.appendAdUnit(BDMAdUnitFormatFromString(obj.adFormat), obj.customParams, nil);
            }];
        }];
        return configuration;
    }];
    
    return model;
}

@end
