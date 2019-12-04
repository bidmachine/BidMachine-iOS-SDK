//
//  BDMPublisherInfo.h
//  BidMachine
//
//  Created by Ilia Lozhkin on 12/4/19.
//  Copyright © 2019 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDMPublisherInfo : NSObject<NSCopying, NSSecureCoding>
/// Publisher Id
@property (copy, nonatomic, readwrite, nullable) NSString *publisherId;
/// Publisher Name
@property (copy, nonatomic, readwrite, nullable) NSString *publisherName;
/// Publisher domain
@property (copy, nonatomic, readwrite, nullable) NSString *publisherDomain;
/// List of advertiser categories using the IAB content categories.
@property (copy, nonatomic, readwrite, nullable) NSArray <NSString *> *publisherCategories;

@end
