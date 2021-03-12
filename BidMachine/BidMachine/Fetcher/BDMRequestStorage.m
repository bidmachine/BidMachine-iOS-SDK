//
//  BDMRequestStorage.m
//  BidMachine
//
//  Created by Ilia Lozhkin on 27.07.2020.
//  Copyright © 2020 Appodeal. All rights reserved.
//

#import "BDMRequestStorage.h"
#import "BDMRequest+Private.h"
#import "BDMRequestStorageItem.h"

#import <StackFoundation/StackFoundation.h>


@interface BDMRequestStorage () <BDMRequestStorageItemDelegate>

@property (nonatomic, strong) NSMutableArray <BDMRequestStorageItem *> *storedObjects;

@end

@implementation BDMRequestStorage

+ (instancetype)shared {
    static BDMRequestStorage *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [BDMRequestStorage privateInit];
    });
    return _instance;
}

+ (instancetype)privateInit {
    BDMRequestStorage *storage = BDMRequestStorage.new;
    storage.storedObjects = NSMutableArray.new;
    return storage;
}

- (void)saveRequest:(BDMRequest *)request {
    [self saveRequest:request withPrice:ANY(request.info.customParams).from(@"bm_pf").string];
}

- (void)saveRequest:(BDMRequest *)request withPrice:(NSString *)price {
    if (!request.info.bidID || !price) {
        return;
    }
    
    BDMRequestStorageItem *item = [[BDMRequestStorageItem alloc] initWithRequest:request price:price type:request.placement.type];
    item.delegate = self;
    [self.storedObjects addObject:item];
}

- (BDMRequest *)requestForPrice:(NSString *)price type:(BDMInternalPlacementType)type {
    __block BDMRequestStorageItem *item = nil;
    [self.storedObjects enumerateObjectsUsingBlock:^(BDMRequestStorageItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (type == obj.type && [price isEqualToString:obj.price] && (!item || (item.creationDate < obj.creationDate))) {
            item = obj;
        }
    }];
    BDMRequest *request = item.request;
    [self.storedObjects removeObject:item];
    return request;
}

- (BOOL)isPrebidRequestsForType:(BDMInternalPlacementType)type {
    __block BOOL isPrebid = NO;
    [self.storedObjects enumerateObjectsUsingBlock:^(BDMRequestStorageItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        isPrebid = obj.type == type;
        *stop = isPrebid;
    }];
    return isPrebid;
}

#pragma mark - BDMRequestStorageItemDelegate

- (void)storageItemDidExpired:(BDMRequestStorageItem *)item {
    [self.storedObjects removeObject:item];
}

@end
