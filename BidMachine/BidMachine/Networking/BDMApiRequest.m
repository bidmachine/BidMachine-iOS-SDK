//
//  BDMApiRequest.m
//
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMApiRequest.h"
#import "BDMUserAgentProvider.h"
#import "BDMSdk+Project.h"
#import <StackFoundation/StackFoundation.h>
#include <ifaddrs.h>
#include <arpa/inet.h>


#define BDM_API_REQUEST_CONTENT_TYPE_OPEN_RTB   STKDevice.isDebug ? @"application/x-protobuf; messageType=bidmachine.protobuf.openrtb.Openrtb" : @"application/x-protobuf"
#define BDM_API_REQUEST_CONTENT_TYPE_INIT       STKDevice.isDebug ? @"application/x-protobuf; messageType=bidmachine.protobuf.InitRequest" : @"application/x-protobuf"

#define BDM_API_REQUEST_USER_AGENT              BDMUserAgentProvider.userAgent


static NSTimeInterval const kBDMRequestTimeoutInterval = 10.0;


@interface BDMApiRequest ()

@property (nonatomic, copy) id HTTPBodyModel;

@end

@implementation BDMApiRequest

+ (BDMApiRequest *)request:(NSNumber *)timeout builder:(void (^)(BDMAuctionBuilder *))build {
    BDMAuctionBuilder * builder = [BDMAuctionBuilder new];
    build(builder);
    NSURL *URL = BDMSdk.sharedSdk.auctionSettings.auctionURL ? [NSURL URLWithString:BDMSdk.sharedSdk.auctionSettings.auctionURL] : [BDMSdk.sharedSdk.baseURL URLByAppendingPathComponent:@"auction"];
    BDMApiRequest * request = [BDMApiRequest requestWithURL:URL
                                                cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                            timeoutInterval:kBDMRequestTimeoutInterval];
    
    request.timeoutInterval = timeout ? timeout.doubleValue : kBDMRequestTimeoutInterval;
    request.HTTPBodyModel = builder.message;
    [request setHTTPMethod:@"POST"];
    
    [request setValue:BDM_API_REQUEST_CONTENT_TYPE_OPEN_RTB forHTTPHeaderField:@"Content-Type"];
    [request setValue:BDM_API_REQUEST_USER_AGENT forHTTPHeaderField:@"User-Agent"];
    
    return request;
}

+ (BDMApiRequest *)sessionRequest:(NSNumber *)timeout builder:(void (^)(BDMSessionBuilder *))build {
    BDMSessionBuilder *builder = [BDMSessionBuilder new];
    build(builder);
    
    NSURL * URL = builder.baseURL;
    BDMApiRequest * request = [BDMApiRequest requestWithURL:URL
                                                cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                            timeoutInterval:kBDMRequestTimeoutInterval];
    
    request.timeoutInterval = timeout ? timeout.doubleValue : kBDMRequestTimeoutInterval;
    request.HTTPBodyModel = builder.message;
    [request setHTTPMethod:@"POST"];
    
    [request setValue:BDM_API_REQUEST_CONTENT_TYPE_INIT forHTTPHeaderField:@"Content-Type"];
    [request setValue:BDM_API_REQUEST_USER_AGENT forHTTPHeaderField:@"User-Agent"];
    
    return request;
}

#pragma mark - Overriding

- (NSData *)HTTPBody {
    return [self.HTTPBodyModel performSelector:@selector(data)];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Destination URL: %@\nMethod: %@\nHTTP Headers: %@\nBody: %@", self.URL, self.HTTPMethod, self.allHTTPHeaderFields, self.HTTPBodyModel];
}

@end
