//
//  BDMPayloadResponse.m
//  BidMachine
//
//  Created by Ilia Lozhkin on 28.03.2021.
//  Copyright © 2021 Appodeal. All rights reserved.
//

#import "BDMPayloadResponse.h"
#import "BDMFactory+BDMServerCommunicator.h"

#import <StackFoundation/StackFoundation.h>


@implementation BDMPayloadResponse

+ (instancetype)parseFromPayload:(NSString *)payload {
    NSData *payloadData = nil;
    if (!payload || !(payloadData = [[NSData alloc] initWithBase64EncodedString:payload options:0])) {
        return nil;
    }
    
    BDMResponsePayload *payloadResponse = [BDMResponsePayload parseFromData:payloadData error:nil];
    id<BDMResponse> response = [[BDMFactory sharedFactory] wrappedResponseData:payloadResponse.responseCache.data];
    NSURL *responseURL = [NSURL stk_url:payloadResponse.responseCacheURL];
    
    if (!response.creative && !responseURL) {
        return nil;
    }
    
    return [[self alloc] initPrivatlyWithResponse:response url:responseURL];
}

- (instancetype)initPrivatlyWithResponse:(id<BDMResponse>)response url:(NSURL *)url {
    if (self = [super init]) {
        _response = response;
        _url = url;
    }
    return self;
}

@end
