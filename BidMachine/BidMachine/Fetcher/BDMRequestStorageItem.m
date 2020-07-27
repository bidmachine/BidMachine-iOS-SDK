//
//  BDMRequestStorageItem.m
//  BidMachine
//
//  Created by Ilia Lozhkin on 27.07.2020.
//  Copyright © 2020 Appodeal. All rights reserved.
//

#import "BDMRequestStorageItem.h"
#import "BDMAdRequests.h"
#import "BDMRequest+Private.h"

#import <StackFoundation/StackFoundation.h>

@interface BDMRequestStorageItem () <BDMRequestDelegate>

@end

@implementation BDMRequestStorageItem

- (instancetype)initWithRequest:(BDMRequest *)request price:(nonnull NSString *)price type:(BDMInternalPlacementType)type {
    if (self = [super init]) {
        _request = request;
        _creationDate = NSDate.date;
        _type = type;
        _price = price;
        
        [self.request registerDelegate:self];
    }
    return self;
}

#pragma mark - BDMRequestDelegate

- (void)request:(BDMRequest *)request completeWithInfo:(BDMAuctionInfo *)info {
    
}
- (void)request:(BDMRequest *)request failedWithError:(NSError *)error {
    
}
- (void)requestDidExpire:(BDMRequest *)request {
    [self.delegate storageItemDidExpired:self];
}

@end
