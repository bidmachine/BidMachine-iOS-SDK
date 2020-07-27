//
//  BDMRequestStorageItem.h
//  BidMachine
//
//  Created by Ilia Lozhkin on 27.07.2020.
//  Copyright © 2020 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDMRequest.h"
#import "BDMDefines.h"

NS_ASSUME_NONNULL_BEGIN

@class BDMRequestStorageItem;

@protocol BDMRequestStorageItemDelegate <NSObject>

- (void)storageItemDidExpired:(BDMRequestStorageItem *)item;

@end

@interface BDMRequestStorageItem : NSObject

@property (nonatomic, strong, readonly) NSString *price;
@property (nonatomic, strong, readonly) BDMRequest *request;
@property (nonatomic, strong, readonly) NSDate *creationDate;
@property (nonatomic, assign, readonly) BDMInternalPlacementType type;
@property (nonatomic, weak) id<BDMRequestStorageItemDelegate> delegate;

- (instancetype)initWithRequest:(BDMRequest *)request price:(NSString *)price type:(BDMInternalPlacementType)type;

@end

NS_ASSUME_NONNULL_END
