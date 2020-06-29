//
//  BDMServerCommunicator.m
//  BidMachine
//
//  Created by Stas Kochkin on 07/11/2017.
//  Copyright © 2017 Appodeal. All rights reserved.
//

#import "BDMServerCommunicator.h"
#import "BDMDefines.h"
#import "BDMFactory+BDMServerCommunicator.h"
#import "BDMUserAgentProvider.h"
#import "BDMApiRequest.h"
#import "NSError+BDMSdk.h"
#import "BDMInitialisationResponseModel.h"
#import <StackFoundation/StackFoundation.h>


@interface BDMServerCommunicator ()

@property (nonatomic, strong) NSURLSession * session;

@end

@implementation BDMServerCommunicator

- (NSURLSession *)session {
    if (!_session) {
        NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:configuration];
    }
    return _session;
}

- (void)makeAuctionRequest:(NSNumber *)timeout
            auctionBuilder:(void (^)(BDMAuctionBuilder *))auctionBuilder
                   success:(void (^)(id<BDMResponse>))success
                   failure:(void (^)(NSError *))failure
{
    BDMApiRequest *urlRequest = [BDMApiRequest request:timeout builder:auctionBuilder];
    BDMLog(@"Performing auction with auction request: %@", urlRequest);
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:urlRequest
                                                 completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         id<BDMResponse> wrappedResponse = [[BDMFactory sharedFactory] wrappedResponseData:data];
                                                         NSError * wrappedError = [weakSelf wrappedError:error response:response wrappedResponse:wrappedResponse];
                                                         if (wrappedError) {
                                                             BDMLog(@"Auction request failed with error: %@", wrappedError);
                                                             STK_RUN_BLOCK(failure, wrappedError);
                                                         } else {
                                                             BDMLog(@"Auction request was successful with response: %@", wrappedResponse);
                                                             STK_RUN_BLOCK(success, wrappedResponse);
                                                         }
                                                     });
                                                 }];
    [task resume];
}

- (void)makeInitRequest:(NSNumber *)timeout
         sessionBuilder:(void (^)(BDMSessionBuilder *))sessionBuilder
                success:(void (^)(id<BDMInitialisationResponse>))success
                failure:(void (^)(NSError *))failure
{
    BDMApiRequest *urlRequest = [BDMApiRequest sessionRequest:timeout builder:sessionBuilder];
    BDMLog(@"Performing init request: %@", urlRequest);
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:urlRequest
                                                 completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         id<BDMInitialisationResponse> wrappedResponse = [BDMInitialisationResponseModel modelWithData:data];
                                                         NSError * wrappedError = [weakSelf wrappedError:error response:response wrappedResponse:wrappedResponse];
                                                         if (wrappedError) {
                                                             BDMLog(@"Init request failed with error: %@", wrappedError);
                                                             STK_RUN_BLOCK(failure, wrappedError);
                                                         } else {
                                                             BDMLog(@"Init request was successful  with response: %@", wrappedResponse);
                                                             STK_RUN_BLOCK(success, wrappedResponse);
                                                         }
                                                     });
                                                 }];
    [task resume];
}

- (void)trackEvent:(BDMEventURL *)tracker fallback:(BDMEventURL *)fallback {
    __weak typeof(self) weakSelf = self;
    [self trackEvent:tracker success:nil failure:^(NSError *error) {
        [weakSelf trackEvent:fallback];
    }];
}

- (void)trackEvent:(BDMEventURL *)tracker {
    [self trackEvent:tracker success:nil failure:nil];
}

- (void)trackEvent:(BDMEventURL *)tracker
           success:(void (^)(void))success
           failure:(void (^)(NSError *))failure {
    if (!tracker) {
        return;
    }
    
    BDMLog(@"Trying to send event tracker: %@", tracker);
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:tracker];
    request.timeoutInterval = 10.0f;
    
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask * task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError * wrappedError = [weakSelf wrappedError:error response:response];
            if (wrappedError) {
                BDMLog(@"Failed to sent event tracker: %@. Error: %@", tracker, wrappedError);
                STK_RUN_BLOCK(failure, wrappedError);
            } else {
                BDMLog(@"Successfully sent event tracker: %@", tracker);
                STK_RUN_BLOCK(success);
            }
        });
    }];
    [task resume];
}

- (NSError *)wrappedError:(NSError *)error response:(NSURLResponse *)response {
    return [self wrappedError:error response:response wrappedResponse:NSNull.null];
}

- (NSError *)wrappedError:(NSError *)error response:(NSURLResponse *)response wrappedResponse:(id)wrappedResponse {
    NSError * wrappedError;
    if (error) {
        wrappedError = [error bdm_wrappedWithCode:error.bdm_transformedFromNSURLErrorDomain];
    } else if (response.bdm_errorCode > BDMErrorCodeUnknown) {
        wrappedError = [NSError bdm_errorWithCode:response.bdm_errorCode description:@"Invalid status code!"];
    } else if (!wrappedResponse) {
        wrappedError = [NSError bdm_errorWithCode:BDMErrorCodeNoContent description:@"Response serialisation failed"];
    }
    return wrappedError;
}

+ (instancetype)sharedCommunicator {
    static BDMServerCommunicator * _sharedCommunicator;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedCommunicator = BDMServerCommunicator.new;
    });
    return _sharedCommunicator;
}

@end
